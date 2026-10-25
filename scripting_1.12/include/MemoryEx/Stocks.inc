
#if defined _MemoryEx_Stocks_include_
  #endinput
#endif
#define _MemoryEx_Stocks_include_

#define LA_8(%0) Deref(%0, NumberType_Int8)
#define LA_16(%0) Deref(%0, NumberType_Int16)
#define LA_24(%0) LoadFromAddressInt24(%0)
#define LA_32(%0) Deref(%0, NumberType_Int32)


stock any ASMSDKCall(Address base)
{
    StartPrepSDKCall(SDKCall_Static);
    PrepSDKCall_SetAddress(base);
    PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
    
    Handle h = EndPrepSDKCall();
    any res = SDKCall(h);

    delete h;
    return res;
}
stock int Deref(any Addr, NumberType size = NumberType_Int32)
{
	if( Addr )
	{
		return LoadFromAddress(view_as<Address>(Addr), size);
	}
	return 0;
}
stock Address DerefEx(any Addr)
{
	if( Addr )
	{
		return view_as<Address>(LoadFromAddress(Addr, NumberType_Int32));
	}
	return Address_Null;
}
stock Address LoadFromAddressEx(any base, NumberType size)
{
	return view_as<Address>(LoadFromAddress(base, size));
}
stock int LoadFromAddressInt24(any base)
{
	int iByte[3];
	iByte[0] = LoadFromAddress(base, NumberType_Int8);
	iByte[1] = LoadFromAddress(base + view_as<Address>(1), NumberType_Int8);
	iByte[2] = LoadFromAddress(base + view_as<Address>(2), NumberType_Int8);
	return iByte[0] + (iByte[1] << 8) + (iByte[2] << 16);
}
stock void StoreToAddressArray(Address base, int[] data, int iSize)
{
	for( int i = 0; i < iSize; i++ )
	{
		StoreToAddress(base + view_as<Address>(i), data[i], NumberType_Int8);
	}
	// alternate:	g_hMem.SetAddr(base); 	g_hMem.WriteData(data, iSize);
}
stock int GetByte(int iNum32, int iByteIndex)
{
	int ret;
	switch( iByteIndex )
	{
		case 1: { ret = (iNum32 & 0xFF); }
		case 2: { ret = (iNum32 & 0xFF00) >> 8; }
		case 3: { ret = (iNum32 & 0xFF0000) >> 16; }
		case 4: { ret = (iNum32 & 0xFF000000) >> 24; }
	}
	return ret;
}
stock void ArrayPushDword(int[] array, int &index, int data)
{
	array[index++] = GetByte(data, 1);
	array[index++] = GetByte(data, 2);
	array[index++] = GetByte(data, 3);
	array[index++] = GetByte(data, 4);
}
stock int ReadString(Address base, char[] sResult, int iMaxLength)
{
    int x;
    int iByte;

    for(x = 0; x < iMaxLength; x++)
    {
        iByte = LoadFromAddress(base + view_as<Address>(x), NumberType_Int8);

        if(iByte == 0x0)
        {
            sResult[x] = '\0';
            break;
        }

        sResult[x] = iByte;
    }
    return x;
}
stock int ReadUnicodeString(Address base, char[] sResult, int iMaxLength)
{
    int iByte;
    int iOffset;

    for(int x = 0; x < iMaxLength; x+=2)
    {
        iByte = LoadFromAddress(base + view_as<Address>(x), NumberType_Int16);

        if(iByte == 0x0)
        {
            sResult[iOffset] = '\0';
            break;
        }

        sResult[iOffset++] = iByte % 0xFF;
    }

    return iOffset;
}
stock int WriteString(Address base, const char[] sString, bool bNull = true)
{
    int x;
    for(x = 0; x < strlen(sString) ; x++)
    {
        StoreToAddress(base + view_as<Address>(x), sString[x], NumberType_Int8);
    }
    if(bNull)
    {
        StoreToAddress(base + view_as<Address>(x), sString[x], NumberType_Int8);
    }
    return x;
}
stock Address FindModuleString(Address base, any size, const char[] sString)
{
    int iLength = strlen(sString);
    int[] pattern = new int[iLength+1];

    for(int x = 0; x < iLength; x++)
    {
        pattern[x] = sString[x];
    }

    return FindPattern(base, size, pattern, iLength);
}
stock Address FindUnicodeModuleString(Address base, any size, const char[] sString)
{
    int iLength = strlen(sString) * 2 ;
    int[] pattern = new int[iLength];
    int index;

    for(int x = 0; x < iLength; x += 2)
    {
        pattern[x] = sString[index];
        pattern[x + 1] = 0x00;
        index++;
    }

    return FindPattern(base, size, pattern, iLength);
}
stock ArrayList FindAllStrings(Address base, any size, const char[] sValue)
{
    ArrayList res = new ArrayList();

    Address addr;

    int iLength = strlen(sValue);
    int[] pattern = new int[iLength];

    for(int x = 0; x < strlen(sValue); x++)
    {
        pattern[x] = sValue[x];
    }

    //LogError("FindAllStrings start [0x%X] [%d]", base, size);

    while((addr = FindPattern(base, size, pattern, iLength)) != Address_Null)
    {
        size -= view_as<int>(addr - base) + iLength;
        base += addr - base + view_as<Address>(iLength);

        // size 13
        // base 4 length 4 start 8 size 6
        //
        // 0x00 0x00 0x00 0xFF 0xFF 0xFF 0xFF 0x00 0x00 0xFF 0xFF 0xFF 0xFF
        // 0                3                   7
        //LogError("FindAllStrings next [0x%X] [%d]", base, size);

        res.Push(addr);
    }

    return res;
}
stock Address FindValue(Address base, any size, any iValue, const int[] iHelpBytes, int iSize)
{
    int[] pattern = new int[4 + iSize];

    pattern[0] = iValue 		& 0xFF;
    pattern[1] = (iValue >> 8) 	& 0xFF;
    pattern[2] = (iValue >> 16) & 0xFF;
    pattern[3] = (iValue >> 24) & 0xFF;

    for(int x = 0; x < iSize; x++)
    {
        pattern[4 + x] = iHelpBytes[x];
    }

    //PrintToServer("FindValue pattern 0x%X 0x%X 0x%X 0x%X 0x%X", pattern[0], pattern[1], pattern[2], pattern[3], pattern[4] );
    // 0x55 0x66 0x55 = 3
    // 4 = 0x55 5 = 0x66 7 = 0x55

    char sBuffer[128];
    for(int x = 0; x < 4 + iSize; x++)
    {
        Format(sBuffer, sizeof sBuffer, "%s 0x%X", sBuffer, pattern[x]);
    }

    return FindPattern(base, size, pattern, 3 + iSize); // 4 + iSize - 1
}
stock void DumpOnAddress(Address addr, int len, int columns = 10)
{
    char buff[128];

    LogError("----------------------DumpOnAddress----------------------");
    Format(buff, sizeof(buff), "[0x%08X]", addr);
    for(int i = 0; i < len; i++)
    {
        Format(buff, sizeof(buff), "%s %02X", buff, LoadFromAddress(addr + view_as<Address>(i), NumberType_Int8));
        if(i % columns == columns - 1)
        {
            LogError("%s", buff);
            Format(buff, sizeof(buff), "[0x%08X]", addr + view_as<Address>(i));
        }
    }

    if((len - 1) % columns != columns - 1)
        LogError("%s", buff);

    LogError("---------------------EndDumpOnAddress---------------------");
}
stock Address FindPattern(Address base, any size, const int[] pattern, int iLength, int iOffset = 0)
{
    Address addr; // default = nullptr
    Address end = base + view_as<Address>(size);

    //PrintToServer("FindPattern base 0x%X size 0x%X", base, size);

    int iByte;
    bool found;

    while(base < end)
    {
        iByte = LoadFromAddress(base, NumberType_Int8);

        if(iByte == pattern[0])
        {
            found = true;

            for(int x = 1; x < iLength; x++)
            {
                if(pattern[x] != 0x2A)
                { 
                    iByte = LoadFromAddress(base + view_as<Address>(x), NumberType_Int8);

                    if(iByte != pattern[x])
                    {
                        found = false;
                        break;
                    }
                }
            }

            if(found)
            {
                addr = base + view_as<Address>(iOffset);
                break;
            }
        }

        base++;
    }

    return addr;
}
/*
    4D 5A 90 00 03 00 00 00 04 00 00 00 FF FF 00 00 B8 00 00 00 00 00 00 00 40 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
    00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 50 01 00 00 56 4C 56 00 01 00 00 00 00 82 61 00 E9 D2 46 5F 
    4C 4B 49 C2 06 85 A1 32 BD D2 A3 63 90 C9 3C D1 3F B8 C4 00 1E 7E 79 D2 7A 5E 31 9C F6 EC FE 52 7A 87 11 AA 19 9F C0 9F

    FindPattern finds pattern from                      Address end: StartRegion + Size
    FindBackPattern finds the required pattern using    Address end: EndRegion - Size
    Address pPattern = FindBackPattern(GetModuleEnd("engine"), GetModuleSize("engine"), {0x4D, 0x5A, 0x90, 0x00, 0x03}, 5);
*/
stock Address FindBackPattern(Address base, any size, const int[] pattern, int iLength, int iOffset = 0)
{
    Address addr;
    Address end = base - view_as<Address>(size);

    int iByte;
    Address offsetByte;
    bool found;

    //LogError("FindBackPattern base 0x%X, size 0x%X, end 0x%X Length %d", base, size, end, iLength);

    while(base >= end)
    {
        iByte = LoadFromAddress(base, NumberType_Int8);
        //LogError("FirstByte 0x%X|0x%X", iByte, pattern[iLength - 0x01]);

        if(iByte == pattern[iLength - 0x01])
        {
            found = true;
            offsetByte = view_as<Address>(0x01);

            for(int x = iLength - 0x02; x >= 0; x--, offsetByte++)
            {
                //LogError("NextByte req byte [%d][0x%X] | Read [0x%X] byte [x%X] offset [%d]", x, pattern[x], base - view_as<Address>(offsetByte), LoadFromAddress(base - view_as<Address>(offsetByte), NumberType_Int8), offsetByte);
                if(pattern[x] != 0x2A)
                { 
                    iByte = LoadFromAddress(base - view_as<Address>(offsetByte), NumberType_Int8);

                    if(iByte != pattern[x])
                    {
                        found = false;
                        break;
                    }
                }
            }

            if(found)
            {
                addr = base + view_as<Address>(-iLength + 0x01 + iOffset);
                break;
            }
        }

        base--;
    }

    return addr;
}
stock Address FindFreeMemory(Address base, any size, any iLength)
{
    if(!iLength || iLength >= size)
    {
        return Address_Null;
    }

    NumberType type = (iLength % 4 == 0) ? NumberType_Int32 : (iLength % 2 == 0) ? NumberType_Int16 : NumberType_Int8;
    any iOffset = type == NumberType_Int32 ? 4 : type == NumberType_Int16 ?  2 : 1;
    int iCount = iLength / iOffset;

    // iLength = 8
    // iCount = 2
    // iLength = 6
    // iCount = 3

    /*  Example: iOffset = 4.                    ↓ <= base + iSize, but if you try read int [4 byte] => server will crash
        0x00 0x00 0x22 0x50 0x00 0x00 0x00 0x00 0x00 0x?? 0x??
        base + size - iOffset ↓                   ↓ but you lost last byte  
        0x00 0x00 0x22 0x50 0x00 0x00 0x00 0x00 0x00 0x?? 0x??
        base + size - iOffset + 1  ↓ - Now everything is correct and you aren't losing anything :)
        0x00 0x00 0x22 0x50 0x00 0x00 0x00 0x00 0x00 0x?? 0x??

    */

    Address end = base + view_as<Address>(size - iOffset + 1);

    int iByte;
    Address iMove;

    while(end >= base + iLength)
    {
        bool bFind = true;
        for(int x = 0; x < iCount; x++)
        {
            iMove = view_as<Address>(iOffset + 1 - (x * iOffset)); // view_as<Address>(iOffset + 1 - (x * iOffset))
            iByte = LoadFromAddress(end + iMove, type);

            //PrintToServer("adr [0x%X] x [%d] length [%d] offset [%d] count [%d] byte = 0x%X", end + iMove, x, iLength, iOffset, iCount, iByte);

            if(iByte != 0x000000)
            {
                bFind = false;
                break;
            }
        }

        if(bFind)
        {
            return end + iMove;
        }

        end -= iOffset;
    }

    return Address_Null;
}
stock int HexToDec(const char[] hex)
{
    int i, result, value;
    while((value = IsHexSymbol(hex[i++])) != -1)
    {
        result = result * 16 + value;
    }
    return result;
}
stock int IsHexSymbol(int ch)
{
    if(!ch)
        return -1;
    
    if('0' <= ch && ch <= '9')
        return ch - '0';
    
    ch &= ~0x20;
    if('A' <= ch && ch <= 'F')
        return ch - 'A' + 10;
    
    return -1;
}
stock bool StrContainsEx(const char[] sStr, const char[] sSubStr)
{
    int iLen = strlen(sStr);
    int iSubLen = strlen(sSubStr);

    if(iLen < iSubLen)
    {
        return false;
    }

    for(int x = 0; x < iSubLen; x++)
    {
        if(sStr[x] != sSubStr[x])
        {
            return false;
        }
    }
    return true;
}