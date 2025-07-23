//#include "stdafx.h"
#include "common_define.h"


const unsigned short CRCTable[] =
{
0x0000, 0xC1C0, 0x81C1, 0x4001, 0x01C3, 0xC003, 0x8002, 0x41C2, 0x01C6, 0xC006, 0x8007, 0x41C7,
0x0005, 0xC1C5, 0x81C4, 0x4004, 0x01CC, 0xC00C, 0x800D, 0x41CD, 0x000F, 0xC1CF, 0x81CE, 0x400E,
0x000A, 0xC1CA, 0x81CB, 0x400B, 0x01C9, 0xC009, 0x8008, 0x41C8, 0x01D8, 0xC018, 0x8019, 0x41D9,
0x001B, 0xC1DB, 0x81DA, 0x401A, 0x001E, 0xC1DE, 0x81DF, 0x401F, 0x01DD, 0xC01D, 0x801C, 0x41DC,
0x0014, 0xC1D4, 0x81D5, 0x4015, 0x01D7, 0xC017, 0x8016, 0x41D6, 0x01D2, 0xC012, 0x8013, 0x41D3,
0x0011, 0xC1D1, 0x81D0, 0x4010, 0x01F0, 0xC030, 0x8031, 0x41F1, 0x0033, 0xC1F3, 0x81F2, 0x4032,
0x0036, 0xC1F6, 0x81F7, 0x4037, 0x01F5, 0xC035, 0x8034, 0x41F4, 0x003C, 0xC1FC, 0x81FD, 0x403D,
0x01FF, 0xC03F, 0x803E, 0x41FE, 0x01FA, 0xC03A, 0x803B, 0x41FB, 0x0039, 0xC1F9, 0x81F8, 0x4038,
0x0028, 0xC1E8, 0x81E9, 0x4029, 0x01EB, 0xC02B, 0x802A, 0x41EA, 0x01EE, 0xC02E, 0x802F, 0x41EF,
0x002D, 0xC1ED, 0x81EC, 0x402C, 0x01E4, 0xC024, 0x8025, 0x41E5, 0x0027, 0xC1E7, 0x81E6, 0x4026,
0x0022, 0xC1E2, 0x81E3, 0x4023, 0x01E1, 0xC021, 0x8020, 0x41E0, 0x01A0, 0xC060, 0x8061, 0x41A1,
0x0063, 0xC1A3, 0x81A2, 0x4062, 0x0066, 0xC1A6, 0x81A7, 0x4067, 0x01A5, 0xC065, 0x8064, 0x41A4,
0x006C, 0xC1AC, 0x81AD, 0x406D, 0x01AF, 0xC06F, 0x806E, 0x41AE, 0x01AA, 0xC06A, 0x806B, 0x41AB,
0x0069, 0xC1A9, 0x81A8, 0x4068, 0x0078, 0xC1B8, 0x81B9, 0x4079, 0x01BB, 0xC07B, 0x807A, 0x41BA,
0x01BE, 0xC07E, 0x807F, 0x41BF, 0x007D, 0xC1BD, 0x81BC, 0x407C, 0x01B4, 0xC074, 0x8075, 0x41B5,
0x0077, 0xC1B7, 0x81B6, 0x4076, 0x0072, 0xC1B2, 0x81B3, 0x4073, 0x01B1, 0xC071, 0x8070, 0x41B0,
0x0050, 0xC190, 0x8191, 0x4051, 0x0193, 0xC053, 0x8052, 0x4192, 0x0196, 0xC056, 0x8057, 0x4197,
0x0055, 0xC195, 0x8194, 0x4054, 0x019C, 0xC05C, 0x805D, 0x419D, 0x005F, 0xC19F, 0x819E, 0x405E,
0x005A, 0xC19A, 0x819B, 0x405B, 0x0199, 0xC059, 0x8058, 0x4198, 0x0188, 0xC048, 0x8049, 0x4189,
0x004B, 0xC18B, 0x818A, 0x404A, 0x004E, 0xC18E, 0x818F, 0x404F, 0x018D, 0xC04D, 0x804C, 0x418C,
0x0044, 0xC184, 0x8185, 0x4045, 0x0187, 0xC047, 0x8046, 0x4186, 0x0182, 0xC042, 0x8043, 0x4183,
0x0041, 0xC181, 0x8180, 0x4040
};


