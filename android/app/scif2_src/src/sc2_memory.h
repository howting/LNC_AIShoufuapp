#ifndef __SC2_MEMORY_H
#define __SC2_MEMORY_H

#include "scif2.h"
#include "scif2_define.h"
#include "common_define.h"

#define PORT_UDP_RECON      1700
#define PORT_UDP_REPLY      1701
#define PORT_UDP_MEDIA      1702



//-------------------------------
struct POLLING_QUEUE
{
	unsigned char   WriteAddr;
    unsigned char   ReadAddr;
    LK_TRANSACTION  Trans[MAX_LOOP_SIZE];
};
                            
//-------------------------------
struct DIRECT_QUEUE
{
	unsigned char   WriteAddr;
    unsigned char   ReadAddr;
    LK_TRANSACTION  Trans[MAX_DIRECT_SIZE];
};

#define MAX_CONTROLLER_NUM_PER_PAGE    30    //向 Media 讀取控制器清單時，分頁向 Media 取得詳資料，每頁的數量

//----------本地端偵測的主機資訊
struct LOCAL_INFO
{
	unsigned short        Count;
    LOCAL_CONTROLLER_INFO Hosts[MAX_CONTROLLER_NUM_PER_MAKER];
};



//------------ 對媒介主機的狀態
enum CONNECT_STEP
{
    CONNECT_STEP_IDLE                       =0,
    CONNECT_STEP_CONNECT_REMOTE             =51,
    CONNECT_STEP_REMOTE_CHECK               =52,
    CONNECT_STEP_CONNECT_LOCAL              =54,
    CONNECT_STEP_CONNECT_CHECK              =56,
    CONNECT_STEP_DISCONNECT                 =58,
    CONNECT_STEP_DISCONNECT_CHECK           =59,

    CONNECT_STEP_CHECK_CONNECT_FAIL         =61,

    //CONNECT_STEP_GET_MAC                    =71,
    //CONNECT_STEP_GET_MAC_CHECK              =72,
    //CONNECT_STEP_GET_RECON_SETTING          =73,
    //CONNECT_STEP_GET_RECON_SETTING_CHECK    =74,
    //CONNECT_STEP_SET_RECON_SETTING          =75,
    //CONNECT_STEP_SET_RECON_SETTING_CHECK    =76,

    CONNECT_STEP_DONE                       =99,
};



enum CONNECT_ACTION
{                      
    CONNECT_ACTION_IDLE                 = 0x00,
    CONNECT_ACTION_TO_CONNECT           = 0x11,          //
    CONNECT_ACTION_TO_REMOTE            = 0x16,          //
    CONNECT_ACTION_TO_DISCONNECT        = 0x22,
};


enum FTP_ACTION
{
    FTP_ACTION_IDLE                 = 0x00,
    FTP_ACTION_TO_UPLOAD_FILE       = 0x11,
    FTP_ACTION_TO_DOWNLOAD_FILE     = 0x12, 
    FTP_ACTION_TO_DELETE_FILE       = 0x13,
    FTP_ACTION_TO_LIST_FILE         = 0x21,
    FTP_ACTION_TO_MAKE_DIR          = 0x22,
    FTP_ACTION_TO_UPLOAD_FILES      = 0x31,
    FTP_ACTION_TO_DOWNLOAD_FILES    = 0x32,  
    FTP_ACTION_TO_DELETE_FILES      = 0x33,
};

//---------- 關於媒介主機的所有資訊
#define MAX_STEP 32

struct PROTOCOL_SECTION
{
    unsigned short  PkgID;
    unsigned char   TranType;
    unsigned char   TranIndex;
    //unsigned int   RxUseByteCnt;
    //unsigned int   RxUnuseByteCnt;
    unsigned int   RxCrcPkgCnt;
    unsigned int   RxPkgCnt;
    unsigned short  RxUnExpectCnt;     //非預期收到的封包
    unsigned short  RxErrFmtCnt;     //格式錯誤的封包
    //unsigned int   TxByteCnt;
    unsigned int   TxPkgCnt;
    unsigned int   TxPkgRetryCnt;      //
    unsigned int   TxConnectCnt;        //連線封包送出次數
    unsigned int   RxConnectCnt;        //連線封包接收次數

