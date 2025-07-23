//#include "stdafx.h"
#include "scif2.h"
#include "sc2_memory.h"
#include "proc_protocol.h"
#include "proc_ftp.h"
#include "proc_data_talk.h"
#include "proc_connect_build.h"
#include "SpaceFunction.h"

//#ifdef __QT
//    #include <QDebug>
//    #include <QHostInfo>
//    #include <QHostAddress>
//#endif
#ifdef __QT
   #define NEED_INIT
    #define __WINDOWS
#endif
#ifdef __BCB
    #define NEED_INIT
    #define __WINDOWS
#endif
#ifdef __VC
    #define NEED_INIT
    #define __WINDOWS
#endif

#ifdef __WINDOWS
    CRITICAL_SECTION g_cs;
#endif

struct sockaddr_in src_addr;	// controller address information

#ifdef NEED_INIT
    #define WSA_VERSION MAKEWORD(2, 2) // using winsock 2.2
    //-------------------------------------------------------------------------------
    char initWinsock()
    {
        WSADATA	WSAData = { 0 };
        if (WSAStartup(WSA_VERSION, &WSAData) != 0)
        {
            // Tell the user that we could not find a usable WinSock DLL.
            if (LOBYTE(WSAData.wVersion) != LOBYTE(WSA_VERSION) ||
                HIBYTE(WSAData.wVersion) != HIBYTE(WSA_VERSION))
                printf("[PD] Incorrect winsock version\n");

            WSACleanup();
            return 0;
        }
        return 1;
    }
#endif

#ifdef __CLASS
    #define CLASS_RANGE SC2::
    CLASS_RANGE SC2()
    {
    }
#else
    #define CLASS_RANGE CALBY
#endif

//====================================================================
int  CLASS_RANGE LibraryInitial(DLL_USE_SETTING *pUseSetting, int MakerID, char *EncString)
{

    unsigned char rt;
    int i;
    static bool Inited=false;
    if (Inited) return -1;
    Inited=true;

	//printf("EncString=%s\n", EncString);
	//for (int j = 0; j < 10; j++)
	//{
	//	printf("%02x", EncString[j]);
	//}
	//printf("\n");


    #ifdef NEED_INIT
        if (!initWinsock())
        {
            printf("[PD] unable to initWinsock. \n");
            return -2;
        }
    #endif
    MainSocket = new int;
    *MainSocket = -1;

    //=============================解碼字串
    int Key=0x788812BF;
    int n = sizeof(FUNCTION_SETTING);
    unsigned char InBuf[100], OutBuf[100];


    //=====================初始化記憶體
    pSes = new COMM_SESSION;
    memset(pSes, 0, sizeof(COMM_SESSION));
//    if      (pUseSetting->SoftwareType==1)  pSes->SoftwareID=0x3567129A;
//    else if (pUseSetting->SoftwareType==2)  pSes->SoftwareID=0xAB358B23;
//    else if (pUseSetting->SoftwareType==3)  pSes->SoftwareID=0x3F57836A;
//    else if (pUseSetting->SoftwareType==4)  pSes->SoftwareID=0x4E4C4340;
//    else if (pUseSetting->SoftwareType==5)  pSes->SoftwareID=0x7F3D9EAC;
//    else                                    pSes->SoftwareID=0;
    pSes->SoftwareID = pUseSetting->SoftwareType;


    for (i=0; i<n+4; i++) HexToByte((unsigned char *)(EncString+i*2), &InBuf[i]);
    rt = CrcDecrypt_adv(Key, InBuf, OutBuf, n);
    memcpy(&pSes->Funcs, OutBuf, n);

    if (!((rt)&&(MakerID==pSes->Funcs.MakerID)))
    {
        //解析設定值
        pSes->Funcs.MakerID = 0;
        pSes->MemSizeI    = 0;
        pSes->MemSizeO    = 0;
        pSes->MemSizeC    = 0;
        pSes->MemSizeS    = 0;
        pSes->MemSizeA    = 0;
        pSes->MemSizeR    = 0;
        pSes->MemSizeF    = 0;
        pSes->MemSizeTimer   = 0;
        pSes->MemSizeCounter = 0;
        pSes->ConnectNum  = 0;
    }
    else
    {
        pSes->MemSizeI    = pUseSetting->MemSizeI;
        pSes->MemSizeO    = pUseSetting->MemSizeO;
        pSes->MemSizeC    = pUseSetting->MemSizeC;
        pSes->MemSizeS    = pUseSetting->MemSizeS;
        pSes->MemSizeA    = pUseSetting->MemSizeA;
        pSes->MemSizeR    = pUseSetting->MemSizeR;
        pSes->MemSizeF    = pUseSetting->MemSizeF;
        pSes->MemSizeTimer   = pUseSetting->MemSizeTimer;
        pSes->MemSizeCounter = pUseSetting->MemSizeCounter;
        pSes->ConnectNum  = pUseSetting->ConnectNum;
    }


    //------建立 talk info
    if (pSes->ConnectNum>0)
    {
        pSes->pTalkInfo = new TALK_INFO[pSes->ConnectNum];
        pSes->pMem = new MIRROR_MEMORY[pSes->ConnectNum];    //建立相同數量的鏡射記憶體區塊，但還不宣告其內容
        memset(pSes->pMem, 0x00, sizeof(MIRROR_MEMORY)*pSes->ConnectNum);
        for (i=0; i<pSes->ConnectNum; i++)
        {
            pSes->pTalkInfo[i].SoftwareID = pSes->SoftwareID;
            if ((pSes->MemSizeI<0)||(pSes->MemSizeI>I_NUM)) pSes->MemSizeI=0;
            if ((pSes->MemSizeO<0)||(pSes->MemSizeO>O_NUM)) pSes->MemSizeO=0;
            if ((pSes->MemSizeC<0)||(pSes->MemSizeC>C_NUM)) pSes->MemSizeC=0;
            if ((pSes->MemSizeS<0)||(pSes->MemSizeS>S_NUM)) pSes->MemSizeS=0;
            if ((pSes->MemSizeA<0)||(pSes->MemSizeA>A_NUM)) pSes->MemSizeA=0;
            if ((pSes->MemSizeR<0)||(pSes->MemSizeR>R_NUM)) pSes->MemSizeR=0;
            if ((pSes->MemSizeF<0)||(pSes->MemSizeF>F_NUM)) pSes->MemSizeF=0;
            if ((pSes->MemSizeTimer<0)||(pSes->MemSizeTimer>TIMER_NUM)) pSes->MemSizeTimer=0;
            if ((pSes->MemSizeCounter<0)||(pSes->MemSizeCounter>COUNTER_NUM)) pSes->MemSizeCounter=0;
            pSes->pMem[i].SizeI = pSes->MemSizeI;
            pSes->pMem[i].SizeO = pSes->MemSizeO;
            pSes->pMem[i].SizeC = pSes->MemSizeC;
            pSes->pMem[i].SizeS = pSes->MemSizeS;
            pSes->pMem[i].SizeA = pSes->MemSizeA;
            pSes->pMem[i].SizeR = pSes->MemSizeR;
            pSes->pMem[i].SizeF = pSes->MemSizeF;
            pSes->pMem[i].SizeTimer = pSes->MemSizeTimer;
            pSes->pMem[i].SizeCounter = pSes->MemSizeCounter;
            pSes->pMem[i].Inited = false;
            pSes->pTalkInfo[i].pMem = &pSes->pMem[i];    //預設指定到全域區塊
            pSes->pTalkInfo[i].OffsetI = 0;  //預設沒有地址偏移
            pSes->pTalkInfo[i].OffsetO = 0;
            pSes->pTalkInfo[i].OffsetC = 0;
            pSes->pTalkInfo[i].OffsetS = 0;
            pSes->pTalkInfo[i].OffsetA = 0;
            pSes->pTalkInfo[i].OffsetR = 0;
            pSes->pTalkInfo[i].OffsetF = 0;
            pSes->pTalkInfo[i].OffsetTimer = 0;
            pSes->pTalkInfo[i].OffsetCounter = 0;
        }
    }
    //取得使用的通訊協定
    printf("[PT] SoftwareID = 0x%x\n", (unsigned int)pSes->SoftwareID);
    printf("[PT] MakerID    = %d  %d\n", MakerID, pSes->Funcs.MakerID);
    printf("[PT] ConnectNum = %d  %d\n", pUseSetting->ConnectNum, pSes->ConnectNum);
    InitFtp(&pSes->FtpInfo);
    //---------初始化 Talk
    for (i=0; i<pSes->ConnectNum; i++)
    {
        TALK_INFO *pTalk = &pSes->pTalkInfo[i];
        InitTalk(pTalk);
    }

    //-----設定回傳值
    if (((rt)&&(MakerID==pSes->Funcs.MakerID))) return 100;
    if (rt) return 10;
    return 0;
}

//====================================================================
void CLASS_RANGE LibrarySetMemSize (int MemID, MEM_SIZE *pSize)
{
    if (pSes==0) return;
    if ((MemID<0)||(MemID>=pSes->ConnectNum)) return;
    if (pSes->pMem[MemID].Inited) return;   //已經初始化過了，不可設定
    if ((pSize->SizeI<0)||(pSize->SizeI>I_NUM)) pSize->SizeI=0;
    if ((pSize->SizeO<0)||(pSize->SizeO>O_NUM)) pSize->SizeO=0;
    if ((pSize->SizeC<0)||(pSize->SizeC>C_NUM)) pSize->SizeC=0;
    if ((pSize->SizeS<0)||(pSize->SizeS>S_NUM)) pSize->SizeS=0;
    if ((pSize->SizeA<0)||(pSize->SizeA>A_NUM)) pSize->SizeA=0;
    if ((pSize->SizeR<0)||(pSize->SizeR>R_NUM)) pSize->SizeR=0;
    if ((pSize->SizeF<0)||(pSize->SizeF>F_NUM)) pSize->SizeF=0;
    if ((pSize->SizeTimer<0)||(pSize->SizeTimer>F_NUM)) pSize->SizeTimer=0;
    if ((pSize->SizeCounter<0)||(pSize->SizeCounter>F_NUM)) pSize->SizeCounter=0;
    pSes->pMem[MemID].SizeI = pSize->SizeI;
    pSes->pMem[MemID].SizeO = pSize->SizeO;
    pSes->pMem[MemID].SizeC = pSize->SizeC;
    pSes->pMem[MemID].SizeS = pSize->SizeS;
    pSes->pMem[MemID].SizeA = pSize->SizeA;
    pSes->pMem[MemID].SizeR = pSize->SizeR;
    pSes->pMem[MemID].SizeF = pSize->SizeF;
    pSes->pMem[MemID].SizeTimer = pSize->SizeTimer;
    pSes->pMem[MemID].SizeCounter = pSize->SizeCounter;
}

//====================================================================
int  CLASS_RANGE LibrarySetMemMapping (int TgrConn, int MemID, MEM_OFFSET *pOffset)        //設定鏡射記憶體對應與偏移
{
    if (pSes==0) return 0;
    if ((TgrConn<0)||(TgrConn>=pSes->ConnectNum)) return 0;
    if ((MemID<0)||(MemID>=pSes->ConnectNum)) return 0;
    TALK_INFO *pTalk = &pSes->pTalkInfo[TgrConn];
    pTalk->pMem = &pSes->pMem[MemID];
    pTalk->OffsetI = pOffset->OffsetI;
    pTalk->OffsetO = pOffset->OffsetO;
    pTalk->OffsetC = pOffset->OffsetC;
    pTalk->OffsetS = pOffset->OffsetS;
    pTalk->OffsetA = pOffset->OffsetA;
    pTalk->OffsetR = pOffset->OffsetR;
    pTalk->OffsetF = pOffset->OffsetF;
    pTalk->OffsetTimer = pOffset->OffsetTimer;
    pTalk->OffsetCounter = pOffset->OffsetCounter;
    return 1;
}



//====================================================================
void  CLASS_RANGE LibrarySetDebug(int level)
{
    if (pSes==0) return;
    pSes->DebugLevel=level;
}


void  CLASS_RANGE LibraryDestroy()
{
    if (pSes==0) return;
    int i;
    TALK_INFO *pTalk;

    for (i=0; i<pSes->ConnectNum; i++)
    {
        pTalk = &pSes->pTalkInfo[i];
        pTalk->Action=CONNECT_ACTION_TO_DISCONNECT;  //
    }

    //-------終結鏡射記憶體
    for (i=0; i<pSes->ConnectNum; i++)
    {
        if (pSes->pTalkInfo[i].pMem->I_Table!=0) {delete pSes->pTalkInfo[i].pMem->I_Table; pSes->pTalkInfo[i].pMem->I_Table=0; }
        if (pSes->pTalkInfo[i].pMem->O_Table!=0) {delete pSes->pTalkInfo[i].pMem->O_Table; pSes->pTalkInfo[i].pMem->O_Table=0; }
        if (pSes->pTalkInfo[i].pMem->C_Table!=0) {delete pSes->pTalkInfo[i].pMem->C_Table; pSes->pTalkInfo[i].pMem->C_Table=0; }
        if (pSes->pTalkInfo[i].pMem->S_Table!=0) {delete pSes->pTalkInfo[i].pMem->S_Table; pSes->pTalkInfo[i].pMem->S_Table=0; }
        if (pSes->pTalkInfo[i].pMem->A_Table!=0) {delete pSes->pTalkInfo[i].pMem->A_Table; pSes->pTalkInfo[i].pMem->A_Table=0; }
        if (pSes->pTalkInfo[i].pMem->R_Table!=0) {delete pSes->pTalkInfo[i].pMem->R_Table; pSes->pTalkInfo[i].pMem->R_Table=0; }
        if (pSes->pTalkInfo[i].pMem->F_Table!=0) {delete pSes->pTalkInfo[i].pMem->F_Table; pSes->pTalkInfo[i].pMem->F_Table=0; }
        if (pSes->pTalkInfo[i].pMem->TT_Table!=0) {delete pSes->pTalkInfo[i].pMem->TT_Table; pSes->pTalkInfo[i].pMem->TT_Table=0; }
        if (pSes->pTalkInfo[i].pMem->TV_Table!=0) {delete pSes->pTalkInfo[i].pMem->TV_Table; pSes->pTalkInfo[i].pMem->TV_Table=0; }
        if (pSes->pTalkInfo[i].pMem->TS_Table!=0) {delete pSes->pTalkInfo[i].pMem->TS_Table; pSes->pTalkInfo[i].pMem->TS_Table=0; }
        if (pSes->pTalkInfo[i].pMem->CT_Table!=0) {delete pSes->pTalkInfo[i].pMem->CT_Table; pSes->pTalkInfo[i].pMem->CT_Table=0; }
        if (pSes->pTalkInfo[i].pMem->CV_Table!=0) {delete pSes->pTalkInfo[i].pMem->CV_Table; pSes->pTalkInfo[i].pMem->CV_Table=0; }
        if (pSes->pTalkInfo[i].pMem->CS_Table!=0) {delete pSes->pTalkInfo[i].pMem->CS_Table; pSes->pTalkInfo[i].pMem->CS_Table=0; }
    }
    //------終結 talk info
    if (pSes->ConnectNum>0)
    {
        delete pSes->pTalkInfo;
    }
    delete pSes;
    pSes=0;
}

