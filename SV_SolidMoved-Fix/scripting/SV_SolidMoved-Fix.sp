#define PLUGIN_VERSION		"1.1-2025/10/27"

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <MemoryEx>

#define GAMEDATA_CONF	"SV_SolidMoved"
#define GAMEDATA_FUNC	"SV_SolidMoved"
#define DEBUG			0

Address g_Addr_Func;
Address g_Addr_Detour;
Address g_Addr_Continue;
Address g_Addr_Retn;

int g_Detour_Size;

public Plugin myinfo =
{
	name = "[L4D2] SV_SolidMoved Detour",
	author = "Dragokas",
	description = "Fixing the null pointer dereference in SV_SolidMoved",
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
	if( GetServerOS() == OS_Windows )
	{
		g_Detour_Size = 5; // (minimum:5 bytes) == sizeof(detour) + leftover of original replaced instruction size
	}
	else {
		g_Detour_Size = 6;
	}
	
	g_Addr_Func = hGameData.GetAddress(GAMEDATA_FUNC);
	if( !g_Addr_Func ) SetFailState("Failed to load \"%s\" address.", GAMEDATA_FUNC);
	
	int iOffsetDetour = hGameData.GetOffset("Detour_Offset");
	if( iOffsetDetour == -1 ) SetFailState("Failed to load \"Detour_Offset\" offset.");
	
	g_Addr_Detour = g_Addr_Func + view_as<Address>(iOffsetDetour);
	
	int iByteMatch = hGameData.GetOffset("Detour_Bytes");
	if( iByteMatch == -1 ) SetFailState("Failed to load \"Detour_Bytes\" byte.");

	#if DEBUG
	LogError("Addr. Func = %i (0x%X)", 		g_Addr_Func, 	g_Addr_Func);
	LogError("Offs. Detour = %i (0x%X)", 	iOffsetDetour,	iOffsetDetour);
	LogError("Addr. Detour = %i (0x%X)", 	g_Addr_Detour, 	g_Addr_Detour);
	LogError("Size. Detour = %i", 			g_Detour_Size);
	#endif

	int iByteOrigin = LoadFromAddress(g_Addr_Detour, NumberType_Int32); // 4 bytes
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
	
	iByteOrigin = LoadFromAddress(g_Addr_Retn, NumberType_Int32); // 4 bytes
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
		
		85 C0 					test eax, eax
		0F 84 ? ? ? ? 			jz => retn
									// bytes, replaced by detour:
		8B 4D 10                mov     ecx, [ebp+arg_8]
		57                      push    edi
		51                      push    ecx
		E9 ? ? ? ?				jmp => detour continue
		
		(LIN)
		
		85 C0 					test eax, eax
		0F 84 ? ? ? ? 			jz => retn
									// bytes, replaced by detour:
		0F B6 FA                movzx   edi, dl
		89 3C 24                mov     [esp], edi
		E9 ? ? ? ?				jmp => detour continue
	*/
	
	int iSize;

	if( GetServerOS() == OS_Windows )
	{
		iSize = 18;
	}
	else {
		iSize = 19;
	}
	
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
		asm[n++] = 0x8B;
		asm[n++] = 0x4D;
		asm[n++] = 0x10;
		asm[n++] = 0x57;
		asm[n++] = 0x51;
	}
	else {
		asm[n++] = 0x0F;
		asm[n++] = 0xB6;
		asm[n++] = 0xFA;
		asm[n++] = 0x89;
		asm[n++] = 0x3C;
		asm[n++] = 0x24;
	}
	
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
		asm[n++] = 0x90; // nop the leftover of original instruction
	}
	
	#if DEBUG
	LogError("E9 Offset of Payload: %i (0x%X)", offset, offset);
	#endif
	
	StoreToAddressArray(g_Addr_Detour, asm, n); // sizeof( detour )
}
