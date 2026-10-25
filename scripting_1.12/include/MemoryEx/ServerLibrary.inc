#if defined _MemoryEx_ServerLibrary_include_
  #endinput
#endif
#define _MemoryEx_ServerLibrary_include_


#include <sdktools>

#include <MemoryEx/Stocks>

#include <MemoryEx/WindowsFunction>
#include <MemoryEx/LinuxFunction>

enum struct ModuleInfo
{
	Address base;
	int size;
}

static const char g_sExts[][] = 
{
	"",

	".dll",
	".so",
	".so"
};

enum OS
{
	OS_Unknown, 

	OS_Windows,
	OS_Linux,
	OS_Mac
}
enum
{
	FindModuleRes_None,

	FindModuleRes_OK,
	FindModuleRes_More // If two or more modules are found
}

stock OS GetServerOS()
{
	static OS os; // default OS_Unknown;

	if(os != OS_Unknown)
	{
		return os;
	}
	//Prolog linux = ./srcds_linux -game csgo
	// windows = srcds.exe -game csgo

	char sProlog[4];
	GetCommandLine(sProlog, sizeof sProlog);

	if(sProlog[0] == '.')
	{
		os = OS_Linux;
	}
	else
	{
		os = OS_Windows;
	}

	return os;
}
stock void CheckInitPEB()
{
	if(GetServerOS() != OS_Windows)
	{
		MemoryExInit();
		return;
	}

	if(!IsValidEntity(0)) // worldspawn
	{
		RequestFrame(CheckInitPEB);
		return;
	}

	GetPEB();
	MemoryExInit();
}
stock void MemoryExInit()
{
	Function func = GetFunctionByName(INVALID_HANDLE, "MemoryEx_InitPEB");

	if(func == INVALID_FUNCTION)
	{
		return;
	}

	Call_StartFunction(INVALID_HANDLE, func);
	Call_Finish();
}
stock StringMap GetListLibraries()
{
	return GetServerOS() == OS_Windows ? WindowsGetDllList() : LinuxParseMapsFile();
}
stock StringMap GetListModulePath()
{
	return GetServerOS() == OS_Windows ? WindowsGetDllList( .bAddressAsKey = true) : LinuxParseMapsFile( .bAddressAsKey = true);
}
stock bool GetModulePath(Address pBase, char[] sName, int max_size)
{
	char sAddr[16];
	StringMap ModulePath = GetListModulePath();
	
	IntToString(view_as<int>(pBase), sAddr, sizeof(sAddr));
	
	if (!ModulePath.GetString(sAddr, sName, max_size))
	{
		return false;
	}
	return true;
}
stock Address GetModuleHandle(const char[] sName)
{
	ModuleInfo info;

	if(!GetModuleInfo(sName, info))
	{
		return Address_Null;
	}

	return info.base;
}
stock any GetModuleSize(const char[] sName)
{
	ModuleInfo info;

	if(!GetModuleInfo(sName, info))
	{
		return 0;
	}

	return info.size;
}
stock Address GetModuleEnd(const char[] sName)
{
	ModuleInfo info;

	if(!GetModuleInfo(sName, info))
	{
		return Address_Null;
	}

	return info.base + view_as<Address>(info.size);
}
stock bool GetModuleInfo(const char[] sNameLibrary, ModuleInfo info)
{
	OS os = GetServerOS();

	int iLength = strlen(sNameLibrary);
	int iLengthExts = strlen(g_sExts[os]);
	int iLengthName = iLength + iLengthExts + 1;

	char[] sName = new char[iLengthName];

	strcopy(sName, iLengthName, sNameLibrary);

	if(iLength > 0x04) // mem.lib.InitModule("engine"); "engine" convert to "engine.so" or "engine.dll"
	{
		if(strcmp(sName[iLength - iLengthExts], g_sExts[os]) != 0)
		{
			FormatEx(sName, iLengthName, "%s%s", sNameLibrary, g_sExts[os]);
		}
	}

	if(!GetListLibraries().GetArray(sName, info, sizeof(ModuleInfo)))
	{
		return false;
	}

	return true;
}
stock Address GetProcAddress(const char[] sLibrary, const char[] sName )
{
	Address pBase = GetModuleHandle(sLibrary);

	if(pBase == Address_Null)
	{
		return Address_Null;
	}

	return GetServerOS() == OS_Windows ? GetProcAddressWindows(pBase, sName) : GetProcAddressLinux(pBase, sName);
}
stock Address GetImportAddress(const char[] sLibrary, const char[] sName )
{
	if(GetServerOS() == OS_Windows)
	{
		Address pBase = GetModuleHandle(sLibrary);

		if(pBase == Address_Null)
		{
			return Address_Null;
		}

		return GetImportAddressWindows(pBase, sName);
	}

	return GetImportAddressLinux(Address_Null, sName);
}
stock int FindModule(const char[] sModule, char[] sResult, int iMaxLength)
{
	StringMap hList = GetListLibraries();
	StringMapSnapshot hSnap = hList.Snapshot();

	char sName[64];
	int res = FindModuleRes_None;

	ModuleInfo info;

	for(int x = 0; x < hSnap.Length; x++)
	{
		hSnap.GetKey(x, sName, sizeof sName);
		hList.GetArray(sName, info, sizeof(ModuleInfo));

		if(StrContainsEx(sName, sModule))
		{
			if(res == FindModuleRes_None)
			{
				res = FindModuleRes_OK;
			}
			else
			{
				res = FindModuleRes_More;
			}

			strcopy(sResult, iMaxLength, sName);
		}

	}

	delete hSnap;
	return res;
}

