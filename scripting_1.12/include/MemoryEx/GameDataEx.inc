/*
	[Extending MemoryEx functionality]
				GameDataEx

	Author: Dragokas 			[vk.com/drago_kas | Discord: Dragokas#1453]
	Version: 					1.6
	
	18.03.2022					Fixed "engine" library mapping.
	07.04.2021					Added mapping "matchmaking_ds" library to "matchmaking_ds_srv" for Linux/Mac.
	04.03.2021					Added mapping "engine" library to "engine_srv" for Linux/Mac.
	01.03.2021					Added SMC-based parsing of gamedata file to bypass "Hex-bug": https://github.com/alliedmodders/sourcemod/issues/1417
								Added support for obtaining the address of Linux function by @name.
	06.02.2021					Added mapping "server" library to "server_srv" for Linux/Mac.
	29.12.2020					First release
*/

#if defined _MemoryEx_GameDataEx_include_
  #endinput
#endif
#define _MemoryEx_GameDataEx_include_

methodmap GameDataEx < KeyValues
{
    public GameDataEx(char[] gameconf)
    {
		char sPath[PLATFORM_MAX_PATH];
		BuildPath(Path_SM, sPath, sizeof(sPath), "gamedata/%s.txt", gameconf);
		KeyValues kv = GameDataEx_ParseKV(sPath);
		return view_as<GameDataEx>(kv);
    }
	
    public void GetSourceEngineName(char[] gamename, int iSize)
    {
		static char name[32];
		if( name[0] == 0 ) {
			switch( GetEngineVersion() ) // CoreProviderImpl::GetSourceEngineName()
			{
				case Engine_Original: 		name = "original";
				case Engine_Left4Dead: 		name = "left4dead";
				case Engine_DarkMessiah: 	name = "darkmessiah";
				case Engine_Left4Dead2:		name = "left4dead2";
				case Engine_AlienSwarm:		name =  "alienswarm";
				case Engine_BloodyGoodTime:	name =  "bloodygoodtime";
				case Engine_EYE:			name =  "eye";
				case Engine_Portal2:		name =  "portal2";
				case Engine_CSGO:			name =  "csgo";
				case Engine_CSS:			name =  "css";
				case Engine_HL2DM:			name =  "hl2dm";
				case Engine_DODS:			name =  "dods";
				case Engine_TF2:			name =  "tf2";
				case Engine_NuclearDawn:	name =  "nucleardawn";
				case Engine_SDK2013:		name =  "sdk2013";
				case Engine_Blade:			name =  "blade";
				case Engine_Insurgency:		name =  "insurgency";
				case Engine_Contagion:		name =  "contagion";
				case Engine_BlackMesa:		name =  "bms";
				case Engine_DOI:			name =  "doi";
				default: {
					LogError("Unknown engine: %i", GetEngineVersion());
					return;
				}
			}
		}
		FormatEx(gamename, iSize, name);
	}
    
    public bool JumpSection(char[] name, char[] type)
    {
		this.Rewind();
		if( this.JumpToKey("#default", false) )
		{
			if( this.JumpToKey(type, false) )
			{
				if( this.JumpToKey(name, false) )
				{
					return true;
				}
			}
		}
		
		static char gamename[32];
		if( gamename[0] == 0 )
    		this.GetSourceEngineName(gamename, sizeof(gamename));
		
		this.Rewind();
		if( this.JumpToKey(gamename, false) )
		{
			if( this.JumpToKey(type, false) )
			{
				if( this.JumpToKey(name, false) )
				{
					return true;
				}
			}
		}
		
		LogError("Cannot find signature section '%s'", name);
		return false;
    }
    
    public bool GetLibrary(char[] name, char[] library, int size)
	{
		if( this.JumpSection(name, "Signatures") )
		{
			this.GetString("library", library, size);
			if( GetServerOS() != OS_Windows )
			{
				if( strcmp(library, "server") == 0 )
				{
					strcopy(library, size, "server_srv");
				}
				else if( strcmp(library, "engine") == 0 && GetEngineVersion() == Engine_Left4Dead2 )
				{
					strcopy(library, size, "engine_srv");
				}
				else if( strcmp(library, "matchmaking_ds") == 0 )
				{
					strcopy(library, size, "matchmaking_ds_srv");
				}
			}
			return library[0] != 0;
		}
		LogError("Cannot find library of '%s'", name);
		return false;
	}
	
	public bool GetPattern(char[] name, char[] pattern, int size)
	{
		if( this.JumpSection(name, "Signatures") )
		{
			this.GetString(GetServerOS() == OS_Windows ? "windows" : "linux", pattern, size);
			return pattern[0] != 0;
		}
		LogError("Cannot find pattern of '%s'", name);
		return false;
	}
	
	public int GetPatternBytes(char[] name, int[] pattern, int size)
	{
		char sig[256];
		if( this.GetPattern (name, sig, sizeof(sig)) )
		{
			int cnt, f1, f2, p, n, len = strlen(sig);
			while( p < len && n < size )
			{
				if( f1 && f2) // "\x"
				{
					cnt = StringToIntEx(sig[p], pattern[n++], 16);
					p += cnt - 1;
					f1 = 0;
					f2 = 0;
				}
				else if( !f1 && sig[p] == '\\' )
					f1 = 1;
				else if( f1 && sig[p] == 'x' )
					f2 = 1;
				else {
					pattern[n++] = sig[p];
					f1 = 0;
					f2 = 0;
				}
				++p;
			}
			return n;
		}
		LogError("Cannot parse pattern bytes of '%s'", name);
		return 0;
	}
	
	public Address GetAddress(char[] name)
	{
		char library[64], sig[256];
		int pattern[256], iSize;
		this.GetLibrary(name, library, sizeof(library));
		if( this.GetPattern (name, sig, sizeof(sig)) )
		{
			if( sig[0] == '@' )
			{
				return GetProcAddress(library, sig[1]);
			}
			else {
				iSize = this.GetPatternBytes(name, pattern, sizeof(pattern));
				DynamicLibrary lib;
				return lib.FindPattern(library, pattern, iSize);
			}
		}
		return Address_Null;
	}
	
	public int GetOffset(char[] name)
	{
		if( this.JumpSection(name, "Offsets") )
		{
			char sNum[16];
			int ret;
			this.GetString(GetServerOS() == OS_Windows ? "windows" : "linux", sNum, sizeof(sNum));
			if( sNum[0] != 0 ) {
				if( strlen(sNum) > 2 && strncmp( sNum, "0x", 2, false ) == 0 )
				{
					ret = StringToInt(sNum[2], 16);
				}
				else {
					ret = StringToInt(sNum, 10);
				}
				return ret;
			}
			else {
				LogError("Cannot find offset '%s'", name);
			}
		}
		return -1;
	}
}