    unsigned short  RetryCnt;         //!< 重送次數

    unsigned char  TalkTxBufs[MAX_PACKET_SIZE];
    unsigned short TalkTxLens;
    
    unsigned char  *TalkTxBuf;
    unsigned short  TalkTxLen;

#ifdef __CLIENT
	int             fd;               //通訊
    unsigned short  TalkRxLenPredit;  //預測應收到回傳的資料長度
    unsigned char   TalkRxBufs[MAX_PACKET_SIZE];    //!< 接收資料的Buf
    unsigned short  TalkRxLens;                     //!< 目前接收資料位址索引
#endif
};

//--------------連線通訊的資訊-------
struct TALK_INFO
{
    int         SoftwareID;        //軟體ID
    //int                ConnectIndex;
    //---傳送用的
    
//#ifdef __QT
//    QUdpSocket*        Sck;
//    QHostAddress       ReconAddr;       // controller address information
//    int                ReconPort;
//#else
    int*               Sck;              //?q?T handle
    struct sockaddr_in ReconAddr;       // controller address information
//#endif
    int ToClearLoop;
    int ToClearDirect;
    //----網際連線所需資訊
    char MediaIP[16];
    char RemoteIP[16];
    unsigned int RemoteIPLong;
    int  RemotePort;
    int  RemotePwd;
    unsigned int MyInternetIPLong;
    int          MyInternetPort;
    int          MediaResponseCount;

    //----Combine封包的暫存資訊
    unsigned int      DirectReadCombineFlag;
    unsigned int      DirectReadIntNum;
    unsigned int      DirectReadFixNum;
    LK_TARGET         DirectReadInt[INT_CB_SIZE];
    LK_TARGET         DirectReadFix[FIX_CB_SIZE];

    unsigned int      LoopReadCombineFlag;
    unsigned int      LoopReadIntNum;
    unsigned int      LoopReadFixNum;
    LK_TARGET         LoopReadInt[INT_CB_SIZE];
    LK_TARGET         LoopReadFix[FIX_CB_SIZE];

    unsigned int      DirectWriteCombineFlag;
    unsigned int      DirectWriteIntNum;
    unsigned int      DirectWriteFixNum;
    LK_TARGET         DirectWriteInt[INT_CB_SIZE];
    int               DirectWriteIntData[INT_CB_SIZE];
    LK_TARGET         DirectWriteFix[FIX_CB_SIZE];
    double            DirectWriteFixData[FIX_CB_SIZE];

    unsigned int      LoopWriteCombineFlag;
    unsigned int      LoopWriteIntNum;
    unsigned int      LoopWriteFixNum;
    LK_TARGET         LoopWriteInt[INT_CB_SIZE];
    LK_TARGET         LoopWriteFix[FIX_CB_SIZE];

    //Connect 用的資訊
    CONNECT_ACTION     Action;
    CONNECT_STEP       Step[MAX_STEP];
    unsigned char      StepIndex;
    char               ConnectPwd[16];
    unsigned char      TxBuf[MAX_CONNECT_SIZE];
    unsigned int       TxLen;
    unsigned short     PacketID;
    unsigned short     MaxRetry;        //最大重試次數
    unsigned short     RetryCnt;            
    unsigned char      ConnectWaiting;         //!< 通訊狀態
    //unsigned char      TryHoleTimes;   //嘗試打洞已經過的次數
    unsigned char      ConnectResponse;

    unsigned int      AliveTxTime;
    unsigned int      AliveRxTime;
    unsigned char      AliveBuf[10];
    unsigned char      ConnState;       //!< 連線狀態
    unsigned int      ConnectTime;      //本次封包的傳送時間點
    unsigned int      ConnectWaitTime;

