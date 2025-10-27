#define PLUGIN_VERSION		"1.2"

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <MemoryEx>

#define GAMEDATA_CONF	"TriggerMoved_Detour"
#define DEBUG			0

Address g_Addr_Func;
Address g_Addr_Detour;
Address g_Addr_Continue;
Address g_Addr_Retn;

int g_Detour_Size;

public Plugin myinfo =
{
	name = "[L4D2] TriggerWorldSpaceBounds & TriggerMoved Detour",
	author = "Dragokas",
	description = "Fixing the null pointer dereference in CM_TriggerWorldSpaceBounds / SV_TriggerMoved",
	version = PLUGIN_VERSION,
	url = "https://github.com/dragokas"
}

/*
	Credits:
	 - The Trick - thanks a lot for help in understanding the asm
	 - Rostu - for "Memory Extended" include
*/

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion test = GetEngineVersion();
	if( test != Engine_Left4Dead2 )
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 2.");
		return APLRes_SilentFailure;
	}
	return APLRes_Success;
}

public void OnPluginStart()
{
	CheckInitPEB();
}

void LoadPatchInfo(GameDataEx hGameData)
{
	g_Detour_Size = 5; // == sizeof(detour) + leftover of original replaced instruction size
	
	g_Addr_Func = hGameData.GetAddress("CM_TriggerWorldSpaceBounds");
	if( !g_Addr_Func ) SetFailState("Failed to load \"CM_TriggerWorldSpaceBounds\" address.");
	
	int iOffsetDetour = hGameData.GetOffset("Detour_Offset");
	if( iOffsetDetour == -1 ) SetFailState("Failed to load \"MOV_Offset\" offset.");
	
	g_Addr_Detour = g_Addr_Func + view_as<Address>(iOffsetDetour);
	
	int iByteMatch = hGameData.GetOffset("Detour_Bytes");
	if( iByteMatch == -1 ) SetFailState("Failed to load \"MOV_Bytes\" byte.");

	#if DEBUG
	LogError("Addr. Func = %i (0x%X)", 		g_Addr_Func, 	g_Addr_Func);
	LogError("Offs. Detour = %i (0x%X)", 	iOffsetDetour,	iOffsetDetour);
	LogError("Addr. Detour = %i (0x%X)", 	g_Addr_Detour, 	g_Addr_Detour);
	LogError("Size. Detour = %i", 			g_Detour_Size);
	#endif

	int iByteOrigin = LoadFromAddressInt24(g_Addr_Detour); // 3 bytes
	if( iByteOrigin != iByteMatch ) SetFailState("Failed to load, Detour byte mis-match @%i (0x%02X, should be: 0x%02X (%i))", iOffsetDetour, iByteOrigin, iByteMatch, iByteMatch);
	
	g_Addr_Continue = g_Addr_Detour + view_as<Address>(g_Detour_Size); // where to jump on success check == sizeof(detour)
	
	int iOffsetRetn = hGameData.GetOffset("Retn_Offset");
	if( iOffsetRetn == -1 ) SetFailState("Failed to load \"Retn_Offset\" byte.");
	
	g_Addr_Retn = g_Addr_Func + view_as<Address>(iOffsetRetn);
	
	iByteMatch = hGameData.GetOffset("Retn_Bytes");
	if( iByteMatch == -1 ) SetFailState("Failed to load \"Retn_Bytes\" byte.");
	
	#if DEBUG
	LogError("Offs. Retn = %i (0x%X)", 		iOffsetRetn, iOffsetRetn);
	LogError("Addr. Retn = %i (0x%X)", 		g_Addr_Retn, g_Addr_Retn);
	LogError("Addr. Continue = %i (0x%X)", 	g_Addr_Continue, g_Addr_Continue);
	#endif
	
	iByteOrigin = LoadFromAddress(g_Addr_Retn, NumberType_Int8); // 1 byte
	if( iByteOrigin != iByteMatch ) SetFailState("Failed to load, Retn byte mis-match @%i (0x%02X, should be: 0x%02X (%i))", iOffsetRetn, iByteOrigin, iByteMatch, iByteMatch);
}

public void MemoryEx_InitPEB()
{
	GameDataEx hGameData = new GameDataEx(GAMEDATA_CONF);
	if( hGameData == null ) {
		SetFailState("Failed to load \"%s.txt\" gamedata.", GAMEDATA_CONF);
	}
	else {
		LoadPatchInfo(hGameData);
		delete hGameData;
	}

	/*
		insert:
		
		(WIN)
		
		85 C0 			test eax, eax
		0F 84 ? ? ? ? 	jz => retn
		89 46 08		mov [esi+8], eax			// bytes, replaced by detour
		8B 10 			mov edx, [eax]				// bytes, replaced by detour
		E9 ? ? ? ?		jmp => detour continue
		
		(NIX)
		
		85 C0 			test eax, eax
		0F 84 ? ? ? ? 	jz => retn
		89 45 CC		mov [ebp+var_34], eax			// bytes, replaced by detour
		8B 10 			mov edx, [eax]				// bytes, replaced by detour
		E9 ? ? ? ?		jmp => detour continue
	*/
	
	int iSize = 18;
	
	Address Payload = VirtualAlloc(iSize);
	
	if( Payload == Address_Null )
	{
		SetFailState("Cannot allocate virtual memory.");
	}
	
	#if DEBUG
	LogError("Addr. Payload = %i (0x%X)", 	Payload, Payload);
	#endif

	int[] asm = new int[iSize];
	int n = 0;
	
	asm[n++] = 0x85;
	asm[n++] = 0xC0;
	
	asm[n++] = 0x0F;
	asm[n++] = 0x84;
	
	int pNext = view_as<int>(Payload) + n + 4; // sizeof( Address )
	int offset = view_as<int>(g_Addr_Retn) - pNext;
	
	// asm +4
	ArrayPushDword(asm, n, offset);
	
	#if DEBUG
	LogError("E9 Offset of Retn: %i (%X)", offset, offset);
	#endif
	
	if( GetServerOS() == OS_Windows )
	{
		asm[n++] = 0x89;
		asm[n++] = 0x46;
		asm[n++] = 0x08;
	}
	else {
		asm[n++] = 0x89;
		asm[n++] = 0x45;
		asm[n++] = 0xCC;
	}
	
	asm[n++] = 0x8B;
	asm[n++] = 0x10;
	
	asm[n++] = 0xE9;
	
	pNext = view_as<int>(Payload) + n + 4; // sizeof( Address )
	offset = view_as<int>(g_Addr_Continue) - pNext;
	
	// asm +4
	ArrayPushDword(asm, n, offset);
	
	#if DEBUG
	LogError("E9 Offset of Continue: %i (0x%X)", offset, offset);
	#endif
	
	StoreToAddressArray(Payload, asm, iSize);
	
	// Setup the detour
	
	// E9 ? ? ? ?		jmp => detour payload
	
	pNext = view_as<int>(g_Addr_Detour) + 5; // sizeof( instruction )
	offset = view_as<int>(Payload) - pNext;
	
	n = 0;
	asm[n++] = 0xE9;
	ArrayPushDword(asm, n, offset);
	
	for(int i = n; i < g_Detour_Size; i++ )
	{
		asm[n++] = 0x90; // nop
	}
	
	#if DEBUG
	LogError("E9 Offset of Payload: %i (0x%X)", offset, offset);
	#endif
	
	StoreToAddressArray(g_Addr_Detour, asm, n); // sizeof( detour )
}