void DoubleToBuf(unsigned char* Buf, double* DoubleVal)
{          
	unsigned char *ptr = (unsigned char *)DoubleVal;
#ifdef __ARM
	Buf[0]=ptr[4];
	Buf[1]=ptr[5];
	Buf[2]=ptr[6];
	Buf[3]=ptr[7];
	Buf[4]=ptr[0];
	Buf[5]=ptr[1];
	Buf[6]=ptr[2];
	Buf[7]=ptr[3];
#else
	Buf[0]=ptr[0];
	Buf[1]=ptr[1];
	Buf[2]=ptr[2];
	Buf[3]=ptr[3];
	Buf[4]=ptr[4];
	Buf[5]=ptr[5];
	Buf[6]=ptr[6];
	Buf[7]=ptr[7];
#endif
}

void BufToDouble(double* DoubleVal, unsigned char* Buf)
{ 
	unsigned char *ptr = (unsigned char *)DoubleVal;
#ifdef __ARM
	ptr[4]=Buf[0];
	ptr[5]=Buf[1];
	ptr[6]=Buf[2];
	ptr[7]=Buf[3];
	ptr[0]=Buf[4];
	ptr[1]=Buf[5];
	ptr[2]=Buf[6];
	ptr[3]=Buf[7];
#else
	ptr[0]=Buf[0];
	ptr[1]=Buf[1];
	ptr[2]=Buf[2];
	ptr[3]=Buf[3];
	ptr[4]=Buf[4];
	ptr[5]=Buf[5];
	ptr[6]=Buf[6];
	ptr[7]=Buf[7];
#endif
}

     
void LongToBuf(unsigned char* Buf, int* LongVal)
{            
	unsigned char *ptr = (unsigned char *)LongVal;
	Buf[0]=ptr[0];
	Buf[1]=ptr[1];
	Buf[2]=ptr[2];
	Buf[3]=ptr[3];
}
void BufToLong(int* LongVal, unsigned char* Buf)
{
	unsigned char *ptr = (unsigned char *)LongVal;
	ptr[0]=Buf[0];
	ptr[1]=Buf[1];
	ptr[2]=Buf[2];
	ptr[3]=Buf[3];
}


void ShortToBuf(unsigned char* Buf, short* ShortVal)
{             
	unsigned char *ptr = (unsigned char *)ShortVal;
	Buf[0]=ptr[0];
	Buf[1]=ptr[1];
}
void BufToShort(short* ShortVal, unsigned char* Buf)
{ 
	unsigned char *ptr = (unsigned char *)ShortVal;
	ptr[0]=Buf[0];
	ptr[1]=Buf[1];
}




//=======================================================================
unsigned short CRC_16(unsigned char *Data, unsigned int Size)
{
   unsigned short  CRCHi = 0x00FF;
   unsigned short  CRCLo = 0x00FF;
   unsigned short  Index;

   while (Size --)
   {
      Index = CRCLo ^ *Data++;
      CRCLo = CRCHi ^ (CRCTable[Index] >> 8);
      CRCHi = (CRCTable[Index] & 0x00FF);
   }

   return ((CRCHi << 8) | (CRCLo & 0x00FF));
}


//=======================================================================
unsigned char CheckCRC( unsigned char *data, unsigned int size )
{
    unsigned short crc,chk_crc;
    crc = CRC_16(data,size-2);
    chk_crc = (data[size-1] << 8) | (data[size-2] & 0xff);
    if(crc==chk_crc)
        return 1;
    else
        return 0;
}


