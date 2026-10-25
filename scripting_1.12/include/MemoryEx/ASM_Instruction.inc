
#if defined _MemoryEx_ASM_Instruction_include_
  #endinput
#endif
#define _MemoryEx_ASM_Instruction_include_


#include <MemoryEx/BaseMemory>
#include <MemoryEx/Ldasm>


enum ASMRegister
{
	ASMRegister_EAX,
	ASMRegister_ECX,
	ASMRegister_EDX,
	ASMRegister_EBX,
	ASMRegister_ESP,
	ASMRegister_EBP,
	ASMRegister_ESI,
	ASMRegister_EDI
}

enum struct ASMInstructions
{
	BaseMemory mem;

	void Set(Address adr)
	{
		this.mem.pAddrBase = adr;
	}
	Address Get()
	{
		return this.mem.pAddrBase;
	}
	int SizeOfCode(any offset = 0)
	{
		return ASM_SizeOfCode(this.mem.pAddrBase + offset);
	}
	int SizeOfProc(any offset = 0)
	{
		return ASM_SizeOfProc(this.mem.pAddrBase + offset);
	}
	bool IsRelativeCmd(any offset = 0)
	{
		return ASM_IsRelativeCmd(this.mem.pAddrBase + offset);
	}
	void PushRegister(ASMRegister reg)
	{
		this.mem.WriteByte(0x50 + view_as<int>(reg), 	_, 	MemoryEx_AddAfterWrite);
	}
	void Push(any value)
	{
		this.mem.WriteByte(0x68, 	_, 	MemoryEx_AddAfterWrite);
		this.mem.WriteInt(value,	_, 	MemoryEx_AddAfterWrite);
	}
	void PopRegister(ASMRegister reg)
	{
		this.mem.WriteByte(0x58 + view_as<int>(reg), 	_, 	MemoryEx_AddAfterWrite);
	}
	void Call(any value)
	{
		this.mem.WriteWord(0x15FF, 	_, MemoryEx_AddAfterWrite);
		this.mem.WriteInt(value,	_, 	MemoryEx_AddAfterWrite);
	}
	void Test(ASMRegister reg)
	{
		switch (reg)
		{
			case ASMRegister_EAX: this.mem.WriteWord(0xC085, 	_, MemoryEx_AddAfterWrite);
			case ASMRegister_ECX: this.mem.WriteWord(0xC985, 	_, MemoryEx_AddAfterWrite);
			case ASMRegister_EDX: this.mem.WriteWord(0xD285, 	_, MemoryEx_AddAfterWrite);
			case ASMRegister_EBX: this.mem.WriteWord(0xDB85, 	_, MemoryEx_AddAfterWrite);
			case ASMRegister_ESP: this.mem.WriteWord(0xE485, 	_, MemoryEx_AddAfterWrite);
			case ASMRegister_EBP: this.mem.WriteWord(0xED85, 	_, MemoryEx_AddAfterWrite);
			case ASMRegister_ESI: this.mem.WriteWord(0xF685, 	_, MemoryEx_AddAfterWrite);
			case ASMRegister_EDI: this.mem.WriteWord(0xFF85, 	_, MemoryEx_AddAfterWrite);
		}
	}
	void Nop()
	{
		this.mem.WriteByte(0x90, 	_, 	MemoryEx_AddAfterWrite);
	}
	void Xchg(ASMRegister reg)
	{
		this.mem.WriteByte(0x90 + view_as<int>(reg), 	_, 	MemoryEx_AddAfterWrite);
	}
	void Retn()
	{
		this.mem.WriteByte(0xC3,	_,	MemoryEx_AddAfterWrite);
	}
}

stock ASMInstructions g_ASM;

#define ASM g_ASM

#define ASMHELP_SET(%0)			g_ASM.Set(%0)
#define ASMHELP_GET()			g_ASM.Get()
#define PUSH_REGISTER(%0) 		g_ASM.PushRegister(ASMRegister_%0)
#define PUSH(%0) 				g_ASM.Push(%0)
#define POP_REGISTER(%0) 		g_ASM.PopRegister(ASMRegister_%0)
#define CALL(%0) 				g_ASM.Call(%0)
#define ASM_TEST(%0) 			g_ASM.Test(ASMRegister_%0)
#define NOP() 					g_ASM.Nop()
#define XCHG(%0) 				g_ASM.Xchg(ASMRegister_%0)
#define RETN() 					g_ASM.Retn()