int  InitTalkMem(TALK_INFO *pTalk)
{
    MIRROR_MEMORY *pMem = pTalk->pMem;
    if (!pMem->Inited)
    {
        pTalk->MediaResponseCount = 0;
        
        if (pMem->SizeI>0)
        {
            pMem->I_Table = new unsigned char[pMem->SizeI];
            memset(pMem->I_Table, 0x00, sizeof(unsigned char)*pMem->SizeI);
        }
        if (pMem->SizeO>0)
        {
            pMem->O_Table = new unsigned char[pMem->SizeO];
            memset(pMem->O_Table, 0x00, sizeof(unsigned char)*pMem->SizeO);
        }
        if (pMem->SizeC>0)
        {
            pMem->C_Table = new unsigned char[pMem->SizeC];
            memset(pMem->C_Table, 0x00, sizeof(unsigned char)*pMem->SizeC);
        }
        if (pMem->SizeS>0)
        {
            pMem->S_Table = new unsigned char[pMem->SizeS];
            memset(pMem->S_Table, 0x00, sizeof(unsigned char)*pMem->SizeS);
        }
        if (pMem->SizeA>0)
        {
            pMem->A_Table = new unsigned char[pMem->SizeA];
            memset(pMem->A_Table, 0x00, sizeof(unsigned char)*pMem->SizeA);
        }
        if (pMem->SizeR>0)
        {
            pMem->R_Table = new unsigned int[pMem->SizeR];
            memset(pMem->R_Table, 0x00, sizeof(int)*pMem->SizeR);
        }
        if (pMem->SizeF>0)
        {
            pMem->F_Table = new double[pMem->SizeF];
            memset(pMem->F_Table, 0x00, sizeof(double)*pMem->SizeF);
        }
        if (pMem->SizeTimer>0)
        {
            pMem->TT_Table = new unsigned char[pMem->SizeTimer];
            pMem->TV_Table = new unsigned int[pMem->SizeTimer];
            pMem->TS_Table = new unsigned int[pMem->SizeTimer];
            memset(pMem->TT_Table, 0x00, sizeof(unsigned char)*pMem->SizeTimer);
            memset(pMem->TV_Table, 0x00, sizeof(int)*pMem->SizeTimer);
            memset(pMem->TS_Table, 0x00, sizeof(int)*pMem->SizeTimer);
        }
        if (pMem->SizeCounter>0)
        {
            pMem->CT_Table = new unsigned char[pMem->SizeCounter];
            pMem->CV_Table = new unsigned int[pMem->SizeCounter];
            pMem->CS_Table = new unsigned int[pMem->SizeCounter];
            memset(pMem->CT_Table, 0x00, sizeof(unsigned char)*pMem->SizeCounter);
            memset(pMem->CV_Table, 0x00, sizeof(int)*pMem->SizeCounter);
            memset(pMem->CS_Table, 0x00, sizeof(int)*pMem->SizeCounter);

        }
        pMem->Inited = true;
    }
	return 1;
}


//=================== 連線相關的函式 ========================================
//=====直接輸入控制器IP進行連線
int  CLASS_RANGE ConnectLocalIP(int TgrConn, char* IP)
{
    if (pSes==0) return 0;
    if ((TgrConn<0)||(TgrConn>=pSes->ConnectNum)) return 0;
    TALK_INFO *pTalk = &pSes->pTalkInfo[TgrConn];
    InitTalkMem(pTalk);
//#ifdef __QT
//    QString IPStr;
//    IPStr.asprintf("%s", IP);
//    pTalk->ReconAddr.setAddress(IPStr);
//    pTalk->ReconPort = PORT_UDP_RECON;
//#else
    unsigned int IPLong = inet_addr(IP);
    pTalk->ReconAddr.sin_family = AF_INET;
    pTalk->ReconAddr.sin_addr.s_addr = IPLong;
    pTalk->ReconAddr.sin_port = htons(PORT_UDP_RECON);	  // short, network byte order
    memset(&(pTalk->ReconAddr.sin_zero), '\0', 8); // zero the rest of the struct
//#endif
    pTalk->Action=CONNECT_ACTION_TO_CONNECT;
    return 1;
}



//=====連線遠端主機
int  CLASS_RANGE ConnectRemote (int TgrConn, char *MediaIP, char* IP, int Port, int Pwd) //連線遠端主機
{
    if (pSes==0) return 0;
    if ((TgrConn<0)||(TgrConn>=pSes->ConnectNum)) return 0;
    TALK_INFO *pTalk = &pSes->pTalkInfo[TgrConn];
    InitTalkMem(pTalk);
    strcpy(pTalk->RemoteIP, IP);
    pTalk->RemotePort = Port;
    pTalk->RemotePwd = Pwd;
//#ifdef __QT
//    QString IPStr;
//    IPStr.asprintf("%s", IP);
//    pTalk->ReconAddr.setAddress(IPStr);
//    pTalk->RemoteIPLong = pTalk->ReconAddr.toIPv4Address();
//    IPStr.asprintf("%s", MediaIP);
//    pTalk->ReconAddr.setAddress(IPStr);
//    pTalk->ReconPort = PORT_UDP_MEDIA;
//#else
    pTalk->RemoteIPLong = inet_addr(IP);
    unsigned int IPLong = inet_addr(MediaIP);
    pTalk->ReconAddr.sin_family = AF_INET;
    pTalk->ReconAddr.sin_addr.s_addr = IPLong;
    pTalk->ReconAddr.sin_port = htons(PORT_UDP_MEDIA);	  // short, network byte order
    memset(&(pTalk->ReconAddr.sin_zero), '\0', 8); // zero the rest of the struct
//#endif
    pTalk->Action=CONNECT_ACTION_TO_REMOTE;
    return 1;
}




//=======中斷連線
int  CLASS_RANGE Disconnect(int TgrConn)
{
    if (pSes==0) return 0;
    if ((TgrConn<0)||(TgrConn>=pSes->ConnectNum)) return 0;
    TALK_INFO *pTalk = &pSes->pTalkInfo[TgrConn];

    pTalk->Action=CONNECT_ACTION_TO_DISCONNECT;  //
    return 1;
}

//設定連線密碼
int  CLASS_RANGE ConnectSetPwd(int TgrConn, char *Pwd)
{
    if (pSes==0) return 0;
    if ((TgrConn<0)||(TgrConn>=pSes->ConnectNum)) return 0;
    TALK_INFO *pTalk = &pSes->pTalkInfo[TgrConn];
    memcpy(pTalk->ConnectPwd, Pwd, 16);
    return 1;
}

//==============================================================================




//------------------------------ I
int CLASS_RANGE memI(int TgrConn, int addr)
{
    if (pSes==0) return 0;
    if ((TgrConn<0)||(TgrConn>=pSes->ConnectNum)) return 0;
    TALK_INFO *pTalk = &pSes->pTalkInfo[TgrConn];
    if (!pTalk->pMem->Inited) return 0;
    int AAddr = addr-pTalk->OffsetI;
    if ((AAddr<0)||(AAddr>=pTalk->pMem->SizeI)) return 0;
    return pTalk->pMem->I_Table[AAddr];
}
//------------------------------ O
int CLASS_RANGE memO(int TgrConn, int addr)
{
    if (pSes==0) return 0;
    if ((TgrConn<0)||(TgrConn>=pSes->ConnectNum)) return 0;
    TALK_INFO *pTalk = &pSes->pTalkInfo[TgrConn];
    if (!pTalk->pMem->Inited) return 0;
    int AAddr = addr-pTalk->OffsetO;
    if ((AAddr<0)||(AAddr>=pTalk->pMem->SizeO)) return 0;
    return pTalk->pMem->O_Table[AAddr];
}
//------------------------------ C
int CLASS_RANGE memC(int TgrConn, int addr)
{
    if (pSes==0) return 0;
    if ((TgrConn<0)||(TgrConn>=pSes->ConnectNum)) return 0;
    TALK_INFO *pTalk = &pSes->pTalkInfo[TgrConn];
    if (!pTalk->pMem->Inited) return 0;
    int AAddr = addr-pTalk->OffsetC;
    if ((AAddr<0)||(AAddr>=pTalk->pMem->SizeC)) return 0;
    return pTalk->pMem->C_Table[AAddr];
}
//------------------------------ S
int CLASS_RANGE memS(int TgrConn, int addr)
{
    if (pSes==0) return 0;
    if ((TgrConn<0)||(TgrConn>=pSes->ConnectNum)) return 0;
    TALK_INFO *pTalk = &pSes->pTalkInfo[TgrConn];
    if (!pTalk->pMem->Inited) return 0;
    int AAddr = addr-pTalk->OffsetS;
    if ((AAddr<0)||(AAddr>=pTalk->pMem->SizeS)) return 0;
    return pTalk->pMem->S_Table[AAddr];
}
//------------------------------ A
int CLASS_RANGE memA(int TgrConn, int addr)
{
    if (pSes==0) return 0;
    if ((TgrConn<0)||(TgrConn>=pSes->ConnectNum)) return 0;
    TALK_INFO *pTalk = &pSes->pTalkInfo[TgrConn];
    if (!pTalk->pMem->Inited) return 0;
    int AAddr = addr-pTalk->OffsetA;
    if ((AAddr<0)||(AAddr>=pTalk->pMem->SizeA)) return 0;
    return pTalk->pMem->A_Table[AAddr];
}

//------------------------------ R
int  CLASS_RANGE memR(int TgrConn, int addr)
{
    if (pSes==0) return 0;
    if ((TgrConn<0)||(TgrConn>=pSes->ConnectNum)) return 0;
    TALK_INFO *pTalk = &pSes->pTalkInfo[TgrConn];
    if (!pTalk->pMem->Inited) return 0;
    int AAddr = addr-pTalk->OffsetR;
    if ((AAddr<0)||(AAddr>=pTalk->pMem->SizeR)) return 0;
    return pTalk->pMem->R_Table[AAddr];
}

//------------------------------ R
char*  CLASS_RANGE memRPtr(int TgrConn, int addr)
{
    if (pSes==0) return 0;
    if ((TgrConn<0)||(TgrConn>=pSes->ConnectNum)) return 0;
    TALK_INFO *pTalk = &pSes->pTalkInfo[TgrConn];
    if (!pTalk->pMem->Inited) return 0;
    int AAddr = addr-pTalk->OffsetR;
    if ((AAddr<0)||(AAddr>=pTalk->pMem->SizeR)) return 0;
    return (char *)(&pTalk->pMem->R_Table[AAddr]);
}


//------------------------------ R
int  CLASS_RANGE memRBit(int TgrConn, int addr, int BitIdx)
{
    if (pSes==0) return 0;
    if ((TgrConn<0)||(TgrConn>=pSes->ConnectNum)) return 0;
    TALK_INFO *pTalk = &pSes->pTalkInfo[TgrConn];
    if (!pTalk->pMem->Inited) return 0;
    int AAddr = addr-pTalk->OffsetR;
    if ((AAddr<0)||(AAddr>=pTalk->pMem->SizeR)) return 0;
    int tmp = pTalk->pMem->R_Table[AAddr];
    if ((tmp & (1<<BitIdx))!=0) return 1;
    else                        return 0;
}

//----------字串讀取
int  CLASS_RANGE memRString(int TgrConn, int addr, int RSize, char *Buf )
{
    if (pSes==0) return 0;
    if ((TgrConn<0)||(TgrConn>=pSes->ConnectNum)) return 0;
    TALK_INFO *pTalk = &pSes->pTalkInfo[TgrConn];
    if (!pTalk->pMem->Inited) return 0;
    int AAddr = addr-pTalk->OffsetR;
    if ((AAddr<0)||(AAddr>=pTalk->pMem->SizeR)) return 0;

    char *pChar;
    int i;
    int BufSize = RSize*4;
    memset(Buf, 0, BufSize);
    pChar = (char *)(&pTalk->pMem->R_Table[AAddr]);
    //檢查是否有0
    for (i=0; i<BufSize; i++)
    {
        if (pChar[i]==0) break;
    }
    memcpy(Buf, pChar, BufSize);
    if (i<BufSize)
    {
        memcpy(Buf, pChar, i);
        return i;
    }
    else
    {
        return 0;
    }
}

//------------------------------ F
double CLASS_RANGE memF(int TgrConn, int addr)
{
    if (pSes==0) return 0;
    if ((TgrConn<0)||(TgrConn>=pSes->ConnectNum)) return 0;
    TALK_INFO *pTalk = &pSes->pTalkInfo[TgrConn];
    if (!pTalk->pMem->Inited) return 0;
    int AAddr = addr-pTalk->OffsetF;
    if ((AAddr<0)||(AAddr>=pTalk->pMem->SizeF)) return 0;
    return pTalk->pMem->F_Table[AAddr];
}


//------------------------------ TS
int CLASS_RANGE memTS(int TgrConn, int addr)
{
    if (pSes==0) return 0;
    if ((TgrConn<0)||(TgrConn>=pSes->ConnectNum)) return 0;
    TALK_INFO *pTalk = &pSes->pTalkInfo[TgrConn];
    if (!pTalk->pMem->Inited) return 0;
    int AAddr = addr-pTalk->OffsetTimer;
    if ((AAddr<0)||(AAddr>=pTalk->pMem->SizeTimer)) return 0;
    return pTalk->pMem->TS_Table[AAddr];
}