//====================== 加密 ===========================
void CrcEncrypt(unsigned short *Crc16, unsigned char *Input, unsigned char *Output, unsigned int Len)
{
    unsigned char TmpOutL, TmpOutH, TmpInput;
    while (Len>0)
    {
        TmpInput=*Input&0x0F;
        TmpOutL=(*Crc16^TmpInput)&0x0F;
        *Crc16=(*Crc16>>4)^(TmpOutL*0x1081);
        TmpInput=(*Input>>4)&0x0F;
        TmpOutH=(*Crc16^TmpInput)&0x0F;
        *Crc16=(*Crc16>>4)^(TmpOutH*0x1081);
        *Output=(TmpOutH<<4)|TmpOutL;
        Input++;
        Output++;
        Len--;
    }
}


//====================== 解密 ===========================
void CrcDecrypt(unsigned short *Crc16, unsigned char *Input, unsigned char *Output, unsigned int Len)
{
    unsigned char TmpOutL, TmpOutH, TmpInput;
    while (Len>0)
    {
        TmpInput=*Input&0x0F;
        TmpOutL=(*Crc16^TmpInput)&0x0F;
        *Crc16=(*Crc16>>4)^(TmpInput*0x1081);
        TmpInput=(*Input>>4)&0x0F;
        TmpOutH=(*Crc16^TmpInput)&0x0F;
        *Crc16=(*Crc16>>4)^(TmpInput*0x1081);
        *Output=(TmpOutH<<4)|TmpOutL;
        Input++;
        Output++;
        Len--;
    }
}



//====================== 反向加密 ===========================
void CrcEncrypt_rev(unsigned short *Crc16, unsigned char *Input, unsigned char *Output, unsigned int Len)
{
    unsigned char TmpOutL, TmpOutH, TmpInput;
    Input+=Len;
    Output+=Len;
    while (Len>0)
    {       
        Input--;
        Output--;
        TmpInput=*Input&0x0F;
        TmpOutL=(*Crc16^TmpInput)&0x0F;
        *Crc16=(*Crc16>>4)^(TmpOutL*0x1081);
        TmpInput=(*Input>>4)&0x0F;
        TmpOutH=(*Crc16^TmpInput)&0x0F;
        *Crc16=(*Crc16>>4)^(TmpOutH*0x1081);
        *Output=(TmpOutH<<4)|TmpOutL;
        Len--;
    }
}


//====================== 反向解密 ===========================
void CrcDecrypt_rev(unsigned short *Crc16, unsigned char *Input, unsigned char *Output, unsigned int Len)
{
    unsigned char TmpOutL, TmpOutH, TmpInput;
    Input+=Len;
    Output+=Len;
    while (Len>0)
    {
        Input--;
        Output--;
        TmpInput=*Input&0x0F;
        TmpOutL=(*Crc16^TmpInput)&0x0F;
        *Crc16=(*Crc16>>4)^(TmpInput*0x1081);
        TmpInput=(*Input>>4)&0x0F;
        TmpOutH=(*Crc16^TmpInput)&0x0F;
        *Crc16=(*Crc16>>4)^(TmpInput*0x1081);
        *Output=(TmpOutH<<4)|TmpOutL;
        Len--;
    }
}


//====================== 加強式 加密 ===========================
void CrcEncrypt_adv(unsigned int Key, unsigned char *Input, unsigned char *Output, unsigned int n)
{
    unsigned char TmpOutL, TmpOutH, TmpInput;
    unsigned int Len;
    unsigned short *pKey = (unsigned short *)&Key;
    unsigned short *Crc16;

    //----正向加密
    Len = n;
    Crc16 = pKey;
    while (Len>0)
    {
        TmpInput=*Input&0x0F;
        TmpOutL=(*Crc16^TmpInput)&0x0F;
        *Crc16=(*Crc16>>4)^(TmpOutL*0x1081);
        TmpInput=(*Input>>4)&0x0F;
        TmpOutH=(*Crc16^TmpInput)&0x0F;
        *Crc16=(*Crc16>>4)^(TmpOutH*0x1081);
        *Output=(TmpOutH<<4)|TmpOutL;
        Input++;
        Output++;
        Len--;
    }
    Input-=n;
    Output-=n;
    memcpy(Input, Output, n);
    //---反向加密
    Input+=n;
    Output+=n;
    Len = n;
    Crc16 = pKey+1;
    while (Len>0)
    {
        Input--;
        Output--;
        TmpInput=*Input&0x0F;
        TmpOutL=(*Crc16^TmpInput)&0x0F;
        *Crc16=(*Crc16>>4)^(TmpOutL*0x1081);
        TmpInput=(*Input>>4)&0x0F;
        TmpOutH=(*Crc16^TmpInput)&0x0F;
        *Crc16=(*Crc16>>4)^(TmpOutH*0x1081);
        *Output=(TmpOutH<<4)|TmpOutL;
        Len--;
    }
    memcpy(Input, Output, n);

    //補上加密檢核碼
    memcpy(Output+n, (char *)pKey, 4);
}


