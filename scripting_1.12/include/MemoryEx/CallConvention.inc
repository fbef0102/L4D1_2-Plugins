#if defined _MemoryEx_CallConvention_include_
  #endinput
#endif
#define _MemoryEx_CallConvention_include_



enum ParamTypeEx
{
    ParamEx_Cell,
    ParamEx_CellByRef,
    ParamEx_String
}
enum struct ParamInfo
{
    ParamTypeEx type;
    any value;
}
enum struct cdecl //base
{
    BaseMemory mem;
    
    ArrayList hArgs;
    ParamInfo info;

    void Init()
    {
        if(this.hArgs != null) this.hArgs.Close();
        this.hArgs = new ArrayList();
    }

    void Push(any data)
    {
        this.info.type = ParamEx_Cell;
        this.info.value = data;

        this.hArgs.PushArray(this.info, sizeof(ParamInfo));
    }

    void PushString(Address str)
    {
        this.info.type = ParamEx_String;
        this.info.value = str;

        this.hArgs.PushArray(this.info, sizeof(ParamInfo));
    }
    void PushStringEx(const char[] sStr)
    {

    }
    void CreateProlog()
    {

    }
    
}