//------------------------------ TV
int CLASS_RANGE memTV(int TgrConn, int addr)
{
    if (pSes==0) return 0;
    if ((TgrConn<0)||(TgrConn>=pSes->ConnectNum)) return 0;
    TALK_INFO *pTalk = &pSes->pTalkInfo[TgrConn];
    if (!pTalk->pMem->Inited) return 0;
    int AAddr = addr-pTalk->OffsetTimer;
    if ((AAddr<0)||(AAddr>=pTalk->pMem->SizeTimer)) return 0;
    return pTalk->pMem->TV_Table[AAddr];
}

//------------------------------ TT
int CLASS_RANGE memTT(int TgrConn, int addr)
{
    if (pSes==0) return 0;
    if ((TgrConn<0)||(TgrConn>=pSes->ConnectNum)) return 0;
    TALK_INFO *pTalk = &pSes->pTalkInfo[TgrConn];
    if (!pTalk->pMem->Inited) return 0;
    int AAddr = addr-pTalk->OffsetTimer;
    if ((AAddr<0)||(AAddr>=pTalk->pMem->SizeTimer)) return 0;
    return pTalk->pMem->TT_Table[AAddr];
}


//------------------------------ CS
int CLASS_RANGE memCS(int TgrConn, int addr)
{
    if (pSes==0) return 0;
    if ((TgrConn<0)||(TgrConn>=pSes->ConnectNum)) return 0;
    TALK_INFO *pTalk = &pSes->pTalkInfo[TgrConn];
    if (!pTalk->pMem->Inited) return 0;
    int AAddr = addr-pTalk->OffsetTimer;
    if ((AAddr<0)||(AAddr>=pTalk->pMem->SizeCounter)) return 0;
    return pTalk->pMem->CS_Table[AAddr];
}

//------------------------------ CV
int CLASS_RANGE memCV(int TgrConn, int addr)
{
    if (pSes==0) return 0;
    if ((TgrConn<0)||(TgrConn>=pSes->ConnectNum)) return 0;
    TALK_INFO *pTalk = &pSes->pTalkInfo[TgrConn];
    if (!pTalk->pMem->Inited) return 0;
    int AAddr = addr-pTalk->OffsetTimer;
    if ((AAddr<0)||(AAddr>=pTalk->pMem->SizeCounter)) return 0;
    return pTalk->pMem->CV_Table[AAddr];
}

//------------------------------ CT
int CLASS_RANGE memCT(int TgrConn, int addr)
{
    if (pSes==0) return 0;
    if ((TgrConn<0)||(TgrConn>=pSes->ConnectNum)) return 0;
    TALK_INFO *pTalk = &pSes->pTalkInfo[TgrConn];
    if (!pTalk->pMem->Inited) return 0;
    int AAddr = addr-pTalk->OffsetTimer;
    if ((AAddr<0)||(AAddr>=pTalk->pMem->SizeCounter)) return 0;
    return pTalk->pMem->CT_Table[AAddr];
}





//------------------------------ O
int CLASS_RANGE memSetO(int TgrConn, int addr, char val)
{
    if (pSes==0) return 0;
    if ((TgrConn<0)||(TgrConn>=pSes->ConnectNum)) return 0;
    TALK_INFO *pTalk = &pSes->pTalkInfo[TgrConn];
    if (!pTalk->pMem->Inited) return 0;
    int AAddr = addr-pTalk->OffsetO;
    if ((AAddr<0)||(AAddr>=pTalk->pMem->SizeO)) return 0;
    pTalk->pMem->O_Table[AAddr] = val;
    return 1;
}
//------------------------------ C
int CLASS_RANGE memSetC(int TgrConn, int addr, char val)
{
    if (pSes==0) return 0;
    if ((TgrConn<0)||(TgrConn>=pSes->ConnectNum)) return 0;
    TALK_INFO *pTalk = &pSes->pTalkInfo[TgrConn];
    if (!pTalk->pMem->Inited) return 0;
    int AAddr = addr-pTalk->OffsetC;
    if ((AAddr<0)||(AAddr>=pTalk->pMem->SizeC)) return 0;
    pTalk->pMem->C_Table[AAddr] = val;
    return 1;
}
//------------------------------ S
int CLASS_RANGE memSetS(int TgrConn, int addr, char val)
{
    if (pSes==0) return 0;
    if ((TgrConn<0)||(TgrConn>=pSes->ConnectNum)) return 0;
    TALK_INFO *pTalk = &pSes->pTalkInfo[TgrConn];
    if (!pTalk->pMem->Inited) return 0;
    int AAddr = addr-pTalk->OffsetS;
    if ((AAddr<0)||(AAddr>=pTalk->pMem->SizeS)) return 0;
    pTalk->pMem->S_Table[AAddr] = val;
    return 1;
}
//------------------------------ A
int CLASS_RANGE memSetA(int TgrConn, int addr, char val)
{
    if (pSes==0) return 0;
    if ((TgrConn<0)||(TgrConn>=pSes->ConnectNum)) return 0;
    TALK_INFO *pTalk = &pSes->pTalkInfo[TgrConn];
    if (!pTalk->pMem->Inited) return 0;
    int AAddr = addr-pTalk->OffsetA;
    if ((AAddr<0)||(AAddr>=pTalk->pMem->SizeA)) return 0;
    pTalk->pMem->A_Table[AAddr] = val;
    return 1;
}

//------------------------------ R
int  CLASS_RANGE memSetR(int TgrConn, int addr, int val)
{
    if (pSes==0) return 0;
    if ((TgrConn<0)||(TgrConn>=pSes->ConnectNum)) return 0;
    TALK_INFO *pTalk = &pSes->pTalkInfo[TgrConn];
    if (!pTalk->pMem->Inited) return 0;
    int AAddr = addr-pTalk->OffsetR;
    if ((AAddr<0)||(AAddr>=pTalk->pMem->SizeR)) return 0;
    pTalk->pMem->R_Table[AAddr] = val;
    return 1;
}


//------------------------------ R
int  CLASS_RANGE memSetRBit(int TgrConn, int addr, int BitIdx, int val)
{
    if (pSes==0) return 0;
    if ((TgrConn<0)||(TgrConn>=pSes->ConnectNum)) return 0;
    TALK_INFO *pTalk = &pSes->pTalkInfo[TgrConn];
    if (!pTalk->pMem->Inited) return 0;
    int AAddr = addr-pTalk->OffsetR;
    if ((AAddr<0)||(AAddr>=pTalk->pMem->SizeR)) return 0;
    if ((BitIdx<0)||(BitIdx>31)) return 0;

    int tmp = pTalk->pMem->R_Table[AAddr];
    if (val==0) tmp &= (~(1<<BitIdx));
    else        tmp |= (1<<BitIdx);
    pTalk->pMem->R_Table[AAddr] = val;
    return 1;
}


//----------字串讀取
int CLASS_RANGE memSetRString(int TgrConn, int addr, int RSize, char *Buf )
{
    if (pSes==0) return 0;
    if ((TgrConn<0)||(TgrConn>=pSes->ConnectNum)) return 0;
    TALK_INFO *pTalk = &pSes->pTalkInfo[TgrConn];
    if (!pTalk->pMem->Inited) return 0;
    int AAddr = addr-pTalk->OffsetR;
    if ((AAddr<0)||(AAddr>=pTalk->pMem->SizeR)) return 0;

    char *pChar;
    int i;
    int BufSize = RSize*4;
    pChar = (char *)(&pTalk->pMem->R_Table[AAddr]);
    memset(pChar, 0x00, BufSize);
    //檢查是否有0
    for (i=0; i<BufSize; i++)
    {
        pChar[i] = Buf[i];
        if (Buf[i]==0) break;
    }
    return 1;
}


//------------------------------ F
int CLASS_RANGE memSetF(int TgrConn, int addr, double val)
{
    if (pSes==0) return 0;
    if ((TgrConn<0)||(TgrConn>=pSes->ConnectNum)) return 0;
    TALK_INFO *pTalk = &pSes->pTalkInfo[TgrConn];
    if (!pTalk->pMem->Inited) return 0;
    int AAddr = addr-pTalk->OffsetF;
    if ((AAddr<0)||(AAddr>=pTalk->pMem->SizeF)) return 0;
    pTalk->pMem->F_Table[AAddr] = val;
    return 1;
}
//==============================================================================


//--==================================檔案傳輸功能=================================
//上傳檔案
int  CLASS_RANGE FtpSetConnection(int TgrConn)
{
    if (pSes==0) return 0;
    if ((TgrConn<0)||(TgrConn>=pSes->ConnectNum)) return 0;
    if (pSes->FtpInfo.Result==FTP_RESULT_PROCESSING) return 0;
    pSes->FtpTalkIdx = TgrConn;
    return 1;
}

//上傳檔案
int  CLASS_RANGE FtpUpload1File(int Folder, char *SubFolder, char *Filename, char *LocalFilename)
{
    if (pSes==0) return 0;
    if ((pSes->FtpTalkIdx<0)||(pSes->FtpTalkIdx>=pSes->ConnectNum)) return 0;
    if (pSes->pTalkInfo[pSes->FtpTalkIdx].ConnState!=SC_CONN_STATE_OK) return 0;   //未連線不可傳輸
    if (pSes->FtpInfo.Result==FTP_RESULT_PROCESSING) return 0;
    if (pSes->FtpInfo.Action!=FTP_ACTION_IDLE) return 0;
    if (pSes->FtpInfo.TryTimes>0) return 0;
    pSes->FtpInfo.State = FTP_STATE_PENDING;
    pSes->FtpInfo.Folder = Folder;
    strcpy(pSes->FtpInfo.SubFolder, SubFolder);
    strcpy(pSes->FtpInfo.FileName, Filename);
    strcpy(pSes->FtpInfo.LocalName, LocalFilename);
    pSes->FtpInfo.Action = FTP_ACTION_TO_UPLOAD_FILE;
    return 1;
}

//下載檔案
int  CLASS_RANGE FtpDownload1File(int Folder, char *SubFolder, char *Filename, char *LocalFilename)
{
    if (pSes==0) return 0;
    if ((pSes->FtpTalkIdx<0)||(pSes->FtpTalkIdx>=pSes->ConnectNum)) return 0;
    if (pSes->pTalkInfo[pSes->FtpTalkIdx].ConnState!=SC_CONN_STATE_OK) return 0;   //未連線不可傳輸
    if (pSes->FtpInfo.Result==FTP_RESULT_PROCESSING) return 0;
    if (pSes->FtpInfo.Action!=FTP_ACTION_IDLE) return 0;
    if (pSes->FtpInfo.TryTimes>0) return 0;
    pSes->FtpInfo.State = FTP_STATE_PENDING;
    pSes->FtpInfo.Folder = Folder;
    strcpy(pSes->FtpInfo.SubFolder, SubFolder);
    strcpy(pSes->FtpInfo.FileName, Filename);
    strcpy(pSes->FtpInfo.LocalName, LocalFilename);
    pSes->FtpInfo.Action = FTP_ACTION_TO_DOWNLOAD_FILE;
    return 1;
}

//刪除檔案
int  CLASS_RANGE FtpDelete1File(int Folder, char *SubFolder, char *Filename)
{
    if (pSes==0) return 0;
    if ((pSes->FtpTalkIdx<0)||(pSes->FtpTalkIdx>=pSes->ConnectNum)) return 0;
    if (pSes->pTalkInfo[pSes->FtpTalkIdx].ConnState!=SC_CONN_STATE_OK) return 0;   //未連線不可傳輸
    if (pSes->FtpInfo.Result==FTP_RESULT_PROCESSING) return 0;
    if (pSes->FtpInfo.Action!=FTP_ACTION_IDLE) return 0;
    if (pSes->FtpInfo.TryTimes>0) return 0;
    pSes->FtpInfo.State = FTP_STATE_PENDING;
    pSes->FtpInfo.Folder = Folder;
    strcpy(pSes->FtpInfo.SubFolder, SubFolder);
    strcpy(pSes->FtpInfo.FileName, Filename);
    pSes->FtpInfo.Action = FTP_ACTION_TO_DELETE_FILE;
    return 1;
}


//=====================增加幾個函式，方便 C# 使用=================
int  CLASS_RANGE FtpTransferFileReset()
{
    if (pSes==0) return 0;
    if ((pSes->FtpTalkIdx<0)||(pSes->FtpTalkIdx>=pSes->ConnectNum)) return 0;
    if (pSes->pTalkInfo[pSes->FtpTalkIdx].ConnState!=SC_CONN_STATE_OK) return 0;   //未連線不可傳輸
    if (pSes->FtpInfo.Result==FTP_RESULT_PROCESSING) return 0;
    if (pSes->FtpInfo.Action!=FTP_ACTION_IDLE) return 0;
    if (pSes->FtpInfo.TryTimes>0) return 0;
    pSes->FtpInfo.TransferCount = 0;
    return 1;
}

int  CLASS_RANGE FtpTransferFileAdd(int Folder, char *SubFolder, char *Filename, char *LocalFilename)
{
    if (pSes==0) return 0;
    if ((pSes->FtpTalkIdx<0)||(pSes->FtpTalkIdx>=pSes->ConnectNum)) return 0;
    if (pSes->pTalkInfo[pSes->FtpTalkIdx].ConnState!=SC_CONN_STATE_OK) return 0;   //未連線不可傳輸
    if (pSes->FtpInfo.Result==FTP_RESULT_PROCESSING) return 0;
    if (pSes->FtpInfo.Action!=FTP_ACTION_IDLE) return 0;
    if (pSes->FtpInfo.TryTimes>0) return 0;
    if (pSes->FtpInfo.TransferCount>=MAX_TRANSFER_FILE_COUNT) return 0;
    int k;
    k=pSes->FtpInfo.TransferCount;
    pSes->FtpInfo.TransferFiles[k].Folder = Folder;
    memcpy(pSes->FtpInfo.TransferFiles[k].SubFolder, SubFolder, 32);
    memcpy(pSes->FtpInfo.TransferFiles[k].Filename, Filename, 32);
    memcpy(pSes->FtpInfo.TransferFiles[k].LocalFilename, LocalFilename, 256);
    pSes->FtpInfo.TransferCount++;
    return 1;
}