//====================== 加強式 解密 ===========================
char CrcDecrypt_adv(unsigned int Key, unsigned char *Input, unsigned char *Output, unsigned int n)
{
    unsigned char TmpOutL, TmpOutH, TmpInput;
    unsigned int Len;
    unsigned short *pKey = (unsigned short *)&Key;
    unsigned short *Crc16;



    //----反向解密
    Input+=n;
    Output+=n;
    Len = n;
    Crc16 = pKey + 1;
    while (Len>0)
    {              
        Input--;
        Output--;
        TmpInput=*Input&0x0F;
        TmpOutL=(*Crc16^TmpInput)&0x0F;
        *Crc16=(*Crc16>>4)^(TmpInput*0x1081);
        TmpInput=(*Input>>4)&0x0F;
        TmpOutH=(*Crc16^TmpInput)&0x0F;
        *Crc16=(*Crc16>>4)^(TmpInput*0x1081);
        *Output=(TmpOutH<<4)|TmpOutL;
        Len--;
    }
    memcpy(Input, Output, n);  
    //----正向解密
    Len = n;
    Crc16 = pKey;
    while (Len>0)
    {
        TmpInput=*Input&0x0F;
        TmpOutL=(*Crc16^TmpInput)&0x0F;
        *Crc16=(*Crc16>>4)^(TmpInput*0x1081);
        TmpInput=(*Input>>4)&0x0F;
        TmpOutH=(*Crc16^TmpInput)&0x0F;
        *Crc16=(*Crc16>>4)^(TmpInput*0x1081);
        *Output=(TmpOutH<<4)|TmpOutL;
        Input++;
        Output++;
        Len--;
    }           
    Input-=n;
    Output-=n;
    memcpy(Input, Output, n);


    //補上解密檢核碼
    memcpy(Output+n, (char *)pKey, 4);

    //比較檢核碼
    unsigned int *pCk1 = (unsigned int *)(Input+n);  
    unsigned int *pCk2 = (unsigned int *)(Output+n);
    if (*pCk1==*pCk2) return 1;
    else              return 0;

}

//====================== 加強式 加密 2===========================
void CrcEncrypt2_adv(unsigned int Key, unsigned char *Input, unsigned char *Output, unsigned int n)
{
    unsigned char TmpOutL, TmpOutH, TmpInput;
    unsigned int Len;
    unsigned short *pKey = (unsigned short *)&Key;
    unsigned short *Crc16;

    //----反向加密
    Len = n;   
    Input+=n;
    Output+=n;
    Crc16 = pKey;
    while (Len>0)
    {       
        Input--;
        Output--;
        TmpInput=*Input&0x0F;
        TmpOutL=(*Crc16^TmpInput)&0x0F;
        *Crc16=(*Crc16>>4)^(TmpOutL*0x1081);
        TmpInput=(*Input>>4)&0x0F;
        TmpOutH=(*Crc16^TmpInput)&0x0F;
        *Crc16=(*Crc16>>4)^(TmpOutH*0x1081);
        *Output=(TmpOutH<<4)|TmpOutL;
        Len--;
    }
    memcpy(Input, Output, n);
    //---正向加密
    Len = n;
    Crc16 = pKey+1;
    while (Len>0)
    {
        TmpInput=*Input&0x0F;
        TmpOutL=(*Crc16^TmpInput)&0x0F;
        *Crc16=(*Crc16>>4)^(TmpOutL*0x1081);
        TmpInput=(*Input>>4)&0x0F;
        TmpOutH=(*Crc16^TmpInput)&0x0F;
        *Crc16=(*Crc16>>4)^(TmpOutH*0x1081);
        *Output=(TmpOutH<<4)|TmpOutL; 
        Input++;
        Output++;
        Len--;
    }                    
    Input-=n;
    Output-=n;
    memcpy(Input, Output, n);

    //補上加密檢核碼
    memcpy(Output+n, (char *)pKey, 4);
}


