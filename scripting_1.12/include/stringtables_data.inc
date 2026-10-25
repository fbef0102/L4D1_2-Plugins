// https://forums.alliedmods.net/showthread.php?t=319828

#if defined __stringtablecontainer__
 #endinput
#endif

#define __stringtablecontainer__

#include <regex>

#define MAXTABLES 32
#define MAX_TABLE_NAME 64

enum EngineOS 
{ 
    OS_Unknown, 
    OS_Windows, 
    OS_Linux, 
    OS_Mac 
}; 

enum ENetworkStringtableFlags
{
	NSF_NONE = 0,
	NSF_DICTIONARY_ENABLED  = (1 << 0) 
};

EngineOS Platform;

stock Handle g_hDeleteStrings;
stock Handle g_hCreateStringTable, g_hRemoveAllTables, g_hFindTable, g_hGetTable, g_hGetNumTables, g_hSetAllowClientSideAddString, g_hCreateDictionary;
stock Handle g_hGetTableName,g_hGetTableId, g_hGetNumStrings, g_hGetMaxStrings, g_hGetEntryBits, g_hSetTick, g_hChangedSinceTick, g_hAddString, g_hGetString, g_hSetStringUserData, g_hGetStringUserData, g_hFindStringIndex, g_hSetStringChangedCallback, g_hDump, g_hLock;

methodmap INetworkStringTableContainer
{
	public INetworkStringTableContainer ()
    {
		InitSDKCalls();
		
		return view_as<INetworkStringTableContainer>(GetStringtableServer());
    }
	
	public INetworkStringTable CreateStringTable (const char tableName[MAX_TABLE_NAME], int maxentries, int userdatafixedsize = 0, int userdatanetworkbits = 0, ENetworkStringtableFlags flags = NSF_NONE)
	{	
		return SDKCall(g_hCreateStringTable, this, tableName, maxentries, userdatafixedsize, userdatanetworkbits, flags);
	}
	
	public void RemoveAllTables ()
	{	
		SDKCall(g_hRemoveAllTables, this);
	}
	
	public INetworkStringTable FindTable (const char tableName[MAX_TABLE_NAME])
	{	
		return SDKCall(g_hFindTable, this, tableName);
	}
	
	public INetworkStringTable GetTable (int index)
	{	
		return SDKCall(g_hGetTable, this, index);
	}
	
	public int GetNumTables ()
	{	
		return SDKCall(g_hGetNumTables, this);
	}
	
	public void SetAllowClientSideAddString (INetworkStringTable table, bool bAllowClientSideAddString)
	{	
		SDKCall(g_hSetAllowClientSideAddString, this, table, bAllowClientSideAddString);
	}
	
	public void CreateDictionary (const char tableName[MAX_TABLE_NAME])
	{	
		SDKCall(g_hCreateDictionary, this, tableName);
	}
	
	public void SetStateCreate (bool state)
	{
		StoreToAddress(view_as<Address>(this) + view_as<Address>(4), state, NumberType_Int32);
	}
};

methodmap INetworkStringTable
{
	public INetworkStringTable (int index)
    {
		InitSDKCalls();
		
		INetworkStringTableContainer local_container = INetworkStringTableContainer();
		return local_container.GetTable(index);
    }
	
	public void GetTableName (char[] buffer, int len = MAX_TABLE_NAME)
    {
        SDKCall(g_hGetTable, this, buffer, len);
    }
	
	public int GetTableId ()
    {
        SDKCall(g_hGetTableId, this);
    }
	
	public int GetNumStrings ()
    {
        SDKCall(g_hGetNumStrings, this);
    }
	
	public int GetEntryBits ()
    {
        SDKCall(g_hGetEntryBits, this);
    }
	
	public bool ChangedSinceTick (int tick)
    {
        return SDKCall(g_hChangedSinceTick, this, tick);
    }
	
	public int AddString (bool bIsServer, const char[] value, int length = -1, int userdata = 0)
    {
        return SDKCall(g_hAddString, this, bIsServer, value, length, userdata);
    }
	
	public void GetString (int stringNumber, char[] buffer, int length)
    {
        SDKCall(g_hGetString, this, stringNumber, buffer, length);
    }
	
	public void SetStringUserData (int stringNumber, int length, int userdata)
    {
        SDKCall(g_hSetStringUserData, this, stringNumber, length, userdata);
    }
	
	public int GetStringUserData (int stringNumber, int &length)
    {
        return SDKCall(g_hGetStringUserData, this, stringNumber, length);
    }
	
	public int FindStringIndex (const char[] string)
    {
        return SDKCall(g_hFindStringIndex, this, string);
    }
	
	public void SetStringChangedCallback (int pObject, Address changeFunc)
    {
        SDKCall(g_hSetStringChangedCallback, this, pObject, changeFunc);
    }
	
	public void Dump ()
    {
        SDKCall(g_hDump, this);
    }
	
	public bool Lock (bool bLock)
    {
        return SDKCall(g_hLock, this, bLock);
    }
	
	public void DeleteStrings ()
    {
        SDKCall(g_hDeleteStrings, this);
    }
}