int  CLASS_RANGE FtpUploadFiles()
{
    if (pSes==0) return 0;
    if ((pSes->FtpTalkIdx<0)||(pSes->FtpTalkIdx>=pSes->ConnectNum)) return 0;
    if (pSes->pTalkInfo[pSes->FtpTalkIdx].ConnState!=SC_CONN_STATE_OK) return 0;   //未連線不可傳輸
    if (pSes->FtpInfo.Result==FTP_RESULT_PROCESSING) return 0;
    if (pSes->FtpInfo.Action!=FTP_ACTION_IDLE) return 0;
    if (pSes->FtpInfo.TryTimes>0) return 0;
    if (pSes->FtpInfo.TransferCount==0) return 0;
    pSes->FtpInfo.State = FTP_STATE_PENDING;
    pSes->FtpInfo.TransferIndex = 0;
    pSes->FtpInfo.Action = FTP_ACTION_TO_UPLOAD_FILES;
    return 1;
}

int  CLASS_RANGE FtpDownloadFiles()
{
    if (pSes==0) return 0;
    if ((pSes->FtpTalkIdx<0)||(pSes->FtpTalkIdx>=pSes->ConnectNum)) return 0;
    if (pSes->pTalkInfo[pSes->FtpTalkIdx].ConnState!=SC_CONN_STATE_OK) return 0;   //未連線不可傳輸
    if (pSes->FtpInfo.Result==FTP_RESULT_PROCESSING) return 0;
    if (pSes->FtpInfo.Action!=FTP_ACTION_IDLE) return 0;
    if (pSes->FtpInfo.TryTimes>0) return 0;
    if (pSes->FtpInfo.TransferCount==0) return 0;
    pSes->FtpInfo.State = FTP_STATE_PENDING;
    pSes->FtpInfo.TransferIndex = 0;
    pSes->FtpInfo.Action = FTP_ACTION_TO_DOWNLOAD_FILES;
    return 1;
}

int  CLASS_RANGE FtpDeleteFiles()
{
    if (pSes==0) return 0;
    if ((pSes->FtpTalkIdx<0)||(pSes->FtpTalkIdx>=pSes->ConnectNum)) return 0;
    if (pSes->pTalkInfo[pSes->FtpTalkIdx].ConnState!=SC_CONN_STATE_OK) return 0;   //未連線不可傳輸
    if (pSes->FtpInfo.Result==FTP_RESULT_PROCESSING) return 0;
    if (pSes->FtpInfo.Action!=FTP_ACTION_IDLE) return 0;
    if (pSes->FtpInfo.TryTimes>0) return 0;
    if (pSes->FtpInfo.TransferCount==0) return 0;
    pSes->FtpInfo.State = FTP_STATE_PENDING;
    pSes->FtpInfo.TransferIndex = 0;
    pSes->FtpInfo.Action = FTP_ACTION_TO_DELETE_FILES;
    return 1;
}



//建立資料夾
int  CLASS_RANGE FtpMakeDir(int Folder, char *DirName)
{
    if (pSes==0) return 0;
    if ((pSes->FtpTalkIdx<0)||(pSes->FtpTalkIdx>=pSes->ConnectNum)) return 0;
    if (pSes->pTalkInfo[pSes->FtpTalkIdx].ConnState!=SC_CONN_STATE_OK) return 0;   //未連線不可傳輸
    if (pSes->FtpInfo.Result==FTP_RESULT_PROCESSING) return 0;
    if (pSes->FtpInfo.Action!=FTP_ACTION_IDLE) return 0;
    if (pSes->FtpInfo.TryTimes>0) return 0;
    pSes->FtpInfo.State = FTP_STATE_PENDING;
    pSes->FtpInfo.Folder = Folder;
    strcpy(pSes->FtpInfo.FileName, DirName);
    pSes->FtpInfo.Action = FTP_ACTION_TO_MAKE_DIR;
    return 1;
}


//取得檔案清單 ------- 增加此項，以取得子目錄的內容
int  CLASS_RANGE FtpGetFileList(int Folder, char *SubFolder, char *HeadFilter, char *TailFilter)
{
    if (pSes==0) return 0;
    if ((pSes->FtpTalkIdx<0)||(pSes->FtpTalkIdx>=pSes->ConnectNum)) return 0;
    if (pSes->pTalkInfo[pSes->FtpTalkIdx].ConnState!=SC_CONN_STATE_OK) return 0;   //未連線不可傳輸
    if (pSes->FtpInfo.Result==FTP_RESULT_PROCESSING) return 0;
    if (pSes->FtpInfo.Action!=FTP_ACTION_IDLE) return 0;
    if (pSes->FtpInfo.TryTimes>0) return 0;
    pSes->FtpInfo.State = FTP_STATE_PENDING;
    pSes->FtpInfo.Folder = Folder;
    strcpy(pSes->FtpInfo.SubFolder, SubFolder);
    strcpy(pSes->FtpInfo.HeadFilter, HeadFilter);
    strcpy(pSes->FtpInfo.TailFilter, TailFilter);
    pSes->FtpInfo.Action = FTP_ACTION_TO_LIST_FILE;
    return 1;
}


//取得執行結果
int  CLASS_RANGE FtpCheckDone()
{
    if (pSes==0) return 0;
    if (pSes->FtpInfo.FtpDone)
    {
        pSes->FtpInfo.FtpDone = 0;
        //pSes->FtpInfo.LastState = pSes->FtpInfo.State;
        //pSes->FtpInfo.LastResult = pSes->FtpInfo.Result;
        //pSes->FtpInfo.State = FTP_STATE_IDLE;
        //pSes->FtpInfo.Result = FTP_RESULT_IDLE;
        return 1;
    }
    else
    {
        return 0;
    }
}
           
int  CLASS_RANGE FtpWaitDone(int MaxWaitTime)
{
    if (pSes==0) return 0;
    unsigned int TimePassed;
    MainProcess();
    TimePassed=0;
    while (1)
    {
        MicroSleep(20000);
        TimePassed+=MainProcess();
        if (pSes->FtpInfo.FtpDone)
        {
            pSes->FtpInfo.FtpDone = 0;
            //pSes->FtpInfo.LastState = pSes->FtpInfo.State;
            //pSes->FtpInfo.LastResult = pSes->FtpInfo.Result;
            //pSes->FtpInfo.State = FTP_STATE_IDLE;
            //pSes->FtpInfo.Result = FTP_RESULT_IDLE;
            return 1;
        }
        if (TimePassed>=(MaxWaitTime*1000)) return 0;
    }
}


//讀取FTP檔案清單筆數
int  CLASS_RANGE FtpReadFileCount()
{
    if (pSes==0) return 0;
    return pSes->FtpInfo.FileCount;
}

//讀取FTP檔案名稱
int  CLASS_RANGE FtpReadFile(int Index, FTP_FILE *file)
{
    if (pSes==0) return 0;
    if (Index<pSes->FtpInfo.FileCount)
    {
        memcpy(file, &pSes->FtpInfo.FileLists[Index], sizeof(FTP_FILE));
        return 1;
    }
    else
    {
        return 0;
    }
}

//取得本地端檔案清單
int  CLASS_RANGE LocalGetFileList(char *Path, char *HeadFilter, char *TailFilter)
{
    if (pSes==0) return 0;
    FTP_INFO *pFtp = &pSes->FtpInfo;
    int retValue, rt;
    struct stat buf;
    time_t tt;
    struct tm *tm1;
    char filename[200];
    char Fullname[200];
    unsigned short i, lenName, lenHead=0, lenTail=0;
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
    pFtp->LocalFileCount = 0;
    strcpy(pFtp->LocalPath, Path);

#ifdef __VC
	WIN32_FIND_DATA   wfd;
	WIN32_FIND_DATA  fd;
    int n; //ifd, ofd;
	HANDLE hFind;
	hFind = FindFirstFile(Path, &wfd);
	if ((hFind != INVALID_HANDLE_VALUE) && (wfd.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY))
	{
		FindClose(hFind);
        sprintf(Fullname, "%s\\*.*", Path);
		hFind = FindFirstFile(Fullname, &fd);
		while (hFind != INVALID_HANDLE_VALUE)
		{
            n = strcmp(filename, fd.cFileName);
            if (n==0) break;
			if (!(fd.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY))
			{
                Pass = 1;
                if ((Pass)&&(lenHead>0))
                {
                	rt = memcmp(fd.cFileName, HeadFilter, lenHead);
                    if (rt!=0) Pass=0;
                }
                if ((Pass)&&(lenTail>0))
                {
                    //-----檢查 Head 長度
                    for (i=0; i<260; i++)
                    {
                        if (fd.cFileName[i]==0)
                        {
                            lenName = i;
                            break;
                        }
                    }
                	rt = memcmp(fd.cFileName+(lenName-lenTail), TailFilter, lenTail);
                    if (rt!=0) Pass=0;
                }
                //設定清單
                if (Pass)
                {
                    memcpy(pFtp->LocalFileLists[pFtp->LocalFileCount].filename, fd.cFileName, FILENAME_LENGTH);
                    pFtp->LocalFileCount++;
                }
				if (pFtp->LocalFileCount>=MAX_FILE_LIST_NUM) break;
			}  
        	strcpy(filename, fd.cFileName);
			FindNextFile( hFind, &fd);
		}
		retValue = pFtp->LocalFileCount;
	}
	else
	{
		retValue = 0;
	}
	FindClose(hFind);
#else
    DIR *dp;
    struct dirent *dirp;
    dp = opendir(Path);
    if (dp != NULL)
    {
        while ((dirp = readdir(dp)) != NULL)
        {
            if (dirp->d_name[0]!='.')
            {
                Pass = 1;

                sprintf(Fullname, "%s\\%s\0", Path, dirp->d_name);
                if (stat(Fullname, &buf)>=0)
                {
                    //Pass=(buf.st_mode&0x8000);
                    Pass=((buf.st_mode & S_IFMT)==S_IFREG);
                }
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
                //設定清單
                if (Pass)
                {
                    memcpy(pFtp->LocalFileLists[pFtp->LocalFileCount].filename, dirp->d_name, FILENAME_LENGTH);
                    pFtp->LocalFileCount++;
                }
            }
            //else if (dirp == NULL) break;
            if (pFtp->LocalFileCount>=MAX_FILE_LIST_NUM) break;
        }
        closedir(dp);
        retValue = pFtp->LocalFileCount;
    }
    else
    {
        retValue = 0;
    }
#endif

    //取得檔案屬性
    if (retValue>0)
    {
        for (i=0; i<retValue; i++)
        {
            //取得檔案屬性
            sprintf(Fullname, "%s\\%s", Path, pFtp->LocalFileLists[i].filename);
            if (stat(Fullname, &buf)>=0)
            {
                if (buf.st_mode&0x8000)
                {
                    pFtp->LocalFileLists[i].filesize = buf.st_size;
                    tt = time_t(buf.st_mtime);
                    tm1 = localtime(&tt);
                    pFtp->LocalFileLists[i].year = tm1->tm_year+1900;
                    pFtp->LocalFileLists[i].month = tm1->tm_mon+1;
                    pFtp->LocalFileLists[i].day = tm1->tm_mday;
                    pFtp->LocalFileLists[i].hour = tm1->tm_hour;
                    pFtp->LocalFileLists[i].minute = tm1->tm_min;
                    pFtp->LocalFileLists[i].second = tm1->tm_sec;
                }
            }
        }
    }
    return retValue;
}

//讀取本地檔案清單筆數
int  CLASS_RANGE LocalReadFileCount()
{
    if (pSes==0) return 0;
    return pSes->FtpInfo.LocalFileCount;
}

//讀取本地檔案名稱
int  CLASS_RANGE LocalReadFile(int Index, FTP_FILE *file)
{
    if (pSes==0) return 0;
    if (Index<pSes->FtpInfo.LocalFileCount)
    {
        memcpy(file, &pSes->FtpInfo.LocalFileLists[Index], sizeof(FTP_FILE));
        return 1;
    }
    else
    {
        return 0;
    }
}

//刪除本地檔案名稱
int  CLASS_RANGE LocalDeleteFile(int Index)
{
    if (pSes==0) return 0;
    if (Index>=pSes->FtpInfo.LocalFileCount) return 0;
    char fullname[260];
    sprintf(fullname, "%s\\%s", pSes->FtpInfo.LocalPath, pSes->FtpInfo.LocalFileLists[Index].filename);
    if (remove(fullname)!=-1) return 1;
    else                      return 0;
}


//==============================================================================




//==================================================================
int    CLASS_RANGE GetLibraryMsg(int MsgID )
{
    if (pSes==0) return 0;
    switch(MsgID)
    {
    //
    case SCIF_PROC_COUNTER:        return pSes->ProcCounter;
    case SCIF_FTP_STATE:           return pSes->FtpInfo.State;
    case SCIF_FTP_RESULT:          return pSes->FtpInfo.Result;
    case SCIF_FTP_STEP:            return pSes->FtpInfo.StepIndex;
    case SCIF_FTP_TOTAL_PACKAGE:   return pSes->FtpInfo.TotalIdx;
    case SCIF_FTP_CURRENT_PACKAGE: return pSes->FtpInfo.CurrentIdx;
    case SCIF_FTP_TOTAL_FILE:      return pSes->FtpInfo.TransferCount;
    case SCIF_FTP_CURRENT_FILE:    return pSes->FtpInfo.TransferIndex;

    case SCIF_MAKER_ID:            return pSes->Funcs.MakerID;

    case SCIF_MEM_SIZE_I:    return pSes->MemSizeI;
    case SCIF_MEM_SIZE_O:    return pSes->MemSizeO;
    case SCIF_MEM_SIZE_C:    return pSes->MemSizeC;
    case SCIF_MEM_SIZE_S:    return pSes->MemSizeS;
    case SCIF_MEM_SIZE_A:    return pSes->MemSizeA;
    case SCIF_MEM_SIZE_R:    return pSes->MemSizeR;
    case SCIF_MEM_SIZE_F:    return pSes->MemSizeF;
    case SCIF_MEM_SIZE_TIMER:    return pSes->MemSizeTimer;
    case SCIF_MEM_SIZE_COUNTER:    return pSes->MemSizeCounter;
    default: return 0;
    }
    return 0;
}