char CrcDecrypt2_adv(unsigned int Key, unsigned char *Input, unsigned char *Output, unsigned int n)
{
    unsigned char TmpOutL, TmpOutH, TmpInput;
    unsigned int Len;
    unsigned short *pKey = (unsigned short *)&Key;
    unsigned short *Crc16;

    //----正向解密
    Len = n;
    Crc16 = pKey + 1;
    while (Len>0)
    {
        TmpInput=*Input&0x0F;
        TmpOutL=(*Crc16^TmpInput)&0x0F;
        *Crc16=(*Crc16>>4)^(TmpInput*0x1081);
        TmpInput=(*Input>>4)&0x0F;
        TmpOutH=(*Crc16^TmpInput)&0x0F;
        *Crc16=(*Crc16>>4)^(TmpInput*0x1081);
        *Output=(TmpOutH<<4)|TmpOutL;
        Input++;
        Output++;
        Len--;
    }        
    Input-=n;
    Output-=n;
    memcpy(Input, Output, n);  
    //----反向解密
    Len = n;      
    Input+=n;
    Output+=n;
    Crc16 = pKey;
    while (Len>0)
    {           
        Input--;
        Output--;
        TmpInput=*Input&0x0F;
        TmpOutL=(*Crc16^TmpInput)&0x0F;
        *Crc16=(*Crc16>>4)^(TmpInput*0x1081);
        TmpInput=(*Input>>4)&0x0F;
        TmpOutH=(*Crc16^TmpInput)&0x0F;
        *Crc16=(*Crc16>>4)^(TmpInput*0x1081);
        *Output=(TmpOutH<<4)|TmpOutL;
        Len--;
    }
    memcpy(Input, Output, n);


    //補上解密檢核碼
    memcpy(Output+n, (char *)pKey, 4);

    //比較檢核碼
    unsigned int *pCk1 = (unsigned int *)(Input+n);  
    unsigned int *pCk2 = (unsigned int *)(Output+n);
    if (*pCk1==*pCk2) return 1;
    else              return 0;

}




//=================================================
void ByteToHex(unsigned char byte, unsigned char *hex)
{
	unsigned char val;
    val=(byte>>4)&0x0F;
    if (val<10) hex[0]='0'+val;
    else        hex[0]='A'+(val-10);
    val=byte&0x0F;
    if (val<10) hex[1]='0'+val;
    else        hex[1]='A'+(val-10);
}

//=======================================================================
void HexToByte(unsigned char *hex, unsigned char *byte)
{
    *byte=0;
	if      ((hex[0]>='0')&&(hex[0]<='9')) *byte=hex[0]-'0';
    else if ((hex[0]>='A')&&(hex[0]<='F')) *byte=hex[0]-'A'+10;

    *byte<<=4;
	if      ((hex[1]>='0')&&(hex[1]<='9')) *byte|=hex[1]-'0';
    else if ((hex[1]>='A')&&(hex[1]<='F')) *byte|=hex[1]-'A'+10;
}

//=================睡覺========================
void MicroSleep(unsigned int ww)
{
#ifdef __QT
    usleep(ww);
#endif
#ifdef __GCC
    usleep(ww);
#endif
#ifdef __BCB
    Sleep(ww/1000);
#endif
#ifdef __VC
    Sleep(ww/1000);
#endif
}


