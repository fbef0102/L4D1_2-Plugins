
#if defined _MemoryEx_WindowsFunction_include_
  #endinput
#endif
#define _MemoryEx_WindowsFunction_include_

#include <MemoryEx/Stocks>
#include <MemoryEx/PatternGenerator>

#define MEMORY_EX_WINAPI_MAX_ARGS 10

#define WINAPI_ARGS_COUNT(%0) %0

#define MEMORY_EX_WINAPI_RET_DEFAULT -2
#define MEMORY_EX_WINAPI_INVALID_FUNC -3

enum 
{
	WINAPI_FLAG_NONE = 0,
	WINAPI_FLAG_NEED_RETURN
}

// for import table
#define CALC_STRUCT_OFFSET(%0) view_as<Address>(%0 * 0x04)
#define STRUCT_SIZE(%0) (sizeof(%0) * 0x04)

stock Address WindowsGetPEHeader(Address base)
{
	return base + LoadFromAddressEx(base + view_as<Address>(0x3C), NumberType_Int32);
}
stock Address WindowsParsePEBHeader(Address base)
{
	return LoadFromAddressEx(WindowsGetPEHeader(base) + view_as<Address>(0x50),  NumberType_Int32); // NT->OptionalHeader.SizeOfImage
}
stock void GetWindowsVersion(int& iMajorVer, int& iMinorVer)
{
	iMajorVer = LoadFromAddress(view_as<Address>(0x7FFE0000 + 0x26C), NumberType_Int32);
	iMinorVer = LoadFromAddress(view_as<Address>(0x7FFE0000 + 0x270), NumberType_Int32);
}

stock Address GetPEB()
{
	static Address pPEB;

	static int PEBAsm[] =
	{
		0x64, 0xA1, 0x30, 0x00, 0x00, 0x00, // mov eax, dword ptr fs:[30]
		0xC3                                // ret
	};

	if(pPEB != Address_Null)
	{
		return pPEB;
	}

	int iOffset = FindSendPropInfo("CBaseEntity", "m_clrRender");

	if(iOffset == -1)
	{
		SetFailState("hm... m_clrRender not found?");
	}

	int iEntity = CreateEntityByName("trigger_push"); // `trigger_push is a brush entity available in all Source games.` =>  https://developer.valvesoftware.com/wiki/Trigger_push
	Address pEntity = GetEntityAddress(iEntity) + view_as<Address>(iOffset);

	SetEntDataArray(iEntity, iOffset, PEBAsm, sizeof(PEBAsm), 1);
	StoreToAddress(pEntity, PEBAsm[0], NumberType_Int8); // for => SourceHook::SetMemAccess(addr, sizeof(uint8_t), SH_MEM_READ|SH_MEM_WRITE|SH_MEM_EXEC);

	pPEB = ASMSDKCall(pEntity);
	AcceptEntityInput(iEntity, "Kill");

	return pPEB;
}
stock StringMap WindowsGetDllList(bool bRefresh = false, bool bAddressAsKey = false)
{
	static StringMap list, modules;
	
	/*
		bAddressAsKey -> true
			StringMap
				key		== Base address
				value 	== Module path
		
		bAddressAsKey -> false
			StringMap
				key		== Module name
				value	== LibraryInfo struct { base; size }
	*/
	
	if(bAddressAsKey)
	{
		if(modules == null)
		{
			modules = new StringMap();
		}
		else if(bRefresh)
		{
			modules.Clear();
		}
		else if(modules.Size != 0)
		{
			return modules;
		}
	}
	else {
		if(list == null)
		{
			list = new StringMap();
		}
		else if(bRefresh)
		{
			list.Clear();
		}
		else if(list.Size != 0)
		{
			return list;
		}
	}

	Address PEB = GetPEB();

	if(PEB == Address_Null)
	{
		return bAddressAsKey ? modules : list;
	}

	char sLibrary[255], sBase[16];

	Address pLdrData = view_as<Address>(LoadFromAddress(PEB + view_as<Address>(0x0C), NumberType_Int32)); // PPEB_LDR_DATA pldr_data = *(PPEB_LDR_DATA*)(peb + 0x0C);

	Address pLdrCurrent = view_as<Address>(LoadFromAddress(pLdrData + view_as<Address>(0x10), NumberType_Int32) - 0x08); //(PLDR_DATA_TABLE_ENTRY)((UINT)pldr_data->InInitializationOrderModuleList.Blink - 0x08);
	//Address pLdrPrev = LoadFromAddress(pLdrData + 0x0C, NumberType_Int32) - 0x08; // pldr_prev = (PMemoryExLoadedTableEntry)((UINT)pldr_data->InLoadOrderModuleList.Flink - 0x08);
	Address pLdrFirst = pLdrCurrent;

	int iBase;

	int tmp[2]; // enum struct hack

	do
	{
		iBase = LoadFromAddress(pLdrCurrent + view_as<Address>(0x20), NumberType_Int32);

		if(iBase) // if (pldr_current->DllBase != NULL)
		{
			ReadUnicodeString(view_as<Address>(LoadFromAddress(pLdrCurrent + view_as<Address>(0x30), NumberType_Int32)), sLibrary, sizeof sLibrary); // pldr_current->FullDllName.Buffer
			
			if(bAddressAsKey)
			{
				IntToString(iBase, sBase, sizeof(sBase));
				modules.SetString(sBase, sLibrary);
			}
			else {
				for(int x = strlen(sLibrary) - 1; x >= 0; x--)
				{
					if(sLibrary[x] == '\\') 
					{
						strcopy(sLibrary, sizeof sLibrary, sLibrary[x + 1]);
						break;
					}
					sLibrary[x] = CharToLower(sLibrary[x]);
				}
				
				tmp[0] = iBase;
				tmp[1] = view_as<int>(WindowsParsePEBHeader(view_as<Address>(iBase)));
	
				list.SetArray(sLibrary, tmp, sizeof(tmp));
			}
		}

		//pLdrPrev = pLdrCurrent;
		pLdrCurrent = view_as<Address>(LoadFromAddress(pLdrCurrent + view_as<Address>(0x0C), NumberType_Int32) - 0x08);
	}
	while(pLdrCurrent != pLdrFirst);
	return bAddressAsKey ? modules : list;
}