//==================================================================
int    CLASS_RANGE GetConnectionMsg(int TgrConn, int MsgID )
{
    if (pSes==0) return 0;
    if ((TgrConn<0)||(TgrConn>=pSes->ConnectNum)) return 0;
    TALK_INFO *pTalk = &pSes->pTalkInfo[TgrConn];
    //---------------與 talk 相關的訊息
    switch(MsgID)
    {
    case SCIF_CONNECT_STATE:             return pTalk->ConnState;
#ifdef __QT
    case SCIF_REMOTE_IPLONG:             return pTalk->ReconAddr.sin_addr.S_un.S_addr;
#endif
#ifdef __BCB
    case SCIF_REMOTE_IPLONG:             return pTalk->ReconAddr.sin_addr.S_un.S_addr;
#endif
#ifdef __VC_DLL
    case SCIF_REMOTE_IPLONG:             return pTalk->ReconAddr.sin_addr.S_un.S_addr;
#endif
    case SCIF_CONNECT_STEP:              return pTalk->StepIndex;
    case SCIF_CONNECT_RESPONSE:          return pTalk->ConnectResponse;
    case SCIF_TALK_STATE:                return pTalk->TalkState;
        //---
    case SCIF_MY_INTERNET_IPLONG:        return pTalk->MyInternetIPLong;
    case SCIF_MY_INTERNET_PORT:          return pTalk->MyInternetPort;
    case SCIF_MEDIA_RSP_COUNT:           return pTalk->MediaResponseCount;
        //
    case SCIF_RESPONSE_TIME:             return pTalk->ResponseTime;
    case SCIF_OK_COUNT:                  return pTalk->Section.RxPkgCnt;
    case SCIF_CRC_ERR_CNT:               return pTalk->Section.RxCrcPkgCnt;
    case SCIF_TX_PKG_CNT:                return pTalk->Section.TxPkgCnt;
    case SCIF_TX_PKG_RETRY_CNT:          return pTalk->Section.TxPkgRetryCnt;
    case SCIF_TX_CONNECT_CNT:            return pTalk->Section.TxConnectCnt;
    case SCIF_RX_UNEXPECT_CNT:           return pTalk->Section.RxUnExpectCnt;
    case SCIF_RX_ERR_FMT_CNT:            return pTalk->Section.RxErrFmtCnt;
    case SCIF_RX_CONNECT_CNT:            return pTalk->Section.RxConnectCnt;

    //
    case SCIF_LOOP_QUEUE_PKG_COUNT:      return pTalk->LoopQueue.WriteAddr;
    case SCIF_DIRECT_QUEUE_PKG_COUNT:    return (pTalk->DirectQueue.WriteAddr-pTalk->DirectQueue.ReadAddr)&DIRECT_ADDR_MASK;
    case SCIF_LOOP_COUNT:                return pTalk->LoopCount;
    }
    return 0;
}

//=====================================================================
void  CLASS_RANGE GetConnectionError(int TgrConn, ERROR_MSG *Msg)
{
    if (pSes==0) return;
    Msg->Type = 0;
    Msg->Cmd  = 0;
    Msg->addr = 0;
    Msg->num  = 0;
    Msg->Error = 0;
    if ((TgrConn<0)||(TgrConn>=pSes->ConnectNum)) return;
    TALK_INFO *pTalk = &pSes->pTalkInfo[TgrConn];

    Msg->Type = pTalk->ErrRec.Type;
    Msg->Cmd  = pTalk->ErrRec.Cmd;
    Msg->addr = pTalk->ErrRec.addr;
    Msg->num  = pTalk->ErrRec.num;
    Msg->Error = pTalk->ErrRec.Error;
    pTalk->ErrRec.Type=0;
    pTalk->ErrRec.Error=0;
    pTalk->ErrRec.Cmd=0;
    pTalk->ErrRec.addr=0;
    pTalk->ErrRec.num=0;
}


//============================= 取得通訊處理狀態
int  CLASS_RANGE GetTranState(PTR pTran)
{
    //TCHAR   Buffer[80];
    char   Buffer[80];
	memset(Buffer, 0, 80);

	//sprintf(Buffer, "GetTranState 1");
	//OutputDebugString((LPCTSTR)Buffer);

    if (pSes==0) return 0;
    if (pTran==0) return SC_TRANSACTION_INVALID;
    if (pTran==1) return SC_TRANSACTION_INVALID;

	LK_TRANSACTION* ptr = (LK_TRANSACTION*)pTran;

	//sprintf(Buffer, "Ptr size=%d\n", sizeof(ptr));
	//OutputDebugString((LPCTSTR)Buffer);

	//sprintf(Buffer, "long size=%d\n", sizeof(long));
	//OutputDebugString((LPCTSTR)Buffer);

	//sprintf(Buffer, "long long size=%d\n", sizeof(long long));
	//OutputDebugString((LPCTSTR)Buffer);

    return ptr->State;;
}


/*
TCHAR   Buffer[DEBUG_BUFFER_SIZE];
va_list argptr;

memset(Buffer, 0, DEBUG_BUFFER_SIZE);

sprintf(Buffer, "%s", "[IFC_DLL] ");

va_start(argptr, fmt);
_vstprintf(&Buffer[10], fmt, argptr);
va_end(argptr);

OutputDebugString((LPCTSTR)Buffer);
*/

SC_DATA*  CLASS_RANGE GetDataPointer(PTR pTran)
{
    if (pSes==0) return 0;
    LK_TRANSACTION *ptr;
    ptr = (LK_TRANSACTION *)pTran;
    return (SC_DATA*)&ptr->Data;
}


//=========等待直接命令完成
int  CLASS_RANGE DWaitDone(int TgrConn, int MaxWaitTime)
{
    if (pSes==0) return 0;
    unsigned int TimePassed;
    int           DirectCount;
    if ((TgrConn<0)||(TgrConn>=pSes->ConnectNum)) return 0;
    TALK_INFO *pTalk = &pSes->pTalkInfo[TgrConn];
    if (pTalk->ConnState==0) return 0;
    MainProcess();
    TimePassed=0;
    while (1)
    {
        MicroSleep(20000);
        TimePassed+=MainProcess();
        DirectCount = (pTalk->DirectQueue.WriteAddr-pTalk->DirectQueue.ReadAddr)&DIRECT_ADDR_MASK;
        if (DirectCount==0) return 1;
        if (TimePassed>=(MaxWaitTime*1000)) return 0;
    }
}

//==========清除 Queue
void  CLASS_RANGE LClearQueue(int TgrConn)
{
    if (pSes==0) return;
    unsigned char pt, st, ed;
    if ((TgrConn<0)||(TgrConn>=pSes->ConnectNum)) return;
    TALK_INFO *pTalk = &pSes->pTalkInfo[TgrConn];
    pTalk->ToClearLoop = 1;
    pTalk->LoopQueue.WriteAddr=0;
}

void  CLASS_RANGE DClearQueue(int TgrConn)
{
    if (pSes==0) return;
    unsigned char pt, st, ed;
    if ((TgrConn<0)||(TgrConn>=pSes->ConnectNum)) return;
    TALK_INFO *pTalk = &pSes->pTalkInfo[TgrConn];
    if (pTalk->DirectQueue.ReadAddr!=pTalk->DirectQueue.WriteAddr)
        pTalk->ToClearDirect=1;
}

//  ============================= Loop ============
PTR  CLASS_RANGE LWriteNO(int TgrConn, int addr, int num) {return cmdBitWriteN(TgrConn, SC_LOOP, LK_DEV_O, addr, num, 0);}
PTR  CLASS_RANGE LWriteNC(int TgrConn, int addr, int num) {return cmdBitWriteN(TgrConn, SC_LOOP, LK_DEV_C, addr, num, 0);}
PTR  CLASS_RANGE LWriteNS(int TgrConn, int addr, int num) {return cmdBitWriteN(TgrConn, SC_LOOP, LK_DEV_S, addr, num, 0);}
PTR  CLASS_RANGE LWriteNA(int TgrConn, int addr, int num) {return cmdBitWriteN(TgrConn, SC_LOOP, LK_DEV_A, addr, num, 0);}
PTR  CLASS_RANGE LWriteNR(int TgrConn, int addr, int num) {return cmdIntWriteN(TgrConn, SC_LOOP, LK_DEV_R, addr, num, 0);}
PTR  CLASS_RANGE LWriteNF(int TgrConn, int addr, int num) {return cmdFixWriteN(TgrConn, SC_LOOP, LK_DEV_F, addr, num, 0);}

PTR  CLASS_RANGE LReadNI(int TgrConn, int addr, int num) {return cmdBitReadN(TgrConn, SC_LOOP, LK_DEV_I, addr, num);}
PTR  CLASS_RANGE LReadNO(int TgrConn, int addr, int num) {return cmdBitReadN(TgrConn, SC_LOOP, LK_DEV_O, addr, num);}
PTR  CLASS_RANGE LReadNC(int TgrConn, int addr, int num) {return cmdBitReadN(TgrConn, SC_LOOP, LK_DEV_C, addr, num);}
PTR  CLASS_RANGE LReadNS(int TgrConn, int addr, int num) {return cmdBitReadN(TgrConn, SC_LOOP, LK_DEV_S, addr, num);}
PTR  CLASS_RANGE LReadNA(int TgrConn, int addr, int num) {return cmdBitReadN(TgrConn, SC_LOOP, LK_DEV_A, addr, num);}
PTR  CLASS_RANGE LReadNR(int TgrConn, int addr, int num ) {return cmdIntReadN(TgrConn, SC_LOOP, LK_DEV_R, addr, num);}
PTR  CLASS_RANGE LReadNF(int TgrConn, int addr, int num ) {return cmdFixReadN(TgrConn, SC_LOOP, LK_DEV_F, addr, num);}
PTR  CLASS_RANGE LReadNTT(int TgrConn, int addr, int num) {return cmdBitReadN(TgrConn, SC_LOOP, LK_DEV_TT, addr, num);}
PTR  CLASS_RANGE LReadNTS(int TgrConn, int addr, int num) {return cmdIntReadN(TgrConn, SC_LOOP, LK_DEV_TS, addr, num);}
PTR  CLASS_RANGE LReadNTV(int TgrConn, int addr, int num) {return cmdIntReadN(TgrConn, SC_LOOP, LK_DEV_TV, addr, num);}
PTR  CLASS_RANGE LReadNCT(int TgrConn, int addr, int num) {return cmdBitReadN(TgrConn, SC_LOOP, LK_DEV_CT, addr, num);}
PTR  CLASS_RANGE LReadNCS(int TgrConn, int addr, int num) {return cmdIntReadN(TgrConn, SC_LOOP, LK_DEV_CS, addr, num);}
PTR  CLASS_RANGE LReadNCV(int TgrConn, int addr, int num) {return cmdIntReadN(TgrConn, SC_LOOP, LK_DEV_CV, addr, num);}

//  ============================= Direct ============
PTR  CLASS_RANGE DWrite1O(int TgrConn, int addr, int val) {return cmdBitWriteN(TgrConn, SC_DIRECT, LK_DEV_O, addr, 1, &val);}
PTR  CLASS_RANGE DWrite1C(int TgrConn, int addr, int val) {return cmdBitWriteN(TgrConn, SC_DIRECT, LK_DEV_C, addr, 1, &val);}
PTR  CLASS_RANGE DWrite1S(int TgrConn, int addr, int val) {return cmdBitWriteN(TgrConn, SC_DIRECT, LK_DEV_S, addr, 1, &val);}
PTR  CLASS_RANGE DWrite1A(int TgrConn, int addr, int val) {return cmdBitWriteN(TgrConn, SC_DIRECT, LK_DEV_A, addr, 1, &val);}
PTR  CLASS_RANGE DWrite1R(int TgrConn, int addr, int val) {return cmdIntWriteN(TgrConn, SC_DIRECT, LK_DEV_R, addr, 1, &val);}
PTR  CLASS_RANGE DWrite1F(int TgrConn, int addr, double val) {return cmdFixWriteN(TgrConn, SC_DIRECT, LK_DEV_F, addr, 1, &val);}

PTR  CLASS_RANGE DWriteNO(int TgrConn, int addr, int num, int *data) {return cmdBitWriteN(TgrConn, SC_DIRECT, LK_DEV_O, addr, num, data);}
PTR  CLASS_RANGE DWriteNC(int TgrConn, int addr, int num, int *data) {return cmdBitWriteN(TgrConn, SC_DIRECT, LK_DEV_C, addr, num, data);}
PTR  CLASS_RANGE DWriteNS(int TgrConn, int addr, int num, int *data) {return cmdBitWriteN(TgrConn, SC_DIRECT, LK_DEV_S, addr, num, data);}
PTR  CLASS_RANGE DWriteNA(int TgrConn, int addr, int num, int *data) {return cmdBitWriteN(TgrConn, SC_DIRECT, LK_DEV_A, addr, num, data);}
PTR  CLASS_RANGE DWriteNR(int TgrConn, int addr, int num, int *data)    {return cmdIntWriteN(TgrConn, SC_DIRECT, LK_DEV_R, addr, num, data);}
PTR  CLASS_RANGE DWriteNF(int TgrConn, int addr, int num, double *data) {return cmdFixWriteN(TgrConn, SC_DIRECT, LK_DEV_F, addr, num, data);}