    ERROR_MSG          ErrRec;           //最後一次的錯誤內容

    unsigned char      QueueFrom;       //目前操作的Queue來源
    POLLING_QUEUE      LoopQueue;    //頁面的 PollingQueue資料
    DIRECT_QUEUE       DirectQueue;     //DirectQueue
    LK_TRANSACTION     *pTran;          //目前通訊處理中的交易
    PROTOCOL_SECTION   Section;         //通訊協定所需的結構資料
    unsigned int       LoopCount;       //loop Queue循環次數
    unsigned int       Timeout;         //通訊 timeout 時間
    unsigned int       ResponseTime;    //最後一次封包的回應時間
    unsigned int       timeSend;        //本次封包的傳送時間點
    unsigned int       timeSpace;       //上次收到資料的時間點
    unsigned char      TalkWaiting;         //!< 通訊狀態
    unsigned char      TalkState;
    unsigned short     TalkMaxRetry;    //最大重試次數

    unsigned char      MAC[6];          //Mac address
    //unsigned char      GetMacDone;
    //unsigned char      GetSettingDone;
    //unsigned char      SetSettingDone;
    //unsigned char      SetSettingResult;
    MIRROR_MEMORY      *pMem;                 //Mirror memory for Process
    int  OffsetI;
    int  OffsetO;
    int  OffsetC;
    int  OffsetS;
    int  OffsetA;
    int  OffsetR;
    int  OffsetF;
    int  OffsetTimer;
    int  OffsetCounter;
};
                     
struct FTP_BLOCK_INFO
{
    unsigned short PacketID;
    unsigned char  TryTimes;     //傳送次數
    unsigned int  WaitTime;
    unsigned short Idx;
    unsigned short Size;
};


enum FTP_STEP
{
	FTP_STEP_SET_MANY               =1,
    FTP_STEP_CHECK_MANY             =2,
    FTP_STEP_REQ_UPLOAD             = 11,
    FTP_STEP_REQ_UPLOAD_CHECK       = 12, 
    FTP_STEP_UPLOAD_MEM             = 13,
    FTP_STEP_UPLOAD_MEM_CHECK       = 14,
    FTP_STEP_TELL_UPLOAD_DONE       = 15,
    FTP_STEP_TELL_UPLOAD_DONE_CHECK = 16,

    FTP_STEP_REQ_DOWNLOAD             = 31,
    FTP_STEP_REQ_DOWNLOAD_CHECK       = 32,
    FTP_STEP_DOWNLOAD_MEM             = 33,
    FTP_STEP_DOWNLOAD_MEM_CHECK       = 34,
    FTP_STEP_TELL_DOWNLOAD_DONE       = 35,
    FTP_STEP_TELL_DOWNLOAD_DONE_CHECK = 36,

    FTP_STEP_REQ_DELETE             = 41,
    FTP_STEP_REQ_DELETE_CHECK       = 42,

    FTP_STEP_REQ_MAKE_DIR         = 51,
    FTP_STEP_REQ_MAKE_DIR_CHECK   = 52,

    FTP_STEP_REQ_LIST              =61,
    FTP_STEP_REQ_LIST_CHECK        =62,
    FTP_STEP_GET_FILE_LIST        =71,
    FTP_STEP_GET_FILE_LIST_CHECK  =72,
    FTP_STEP_DONE                   = 81,
};


struct FTP_INFO
{
    int   State;           //狀態
    int   Result;          //傳送結果
    int   FtpDone;         //Ftp工作完成註記
    //int   LastState;           //狀態
    //int   LastResult;          //傳送結果

    FTP_ACTION      Action;

    //----檔案傳輸資料
    char            Folder;          //檔案傳輸資料夾  
    char            SubFolder[32];   //子目錄名稱
    char            HeadFilter[10];
    char            TailFilter[10];
    char            FileName[32];    //檔案名稱
    char            LocalName[256];  //檔案名稱
    char            DirName[16];
    int    FileSize;
    unsigned char*  pFileMem;
    short  FileCRC;
    int  TotalIdx;
    int  CurrentIdx;