KeyValues GameDataEx_KV;

KeyValues GameDataEx_ParseKV(char[] sPath)
{
	int line, col;
	KeyValues kv = new KeyValues("Games");
	GameDataEx_KV = kv;
	SMCParser parser = new SMCParser();
	SMC_SetReaders(parser, GameDataEx_Config_NewSection, GameDataEx_Config_KeyValue, GameDataEx_Config_EndSection);
	SMCError result = parser.ParseFile(sPath, line, col);
	delete parser;
	if( result != SMCError_Okay )
	{
		delete kv;
		char error[128];
		SMC_GetErrorString(result, error, sizeof(error));
		SetFailState("%s on line %d, col %d of %s [%d]", error, line, col, sPath, result);
	}
	return kv;
}

// SourcePawn doesn't support callbacks within a methodmap
//
public SMCResult GameDataEx_Config_NewSection(SMCParser smc, const char[] name, bool opt_quotes)
{
	if( strcmp(name, "Games", false) == 0 ) // skip root section
	{
		char sect[64];
		GameDataEx_KV.GetSectionName(sect, sizeof(sect));
		if( strcmp(sect, "Games", false) == 0 )
		{
			return SMCParse_Continue;
		}
	}
	GameDataEx_KV.JumpToKey(name, true);
	return SMCParse_Continue;
}
public SMCResult GameDataEx_Config_KeyValue(SMCParser smc, const char[] key, const char[] value, bool key_quotes, bool value_quotes)
{
	GameDataEx_KV.SetString(key, value);
	return SMCParse_Continue;
}
public SMCResult GameDataEx_Config_EndSection(SMCParser smc)
{
	GameDataEx_KV.GoBack();
	return SMCParse_Continue;
}