//My thread with an analysis of all this
//https://hlmod.ru/threads/urok-chtenie-import-table-s-pomoschju-sourcepawn.52289/

enum struct ImportDescription
{
	Address originalFirstThunk;
	int timeDateStamp;
	int forwarderChaine;
	Address dllName;
	Address firstThunk;

	void FillInfo(Address base, Address addr)
	{
		this.originalFirstThunk = base + view_as<Address>(LoadFromAddress(addr + CALC_STRUCT_OFFSET(ImportDescription::originalFirstThunk), NumberType_Int32));
		this.timeDateStamp      = LoadFromAddress(addr + CALC_STRUCT_OFFSET(ImportDescription::timeDateStamp), NumberType_Int32);
		this.forwarderChaine   	= LoadFromAddress(addr + CALC_STRUCT_OFFSET(ImportDescription::forwarderChaine), NumberType_Int32);
		this.dllName            = base + view_as<Address>(LoadFromAddress(addr + CALC_STRUCT_OFFSET(ImportDescription::dllName), NumberType_Int32));
		this.firstThunk         = base + view_as<Address>(LoadFromAddress(addr + CALC_STRUCT_OFFSET(ImportDescription::firstThunk), NumberType_Int32));
	}
	void GetName(char[] sBuffer, int iMaxLength)
	{
		ReadString(this.dllName, sBuffer, iMaxLength);
	}
}


