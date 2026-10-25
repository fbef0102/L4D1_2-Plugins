#if defined _MemoryEx_LinuxFunction_include_
  #endinput
#endif

#define _MemoryEx_LinuxFunction_include_

#include <MemoryEx/Stocks>
#include <MemoryEx/BinaryFile>

enum struct LibraryInfo // very bad.  same as in DynamicLibrary.
{
    Address base;
    int size;
}

stock StringMap LinuxParseMapsFile(bool bRefresh = false, bool bAddressAsKey = false)
{
    static StringMap list, modules;
    
    /*
        bAddressAsKey -> true
            StringMap
                key   == Base address
                value == Module path
        
        bAddressAsKey -> false
            StringMap
                key   == Module name
                value == LibraryInfo struct { base; size }
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

    char sBaseAddress[16];
    char sName[64], sPath[PLATFORM_MAX_PATH];
    char sBuffer[1024];

    int iLength;
    File file = OpenFile("file:///proc/self/maps", "rt");

    while(file.ReadLine(sBuffer, sizeof sBuffer))
    {
        TrimString(sBuffer);
        iLength = strlen(sBuffer);

        if((strcmp(sBuffer[iLength - 3], ".so") != 0) && (strncmp(sBuffer[iLength - 5], ".so", 3) != 0))
        {
            continue;
        }

        int x;
        for(x = iLength - 1; x >= 0; x--)
        {
            if(sBuffer[x] == '/')
            {
                FormatEx(sName, sizeof sName, "%s", sBuffer[x + 1]); // parse name /home/ttt/serverfiles/csgo/addons/sourcemod/extensions/dbi.sqlite.ext.so => sName = dbi.sqlite.ext.so

                //fix name conflict
                // /home/ttt/serverfiles/csgo/addons/metamod/bin/server.so
                // /home/ttt/serverfiles/csgo/bin/server.so

                if(!strcmp(sName, "server.so")) 
                {
                    if(StrContains(sBuffer, "/metamod/") != -1) // it's metamod
                    {
                        Format(sName, sizeof sName, "mm_%s", sName);
                    }
                }
                break;
            }
        }
        
        if(bAddressAsKey)
        {
            for(x = x - 1; x >= 0; x--)
            {
                if(sBuffer[x] == ' ')
                {
                    FormatEx(sPath, sizeof sPath, "file://%s", sBuffer[x + 1]);
                    break;
                }
            }
            
            FormatEx(sBaseAddress, 9, "%s", sBuffer);
            IntToString(HexToDec(sBaseAddress), sBaseAddress, sizeof(sBaseAddress));
            
            modules.SetString(sBaseAddress, sPath);
        }
        else {
            LibraryInfo info;

            if(list.GetArray(sName, info, sizeof(LibraryInfo))) // exist
            {
                continue;
            }

            FormatEx(sBaseAddress, 9, "%s", sBuffer);
            info.base = view_as<Address>(HexToDec(sBaseAddress));
            
            if(ParseElfHeader(info.base, info.size))
            {
                list.SetArray(sName, info, sizeof(LibraryInfo));
                
                //LogError("Lib: %s. Base = %i", sName, info.base);
            }
        }
    }

    delete file;
    return bAddressAsKey ? modules : list;
}

stock Address GetFirstElfTablePh(Address base)
{
    return view_as<Address>(LoadFromAddress(base + view_as<Address>(0x1C), NumberType_Int32)); // <= e_phoff;
}
stock int GetElfTablePhSize(Address base)
{
    return LoadFromAddress(base + view_as<Address>(0x2A), NumberType_Int16); // <= e_phentsize
}
stock int GetCountElfTablePh(Address base)
{
    return LoadFromAddress(base + view_as<Address>(0x2C), NumberType_Int16); // <= e_phnum;
}

stock Address GetFirstElfTableSect(BinaryFile bf)
{
    return bf.LoadFromAddressEx(view_as<Address>(0x20), NumberType_Int32); // <= e_shoff;
}
stock int GetElfTableSectSize(BinaryFile bf)
{
    return bf.LoadFromAddress(view_as<Address>(0x2E), NumberType_Int16); // <= e_shentsize
}
stock int GetCountElfTableSect(BinaryFile bf)
{
    return bf.LoadFromAddress(view_as<Address>(0x30), NumberType_Int16); // <= e_shnum;
}

//https://wikipedia.org/wiki/Executable_and_Linkable_Format
static stock bool ParseElfHeader(Address base, int& iSize)
{
    bool isELF = view_as<bool>(LoadFromAddress(base, NumberType_Int32) == 0x464C457F);
    bool x86 = view_as<bool>(LoadFromAddress(base + view_as<Address>(0x04), NumberType_Int8) == 1); // e_ident[EI_CLASS]

    if(!isELF || !x86)
    {
        return false;
    }

    Address pFirstPHTable   = GetFirstElfTablePh(base);
    int iPHTableSize        = GetElfTablePhSize(base);
    int iCountPHTable       = GetCountElfTablePh(base);

    Address iStartAddress;

    int iType;
    int iFlags;

    for(int x = 0; x < iCountPHTable; x++)
    {
        iStartAddress = base + pFirstPHTable + view_as<Address>(iPHTableSize * x);
        iType = LoadFromAddress(iStartAddress, NumberType_Int32);

        if(iType != 1) // 1 == PT_LOAD
        {
            continue;
        }

        iFlags = LoadFromAddress(iStartAddress + view_as<Address>(0x18), NumberType_Int32); // p_flags

        if(iFlags == (0x01|0x04)) // hdr.p_flags == (PF_X|PF_R)
        {
            iSize = LoadFromAddress(iStartAddress + view_as<Address>(0x10), NumberType_Int32) - 1; // p_filesz
            break;
        }
    }

    return true;
}
stock Address GetProcAddressLinux(Address pBase, const char[] sName, bool bDynamicOnly = false )
{
    const int PT_DYNAMIC = 2;
    const int DT_STRTAB = 5;
    const int DT_SYMTAB = 6;
    const int SHT_SYMTAB = 2;
    const int SHT_STRTAB = 3;
    
     //From MemoryEx/LinuxFunction/ParseElfHeader
    Address pFirstTable = GetFirstElfTablePh(pBase);
    int iPHTableSize    = GetElfTablePhSize(pBase);
    int iCountPHTable   = GetCountElfTablePh(pBase);

    Address iStartAddress;
    Address pDynamic;

    int iType;

    for(int x = 0; x < iCountPHTable; x++)
    {
        iStartAddress = pBase + pFirstTable + view_as<Address>(iPHTableSize * x);
        iType = LoadFromAddress(iStartAddress, NumberType_Int32);

        if(iType != PT_DYNAMIC)
        {
            continue;
        }

        pDynamic = pBase + LoadFromAddressEx(iStartAddress + view_as<Address>(0x08), NumberType_Int32); // p_vaddr
        break;
    }

    //DumpOnAddress(pDynamic, 0xE8, 8);

    Address offset;
    Address pStrTab;
    Address pDynSym;
    Address pStr;
    Address pFunc;
    
    // Dynamic Sections
    while((iType = LoadFromAddress(pDynamic + offset, NumberType_Int16)) != 0)
    {
        switch(iType)
        {
            case DT_STRTAB: pStrTab  = LoadFromAddressEx(pDynamic + offset + view_as<Address>(0x04), NumberType_Int32);
            case DT_SYMTAB: pDynSym  = LoadFromAddressEx(pDynamic + offset + view_as<Address>(0x04), NumberType_Int32); 
        }
        offset += view_as<Address>(0x08); // sizeof(Elf32_Dyn)
    }

    char sStr[256];
    
    int iCount = view_as<int>(pStrTab - pDynSym) / 0x10;
    int iLen = strlen(sName);
    int iLenStr;

    //DumpOnAddress(pDynSym, 0x100, 16);

    // .dynsym entries
    for(int x = 0; x < iCount; x++)
    {
        pStr = pStrTab + LoadFromAddressEx(pDynSym, NumberType_Int32);
        iLenStr = ReadString(pStr, sStr, sizeof sStr);

        if(iLen == iLenStr)
        {
            if(!strcmp(sName, sStr))
            {
                pFunc = pBase + LoadFromAddressEx(pDynSym + view_as<Address>(0x04), NumberType_Int32); // d_ptr
                
                if(pFunc == pBase)
                {
                    return Address_Null;
                }
                return pFunc;
            }
        }
        pDynSym += view_as<Address>(0x10); // sizeof(Elf32_Sym)
    }
    
    if (bDynamicOnly)
    {
        return Address_Null;
    }
    
    // .symtab entries (not mapped in memory)
    static StringMap FuncNames;
    static StringMap ModuleProcessed;
    char sModule[PLATFORM_MAX_PATH];
    
    pFunc = Address_Null;
    
    if (FuncNames == null)
    {
        FuncNames = new StringMap();
        ModuleProcessed = new StringMap();
    }
    
    GetModulePath(pBase, sModule, sizeof(sModule));
    
    if (!GetModulePath(pBase, sModule, sizeof(sModule)))
    {
        return Address_Null;
    }
    if (!ModuleProcessed.GetValue(sModule, iType))
    {
        BinaryFile bf = new BinaryFile(sModule, FILE_READ);
        
        if (bf)
        {
            int iSymSize;
            Address pSymTab;
        
            pFirstTable           = GetFirstElfTableSect(bf);
            int iSectTableSize    = GetElfTableSectSize(bf);
            int iCountSectTable   = GetCountElfTableSect(bf);
            
            for(int x = 0; x < iCountSectTable; x++)
            {
                iStartAddress = pFirstTable + view_as<Address>(iSectTableSize * x);
                iType = bf.LoadFromAddress(iStartAddress + view_as<Address>(4), NumberType_Int32); // s_type
                
                switch(iType)
                {
                    case SHT_SYMTAB: {
                        pSymTab = bf.LoadFromAddressEx(iStartAddress + view_as<Address>(16), NumberType_Int32); // s_offset
                        iSymSize = bf.LoadFromAddress(iStartAddress + view_as<Address>(20), NumberType_Int32); // s_size
                    }
                    case SHT_STRTAB: pStrTab = bf.LoadFromAddressEx(iStartAddress + view_as<Address>(16), NumberType_Int32); // s_offset
                }
            }
            iCount = iSymSize / 0x10; // sizeof(Elf32_Sym)
            
            for(int x = 0; x < iCount; x++)
            {
                pStr = pStrTab + bf.LoadFromAddressEx(pSymTab, NumberType_Int32);
                iLenStr = bf.ReadString(pStr, sStr, sizeof sStr);
                
                /*
                if(iLen == iLenStr)
                {
                    if(!strcmp(sName, sStr))
                    {
                        pFunc = pBase + bf.LoadFromAddressEx(pSymTab + view_as<Address>(0x04), NumberType_Int32); // sym_value
                        if(pFunc == pBase)
                        {
                            pFunc = Address_Null;
                        }
                        break;
                    }
                }
                */
                
                // instead, let's precache all strings together:
                pFunc = pBase + bf.LoadFromAddressEx(pSymTab + view_as<Address>(0x04), NumberType_Int32); // sym_value
                
                if (pFunc != pBase)
                {
                    FuncNames.SetValue(sStr, pFunc);
                }
                pSymTab += view_as<Address>(0x10); // sizeof(Elf32_Sym)
            }
        }
        delete bf;
        ModuleProcessed.SetValue(sModule, 1);
    }
    FuncNames.GetValue(sName, pFunc); // let's assume that modules has no intersecting function names (for simplicity)
    return pFunc;
}
stock Address GetImportAddressLinux(Address pBase, const char[] sName )
{
    StringMap hList = LinuxParseMapsFile();
    StringMapSnapshot hSnap = hList.Snapshot();

    Address pAddress;

    char sLibrary[64];

    LibraryInfo info;

    for(int x = 0; x < hSnap.Length; x++)
    {
        hSnap.GetKey(x, sLibrary, sizeof sLibrary);
        hList.GetArray(sLibrary, info, sizeof(LibraryInfo));

        pAddress = GetProcAddressLinux(info.base, sName, true);

        if(pAddress != Address_Null)
        {
            //PrintToServer("lib %s| base 0x%X", sLibrary, info.base);
            delete hSnap;
            return pAddress;
        }
    }

    delete hSnap;
    return Address_Null;
}