#ifndef __COMMON_DEFINE_H
#define __COMMON_DEFINE_H


//---------------------------------------------------------------------------
#ifdef __QT
    #include <windows.h>
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <sys/time.h>
    #include <sys/stat.h>
    #include <time.h>
    #include <sys/types.h>
    #include <semaphore.h>
    #include <fcntl.h>
    #include <errno.h>
    #include <unistd.h>
    #include <dirent.h>
    //#include <QUdpSocket>

#endif
#ifdef __BCB
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <sys/stat.h>
    #include <sys/types.h>
    #include <time.h>
    #include <fcntl.h>
    #include <errno.h>
    #include <dirent.h>
	#include <windows.h>
#endif
#ifdef __GCC
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <time.h>
    #include <fcntl.h>
    #include <errno.h>
    #include <dirent.h>
    #include <netdb.h>
    #include <unistd.h>
    #include <netinet/in.h>
    #include <arpa/inet.h>
    //#include <sys/filio.h>
    #include <sys/socket.h>
    #include <sys/ioctl.h>
    #include <sys/stat.h>
    #include <sys/types.h>
    #include <sys/time.h>
    #include "ifaddrs.h"
#endif
#ifdef __VC
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <sys/stat.h>
    #include <sys/types.h>
    #include <time.h>
    #include <fcntl.h>
    #include <errno.h>
	#include <windows.h>
    //#include <winsock2.h>
    #pragma comment(lib, "ws2_32")
#endif


#include "scif2_define.h"

#define START_CHAR_MEDIA      0xAA
#define START_CHAR_CONNECT    0x5A
#define START_CHAR_TALK       0x55
#define START_CHAR_ADMIN      0xA5   //管理封包的起始字元
#define START_CHAR_FTP        0x7E   //FTP用的起始字元
#define START_CHAR_ALIVE      0x66   //連線封包
#define START_CHAR_TALK_GROUP 0x99   //Talk 的群組開頭
                                                
#define FTP_PAGE_SHIFT        14    //位移數 2^12 = 4096 Byte/page
#define FTP_PAGE_MASK      0x3FFF    //頁面的Mask, 需與FTP_PAGE_SHIFT 搭配
#define MAX_PACKET_SIZE     20000    //最大的封包尺寸
#define MAX_MEDIA_SIZE       1500    //與 Media 通訊的最大封包尺寸   
#define MAX_CONNECT_SIZE     1500   //連線封包的最大尺寸




struct LK_TIME
{
	unsigned int Sec;
	unsigned int uSec;
};
            
enum LK_PROTOCOL
{
	LK_PROTOCOL_NONE=0, 
	LK_PROTOCOL_FRIEND=1,
	LK_PROTOCOL_FX_SERIES=2,
	LK_PROTOCOL_MODBUS_RTU=3,
	LK_PROTOCOL_MODBUS_ASCII=4,
};


enum LK_CMD
{
    //--------------------------- bit data
    LK_CMD_BIT_1_READ         =1,
    LK_CMD_BIT_1_WRITE        =2,
    LK_CMD_BIT_N_READ         =3,
    LK_CMD_BIT_N_WRITE        =4,  
    LK_CMD_BIT_D_READ         =5,
    LK_CMD_BIT_D_WRITE        =6,
    //--------------------------- byte data
    LK_CMD_BYTE_1_READ        =11,
    LK_CMD_BYTE_1_WRITE       =12,
    LK_CMD_BYTE_N_READ        =13,
    LK_CMD_BYTE_N_WRITE       =14,
    LK_CMD_BYTE_D_READ        =15,
    LK_CMD_BYTE_D_WRITE       =16,
    //--------------------------- word
    LK_CMD_WORD_1_READ        =21,
    LK_CMD_WORD_1_WRITE       =22,
    LK_CMD_WORD_N_READ        =23,
    LK_CMD_WORD_N_WRITE       =24,
    LK_CMD_WORD_D_READ        =25,
    LK_CMD_WORD_D_WRITE       =26,
    //--------------------------- int
    LK_CMD_INT_1_READ         =41,
    LK_CMD_INT_1_WRITE        =42,
    LK_CMD_INT_N_READ         =43,
    LK_CMD_INT_N_WRITE        =44,
    LK_CMD_INT_D_READ         =45,
    LK_CMD_INT_D_WRITE        =46,
    //---------------------------- fix
    LK_CMD_FIX_1_READ         =51,
    LK_CMD_FIX_1_WRITE        =52,
    LK_CMD_FIX_N_READ         =53,
    LK_CMD_FIX_N_WRITE        =54,
    LK_CMD_FIX_D_READ         =55,
    LK_CMD_FIX_D_WRITE        =56,
};


enum LK_DEVICE
{
    LK_DEV_I     =1,
    LK_DEV_O     =2,
    LK_DEV_C     =3,
    LK_DEV_S     =4,
    LK_DEV_A     =5,
    LK_DEV_TT    =6,
    LK_DEV_CT    =7,
    LK_DEV_R     =11,
    LK_DEV_TS    =12,
    LK_DEV_TV    =13,
    LK_DEV_CS    =14,
    LK_DEV_CV    =15,
    LK_DEV_F     =21,
    LK_DEV_P     =31,
    LK_DEV_RBIT  =40,
    LK_DEV_NONE  =50,
    LK_DEV_RI    =60,
    LK_DEV_RO    =61,
    LK_DEV_RC    =62,
    LK_DEV_RS    =63,
    LK_DEV_RA    =64,
    LK_DEV_RTT    =65,
    LK_DEV_RCT    =66,
};