PTR  CLASS_RANGE DReadNI(int TgrConn, int addr, int num) {return cmdBitReadN(TgrConn, SC_DIRECT, LK_DEV_I, addr, num);}
PTR  CLASS_RANGE DReadNO(int TgrConn, int addr, int num) {return cmdBitReadN(TgrConn, SC_DIRECT, LK_DEV_O, addr, num);}
PTR  CLASS_RANGE DReadNC(int TgrConn, int addr, int num) {return cmdBitReadN(TgrConn, SC_DIRECT, LK_DEV_C, addr, num);}
PTR  CLASS_RANGE DReadNS(int TgrConn, int addr, int num) {return cmdBitReadN(TgrConn, SC_DIRECT, LK_DEV_S, addr, num);}
PTR  CLASS_RANGE DReadNA(int TgrConn, int addr, int num) {return cmdBitReadN(TgrConn, SC_DIRECT, LK_DEV_A, addr, num);}
PTR  CLASS_RANGE DReadNR(int TgrConn, int addr, int num ) {return cmdIntReadN(TgrConn, SC_DIRECT, LK_DEV_R, addr, num);}
PTR  CLASS_RANGE DReadNF(int TgrConn, int addr, int num ) {return cmdFixReadN(TgrConn, SC_DIRECT, LK_DEV_F, addr, num);}
PTR  CLASS_RANGE DReadNTT(int TgrConn, int addr, int num) {return cmdBitReadN(TgrConn, SC_DIRECT, LK_DEV_TT, addr, num);}
PTR  CLASS_RANGE DReadNTS(int TgrConn, int addr, int num) {return cmdIntReadN(TgrConn, SC_DIRECT, LK_DEV_TS, addr, num);}
PTR  CLASS_RANGE DReadNTV(int TgrConn, int addr, int num) {return cmdIntReadN(TgrConn, SC_DIRECT, LK_DEV_TV, addr, num);}
PTR  CLASS_RANGE DReadNCT(int TgrConn, int addr, int num) {return cmdBitReadN(TgrConn, SC_DIRECT, LK_DEV_CT, addr, num);}
PTR  CLASS_RANGE DReadNCS(int TgrConn, int addr, int num) {return cmdIntReadN(TgrConn, SC_DIRECT, LK_DEV_CS, addr, num);}
PTR  CLASS_RANGE DReadNCV(int TgrConn, int addr, int num) {return cmdIntReadN(TgrConn, SC_DIRECT, LK_DEV_CV, addr, num);}




//------------------------------ StartComboinSet
void  CLASS_RANGE LReadBegin(int TgrConn)
{
    if (pSes==0) return;
    unsigned char pt, st, ed;
    int SenId = TgrConn;
    if ((SenId!=-1)&&(SenId>=pSes->ConnectNum)) return;
    if   (SenId>=0) { st=SenId; ed=TgrConn+1; }
    else            { st=0;     ed=pSes->ConnectNum; }
    for (pt=st; pt<ed; pt++)
    {
        TALK_INFO *pTalk = &pSes->pTalkInfo[pt];
        pTalk->LoopReadCombineFlag=1;
        pTalk->LoopReadIntNum=0;
        pTalk->LoopReadFixNum=0;
    }
}

//------------------------------ StartComboinSet
void  CLASS_RANGE DReadBegin(int TgrConn)
{
    if (pSes==0) return;
    unsigned char pt, st, ed;
    int SenId = TgrConn;
    if ((SenId!=-1)&&(SenId>=pSes->ConnectNum)) return;
    if   (SenId>=0) { st=SenId; ed=TgrConn+1; }
    else            { st=0;     ed=pSes->ConnectNum; }
    for (pt=st; pt<ed; pt++)
    {
        TALK_INFO *pTalk = &pSes->pTalkInfo[pt];
        pTalk->DirectReadCombineFlag=1;
        pTalk->DirectReadIntNum=0;
        pTalk->DirectReadFixNum=0;
    }
}


//------------------------------ FinishComboinSet
PTR  CLASS_RANGE LReadEnd(int TgrConn)
{
    if (pSes==0) return 0;
    unsigned char pt, st, ed;
    PTR pTran=0;

    int SenId = TgrConn;
    if ((SenId!=-1)&&(SenId>=pSes->ConnectNum)) return 0;
    if   (SenId>=0) { st=SenId; ed=TgrConn+1; }
    else            { st=0;     ed=pSes->ConnectNum; }
    for (pt=st; pt<ed; pt++)
    {
        int num, k;
        TALK_INFO *pTalk = &pSes->pTalkInfo[pt];
        pTalk->LoopReadCombineFlag=0;
        //-----loop read Reg
        k=0;
        while (pTalk->LoopReadIntNum>0)
        {
            if (pTalk->LoopReadIntNum>MAX_CB_INT_NUM) num=MAX_CB_INT_NUM;
            else                                         num=pTalk->LoopReadIntNum;
            pTran = CombineIntRead(pt, 0, num, k);
            k+=num;
            pTalk->LoopReadIntNum-=num;
        }
        //-----loop read Fix
        k=0;
        while (pTalk->LoopReadFixNum>0)
        {
            if (pTalk->LoopReadFixNum>MAX_CB_FIX_NUM) num=MAX_CB_FIX_NUM;
            else                                    num=pTalk->LoopReadFixNum;
            pTran = CombineFixRead(pt, 0, num, k);
            k+=num;
            pTalk->LoopReadFixNum-=num;
        }
    }
    return pTran;
}


//------------------------------ FinishComboinSet
PTR  CLASS_RANGE DReadEnd(int TgrConn)
{
    if (pSes==0) return 0;
    unsigned char pt, st, ed;
    PTR pTran=0;

    int SenId = TgrConn;
    if ((SenId!=-1)&&(SenId>=pSes->ConnectNum)) return 0;
    if   (SenId>=0) { st=SenId; ed=TgrConn+1; }
    else            { st=0;     ed=pSes->ConnectNum; }
    for (pt=st; pt<ed; pt++)
    {
        int num, k;
        TALK_INFO *pTalk = &pSes->pTalkInfo[pt];
        pTalk->DirectReadCombineFlag=0;
        //-----direct read Reg
        k=0;
        while (pTalk->DirectReadIntNum>0)
        {
            if (pTalk->DirectReadIntNum>MAX_CB_INT_NUM) num=MAX_CB_INT_NUM;
            else                                        num=pTalk->DirectReadIntNum;
            pTran = CombineIntRead(pt, 1, num, k);
            k+=num;
            pTalk->DirectReadIntNum-=num;
        }
        //-----direct read Fix
        k=0;
        while (pTalk->DirectReadFixNum>0)
        {
            if (pTalk->DirectReadFixNum>MAX_CB_FIX_NUM) num=MAX_CB_FIX_NUM;
            else                                    num=pTalk->DirectReadFixNum;
            pTran = CombineFixRead(pt, 1, num, k);
            k+=num;
            pTalk->DirectReadFixNum-=num;
        }
    }
    return pTran;
}

//------------------------------
void  CLASS_RANGE LWriteBegin(int TgrConn)
{
    if (pSes==0) return;
    unsigned char pt, st, ed;
    int SenId = TgrConn;
    if ((SenId!=-1)&&(SenId>=pSes->ConnectNum)) return;
    if   (SenId>=0) { st=SenId; ed=TgrConn+1; }
    else            { st=0;     ed=pSes->ConnectNum; }
    for (pt=st; pt<ed; pt++)
    {
        TALK_INFO *pTalk = &pSes->pTalkInfo[pt];
        pTalk->LoopWriteCombineFlag=1;
        pTalk->LoopWriteIntNum=0;
        pTalk->LoopWriteFixNum=0;
    }
}
//------------------------------
void  CLASS_RANGE DWriteBegin(int TgrConn)
{
    if (pSes==0) return;
    unsigned char pt, st, ed;
    int SenId = TgrConn;
    if ((SenId!=-1)&&(SenId>=pSes->ConnectNum)) return;
    if   (SenId>=0) { st=SenId; ed=TgrConn+1; }
    else            { st=0;     ed=pSes->ConnectNum; }
    for (pt=st; pt<ed; pt++)
    {
        TALK_INFO *pTalk = &pSes->pTalkInfo[pt];
        pTalk->DirectWriteCombineFlag=1;
        pTalk->DirectWriteIntNum=0;
        pTalk->DirectWriteFixNum=0;
    }
}

//------------------------------
PTR  CLASS_RANGE LWriteEnd(int TgrConn)
{
    if (pSes==0) return 0;
    unsigned char pt, st, ed;
    PTR pTran=0;

    int SenId = TgrConn;
    if ((SenId!=-1)&&(SenId>=pSes->ConnectNum)) return 0;
    if   (SenId>=0) { st=SenId; ed=TgrConn+1; }
    else            { st=0;     ed=pSes->ConnectNum; }
    for (pt=st; pt<ed; pt++)
    {
        int num, k;
        TALK_INFO *pTalk = &pSes->pTalkInfo[pt];
        pTalk->LoopWriteCombineFlag=0;
        //-----loop write Reg
        k=0;
        while (pTalk->LoopWriteIntNum>0)
        {
            if (pTalk->LoopWriteIntNum>MAX_CB_INT_NUM) num=MAX_CB_INT_NUM;
            else                                          num=pTalk->LoopWriteIntNum;
            pTran = CombineIntWrite(pt, 0, num, k);
            k+=num;
            pTalk->LoopWriteIntNum-=num;
        }
        //-----loop write Fix
        k=0;
        while (pTalk->LoopWriteFixNum>0)
        {
            if (pTalk->LoopWriteFixNum>MAX_CB_FIX_NUM) num=MAX_CB_FIX_NUM;
            else                                          num=pTalk->LoopWriteFixNum;
            pTran = CombineFixWrite(pt, 0, num, k);
            k+=num;
            pTalk->LoopWriteFixNum-=num;
        }
    }
    return pTran;
}


//------------------------------
PTR  CLASS_RANGE DWriteEnd(int TgrConn)
{
    if (pSes==0) return 0;
    unsigned char pt, st, ed;
    PTR pTran=0;

    int SenId = TgrConn;
    if ((SenId!=-1)&&(SenId>=pSes->ConnectNum)) return 0;
    if   (SenId>=0) { st=SenId; ed=TgrConn+1; }
    else            { st=0;     ed=pSes->ConnectNum; }
    for (pt=st; pt<ed; pt++)
    {
        int num, k;
        TALK_INFO *pTalk = &pSes->pTalkInfo[pt];
        pTalk->DirectWriteCombineFlag=0;
        //-----direct write Reg
        k=0;
        while (pTalk->DirectWriteIntNum>0)
        {
            if (pTalk->DirectWriteIntNum>MAX_CB_INT_NUM) num=MAX_CB_INT_NUM;
            else                                         num=pTalk->DirectWriteIntNum;
            pTran = CombineIntWrite(pt, 1, num, k);
            k+=num;
            pTalk->DirectWriteIntNum-=num;
        }
        //-----direct write Fix
        k=0;
        while (pTalk->DirectWriteFixNum>0)
        {
            if (pTalk->DirectWriteFixNum>MAX_CB_FIX_NUM) num=MAX_CB_FIX_NUM;
            else                                         num=pTalk->DirectWriteFixNum;
            pTran = CombineFixWrite(pt, 1, num, k);
            k+=num;
            pTalk->DirectWriteFixNum-=num;
        }
    }
    return pTran;
}


//-------------------------------------------------------------------------------
PTR  CLASS_RANGE DWriteRString(int TgrConn,  int addr, int RSize, char *Buf)
{
    if (pSes==0) return 0;
    int SenId = TgrConn;
    if ((SenId<0)||(SenId>=pSes->ConnectNum)) return 0;
    int i, num, ZeroAppeared;
    char tmpBuf[256];
    if (RSize>64) RSize=64;
    ZeroAppeared=0;
    for (i=0; i<RSize*4; i++)
    {
        if (ZeroAppeared) tmpBuf[i]=0;
        else              tmpBuf[i]=Buf[i];
        if (Buf[i]==0) ZeroAppeared=1;
    }
    return DWriteNR(TgrConn, addr, RSize, (int *)Buf);
    //return cmdIntWriteN(TgrConn, SC_DIRECT, LK_DEV_R, addr, num, (int *)tmpBuf);
}

//-------------------------------------------------------------------------------
PTR  CLASS_RANGE DWrite1RBit(int TgrConn, int addr, int BitIdx, int BitValue)
{
    if (pSes==0) return 0;
    unsigned char pt, st, ed;
    int rt;
    int SenId = TgrConn;
    if ((SenId!=-1)&&(SenId>=pSes->ConnectNum)) return 0;
    if   (SenId>=0) { st=SenId; ed=TgrConn+1; }
    else            { st=0;     ed=pSes->ConnectNum; }
    for (pt=st; pt<ed; pt++)
    {
        int data = (BitIdx<<1)|(BitValue&0x01);
        rt = cmdBitWriteN(pt, SC_DIRECT, LK_DEV_RBIT, addr, 1, &data);
    }
    return rt;
}