static stock const int g_hEmptyWinApiArgs[MEMORY_EX_WINAPI_MAX_ARGS] = {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};

// return -2 if flags WINAPI_FLAG_NEED_RETURN is not found
stock any WINAPI_CALL(const char[] libName, const char[] funcName, int flags = WINAPI_FLAG_NONE, int parms = 0, any arg1 = 0, any arg2 = 0, any arg3 = 0, any arg4 = 0, any arg5 = 0, any arg6 = 0, any arg7 = 0, any arg8 = 0, any arg9 = 0, any arg10 = 0)
{
	Address pFunc = GetProcAddress(libName, funcName);
	Handle h;

	if(pFunc == Address_Null)
	{
		return MEMORY_EX_WINAPI_INVALID_FUNC;
	}

	StartPrepSDKCall(SDKCall_Static);
	PrepSDKCall_SetAddress(pFunc);

	for(int x = 0; x < parms; x++)
	{
		PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	}

	if(flags & WINAPI_FLAG_NEED_RETURN)
	{
		PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	}

	h = EndPrepSDKCall();

	any result;

	switch(parms)
	{
		case 0: result = SDKCall(h)
		case 1: result 	= SDKCall(h, arg1);
		case 2: result 	= SDKCall(h, arg1, arg2);
		case 3: result 	= SDKCall(h, arg1, arg2, arg3);
		case 4: result 	= SDKCall(h, arg1, arg2, arg3, arg4);
		case 5: result 	= SDKCall(h, arg1, arg2, arg3, arg4, arg5);
		case 6: result 	= SDKCall(h, arg1, arg2, arg3, arg4, arg5, arg6);
		case 7: result 	= SDKCall(h, arg1, arg2, arg3, arg4, arg5, arg6, arg7);
		case 8: result 	= SDKCall(h, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8);
		case 9: result 	= SDKCall(h, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9);
		case 10: result = SDKCall(h, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10);
	}

	if(h != null)
	{
		delete h;
	}

	if(flags & WINAPI_FLAG_NEED_RETURN)
	{
		return result;
	}

	return MEMORY_EX_WINAPI_RET_DEFAULT;
}