void InitSDKCalls()
{
	static bool set;
	
	if ( set )
		return;
		
	set = true;
	
	int shifted = (GameEnginePlatform(OS_Linux) ? 1 : 0);
	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetVirtual(1 + shifted);
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	g_hCreateStringTable = EndPrepSDKCall();
	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetVirtual(2 + shifted);
	g_hRemoveAllTables = EndPrepSDKCall();
	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetVirtual(3 + shifted);
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	g_hFindTable = EndPrepSDKCall();
	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetVirtual(4 + shifted);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	g_hGetTable = EndPrepSDKCall();
	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetVirtual(5 + shifted);
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	g_hGetNumTables = EndPrepSDKCall();
	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetVirtual(6 + shifted);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
	g_hSetAllowClientSideAddString = EndPrepSDKCall();
	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetVirtual(7 + shifted);
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	g_hCreateDictionary = EndPrepSDKCall();
	
	/* --------------------------------- */
	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetVirtual(1 + shifted);
	PrepSDKCall_SetReturnInfo(SDKType_String, SDKPass_Pointer);
	g_hGetTableName = EndPrepSDKCall();
	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetVirtual(2 + shifted);
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	g_hGetTableId = EndPrepSDKCall();
	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetVirtual(3 + shifted);
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	g_hGetNumStrings = EndPrepSDKCall();
	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetVirtual(4 + shifted);
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	g_hGetMaxStrings = EndPrepSDKCall();
	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetVirtual(5 + shifted);
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	g_hGetEntryBits = EndPrepSDKCall();
	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetVirtual(6 + shifted);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	g_hSetTick = EndPrepSDKCall();
	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetVirtual(7 + shifted);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	g_hChangedSinceTick = EndPrepSDKCall();
	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetVirtual(8 + shifted);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer, VDECODE_FLAG_ALLOWNULL | VDECODE_FLAG_ALLOWWORLD);
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	g_hAddString = EndPrepSDKCall();
	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetVirtual(9 + shifted);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_String, SDKPass_Pointer);
	g_hGetString = EndPrepSDKCall();
	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetVirtual(10 + shifted);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_ByRef);
	g_hSetStringUserData = EndPrepSDKCall();
	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetVirtual(11 + shifted);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_ByRef, .encflags = VENCODE_FLAG_COPYBACK);
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	g_hGetStringUserData = EndPrepSDKCall();
	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetVirtual(12 + shifted);
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	g_hFindStringIndex = EndPrepSDKCall();
	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetVirtual(13 + shifted);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	g_hSetStringChangedCallback = EndPrepSDKCall();
	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetVirtual(14 + shifted);
	g_hDump = EndPrepSDKCall();
	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetVirtual(15 + shifted);
	PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
	g_hLock = EndPrepSDKCall();
			
	StartPrepSDKCall(SDKCall_Raw);
	if ( !PrepSDKCall_SetSignature(SDKLibrary_Engine, "@_ZN19CNetworkStringTable16DeleteAllStringsEv", 0) )
	{
		if ( !PrepSDKCall_SetSignature(SDKLibrary_Engine, "\x53\x56\x8B\xF1\x8B\x4E\x38\x33\xDB", 9) )
		{
			LogMessage("Failed to create call for \"CNetworkStringTable::DeleteAllStrings\"\n\
			Create call manually or update signature");
		}
	}
	g_hDeleteStrings = EndPrepSDKCall();
}

Address GetStringtableServer ()
{
	static Address s_NetworkStringTableServer;
	
	if (s_NetworkStringTableServer == Address_Null)
	{
		StartPrepSDKCall(SDKCall_Static);
		PrepSDKCall_SetSignature(SDKLibrary_Engine, "@CreateInterface", 0);
		PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
		PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Pointer, VDECODE_FLAG_ALLOWNULL);
		PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	
		Handle call = EndPrepSDKCall();
		
		char name[36];
		int i, retn;
		
		while ( !retn && i <= 10 )
		{
			FormatEx(name, sizeof name, "VEngineServerStringTable%03d", i++);
			retn = SDKCall(call, name, 0);
		}
		
		s_NetworkStringTableServer = view_as<Address>(retn);
		
		if ( !s_NetworkStringTableServer )
		{
			SetFailState("Failed to find \"VEngineServerStringTable\" interface");
		}
	}
	
	return s_NetworkStringTableServer;
}

// credits to gubka f. to get OS

stock bool GameEnginePlatform(EngineOS oS) 
{
	if(Platform != OS_Unknown) 
		return (Platform == oS);
		
	char sBuffer[PLATFORM_MAX_PATH * 2]; 
	
	ServerCommandEx(sBuffer, sizeof sBuffer , "status"); 
	
	Regex hRegex = CompileRegex("(os\\s+:\\s+\\w+)");  
	
	int iCount = hRegex.Match(sBuffer);
	int iSystem;
	
	for(int i = 0; i < iCount; i++)  
	{
		hRegex.GetSubString(i, sBuffer, sizeof(sBuffer));  
		iSystem = FindCharInString(sBuffer, ' ', true) + 1; 
		Platform = !strncmp(sBuffer[iSystem], "win", 3, false) ? OS_Windows : !strncmp(sBuffer[iSystem], "lin", 3, false) ? OS_Linux : OS_Mac; 
		break; 
	}
	
	delete hRegex; 
	return (Platform == oS); 
}  