//======================= MainProcess ========================================
int CLASS_RANGE MainProcess()
{
    if (pSes==0) return 0;

//#ifdef __WINDOWS
//    EnterCriticalSection(&g_cs);
//#endif

    static LK_TIME ts, te, td;
    static unsigned int TimePass=0;

    unsigned int tdiff;
    int i, RxLen;
    unsigned char RxBuf[MAX_PACKET_SIZE];

    getTime(&te);
    getTimeDiff(&td, &te, &ts);
    tdiff=td.Sec*1000000+td.uSec;
    memcpy(&ts, &te, sizeof(LK_TIME));





    TimePass+=tdiff;
    if (TimePass>=1000000)
    {
        TimePass=0;
        pSes->ProcCounter++;
    }

    for (i=0; i<pSes->ConnectNum; i++)
    {
        TALK_INFO *pTalk = &pSes->pTalkInfo[i];
        //------------------
        switch (pTalk->Action)
        {
        case CONNECT_ACTION_TO_CONNECT:
            pTalk->Action=CONNECT_ACTION_IDLE;
            ResetTalk(pTalk);
            LocalConnect(pTalk);
            break;
        case CONNECT_ACTION_TO_REMOTE:
            pTalk->Action=CONNECT_ACTION_IDLE;
            ResetTalk(pTalk);
            RemoteConnect(pTalk);
            break;
        case CONNECT_ACTION_TO_DISCONNECT:
            pTalk->Action=CONNECT_ACTION_IDLE;
            if (pTalk->ConnState!=SC_CONN_STATE_DISCONNECT)
            {
                TalkDisconnect(pTalk);
            }
            break;
        default:
            break;
        }
        if ((*pTalk->Sck!=-1)&&(pTalk->ConnState!=SC_CONN_STATE_DISCONNECT))
        {
            //======AliveRxTime
            if (FtpIndex==255) pTalk->AliveRxTime+=tdiff;
            if (pTalk->AliveRxTime>3000000)
            {
                pTalk->AliveRxTime = 0;
                if (pTalk->ConnState!=SC_CONN_STATE_CONNECTING)
                {
                    ReConnect(pTalk);
                    pTalk->TalkWaiting = 0;
                    pTalk->ConnState = SC_CONN_STATE_NORESPONSE;
                }
            }
            pTalk->AliveTxTime+=tdiff;
            if (pTalk->AliveTxTime>1000000)
            {
                pTalk->AliveTxTime = 0;
				//if ((pTalk->ConnState == SC_CONN_STATE_NORESPONSE)
				//	|| (pTalk->ConnState == SC_CONN_STATE_OK))
				if (pTalk->ConnState == SC_CONN_STATE_OK)
                {
                    pTalk->AliveBuf[0] = START_CHAR_ALIVE;
                    WriteOutMessage(pTalk, (char *)pTalk->AliveBuf, 10);
                }
            }
            while (1)
            {
                unsigned Valid = 0;
                #ifdef __GCC
                    socklen_t adlen = sizeof(struct sockaddr);
                #else
                    int adlen = sizeof(struct sockaddr);
                #endif
                RxLen = recvfrom(*pTalk->Sck, (char *)RxBuf, MAX_PACKET_SIZE, 0, (struct sockaddr *)&src_addr, &adlen);
                if (RxLen<=0) break;
                unsigned int CurrentIPLong = src_addr.sin_addr.s_addr;
                unsigned short  CurrentPort   = ntohs(src_addr.sin_port);
                if ( (CurrentIPLong==pTalk->ReconAddr.sin_addr.s_addr)
                   && (CurrentPort==ntohs(pTalk->ReconAddr.sin_port)) )
                    Valid = 1;
                if (Valid)
                {
                    switch (RxBuf[0])
                    {
                    case START_CHAR_TALK:
                        if (!(pTalk->ToClearDirect||pTalk->ToClearLoop))
                            ReceiveTalk(pTalk, RxLen, RxBuf);
                        Valid = 2;
                        break;
                    case START_CHAR_CONNECT:
                    case START_CHAR_ADMIN:
                        ReceiveConnect(pTalk, RxLen, RxBuf);
                        if (pTalk->ConnectResponse==CONNECT_RESULT_SOFTWARE_CONNECTED) Valid = 2;
                        break;
                    case START_CHAR_ALIVE:
                        Valid = 2;
                        break;
                    case START_CHAR_FTP:
                        if (pTalk==(&pSes->pTalkInfo[pSes->FtpTalkIdx])) ReceiveFtp(&pSes->FtpInfo, RxLen, RxBuf);
                        Valid = 2;
                        break;
                    case START_CHAR_MEDIA:
                        ReceiveConnect(pTalk, RxLen, RxBuf);
                        Valid = 1;
                        break;
                    default:
                        Valid = 0;
                        break;
                    }
                    if (Valid==2)
                    {
                        pTalk->AliveRxTime = 0;
                        pTalk->AliveTxTime = 0;
                        if (pTalk->ConnState!=SC_CONN_STATE_CONNECTING)
                        {
                            pTalk->ConnState = SC_CONN_STATE_OK;
                        }
                    }
                }
            }
        }
        if (pTalk->ToClearLoop)
        {
            pTalk->LoopQueue.ReadAddr=0;
            pTalk->ToClearLoop = 0;
            pTalk->TalkWaiting = 0;
    	    pTalk->Section.PkgID++;
        }
        else if (pTalk->ToClearDirect)
        {
            pTalk->DirectQueue.ReadAddr=pTalk->DirectQueue.WriteAddr;
            pTalk->ToClearDirect = 0;
            pTalk->TalkWaiting = 0;
    	    pTalk->Section.PkgID++;
        }
        RegularCallTalk(pTalk, tdiff);
        RegularCallConnect(pTalk, tdiff);
    }
    //======================================================================
    switch (pSes->FtpInfo.Action)
    {
    case FTP_ACTION_TO_UPLOAD_FILE:
        pSes->FtpInfo.Action=FTP_ACTION_IDLE;
        SetUploadFile(&pSes->FtpInfo);
        break;
    case FTP_ACTION_TO_DOWNLOAD_FILE:
        pSes->FtpInfo.Action=FTP_ACTION_IDLE;
        SetDownloadFile(&pSes->FtpInfo);
        break;
    case FTP_ACTION_TO_DELETE_FILE:
        pSes->FtpInfo.Action=FTP_ACTION_IDLE;
        SetDeleteFile(&pSes->FtpInfo);
        break;
    case FTP_ACTION_TO_LIST_FILE:
        pSes->FtpInfo.Action=FTP_ACTION_IDLE;
        SetListFile(&pSes->FtpInfo);
        break;
    case FTP_ACTION_TO_UPLOAD_FILES:
        pSes->FtpInfo.Action=FTP_ACTION_IDLE;
        SetUploadFiles(&pSes->FtpInfo);
        break;
    case FTP_ACTION_TO_DOWNLOAD_FILES:
        pSes->FtpInfo.Action=FTP_ACTION_IDLE;
        SetDownloadFiles(&pSes->FtpInfo);
        break;
    case FTP_ACTION_TO_DELETE_FILES:
        pSes->FtpInfo.Action=FTP_ACTION_IDLE;
        SetDeleteFiles(&pSes->FtpInfo);
        break;
    case FTP_ACTION_TO_MAKE_DIR:
        pSes->FtpInfo.Action=FTP_ACTION_IDLE;
        SetMakeDir(&pSes->FtpInfo);
        break;
    default:
        break;
    }
    RegularCallFtp(&pSes->FtpInfo, tdiff);

//#ifdef __WINDOWS
//    LeaveCriticalSection(&g_cs);
//#endif

    return tdiff;
}
//=====================================Detect ================================




//-------------------------------------------------------------------------------
int  CLASS_RANGE ConnectLocalList(int TgrConn, int Index)
{
    if (pSes==0) return 0;

    if (Index >= pSes->LocalInfo.Count) return 0;
    //int SenId = TgrConn;

    if ((TgrConn<0)||(TgrConn>=pSes->ConnectNum)) return 0;
    TALK_INFO *pTalk = &pSes->pTalkInfo[TgrConn];

    InitTalkMem(pTalk);
    //pTalk->ConnectIndex = Index;
//#ifdef __QT
//    pTalk->ReconAddr.setAddress(pSes->LocalInfo.Hosts[Index].IPLong);
//    pTalk->ReconPort = PORT_UDP_RECON;
//#else
    pTalk->ReconAddr.sin_family = AF_INET;
    pTalk->ReconAddr.sin_addr.s_addr = inet_addr(pSes->LocalInfo.Hosts[Index].IP);
    pTalk->ReconAddr.sin_port = htons(PORT_UDP_RECON);	  // short, network byte order
    memset(&(pTalk->ReconAddr.sin_zero), '\0', 8); // zero the rest of the struct
//#endif
    pTalk->Action=CONNECT_ACTION_TO_CONNECT;
    //printf("ConnectLocalList Finished\n");
    return 1;
}



//-------------------------------------------------------------------------------
int  CLASS_RANGE LocalReadControllerCount()
{
    if (pSes==0) return 0;
    return pSes->LocalInfo.Count;
}

//-------------------------------------------------------------------------------
int  CLASS_RANGE LocalReadController(int Index, LOCAL_CONTROLLER_INFO *Info)
{
    if (pSes==0) return 0;
    if (Index<pSes->LocalInfo.Count)
    {
        memcpy(Info, &pSes->LocalInfo.Hosts[Index], sizeof(LOCAL_CONTROLLER_INFO));
        return 1;
    }
    else
    {
        return 0;
    }
}


#define MAXBUFLEN 32

int  CLASS_RANGE LocalDetectControllers()
{
//#ifdef __QT
//    if (pSes==0) return 0;
//    char ReqCh='?';
//    int RxLen;
//    unsigned char RxBuf[MAXBUFLEN];
//    unsigned char TxBuf[3];
//    QString tmpStr;

//    TxBuf[0]=ReqCh;
//    MainSocket->writeDatagram((char *)TxBuf, 1, QHostAddress::Broadcast, PORT_UDP_REPLY);

//    //接收
//    pSes->LocalInfo.Count=0;
//    unsigned short tick;
//    tick=0;
//    //QHostAddress       RemoteAddr;
//    //quint16            RemotePort;
//    while (1)
//    {
//        usleep(20000);
//        while (1)
//        {
//            RxLen = MainSocket->readDatagram((char *)RxBuf, MAXBUFLEN, &SrcAddr, &SrcPort);
//            if ((RxLen==16)||(RxLen==32))
//            {
//                if (SrcPort==PORT_UDP_REPLY)
//                {
//                    unsigned char j;
//                    unsigned char Repeat=0;
//                    for (j=0; j<pSes->LocalInfo.Count; j++)
//                    {
//                        if (pSes->LocalInfo.Hosts[j].IPLong==SrcAddr.toIPv4Address())
//                        {
//                            Repeat=1;
//                            break;
//                        }
//                    }
//                    if (!Repeat)
//                    {
//                        uint IPLong=SrcAddr.toIPv4Address();
//                        pSes->LocalInfo.Hosts[pSes->LocalInfo.Count].IPLong=IPLong;
//                        sprintf(pSes->LocalInfo.Hosts[pSes->LocalInfo.Count].IP, "%d.%d.%d.%d", (IPLong>>24)&0xff, (IPLong>>16)&0xff, (IPLong>>8)&0xff, (IPLong>>0)&0xff);
//                        memcpy(pSes->LocalInfo.Hosts[pSes->LocalInfo.Count].Name, RxBuf, RxLen);
//                        pSes->LocalInfo.Count++;
//                        if (pSes->LocalInfo.Count>=MAX_CONTROLLER_NUM_PER_MAKER) break;
//                    }
//                }
//            }
//            else break;
//        }
//        tick++;
//        if (tick>50) break;
//    }
//    return pSes->LocalInfo.Count;
//#else
    if (pSes==0) return 0;
    struct sockaddr_in my_addr;	   // my address information
    struct sockaddr_in BroadCast_addr; // connector's address information
    struct sockaddr_in their_addr; // connector's address information
    char ReqCh='?';
    int fd;
    int RxLen, TxLen;
    unsigned char RxBuf[MAXBUFLEN];
    unsigned char TxBuf[3];
    char cOn=1;
    unsigned long on=1;
    int ret;
    char *addr;
    #ifdef __GCC
        socklen_t adlen;
    #else
        int adlen;
    #endif
    
    adlen = sizeof(struct sockaddr);
    char ThisIPs[16][16];
    unsigned char ThisIPcount=0;
    unsigned char i;
    //===============????????IP
    hostent *hent;
    char    s[128];
    char    *p1;
    char    *p2;
    gethostname(s,   128);        //Get   the   computer   name
    hent =   gethostbyname(s);
    //printf("[PD] %s \n", hent->h_name);   //Get   the   IpAddress
    for (i=0; i < hent->h_length; i++)
    {
        p1=hent->h_addr_list[i];
        if (p1==NULL) break;
        p2 = inet_ntoa( *((in_addr*)hent->h_addr_list[i]));
        memcpy(ThisIPs[ThisIPcount], p2, 16);
        ThisIPcount++;
    }

    pSes->LocalInfo.Count=0;
    for (i=0; i<ThisIPcount; i++)
    {
        printf("[PD] Scan for IP %s \n", ThisIPs[i]);
        if ((fd = (int)socket(AF_INET, SOCK_DGRAM, 0)) < 0)
        {
            printf("  [PD] unable to create socket. \n");
            return -1;
        }
        printf("  [PD] socket built\n");

        //==============bind ========
        my_addr.sin_family = AF_INET;		  // host byte order
        my_addr.sin_addr.s_addr = inet_addr(ThisIPs[i]);
        //my_addr.sin_addr.s_addr = INADDR_ANY;
        my_addr.sin_port = htons(0);	  // short, network byte order
        memset(&(my_addr.sin_zero), '\0', 8); // zero the rest of the struct
        if (bind(fd, (struct sockaddr *)&my_addr, adlen) == -1)
        {
            printf("  [PD] unable to bind. \n"); 
            #ifdef __GCC
                close(fd);
            #else
                closesocket(fd);
            #endif
            return -1;
        }
        unsigned short portshort=ntohs(my_addr.sin_port);
        printf("  [PD] Address Binded, port=%d.\n", portshort);

        //============?]?w???s?????
        ret = setsockopt(fd, SOL_SOCKET, SO_BROADCAST, &cOn, sizeof(cOn) );
        //================?]?? non blocking mode==============
        #ifndef __GCC
            if (ioctlsocket(fd, FIONBIO, &on) == SOCKET_ERROR)
            {
                printf("  [PD] Unable to set nonblocking mode. \n");
                closesocket(fd);
                fd = -1;
                return -1;
            }
        #endif
        //================== set up destination address
        BroadCast_addr.sin_family = AF_INET;
        BroadCast_addr.sin_addr.s_addr = htonl(INADDR_BROADCAST);
        //BroadCast_addr.sin_port=htons(PORT_UDP_CONTROLLER);
        BroadCast_addr.sin_port=htons(PORT_UDP_REPLY);
        memset(&(BroadCast_addr.sin_zero), '\0', 8); // zero the rest of the struct

        //??e
        printf("  [PD] Send detect packet\n");
        TxBuf[0]=ReqCh;

        TxLen=sendto( fd, (char *)TxBuf, 1, 0, (struct sockaddr *)&BroadCast_addr, adlen);
        if ( TxLen<0)
        {
            printf("  [PD] Detect packet sent faild.\n");
            #ifdef __GCC
                close(fd);
            #else
                closesocket(fd);
            #endif
            return -1;
        }

        //????
        unsigned short tick;
        tick=0;
        printf("  [PD] Check reply packet\n");
        while (1)
        {
            #ifdef __GCC
                usleep(10000);
            #else
                Sleep(10);
            #endif
            RxLen = recvfrom(fd, (char *)RxBuf, MAXBUFLEN , 0, (struct sockaddr *)&their_addr, &adlen);
            if (ntohs(their_addr.sin_port)==PORT_UDP_REPLY)
            {
                if ((RxLen==16)||(RxLen==32))
                {
                    unsigned char j;
                    unsigned char Repeat=0;
                    unsigned int ll;
                    ll=their_addr.sin_addr.s_addr ;
                    //ll=inet_addr(inet_ntoa(their_addr.sin_addr));
                    for (j=0; j<pSes->LocalInfo.Count; j++)
                    {
                        if (pSes->LocalInfo.Hosts[j].IPLong==ll)
                        {
                            Repeat=1;
                            break;
                        }
                    }
                    if (!Repeat)
                    {
                        pSes->LocalInfo.Hosts[pSes->LocalInfo.Count].IPLong=ll;
                        addr=(char *)inet_ntoa(their_addr.sin_addr);
                        memcpy(pSes->LocalInfo.Hosts[pSes->LocalInfo.Count].IP, addr, 16);
                        memcpy(pSes->LocalInfo.Hosts[pSes->LocalInfo.Count].Name, RxBuf, RxLen);
                        pSes->LocalInfo.Count++;
                        if (pSes->LocalInfo.Count>=MAX_CONTROLLER_NUM_PER_MAKER) break;
                    }
                    printf("  [PD] From %s, size=%d \n", inet_ntoa(their_addr.sin_addr), RxLen);
                }
            }
            tick++;
            if (tick>40) break;
        }
        #ifdef __GCC
            close(fd);
        #else
            closesocket(fd);
        #endif
    }
    return pSes->LocalInfo.Count;
//#endif
}


