#if defined _MemoryEx_Dynamic_Library_include_
  #endinput
#endif
#define _MemoryEx_Dynamic_Library_include_

#include <MemoryEx/ServerLibrary>
#include <MemoryEx/BaseMemory>
#include <MemoryEx/ASM_Instruction>

enum struct DynamicLibrary
{
    BaseMemory mem;
	
	StringMap GetListLibraries()
	{
		return GetListLibraries();
	}
	Address GetModuleHandle(const char[] sName)
	{
		return GetModuleHandle(sName);
	}
	any GetModuleSize(const char[] sName)
	{
		return GetModuleSize(sName);
	}
	Address GetEndModule(const char[] sName)
	{
		return GetModuleEnd(sName);
	}
    Address GetProcAddress(const char[] sLibrary, const char[] sName)
	{
		return GetProcAddress(sLibrary, sName);
	}
	Address GetImportAddress(const char[] sLibrary, const char[] sName)
	{
		return GetImportAddress(sLibrary, sName);
	}
	int FindModule(const char[] sModule, char[] sResult, int iMaxLength)
	{
		return FindModule(sModule, sResult, iMaxLength);
	}
	Address FindPattern(const char[] sModule, const int[] sPattern, int iLength, int iOffset = 0)
	{
		ModuleInfo info;

		info.base = this.GetModuleHandle(sModule);
		info.size = this.GetModuleSize(sModule);

		if(info.base == nullptr) return nullptr;

		return FindPattern(info.base, info.size, sPattern, iLength, iOffset);
	}
	Address FindString(const char[] sModule, const char[] sString)
	{
		ModuleInfo info;
		
		info.base = this.GetModuleHandle(sModule);
		info.size = this.GetModuleSize(sModule);

		//PrintToServer("DynamicLibrary::findString sModule %s base [0x%X] size [0x%X] str = %s", sModule, info.base, info.size, sString);

		if(info.base == nullptr) return nullptr;

		return FindModuleString(info.base, info.size, sString);
	}
	ArrayList FindAllStrings(const char[] sModule, const char[] sString)
	{
		ModuleInfo info;
		
		info.base = this.GetModuleHandle(sModule);
		info.size = this.GetModuleSize(sModule);

		if(info.base == nullptr) return new ArrayList();

		return FindAllStrings(info.base, info.size, sString);
	}
	Address FindUnicodeString(const char[] sModule, const char[] sString)
	{
		ModuleInfo info;

		info.base = this.GetModuleHandle(sModule);
		info.size = this.GetModuleSize(sModule);

		if(info.base == nullptr) return nullptr;

		return FindUnicodeModuleString(info.base, info.size, sString);
	}
	Address FindValue(const char[] sModule, any iValue, int iNextByte = 0x2A ) // iNextByte - to help
	{
		ModuleInfo info;

		info.base = this.GetModuleHandle(sModule);
		info.size = this.GetModuleSize(sModule);

		if(info.base == nullptr) return nullptr;

		int pattern[8]; // pattern[5] auto to pattern[8];

		pattern[0] = iValue 		& 0xFF;
		pattern[1] = (iValue >> 8) 	& 0xFF;
		pattern[2] = (iValue >> 16) & 0xFF;
		pattern[3] = (iValue >> 24) & 0xFF;
		pattern[4] = iNextByte;

		return FindPattern(info.base, info.size, pattern, 5);
	}
	Address FindValueEx(const char[] sModule, any iValue, const int[] iPattern, int iSize)
	{
		ModuleInfo info;

		info.base = this.GetModuleHandle(sModule);
		info.size = this.GetModuleSize(sModule);

		if(info.base == nullptr) return nullptr;

		return FindValue(info.base, info.size, iValue, iPattern, iSize);
	}
}