stock Address GetImportAddressWindows(Address pBase, const char[] sName )
{
	Address PE = pBase + view_as<Address>(LoadFromAddress(pBase + view_as<Address>(0x3C), NumberType_Int32));

	Address importTable = pBase +  view_as<Address>(LoadFromAddress(PE + view_as<Address>(0x80), NumberType_Int32));
	Address importTableSize = view_as<Address>(LoadFromAddress(PE + view_as<Address>(0x84), NumberType_Int32));
	int iSize = view_as<int>(importTableSize) / STRUCT_SIZE(ImportDescription);

	ImportDescription disc;
	//char sDll[64];
	char sFunction[256];

	for(int x = 0; x < iSize; x++)
	{
		Address addr = importTable + view_as<Address>((STRUCT_SIZE(ImportDescription) * x));
		disc.FillInfo(pBase, addr);
		//disc.GetName(sDll, sizeof sDll);


		for(Address offset = Address_Null; offset >= Address_Null; offset += view_as<Address>(0x04)) // endless cycle
		{
			Address pFunctionStr = view_as<Address>(LoadFromAddress(disc.originalFirstThunk + offset, NumberType_Int32));

			if(pFunctionStr == Address_Null)
			{
				break;
			}

			pFunctionStr += pBase;

			ReadString(pFunctionStr + view_as<Address>(0x02), sFunction, sizeof sFunction);
			
			if(!strcmp(sName, sFunction))
			{
				return view_as<Address>(LoadFromAddress(disc.firstThunk + offset, NumberType_Int32));
			}
			
		}
	}

	return Address_Null;
}


/*
.rdata:10047E50                         ; Export directory for tier0.dll
.rdata:10047E50                         ;
.rdata:10047E50 00 00 00 00                             dd 0                    ; Characteristics
.rdata:10047E54 20 A2 83 5E                             dd 5E83A220h            ; TimeDateStamp: Tue Mar 31 20:03:44 2020
.rdata:10047E58 00 00                                   dw 0                    ; MajorVersion
.rdata:10047E5A 00 00                                   dw 0                    ; MinorVersion
.rdata:10047E5C C6 94 04 00                             dd rva aTier0Dll        ; Name
.rdata:10047E60 01 00 00 00                             dd 1                    ; Base
.rdata:10047E64 3B 02 00 00                             dd 23Bh                 ; NumberOfFunctions
.rdata:10047E68 3B 02 00 00                             dd 23Bh                 ; NumberOfNames
.rdata:10047E6C 78 7E 04 00                             dd rva off_10047E78     ; AddressOfFunctions
.rdata:10047E70 64 87 04 00                             dd rva off_10048764     ; AddressOfNames
.rdata:10047E74 50 90 04 00                             dd rva word_10049050    ; AddressOfNameOrdinals
*/
stock Address GetProcAddressWindows(Address pBase, const char[] sName)
{
	Address pExportTable = pBase + LoadFromAddressEx(WindowsGetPEHeader(pBase) + view_as<Address>(0x78), NumberType_Int32);

	int iNumFunc = LoadFromAddress(pExportTable + view_as<Address>(0x14), NumberType_Int32);

	Address pFunctions 	= pBase + LoadFromAddressEx(pExportTable + view_as<Address>(0x1C), NumberType_Int32);
	Address pNames 		= pBase + LoadFromAddressEx(pExportTable + view_as<Address>(0x20), NumberType_Int32);
	Address pOrdinals 	= pBase + LoadFromAddressEx(pExportTable + view_as<Address>(0x24), NumberType_Int32);

	static char sExport[512];

	Address pStr;
	int iBytes;
	int iStrLen = strlen(sName);
	int iOrdinal;

	for(int x = 0; x < iNumFunc; x++)
	{
		pStr = pBase + LoadFromAddressEx(pNames + view_as<Address>(x * 0x04), NumberType_Int32);
		iBytes = ReadString(pStr, sExport, sizeof sExport);

		if(iBytes == iStrLen)
		{
			if(!strcmp(sName, sExport))
			{
				iOrdinal = LoadFromAddress(pOrdinals + view_as<Address>(x * 0x02), NumberType_Int16);
				return pBase + LoadFromAddressEx(pFunctions + view_as<Address>(iOrdinal * 0x04), NumberType_Int32);
			}
		}
	}

	return Address_Null;
}