int  CLASS_RANGE RemoteGetMyInfo (int TgrConn, char *MediaIP)                 //取得本身的網際 IP+Port
{
    if (pSes==0) return 0;
    if ((TgrConn<0)||(TgrConn>=pSes->ConnectNum)) return 0;
    TALK_INFO *pTalk = &pSes->pTalkInfo[TgrConn];
    InitTalkMem(pTalk);
//#ifdef __QT
//    QString IPStr;
//    IPStr.asprintf("%s", MediaIP);
//    pTalk->ReconAddr.setAddress(IPStr);
//    pTalk->RemoteIPLong = pTalk->ReconAddr.toIPv4Address();
//    IPStr.asprintf("%s", MediaIP);
//    pTalk->ReconAddr.setAddress(IPStr);
//    pTalk->ReconPort = PORT_UDP_MEDIA;
//#else
    pTalk->RemoteIPLong = inet_addr(MediaIP);
    unsigned int IPLong = inet_addr(MediaIP);
    pTalk->ReconAddr.sin_family = AF_INET;
    pTalk->ReconAddr.sin_addr.s_addr = IPLong;
    pTalk->ReconAddr.sin_port = htons(PORT_UDP_MEDIA);	  // short, network byte order
    memset(&(pTalk->ReconAddr.sin_zero), '\0', 8); // zero the rest of the struct
//#endif


    static unsigned short MediaPacketID=0;
    unsigned short temp;
    unsigned char RxBuf[1500], RxLen;

    //---------- Request - 封包內容格式
    //製造商 ID (4)
    //列表索引  (4)
    //控制器 ID (4)
    //控制器名稱 (32)
    //----------------------------------
    pTalk->MyInternetIPLong = 0;
    pTalk->MyInternetPort   = 0;
    pTalk->TxLen=6;
    MediaPacketID++;
    pTalk->TxBuf[0]=START_CHAR_MEDIA;
    pTalk->TxBuf[1]=MEDIA_CMD_TELL_MY_PORT;
    pTalk->TxBuf[2]=MediaPacketID & 0xff;
    pTalk->TxBuf[3]=(MediaPacketID>>8) & 0xff;
    pTalk->TxBuf[4]=pTalk->TxLen & 0xff;
    pTalk->TxBuf[5]=(pTalk->TxLen>>8) & 0xff;

    //----計算CRC
    temp = CRC_16(pTalk->TxBuf, pTalk->TxLen);
    pTalk->TxBuf[pTalk->TxLen++] = temp & 0xff;
    pTalk->TxBuf[pTalk->TxLen++] = (temp >> 8) & 0xff;
    //----傳送

//#ifdef __QT
//    pTalk->Sck->writeDatagram((char *)pTalk->TxBuf, pTalk->TxLen, pTalk->ReconAddr, pTalk->ReconPort);
//#else
    int adlen = sizeof(struct sockaddr);
    sendto(*pTalk->Sck, (char *)pTalk->TxBuf, pTalk->TxLen, 0, (struct sockaddr *)&pTalk->ReconAddr, adlen); //sizeof(struct sockaddr));
//#endif

    int ttk = 0;
    int Valid;
    while (1)
    {
        MicroSleep(20000);

        Valid = 0;
//    #ifdef __QT
//        RxLen = pTalk->Sck->readDatagram((char *)RxBuf, MAX_PACKET_SIZE, &SrcAddr, &SrcPort);
//        if (RxLen<=0) break;
//        if ((SrcAddr.toIPv4Address()==pTalk->ReconAddr.toIPv4Address())
//           && (SrcPort==pTalk->ReconPort))   //PORT_UDP_RECON
//            Valid = 1;
//    #else
        #ifdef __GCC
            socklen_t adlen = sizeof(struct sockaddr);
        #else
            int adlen = sizeof(struct sockaddr);
        #endif
        RxLen = recvfrom(*pTalk->Sck, (char *)RxBuf, MAX_PACKET_SIZE, 0, (struct sockaddr *)&src_addr, &adlen);
        if (RxLen>0)
        {
            unsigned int CurrentIPLong = src_addr.sin_addr.s_addr;
            unsigned short  CurrentPort   = ntohs(src_addr.sin_port);
            if ( (CurrentIPLong==pTalk->ReconAddr.sin_addr.s_addr)
               && (CurrentPort==ntohs(pTalk->ReconAddr.sin_port)) )
                Valid = 1;
        }
//    #endif
        if (Valid==1)
        {
            if ( (RxBuf[0]!=pTalk->TxBuf[0])
               ||(RxBuf[1]!=pTalk->TxBuf[1])
               ||(RxBuf[2]!=pTalk->TxBuf[2])
               ||(RxBuf[3]!=pTalk->TxBuf[3]) ) Valid=0;
        }

        //讀取封包長度
        if (Valid==1)
        {
            int TotalByte = RxBuf[4] | (RxBuf[5]<<8);
            if (RxLen!=(TotalByte+2)) Valid=0;
        }

        //檢查CRC
        if (Valid==1)
        {
            if( !CheckCRC(RxBuf, RxLen) ) Valid=0;
        }


        if (Valid==1)
        {
            if (RxBuf[1]==MEDIA_CMD_TELL_MY_PORT)
            {
                //---------- Reply - 封包內容格式
                //詢問者的IP (4)
                //詢問者的Port(4)
                //----------------------------------
                pTalk->MediaResponseCount++;
                pTalk->MyInternetIPLong = *(unsigned int *)(RxBuf+6);
                pTalk->MyInternetPort   = *(unsigned int *)(RxBuf+10);
                return 1;
            }
        }
        ttk++;
        if (ttk>=50) return 0;
    }
    //udp_write(TxBuf, TxLen, &Media_addr);
    //printf("Write to Media %s : %d\n", inet_ntoa(Media_addr.sin_addr), ntohs(Media_addr.sin_port) );

}


//===============================記錄錯誤
void ClosePort(int *pSck)
{
    if (*pSck!=-1)
        #ifdef __GCC
            close(*pSck);
        #else
            closesocket(*pSck);
        #endif
    *pSck=-1;
}


//----------------------------------
bool OpenPort(int *pSck)
{
    struct sockaddr_in my_addr;	   // my address information
    my_addr.sin_family = AF_INET;		  // host byte order
    my_addr.sin_addr.s_addr = INADDR_ANY;
    my_addr.sin_port = htons(0);	  // short, network byte order
    memset(&(my_addr.sin_zero), '\0', 8); // zero the rest of the struct

    //----bind
    *pSck = socket(AF_INET, SOCK_DGRAM, 0);
    if (*pSck == -1)
    {
        printf("[UR] open socket failed.\n");
        return false;
    }
    if (bind(*pSck, (struct sockaddr *)&my_addr, sizeof(my_addr)) == -1)
    {
        printf("[UR] Error binding socket.\n");
        return false;
    }

    //----set to non-blocking mode
    #ifdef __GCC
        int flags;
        flags = fcntl(*pSck, F_GETFL, 0);
        fcntl(*pSck, F_SETFL, flags | O_NONBLOCK);
    #else
        unsigned long on=1;
        if (ioctlsocket(*pSck, FIONBIO, &on) == SOCKET_ERROR)
        {
            printf("  [UR] Unable to set nonblocking mode. \n");
            closesocket(*pSck);
            *pSck = -1;
            return false;
        }
    #endif
    printf("[UR] Address %s:%d Binded.\n", inet_ntoa(my_addr.sin_addr), ntohs(my_addr.sin_port) );
    return true;
}


//===============================記錄錯誤
void LogTalkError(TALK_INFO *pTalk, int Type)
{
    pTalk->ErrRec.Type=Type;
    if (pTalk->pTran!=0)
    {
        pTalk->ErrRec.Cmd=pTalk->pTran->Cmd;
        pTalk->ErrRec.addr=pTalk->pTran->Target[0].Addr;
        pTalk->ErrRec.num=pTalk->pTran->Num;
        pTalk->ErrRec.Error=pTalk->pTran->ErrCode;

        /*
        if (pTalk->QueueFrom==0)
            printf("[PT] DefaultQueue Cmd Err=%02x, Cmd=%d, num=%d, Addr=%d \n", pTalk->ErrRec.Error, pTalk->ErrRec.Cmd, pTalk->ErrRec.num, pTalk->ErrRec.addr);
        else
        */
        if (pTalk->QueueFrom==0)
            printf("[PT] PollingQueue Err=%02x, Cmd=%d, num=%d, Addr=%d \n", pTalk->ErrRec.Error, pTalk->ErrRec.Cmd, pTalk->ErrRec.num, pTalk->ErrRec.addr);
        else if (pTalk->QueueFrom==1)
            printf("[PT] DirectQueue Err=%02x, Cmd=%d, num=%d, Addr=%d \n", pTalk->ErrRec.Error, pTalk->ErrRec.Cmd, pTalk->ErrRec.num, pTalk->ErrRec.addr);
        pTalk->pTran->Cancelled++;
    }
    else
    {
        pTalk->ErrRec.Cmd=0x99;
        pTalk->ErrRec.addr=0;
        pTalk->ErrRec.num=0;
        pTalk->ErrRec.Error=0x99;
    }
}





#ifdef __HAVE_STRING
//-------------產生功能字串
int  GenerateFunctionString(FUNCTION_SETTING *pFuncs, char *FuncString)
{
    //if (pSes==0) return 0;
    unsigned int Key=0x788812BF;
    unsigned char n = sizeof(FUNCTION_SETTING);
    unsigned char InBuf[100], OutBuf[100];
    unsigned int i;
    memcpy(InBuf, (unsigned char *)pFuncs, n);
    CrcEncrypt_adv(Key, InBuf, OutBuf, n);
    for (i=0; i<n+4; i++) ByteToHex(OutBuf[i], FuncString+i*2);
    FuncString[(n+4)*2]=0;
    return 1;
}
//==============================================================================
#endif


////==============================================================================
//int  CLASS_RANGE GlobalToLocal(int Euler, double *pCoor, double *pGlobal, double *pLocal)
//{
//    mEulerType = Euler;
//    STANCE SdCoor;
//    SdCoor.Pos.X = pCoor[0];
//    SdCoor.Pos.Y = pCoor[1];
//    SdCoor.Pos.Z = pCoor[2];
//    SdCoor.Dir.A = pCoor[3];
//    SdCoor.Dir.B = pCoor[4];
//    SdCoor.Dir.C = pCoor[5];
//    SF::Abc2Coor(&SdCoor.Dir, &SdCoor.Coor);

//    STANCE SdGlobal;
//    SdGlobal.Pos.X = pGlobal[0];
//    SdGlobal.Pos.Y = pGlobal[1];
//    SdGlobal.Pos.Z = pGlobal[2];
//    SdGlobal.Dir.A = pGlobal[3];
//    SdGlobal.Dir.B = pGlobal[4];
//    SdGlobal.Dir.C = pGlobal[5];
//    SF::Abc2Coor(&SdGlobal.Dir, &SdGlobal.Coor);

//    STANCE SdLocal;
//    SF::StanceInvert(&SdCoor, &SdGlobal, &SdLocal);
//    pLocal[0] = SdLocal.Pos.X;
//    pLocal[1] = SdLocal.Pos.Y;
//    pLocal[2] = SdLocal.Pos.Z;
//    pLocal[3] = SdLocal.Dir.A;
//    pLocal[4] = SdLocal.Dir.B;
//    pLocal[5] = SdLocal.Dir.C;

//    return 0;
//}

////==============================================================================
//int  CLASS_RANGE LocalToGlobal(int Euler, double *pCoor, double *pLocal, double *pGlobal)
//{
//    mEulerType = Euler;
//    STANCE SdCoor;
//    SdCoor.Pos.X = pCoor[0];
//    SdCoor.Pos.Y = pCoor[1];
//    SdCoor.Pos.Z = pCoor[2];
//    SdCoor.Dir.A = pCoor[3];
//    SdCoor.Dir.B = pCoor[4];
//    SdCoor.Dir.C = pCoor[5];
//    SF::Abc2Coor(&SdCoor.Dir, &SdCoor.Coor);

//    STANCE SdLocal;
//    SdLocal.Pos.X = pLocal[0];
//    SdLocal.Pos.Y = pLocal[1];
//    SdLocal.Pos.Z = pLocal[2];
//    SdLocal.Dir.A = pLocal[3];
//    SdLocal.Dir.B = pLocal[4];
//    SdLocal.Dir.C = pLocal[5];
//    SF::Abc2Coor(&SdLocal.Dir, &SdLocal.Coor);

//    STANCE SdGlobal;
//    SF::StanceConvert(&SdCoor, &SdLocal, &SdGlobal);
//    pGlobal[0] = SdGlobal.Pos.X;
//    pGlobal[1] = SdGlobal.Pos.Y;
//    pGlobal[2] = SdGlobal.Pos.Z;
//    pGlobal[3] = SdGlobal.Dir.A;
//    pGlobal[4] = SdGlobal.Dir.B;
//    pGlobal[5] = SdGlobal.Dir.C;

//    return 0;

//}















