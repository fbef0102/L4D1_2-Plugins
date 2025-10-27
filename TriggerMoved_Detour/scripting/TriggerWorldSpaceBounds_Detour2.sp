#define PLUGIN_VERSION		"1.0"

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <MemoryEx>

#define GAMEDATA_CONF	"TriggerWorldSpaceBounds2"
#define DEBUG			0

Address g_Addr_Func;
Address g_Addr_Detour;
Address g_Addr_Continue;
Address g_Addr_Retn;

bool g_bOnce = true;

public Plugin myinfo =
{
	name = "[L4D2][WIN] TriggerWorldSpaceBounds_Detour",
	author = "Dragokas",
	description = "Fixing the null pointer dereference in CM_TriggerWorldSpaceBounds()",
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
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), "gamedata/%s.txt", GAMEDATA_CONF);

	GameData hGameData = new GameData(GAMEDATA_CONF);
	if( hGameData == null ) {
		SetFailState("Failed to load \"%s.txt\" gamedata.", GAMEDATA_CONF);
	}
	else {
		LoadPatchInfo(hGameData);
		delete hGameData;
	}
	CheckInitPEB(); 
}

void LoadPatchInfo(GameData hGameData)
{
	// #region "Validate Detour Address"
	
	g_Addr_Func = hGameData.GetAddress("CM_TriggerWorldSpaceBounds");
	if( !g_Addr_Func ) SetFailState("Failed to load \"CM_TriggerWorldSpaceBounds\" address.");
	
	int iOffsetDetour = hGameData.GetOffset("Detour_Offset");
	if( iOffsetDetour == -1 ) SetFailState("Failed to load \"MOV_Offset\" offset.");
	
	g_Addr_Detour = g_Addr_Func + view_as<Address>(iOffsetDetour);
	
	int iByteMatch = hGameData.GetOffset("Detour_Bytes");
	if( iByteMatch == -1 ) SetFailState("Failed to load \"MOV_Bytes\" byte.");

	int iByteOrigin = LoadFromAddressInt24(g_Addr_Detour); // 3 bytes
	if( iByteOrigin != iByteMatch ) SetFailState("Failed to load, byte mis-match @ %d (0x%02X != 0x%02X)", iOffsetDetour, iByteOrigin, iByteMatch);
	// #endregion
	
	g_Addr_Continue = g_Addr_Detour + view_as<Address>(3 + 2); // where to jump on success check == sizeof(detour)
	
	// #region "Validate Trigger func Retn Address"
	
	int iOffsetRetn = hGameData.GetOffset("Retn_Offset");
	if( iOffsetRetn == -1 ) SetFailState("Failed to load \"Retn_Offset\" byte.");
	
	g_Addr_Retn = g_Addr_Func + view_as<Address>(iOffsetRetn);
	
	iByteMatch = hGameData.GetOffset("Retn_Bytes");
	if( iByteMatch == -1 ) SetFailState("Failed to load \"Retn_Bytes\" byte.");
	
	iByteOrigin = LoadFromAddress(g_Addr_Retn, NumberType_Int8); // 1 byte
	if( iByteOrigin != iByteMatch ) SetFailState("Failed to load, byte mis-match @ %d (0x%02X != 0x%02X)", iOffsetDetour, iByteOrigin, iByteMatch);
	// #endregion
}

public void MemoryEx_InitPEB()
{
	#if DEBUG
	LogError("MemoryEx_InitPEB");
	#endif

	if( !g_bOnce ) // just in case
	{
		return;
	}
	g_bOnce = false;
	
	/*
		insert:
		
		85 C0 			test eax, eax
		0F 84 ? ? ? ? 	jz => retn
		89 46 08		mov [esi+8], eax 	// bytes, replaced by detour
		8B 10 			mov edx, [eax]		// bytes, replaced by detour
		E9 ? ? ? ?		jmp => detour continue
	*/
	
	int iSize = 18;
	
	Address Payload = VirtualAlloc(iSize);
	
	if( Payload == Address_Null )
	{
		SetFailState("Cannot allocate virtual memory.");
	}
	
	#if DEBUG
	LogError("Addr. Func = %i", 	g_Addr_Func);
	LogError("Addr. Detour = %i", 	g_Addr_Detour);
	LogError("Addr. Retn = %i", 	g_Addr_Retn);
	LogError("Addr. Payload = %i", 	Payload);
	#endif

	int[] asm = new int[iSize];
	int n = 0;
	
	asm[n++] = 0x85;
	asm[n++] = 0xC0;
	
	asm[n++] = 0x0F;
	asm[n++] = 0x84;
	
	int pNext = view_as<int>(Payload) + n + 4; // sizeof( Address )
	int offset = view_as<int>(g_Addr_Retn) - pNext;
	
	#if DEBUG
	LogError("Offset of Retn: %i", offset);
	#endif
	
	asm[n++] = GetByte(offset, 1);
	asm[n++] = GetByte(offset, 2);
	asm[n++] = GetByte(offset, 3);
	asm[n++] = GetByte(offset, 4);
	
	asm[n++] = 0x89;
	asm[n++] = 0x46;
	asm[n++] = 0x08;
	asm[n++] = 0x8B;
	asm[n++] = 0x10;
	
	asm[n++] = 0xE9;
	
	pNext = view_as<int>(Payload) + n + 4; // sizeof( Address )
	offset = view_as<int>(g_Addr_Continue) - pNext;
	
	#if DEBUG
	LogError("Offset of Continue: %i", offset);
	#endif
	
	asm[n++] = GetByte(offset, 1);
	asm[n++] = GetByte(offset, 2);
	asm[n++] = GetByte(offset, 3);
	asm[n++] = GetByte(offset, 4);
	
	StoreToAddressArray(Payload, asm, iSize);
	
	//return;
	
	// Setup the detour
	
	// E9 ? ? ? ?		jmp => detour payload
	
	pNext = view_as<int>(g_Addr_Detour) + 5; // sizeof( instruction )
	offset = view_as<int>(Payload) - pNext;
	
	n = 0;
	asm[n++] = 0xE9;
	asm[n++] = GetByte(offset, 1);
	asm[n++] = GetByte(offset, 2);
	asm[n++] = GetByte(offset, 3);
	asm[n++] = GetByte(offset, 4);
	
	StoreToAddressArray(g_Addr_Detour, asm, n); // sizeof( detour )
}