struct LK_TARGET
{
    LK_DEVICE    Device;
    int          Addr;
};


struct MIRROR_MEMORY
{
    bool Inited;
    int SizeI;
    int SizeO;
    int SizeC;
    int SizeS;
    int SizeA;
    int SizeR;
    int SizeF;
    int SizeTimer;
    int SizeCounter;
    unsigned char *I_Table;
    unsigned char *O_Table;
    unsigned char *C_Table;
    unsigned char *S_Table;
    unsigned char *A_Table;
    unsigned int  *R_Table;
    double        *F_Table;
    unsigned char *TT_Table;
    unsigned int *TV_Table;
    unsigned int *TS_Table;
    unsigned char *CT_Table;
    unsigned int *CV_Table;
    unsigned int *CS_Table;
};



enum FTP_CMD
{
	FTP_CMD_ENUM_FOLDER=0x10,        //切換到資料夾
    FTP_CMD_GET_FILE_LIST=0x11,      //取得檔案清單
    FTP_CMD_SET_DOWNLOAD_FILE=0x20,
    FTP_CMD_DOWNLOAD_FILE_MEM=0x21,
    FTP_CMD_DOWNLOAD_FILE_DONE=0x22,
    FTP_CMD_SET_UPLOAD_FILE=0x30,
    FTP_CMD_UPLOAD_FILE_MEM=0x31,
    FTP_CMD_UPLOAD_FILE_DONE=0x32,
    FTP_CMD_SET_DELETE_FILE=0x40,
    FTP_CMD_SET_MAKE_DIR=0x50,
};

         


//-----------媒介主機命令碼
enum MEDIA_CMD
{
    MEDIA_CMD_TELL_MY_PORT=0x41,
    MEDIA_CMD_CONNECT_REQ=0x51,
    CONNECT_CMD_SOFTWARE_ID=0x61,
    CONNECT_CMD_DISCONNECT=0x62,
};

struct LK_REQUEST
{
    unsigned char ErrCode;   //錯誤碼
	unsigned char SlaveID;
	LK_CMD        Cmd;
    unsigned int Num;
    LK_TARGET     Target[MAX_CB_NUM];
    unsigned int Addr[MAX_CB_NUM];
    SC_DATA       Data;
};

//-------------------------------
struct LK_TRANSACTION
{
    int  State;     //refer to define above
    int  Cancelled;
    int  ErrCode;   //錯誤碼
    int  SlaveID;
	LK_CMD         Cmd;
    int            Num;
    LK_TARGET      Target[MAX_CB_NUM];
    SC_DATA        Data;
    int            RxByteCnt;
};


//------------------公用函式
                                   
void DoubleToBuf(unsigned char* Buf, double* DoubleVal);
void BufToDouble(double* DoubleVal, unsigned char* Buf);

void LongToBuf(unsigned char* Buf, int* LongVal);
void BufToLong(int* LongVal, unsigned char* Buf);
                                                             
void ShortToBuf(unsigned char* Buf, short* ShortVal);
void BufToShort(short* ShortVal, unsigned char* Buf);

unsigned short CRC_16(unsigned char *Data, unsigned int Size);
unsigned char CheckCRC( unsigned char *data, unsigned int size );
void ByteToHex(unsigned char byte, unsigned char *hex);
void HexToByte(unsigned char *hex, unsigned char *byte);
void MicroSleep(unsigned int ww);
void getTime(LK_TIME *tt);
void getTimeDiff(LK_TIME *tt, LK_TIME *t2, LK_TIME *t1);
                                                                                                 
void CrcEncrypt(unsigned short *Crc16, unsigned char *Input, unsigned char *Output, unsigned int Len);
void CrcDecrypt(unsigned short *Crc16, unsigned char *Input, unsigned char *Output, unsigned int Len);
  
void CrcEncrypt_rev(unsigned short *Crc16, unsigned char *Input, unsigned char *Output, unsigned int Len);
void CrcDecrypt_rev(unsigned short *Crc16, unsigned char *Input, unsigned char *Output, unsigned int Len);
                                                                                                     
void CrcEncrypt_adv(unsigned int Key, unsigned char *Input, unsigned char *Output, unsigned int n);
char CrcDecrypt_adv(unsigned int Key, unsigned char *Input, unsigned char *Output, unsigned int n);
                                                                                          
void CrcEncrypt2_adv(unsigned int Key, unsigned char *Input, unsigned char *Output, unsigned int n);
char CrcDecrypt2_adv(unsigned int Key, unsigned char *Input, unsigned char *Output, unsigned int n);

void CrcCalculate(unsigned short *Crc16, unsigned char *Input, unsigned int Len);


int GetFileSize(char *filename);

unsigned short GetSignature(unsigned short CRCHi, unsigned short CRCLo, unsigned char *Data, unsigned int Size);

int ReadFileFromDisk(char *filename, unsigned char *Buf, int MaxSize);   
int WriteFileToDisk(char *filename, unsigned char *Buf, int Size);


int CheckEncrypted(char *OriName);  
int CheckEncrypted(char *OriName, char *EncryptName);

int EnumFilesInFolder(char *FilePath, char *HeadFilter, char *TailFilter, FTP_FILE *pFiles, unsigned short *FileCount);

#endif