    //----主機資料夾檔案清單
    char             FilePath[200];
    int   FileCount;
    int   FileIndex;
    FTP_FILE         FileLists[MAX_FILE_LIST_NUM];
                          
    //----主機資料夾檔案清單
    char             LocalPath[200];
    int   LocalFileCount;
    int   LocalFileIndex;
    FTP_FILE         LocalFileLists[MAX_FILE_LIST_NUM];

    //----檔案傳輸清單
    int    TransferCount;
    int    TransferIndex;
    FTP_TRANFER_FILE TransferFiles[MAX_TRANSFER_FILE_COUNT];

	unsigned short  PacketID;
    FTP_STEP        Step[20];
    unsigned char   StepIndex;

    unsigned char   TxBuf[MAX_PACKET_SIZE];
    unsigned short  TxLen;
    unsigned char   TryTimes;
    unsigned int    TimeSend;
    unsigned int    Timeout;
    unsigned int    MaxRetry;

    unsigned char   CmdResult;   //目前命令的回應結果 0:未有結果  1:成功  2:失敗  3:通訊失敗
};

//-------------------------------
struct COMM_SESSION
{
    int     SoftwareID;              //軟體ID
    int     ConnectNum;             //連線數目
    int     DebugLevel;              //除錯等級
    unsigned int     ProcCounter;             //Proc 計數器

    FUNCTION_SETTING Funcs;                   //功能設定
    LOCAL_INFO       LocalInfo;               //區域網路內的主機資訊
    FTP_INFO         FtpInfo;
    int              FtpTalkIdx;

    TALK_INFO       *pTalkInfo;  //資訊通訊的資訊
    int  MemSizeI;
    int  MemSizeO;
    int  MemSizeC;
    int  MemSizeS;
    int  MemSizeA;
    int  MemSizeR;
    int  MemSizeF;
    int  MemSizeTimer;
    int  MemSizeCounter;
    MIRROR_MEMORY   *pMem;      //鏡射記憶體
};

          
extern COMM_SESSION  *pSes;
//#ifdef __QT
//    extern QUdpSocket* MainSocket;
//#else
    extern int*        MainSocket;
//#endif
extern int FtpIndex;


//#ifdef __QT
//    void ClosePort(QUdpSocket *pSck);
//    bool OpenPort(QUdpSocket *pSck);
//#else
    void ClosePort(int *pSck);
    bool OpenPort(int *pSck);
//#endif
void LogTalkError(TALK_INFO *pTalk, int Type);
int WriteOutMessage(TALK_INFO *pTalk, char *Buf, int Len);


PTR cmdBitWriteN(int SIdx, int type, LK_DEVICE dev, int addr, int num, int *data);
PTR cmdIntWriteN(int SIdx, int type, LK_DEVICE dev, int addr, int num, int *data);
PTR cmdFixWriteN(int SIdx, int type, LK_DEVICE dev, int addr, int num, double *data);

PTR cmdBitReadN(int SIdx, int type, LK_DEVICE dev, int Addrs, int Nums);
PTR cmdIntReadN(int SIdx, int type, LK_DEVICE dev, int Addrs, int Nums);
PTR cmdFixReadN(int SIdx, int type, LK_DEVICE dev, int Addrs, int Nums);


PTR CombineIntWrite(int SIdx, int type, int num, int StIdx);
PTR CombineFixWrite(int SIdx, int type, int num, int StIdx);

PTR CombineIntRead(int SIdx, int type, int num, int StIdx);
PTR CombineFixRead(int SIdx, int type, int num, int StIdx);

PTR AddDirectQueue(int SIdx, LK_TRANSACTION *pTran);
PTR AddLoopQueue(int SIdx, LK_TRANSACTION *pTran);



#endif

