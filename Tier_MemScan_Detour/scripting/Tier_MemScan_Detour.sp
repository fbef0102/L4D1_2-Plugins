#define PLUGIN_VERSION		"1.0-2025/10/27"

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <MemoryEx> //https://github.com/dragokas/Memory-Extended

#define GAMEDATA_CONF	"Tier_MemScan"
#define DEBUG			0

Address g_Addr_Detour;
Address g_Addr_Continue;
Address g_Addr_Retn;

bool g_bOnce = true;

public Plugin myinfo =
{
	name = "[L4D2][WIN] Tier1 specific detour",
	author = "Dragokas",
	description = "Temp. walkaround agains wrong mem. address access in Tier0, maybe some mem. scan related",
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
	const Address Detour_Size = view_as<Address>(6);
	
	g_Addr_Detour = hGameData.GetAddress("Tier_Sub1");
	
	int iByteMatch = hGameData.GetOffset("Detour_Bytes");
	if( iByteMatch == -1 ) SetFailState("Failed to load \"MOV_Bytes\" byte.");
	
	int iByteOrigin = LoadFromAddressInt24(g_Addr_Detour); // 3 bytes
	if( iByteOrigin != iByteMatch ) SetFailState("Failed to load, byte mis-match @ (0x%02X != 0x%02X)", iByteOrigin, iByteMatch);

	g_Addr_Continue = g_Addr_Detour + Detour_Size; // where to jump on success check == sizeof(detour)
	
	int iOffsetRetn = hGameData.GetOffset("Retn_Offset");
	if( iOffsetRetn == -1 ) SetFailState("Failed to load \"Retn_Offset\" byte.");
	
	g_Addr_Retn = g_Addr_Detour + view_as<Address>(iOffsetRetn);
	
	iByteMatch = hGameData.GetOffset("Retn_Bytes");
	if( iByteMatch == -1 ) SetFailState("Failed to load \"Retn_Bytes\" byte.");
	
	iByteOrigin = LoadFromAddress(g_Addr_Retn, NumberType_Int8); // 1 byte
	if( iByteOrigin != iByteMatch ) SetFailState("Failed to load, byte mis-match @ (0x%02X != 0x%02X)", iByteOrigin, iByteMatch);
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
	
	if( !g_bOnce ) // just in case
	{
		return;
	}
	g_bOnce = false;
	
	/*
		insert:
		
		81 FE 08 00 41 24 	cmp esi, 0x24410008 // magik, - constantly seen in Crash report
		0F 85 ? ? ? ? 		jnz => retn
		89 4E 1C			mov     [esi+1Ch], ecx 	// bytes, replaced by detour
		89 7E 14 			mov     [esi+14h], edi	// bytes, replaced by detour
		E9 ? ? ? ?			jmp => detour continue
	*/
	
	int iSize = 23;
	
	Address Payload = VirtualAlloc(iSize);
	
	if( Payload == Address_Null )
	{
		SetFailState("Cannot allocate virtual memory.");
	}
	
	#if DEBUG
	LogError("Addr. Detour = %i", 	g_Addr_Detour);
	LogError("Addr. Retn = %i", 	g_Addr_Retn);
	LogError("Addr. Payload = %i", 	Payload);
	#endif

	int[] asm = new int[iSize];
	int n = 0;
	
	asm[n++] = 0x81;
	asm[n++] = 0xFE;
	asm[n++] = 0x08;
	asm[n++] = 0x00;
	asm[n++] = 0x41;
	asm[n++] = 0x24;
	
	asm[n++] = 0x0F;
	asm[n++] = 0x85;
	
	int pNext = view_as<int>(Payload) + n + 4; // sizeof( Address )
	int offset = view_as<int>(g_Addr_Retn) - pNext;
	
	asm[n++] = GetByte(offset, 1);
	asm[n++] = GetByte(offset, 2);
	asm[n++] = GetByte(offset, 3);
	asm[n++] = GetByte(offset, 4);
	
	#if DEBUG
	LogError("Offset of Retn: %i", offset);
	#endif
	
	asm[n++] = 0x89;
	asm[n++] = 0x4E;
	asm[n++] = 0x1C;
	
	asm[n++] = 0x89;
	asm[n++] = 0x7E;
	asm[n++] = 0x14;
	
	asm[n++] = 0xE9;
	
	pNext = view_as<int>(Payload) + n + 4; // sizeof( Address )
	offset = view_as<int>(g_Addr_Continue) - pNext;
	
	asm[n++] = GetByte(offset, 1);
	asm[n++] = GetByte(offset, 2);
	asm[n++] = GetByte(offset, 3);
	asm[n++] = GetByte(offset, 4);
	
	#if DEBUG
	LogError("Offset of Continue: %i", offset);
	#endif
	
	g_hMem.SetAddr(Payload);
	g_hMem.WriteData(asm, iSize);

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
	asm[n++] = 0x90;
	
	#if DEBUG
	LogError("Offset of Payload: %i", offset);
	#endif
	
	g_hMem.SetAddr(g_Addr_Detour);
	g_hMem.WriteData(asm, n); // sizeof( detour )
}