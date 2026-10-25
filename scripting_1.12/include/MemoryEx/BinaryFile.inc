/*
	[Extending MemoryEx functionality]
				BinaryFile

	Author: Dragokas 			[vk.com/drago_kas | Discord: Dragokas#1453]
	Version: 					1.0
	
	01.03.2021					First release
*/

#if defined _MemoryEx_BinaryFile_include_
  #endinput
#endif
#define _MemoryEx_BinaryFile_include_

enum FILE_ACCESS
{
	FILE_READ = 1,
	FILE_WRITE = 2,
	FILE_APPEND = 4,
	FILE_OVERWRITE = 8
}

methodmap BinaryFile < File
{
    public BinaryFile(char[] path, FILE_ACCESS access)
    {
		char mode[4];
		if (access & FILE_APPEND)
		{
			if (access & FILE_READ)
			{
				mode = "ab+"; // rwa
			}
			else {
				mode = "ab"; // wa
			}
		}
		else {
			if (access & FILE_OVERWRITE)
			{
				if (access & FILE_READ)
				{
					mode = "wb+"; // rwo
				}
				else {
					mode = "wb"; // wo
				}
			}
			else {
				if (access & FILE_WRITE)
				{
					mode = "rb+"; // rw
				}
				else {
					mode = "rb"; // r
				}
			}
		}
		File file = OpenFile(path, mode);
		return view_as<BinaryFile>(file);
    }
	
    public int LoadFromAddress(Address base, NumberType size)
    {
		int data;
		if (this.Seek(view_as<int>(base), SEEK_SET))
		{
			switch(size)
			{
				case NumberType_Int32: this.ReadInt32(data);
				case NumberType_Int16: this.ReadInt16(data);
				case NumberType_Int8: this.ReadInt8(data);
			}
		}
		else {
			LogError("Cannot set file pointer to: %i", base);
		}
		return data;
	}
	
	public Address LoadFromAddressEx(Address base, NumberType size)
    {
		return view_as<Address>(this.LoadFromAddress(base, size));
	}
	
	public int StoreToAddress(Address base, int data, NumberType size)
    {
		if (this.Seek(view_as<int>(base), SEEK_SET))
		{
			switch(size)
			{
				case NumberType_Int32: this.WriteInt32(data);
				case NumberType_Int16: this.WriteInt16(data);
				case NumberType_Int8: this.WriteInt8(data);
			}
		}
		else {
			LogError("Cannot set file pointer to: %i", base);
		}
		return data;
	}
	
	public int ReadString(Address base, char[] sResult, int iMaxLength)
	{
		int x;
		int iByte;

		for(x = 0; x < iMaxLength; x++)
		{
			iByte = this.LoadFromAddress(base + view_as<Address>(x), NumberType_Int8);

			if(iByte == 0x0)
			{
				sResult[x] = '\0';
				break;
			}

			sResult[x] = iByte;
		}
		return x;
	}
	
	public int ReadUnicodeString(Address base, char[] sResult, int iMaxLength)
	{
		int iByte;
		int iOffset;

		for(int x = 0; x < iMaxLength; x+=2)
		{
			iByte = this.LoadFromAddress(base + view_as<Address>(x), NumberType_Int16);

			if(iByte == 0x0)
			{
				sResult[iOffset] = '\0';
				break;
			}

			sResult[iOffset++] = iByte % 0xFF;
		}
		return iOffset;
	}
	
	public int WriteString(Address base, const char[] sString, bool bNull = true)
	{
		int x;
		for(x = 0; x < strlen(sString) ; x++)
		{
			this.StoreToAddress(base + view_as<Address>(x), sString[x], NumberType_Int8);
		}

		if(bNull)
		{
			this.StoreToAddress(base + view_as<Address>(x), sString[x], NumberType_Int8);
		}
		return x;
	}
}