//=================取得目前時間======================
void getTime(LK_TIME *tt)
{
#ifdef __QT
    #define ISGCC
#endif
#ifdef __GCC
    #define ISGCC
#endif


#ifdef ISGCC
    struct timeval t1;
    gettimeofday(&t1,NULL);  //取得目前時間
    tt->Sec = t1.tv_sec;
    tt->uSec = t1.tv_usec;
#else
    SYSTEMTIME stime;
    GetSystemTime(&stime);
    tt->Sec = (((stime.wHour*60)+stime.wMinute)*60)+stime.wSecond;
    tt->uSec = stime.wMilliseconds*1000;
#endif
}

void getTimeDiff(LK_TIME *tt, LK_TIME *t2, LK_TIME *t1)
{
    if (t2->uSec>=t1->uSec)
    {
        tt->Sec = t2->Sec-t1->Sec;
        tt->uSec = t2->uSec-t1->uSec;
    }
    else
    {
        tt->Sec = t2->Sec-t1->Sec-1;
        tt->uSec = t2->uSec-t1->uSec+1000000;
    } 
}


//---------------------------------------------------------------------------
void CrcCalculate(unsigned short *Crc16, unsigned char *Input, unsigned int Len)
{
    unsigned char TmpOutL, TmpOutH, TmpInput;
    while (Len>0)
    {
        TmpInput=*Input&0x0F;
        TmpOutL=(*Crc16^TmpInput)&0x0F;
        *Crc16=(*Crc16>>4)^(TmpOutL*0x1081);
        TmpInput=(*Input>>4)&0x0F;
        TmpOutH=(*Crc16^TmpInput)&0x0F;
        *Crc16=(*Crc16>>4)^(TmpOutH*0x1081);
        //*Output=(TmpOutH<<4)|TmpOutL;
        Input++;
        //Output++;
        Len--;
    }
}

                             
//----------------------------------------------------------------
int GetFileSize(char *filename)
{
    struct stat buf;
    if (stat(filename, &buf)>=0)
        return buf.st_size;
    else
    	return -1;
}


//=======================================================================
unsigned short GetSignature(unsigned short CRCHi, unsigned short CRCLo, unsigned char *Data, unsigned int Size)
{
   unsigned short  Index;

   while (Size --)
   {
      Index = CRCLo ^ *Data++;
      CRCLo = CRCHi ^ (CRCTable[Index] >> 8);
      CRCHi = (CRCTable[Index] & 0x00FF);
   }

   return ((CRCHi << 8) | (CRCLo & 0x00FF));
}


//----------------------------------------------------------------
int ReadFileFromDisk(char *filename, unsigned char *Buf, int MaxSize)
{
    FILE *f;
    int BufLen=0;
    f=fopen (filename, "rb");
    if (f!=NULL)
    {
        BufLen = fread(Buf, 1, MaxSize, f);
    	fclose(f);
    }
    return BufLen;
}
                
//----------------------------------------------------------------
int WriteFileToDisk(char *filename, unsigned char *Buf, int Size)
{
    FILE *f;
    int Result=0;
    int rt;
    int k, p;
    char filePath[200];
    struct stat st;
    //檢查檔案路徑是否存在
    //printf("WriteFileToDisk filename=%s", filename);
    k=0;
    while (1)
    {
    #ifdef __WIN 
        if (filename[k]==0) break;
        if (filename[k]=='\\') p=k;
    #else
        if (filename[k]==0) break;
        if (filename[k]=='/') p=k;
    #endif
        filePath[k]=filename[k];
        k++;
    }
    filePath[p]=0;
    //printf("%s\n", filePath);
    //printf("%s\n", filename);
    rt = stat(filePath, &st);
    if (rt!=0) return 0;
    //--如果檔案已存在，先刪除
    if (stat(filename, &st)>=0)
    {
        remove(filename);
    }

    f=fopen(filename, "wb");
    if (f!=NULL)
    {
        unsigned int ByteWritten;
        if (Size>0)
        {
            ByteWritten = fwrite(Buf, 1, Size, f);
            if (ByteWritten==Size) Result=1;
        }
        else
        {
            Result = 1;
        }
        fclose(f);
    }
    else
    {
        fclose(f);
    }
    return Result;
}


