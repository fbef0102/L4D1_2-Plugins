#if defined _MemoryEx_MemoryAlloc_include_
  #endinput
#endif
#define _MemoryEx_MemoryAlloc_include_

#include <MemoryEx/ServerLibrary>

stock int GetProcessHeap()
{
    static Address pFunc;
    static Handle h;

    if(pFunc == Address_Null)
    {
        pFunc = GetProcAddress("kernel32", "GetProcessHeap");
		
        if(pFunc != Address_Null)
        {
            StartPrepSDKCall(SDKCall_Static);
            PrepSDKCall_SetAddress(pFunc);
            PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
            h = EndPrepSDKCall();
        }
    }

    return SDKCall(h);
}

Address GetImportAddressWindows_Base(char[] func)
{
	ModuleInfo info;
	StringMap list = WindowsGetDllList(false);
	list.GetArray("srcds.exe", info, sizeof(ModuleInfo));
	Address pBase = info.base;
	return GetImportAddressWindows(pBase, func);
}

stock Address VirtualAlloc(int iSize)
{
    static Address pFunc;
    static Handle h;
	
    if(pFunc == Address_Null)
    {
        if(GetServerOS() == OS_Windows)
        {
            //pFunc = GetImportAddress("kernel32", "HeapAlloc");
            pFunc = GetImportAddressWindows_Base("HeapAlloc");
            
            if(pFunc != Address_Null)
            {
                StartPrepSDKCall(SDKCall_Static);
                PrepSDKCall_SetAddress(pFunc);
                PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
                PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
                PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
                PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
                h = EndPrepSDKCall();
            }
        }
        else
        {
            pFunc = GetImportAddress(NULL_STRING, "malloc");

            StartPrepSDKCall(SDKCall_Static);
            PrepSDKCall_SetAddress(pFunc);
            PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
            PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
            h = EndPrepSDKCall();

        }
    }

    if(GetServerOS() == OS_Windows)
    {
        return SDKCall(h, GetProcessHeap(), 0x00000008, iSize); // 0x08 == HEAP_ZERO_MEMORY => https://docs.microsoft.com/en-us/windows/win32/api/heapapi/nf-heapapi-heapalloc
    }

    return SDKCall(h, iSize);
}

stock void FreeMemory(Address pBase)
{
    static Address pFunc;
    static Handle h;

    if(pFunc == Address_Null)
    {
        if(GetServerOS() == OS_Windows)
        {
            //pFunc = GetImportAddress("kernel32", "HeapFree");
            pFunc = GetImportAddressWindows_Base("HeapFree");

            if(pFunc != Address_Null)
            {
                StartPrepSDKCall(SDKCall_Static);
                PrepSDKCall_SetAddress(pFunc);
                PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
                PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
                PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
                h = EndPrepSDKCall();
            }
        }
        else
        {
            pFunc = GetImportAddress(NULL_STRING, "free");

            StartPrepSDKCall(SDKCall_Static);
            PrepSDKCall_SetAddress(pFunc);
            PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
            h = EndPrepSDKCall();

        }
    }

    if(GetServerOS() == OS_Windows)
    {
        SDKCall(h, GetProcessHeap(), 0x00, pBase);
    }
    else
    {
        SDKCall(h, pBase);
    }
}
