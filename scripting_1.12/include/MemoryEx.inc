/*
	[Extending opportunities to work with memory in SourcePawn]
				Memory Extended

	Author: Rostu 				[vk.com/rostu13 | Discord: Rostu#7917]
	Fork: Dragokas				[vk.com/drago_kas | Discord: Dragokas#1453]
	Version: 					3.1.11

	18.12.2019					First release [Windows Only]
	22.12.2019					Version 1.1 [Windows Only]
	19.01.2020					Version 2.0 Windows + linux [x86 only]
	20.03.2020					Version 2.5 [All Source Games]
	05.05.2020					Version 2.7 [Export/Import Tables]
	08.06.2020					Version 3.0 [malloc/free]
	20.08.2020					Version 3.1 [PatternGenerator]
	14.12.2020					Version 3.1.1 [MemoryAlloc - fix for VirtualAlloc/FreeMemory (Win)]
	29.12.2020					Version 3.1.2 [GameDataEx]
	26.02.2021					Version 3.1.3 [MemSearcher - IsValidAddress]
	02.03.2021					Version 3.1.4 [BinaryFile, Fixed GetProcAddress (Linux), new Stocks]
	07.04.2021					Version 3.1.5 Added mapping "matchmaking_ds" library to "matchmaking_ds_srv" for Linux/Mac.
	16.01.2022					Version 3.1.6:
		[ASM_Instruction.inc] Added SizeOfCode, SizeOfProc - to calculate the length of opcode instruction / procedure (thanks to Ms-Rem & The Trick).
		[ASM_Instruction.inc] Added IsRelativeCmd - to check whether JMP is relative.
		#define PTR & Pointer are deprecated (to prevent confusion with C-Pointers). Use ADDR instead.
		#define nullptr is deprecated. Use Address_Null instead.
		Added define: ADDR - to view as Address.
		Added defines: LA_8, LA_16, LA_24, LA_32 - shortcuts to load 1-4 byte size data from address.
	19.01.2022					Version 3.1.7: MemSearcher: Added "IsValidPointer", better read access check.
	18.03.2022					Version 3.1.8: Fixed "engine" library mapping.
	08.07.2022					Version 3.1.9: Fixed warnings on SM 1.11. VirtualQuery optimizations (Windows).
	06.11.2022					Version 3.1.10: Fixed "array out of bounds" in FindModuleString.
	01.02.2023					Version 3.1.11: Added "test x,x" (0x85) assembler instruction.
*/

//#define MEMORY_EX_DBG

#if defined _MemoryEx_included
 #endinput
#endif
#define _MemoryEx_included

#include <MemoryEx/ServerLibrary>
#include <MemoryEx/BaseMemory>
#include <MemoryEx/ASM_Instruction>
#include <MemoryEx/DynamicLibrary>
#include <MemoryEx/MemoryAlloc>
#include <MemoryEx/GameDataEx>
#include <MemoryEx/MemSearcher>
//#include <MemoryEx/Smx>

#if defined MEMORY_EX_DBG
#include <MemoryEx/DbgFunctions>
#endif

enum struct MemoryEx
{
	BaseMemory mem;
	DynamicLibrary lib;

	void SetAddr(any address)
	{
		this.mem.SetAddr(address);
	}
	Address GetAddr()
	{
		return this.mem.GetAddr();
	}
    void Add(any iOffset)
	{
		this.mem.Add(iOffset);
	}
	int ReadByte(int iOffset = 0)
	{
		return this.mem.ReadByte(iOffset);
	}
	void WriteByte(any iByte, int iOffset = 0,  int flags = MemoryEx_NoNeedAdd)
	{
		this.mem.WriteByte(iByte, iOffset, flags);
	}
	int ReadWord(int iOffset = 0)
	{
		return this.mem.ReadWord(iOffset);
	}
	void WriteWord(any iWord, int iOffset = 0,  int flags = MemoryEx_NoNeedAdd)
	{
		this.mem.WriteWord(iWord, iOffset, flags);
	}
	int ReadInt	(int iOffset = 0)
	{
		return this.mem.ReadInt(iOffset);
	}
	void WriteInt(any iNumber, int iOffset = 0, int flags = MemoryEx_NoNeedAdd)
	{
		this.mem.WriteInt(iNumber, iOffset, flags);
	}
	void WriteData(const int[] data, int iSize, int flags = MemoryEx_NoNeedAdd)
	{
		this.mem.WriteData(data, iSize, flags);
	}
	int ReadString(char[] sString, int iMaxLength)
	{
		return this.mem.ReadString(sString, iMaxLength);
	}
	void WriteString(const char[] sString, bool bNull = true, int flags = MemoryEx_NoNeedAdd)
	{
		this.mem.WriteString(sString, bNull, flags);
	}
	void WriteUnicodeString(const char[] sString, bool bNull = true, int flags = MemoryEx_NoNeedAdd)
	{
		this.mem.WriteUnicodeString(sString, bNull, flags);
	}

	//dynamic library
	StringMap GetListLibraries()
	{
		return this.lib.GetListLibraries();
	}
	Address GetModuleHandle(const char[] sName)
	{
		return this.lib.GetModuleHandle(sName);
	}
	any GetModuleSize(const char[] sName)
	{
		return this.lib.GetModuleSize(sName);
	}
	Address GetEndModule(const char[] sName)
	{
		return this.lib.GetEndModule(sName);
	}
	Address GetProcAddress(const char[] sLibrary, const char[] sName)
	{
		return this.lib.GetProcAddress(sLibrary, sName);
	}
	Address GetImportAddress(const char[] sLibrary, const char[] sName)
	{
		return this.lib.GetImportAddress(sLibrary, sName);
	}
	int FindModule(const char[] sModule, char[] sResult, int iMaxLength)
	{
		return this.lib.FindModule(sModule, sResult, iMaxLength);
	}
	Address FindPattern(const char[] sModule, const int[] sPattern, int iLength, int iOffset = 0)
	{
		return this.lib.FindPattern(sModule, sPattern, iLength, iOffset);
	}
	Address FindString(const char[] sModule, const char[] sString)
	{
		return this.lib.FindString(sModule, sString);
	}
	ArrayList FindAllStrings(const char[] sModule, const char[] sString)
	{
		return this.lib.FindAllStrings(sModule, sString);
	}
	Address FindUnicodeString(const char[] sModule, const char[] sString)
	{
		return this.lib.FindUnicodeString(sModule, sString);
	}
	Address FindValue(const char[] sModule, any iValue, int iNextByte = 0x2A )
	{
		return this.lib.FindValue(sModule, iValue, iNextByte);
	}
	Address FindValueEx(const char[] sModule, any iValue, const int[] iPattern, int iSize)
	{
		return this.lib.FindValueEx(sModule, iValue, iPattern, iSize);
	}
}

stock MemoryEx g_hMem;