//----------檢查是否為已加密的檔案
int CheckEncrypted(char *OriName)
{
    char *k;
    k = strstr(OriName, ".lnc");
    if (k!=0)
    {
        k[0]=0;
    	return 1;
    }
    k = strstr(OriName, ".mak");
    if (k!=0)
    {
        k[0]=0;
    	return 2;
    }
    return 0;
}



//----------檢查是否為已加密的檔案
int CheckEncrypted(char *OriName, char *EncryptName)
{
    char *k;
    k = strstr(OriName, ".lnc");
    if (k!=0)
    {
        strcpy(EncryptName, OriName);
        k[0]=0;
    	return 1;
    }
    k = strstr(OriName, ".mak");
    if (k!=0)
    {            
        strcpy(EncryptName, OriName);
        k[0]=0;
    	return 2;
    }
    return 0;
}

#ifndef __VC_DLL
int EnumFilesInFolder(char *FilePath, char *HeadFilter, char *TailFilter, FTP_FILE *pFiles, unsigned short *FileCount)
{
    //printf("FilePath=%s, HeadFilter=%s, TailFilter=%s\n", FilePath, HeadFilter, TailFilter);

    DIR *dp;
    int i;
    int MaxFileCount;
    struct dirent *dirp;
    struct stat buf;
    time_t tt;
    struct tm *tm1;
    char Fullname[256];
    int rt;
    unsigned short lenName, lenHead=0, lenTail=0;
    unsigned char Pass;
    //-----檢查 Head 長度
    for (i=0; i<10; i++)
    {
        if (HeadFilter[i]==0)
        {
            lenHead = i;
            break;
        }
    }
    //-----檢查 Tail 長度
    for (i=0; i<10; i++)
    {
        if (TailFilter[i]==0)
        {
            lenTail = i;
            break;
        }
    }
    //---------------列舉檔案
    MaxFileCount = *FileCount;
    *FileCount = 0;
    dp = opendir(FilePath);
    if (dp != NULL)
    {
        while ((dirp = readdir(dp)) != NULL)
        {
            if (dirp->d_name[0]!='.')
            {
                Pass = 1;
                if ((Pass)&&(lenHead>0))
                {
                    rt = memcmp(dirp->d_name, HeadFilter, lenHead);
                    if (rt!=0) Pass=0;
                }
                if ((Pass)&&(lenTail>0))
                {
                    //-----檢查 Head 長度
                    for (i=0; i<260; i++)
                    {
                        if (dirp->d_name[i]==0)
                        {
                            lenName = i;
                            break;
                        }
                    }
                    rt = memcmp(dirp->d_name+(lenName-lenTail), TailFilter, lenTail);
                    if (rt!=0) Pass=0;
                }
                if (Pass)
                {
                    memcpy(pFiles[*FileCount].filename, dirp->d_name, FILENAME_LENGTH);
                    //取得檔案屬性
                    #ifdef __WIN
                    	sprintf(Fullname, "%s\\%s", FilePath, dirp->d_name);
                    #else
                    	sprintf(Fullname, "%s/%s", FilePath, dirp->d_name);
                    #endif
                    if (stat(Fullname, &buf)>=0)
                    {
                        if (buf.st_mode&0x8000)
                        {
                            pFiles[*FileCount].filesize = buf.st_size;
                            tt = time_t(buf.st_mtime);
                            tm1 = localtime(&tt);
                            pFiles[*FileCount].year = tm1->tm_year+1900;
                            pFiles[*FileCount].month = tm1->tm_mon+1;
                            pFiles[*FileCount].day = tm1->tm_mday;
                            pFiles[*FileCount].hour = tm1->tm_hour;
                            pFiles[*FileCount].minute = tm1->tm_min;
                            pFiles[*FileCount].second = tm1->tm_sec;
                            (*FileCount)++;
                        }
                    }
                }
            }
            if (*FileCount>=MaxFileCount) break;
        }
        closedir(dp);   
        return 1;
    }
    return 0;
}
#endif



