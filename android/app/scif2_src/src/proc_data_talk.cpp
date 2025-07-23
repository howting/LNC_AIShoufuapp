//#include "stdafx.h"
#define BYTE_SPACE_TIME     20000
#include "sc2_memory.h"
#include "proc_data_talk.h"
#include "proc_protocol.h"
#include "proc_sync_handle.h"
    


void InitTalk(TALK_INFO *pTalk)
{
//#ifdef __QT
//    pTalk->Sck = new QUdpSocket();
//#else
    pTalk->Sck = new int;
    *pTalk->Sck = -1;
    OpenPort(pTalk->Sck);
//#endif
    pTalk->StepIndex = 255;
    pTalk->ConnState = SC_CONN_STATE_DISCONNECT;
    //設定通訊參數
    pTalk->Timeout=1000000;
    pTalk->TalkMaxRetry=3;
    pTalk->Action = CONNECT_ACTION_IDLE;
    //pTalk->ToClearDirect=0;
    //pTalk->ToClearLoop=0;
	pTalk->LoopQueue.ReadAddr = 0;
	pTalk->LoopQueue.WriteAddr = 0;
	pTalk->DirectQueue.ReadAddr = 0;
    pTalk->DirectQueue.WriteAddr = 0;
    pTalk->DirectWriteIntNum = 0;
    pTalk->DirectWriteFixNum = 0;
    pTalk->LoopWriteIntNum = 0;
    pTalk->LoopWriteFixNum = 0;
    pTalk->DirectWriteCombineFlag = 0;
    pTalk->LoopWriteCombineFlag = 0;
}

void ResetTalk(TALK_INFO *pTalk)
{ 
    //清除 Direct Queue 內容
    pTalk->DirectQueue.ReadAddr=0;
    pTalk->DirectQueue.WriteAddr=0;
    //初始化通訊資料
    pTalk->TalkWaiting = 0;
    pTalk->LoopCount=0;
    pTalk->Section.RxCrcPkgCnt = 0;
    pTalk->Section.RxUnExpectCnt = 0;
    pTalk->Section.RxErrFmtCnt = 0;
    pTalk->Section.RxPkgCnt = 0;
    pTalk->Section.RxConnectCnt = 0;
    pTalk->Section.TxPkgCnt = 0;  
    pTalk->Section.TxConnectCnt = 0;
    pTalk->Section.TxPkgRetryCnt = 0;
	pTalk->DirectReadCombineFlag = 0;
	pTalk->LoopReadCombineFlag = 0;

    pTalk->timeSend=0;
}

void RegularCallTalk(TALK_INFO *pTalk, unsigned int Interval)
{
    if (pTalk->ConnState==SC_CONN_STATE_DISCONNECT)
    {
    	pTalk->TalkWaiting=0;
    }
    //------狀態不符，直接跳出     
    if (pTalk->ConnState!=SC_CONN_STATE_OK) return;
    
    //更新時間
    pTalk->timeSend+=Interval;
    pTalk->timeSpace+=Interval;

    //===================================不在等待狀態=====================
    if (!pTalk->TalkWaiting)
    {                               
    	pTalk->pTran = 0;
        pTalk->QueueFrom = 0;
        //優先處理 Direct queue --- 使用單一封包方式
        if (pTalk->DirectQueue.ReadAddr!=pTalk->DirectQueue.WriteAddr)
        {
            pTalk->pTran = &pTalk->DirectQueue.Trans[pTalk->DirectQueue.ReadAddr]; 
            pTalk->pTran->ErrCode=0x00;
            pTalk->QueueFrom = 1;
            //----------------使用單一封包方式
            if (pTalk->pTran->Num<=0)   //20210110 DT 避免傳送長度為0的封包
            {
                pTalk->DirectQueue.ReadAddr=(pTalk->DirectQueue.ReadAddr+1)&DIRECT_ADDR_MASK;
            }
            else
            {
                //unsigned short tmp;
                pTalk->Section.RetryCnt=0;
                //準備傳送的資料
                pTalk->Section.TalkTxBuf = pTalk->Section.TalkTxBufs;
                pTalk->Section.TalkTxBuf[0]=START_CHAR_TALK;
                pTalk->Section.TalkTxBuf[2]=(pTalk->Section.PkgID>>0);
                pTalk->Section.TalkTxBuf[3]=(pTalk->Section.PkgID>>8);
                pTalk->Section.TalkTxLen=4;
                if (TransactionToBuf(&pTalk->Section, pTalk->pTran))
                {
                    pTalk->Section.TalkTxLens = pTalk->Section.TalkTxLen;
                    WriteOutTalk(pTalk);
                    pTalk->Section.TxPkgCnt++;
                }
                else
                {
                    pTalk->pTran->ErrCode=SCIF_ERROR_INVALID_PACKET_SET;
                    pTalk->TalkState = TALK_STATE_ERROR;
                    LogTalkError(pTalk, ERROR_TYPE_DIRECT);                //記錄錯誤
                    pTalk->Action=CONNECT_ACTION_TO_DISCONNECT;
                }
            }
        }
        else if (pTalk->LoopQueue.WriteAddr!=0)
        {
            unsigned char WhileCount=0;
            while (1)
            {
                if (pTalk->LoopQueue.ReadAddr < pTalk->LoopQueue.WriteAddr)
                {
                    pTalk->QueueFrom = 0;
                    pTalk->pTran = &pTalk->LoopQueue.Trans[pTalk->LoopQueue.ReadAddr];
                    break;
                }
                else
                {
                    pTalk->LoopQueue.ReadAddr=0;
                    pTalk->LoopCount++;
                }
                WhileCount++;
                if (WhileCount>2) break;
            }
            if (pTalk->pTran!=0)
            {
                if (pTalk->pTran->Num<=0)   //20210110 DT 避免傳送長度為0的封包
                {
                    pTalk->LoopQueue.ReadAddr++;
                }
                else
                {
                    switch (pTalk->pTran->Cmd)
                    {
                    case LK_CMD_BIT_N_WRITE:
                        for (int i=0; i<pTalk->pTran->Num; i++)
                        {
                            switch (pTalk->pTran->Target[i].Device)
                            {
                            case LK_DEV_O: pTalk->pTran->Data.Bytes[i] = pTalk->pMem->O_Table[pTalk->pTran->Target[i].Addr-pTalk->OffsetO]; break;
                            case LK_DEV_C: pTalk->pTran->Data.Bytes[i] = pTalk->pMem->C_Table[pTalk->pTran->Target[i].Addr-pTalk->OffsetC]; break;
                            case LK_DEV_S: pTalk->pTran->Data.Bytes[i] = pTalk->pMem->S_Table[pTalk->pTran->Target[i].Addr-pTalk->OffsetS]; break;
                            case LK_DEV_A: pTalk->pTran->Data.Bytes[i] = pTalk->pMem->A_Table[pTalk->pTran->Target[i].Addr-pTalk->OffsetA]; break;
                            default: break;
                            }
                        }
                        break;
                    case LK_CMD_INT_N_WRITE:
                        for (int i=0; i<pTalk->pTran->Num; i++)
                        {
                            switch (pTalk->pTran->Target[i].Device)
                            {
                            case LK_DEV_R: pTalk->pTran->Data.Ints[i] = pTalk->pMem->R_Table[pTalk->pTran->Target[i].Addr-pTalk->OffsetR]; break;
                            default: break;
                            }
                        }
                        break;
                    case LK_CMD_FIX_N_WRITE:
                        for (int i=0; i<pTalk->pTran->Num; i++)
                        {
                            switch (pTalk->pTran->Target[i].Device)
                            {
                            case LK_DEV_F: pTalk->pTran->Data.Fixs[i] = pTalk->pMem->F_Table[pTalk->pTran->Target[i].Addr-pTalk->OffsetF]; break;
                            default: break;
                            }
                        }
                        break;
                    case LK_CMD_INT_D_WRITE:
                        for (int i=0; i<pTalk->pTran->Num; i++)
                        {
                            switch (pTalk->pTran->Target[i].Device)
                            {
                            case LK_DEV_R:
                                pTalk->pTran->Data.Ints[i] = pTalk->pMem->R_Table[pTalk->pTran->Target[i].Addr-pTalk->OffsetR];
                                break;
                            case LK_DEV_RO:
                                pTalk->pTran->Data.Bytes[4*i+0] = pTalk->pMem->O_Table[pTalk->pTran->Target[i].Addr+0-pTalk->OffsetO];
                                pTalk->pTran->Data.Bytes[4*i+1] = pTalk->pMem->O_Table[pTalk->pTran->Target[i].Addr+1-pTalk->OffsetO];
                                pTalk->pTran->Data.Bytes[4*i+2] = pTalk->pMem->O_Table[pTalk->pTran->Target[i].Addr+2-pTalk->OffsetO];
                                pTalk->pTran->Data.Bytes[4*i+3] = pTalk->pMem->O_Table[pTalk->pTran->Target[i].Addr+3-pTalk->OffsetO];
                                break;
                            case LK_DEV_RC:
                                pTalk->pTran->Data.Bytes[4*i+0] = pTalk->pMem->C_Table[pTalk->pTran->Target[i].Addr+0-pTalk->OffsetC];
                                pTalk->pTran->Data.Bytes[4*i+1] = pTalk->pMem->C_Table[pTalk->pTran->Target[i].Addr+1-pTalk->OffsetC];
                                pTalk->pTran->Data.Bytes[4*i+2] = pTalk->pMem->C_Table[pTalk->pTran->Target[i].Addr+2-pTalk->OffsetC];
                                pTalk->pTran->Data.Bytes[4*i+3] = pTalk->pMem->C_Table[pTalk->pTran->Target[i].Addr+3-pTalk->OffsetC];
                                break;
                            case LK_DEV_RS:
                                pTalk->pTran->Data.Bytes[4*i+0] = pTalk->pMem->S_Table[pTalk->pTran->Target[i].Addr+0-pTalk->OffsetS];
                                pTalk->pTran->Data.Bytes[4*i+1] = pTalk->pMem->S_Table[pTalk->pTran->Target[i].Addr+1-pTalk->OffsetS];
                                pTalk->pTran->Data.Bytes[4*i+2] = pTalk->pMem->S_Table[pTalk->pTran->Target[i].Addr+2-pTalk->OffsetS];
                                pTalk->pTran->Data.Bytes[4*i+3] = pTalk->pMem->S_Table[pTalk->pTran->Target[i].Addr+3-pTalk->OffsetS];
                                break;
                            case LK_DEV_RA:
                                pTalk->pTran->Data.Bytes[4*i+0] = pTalk->pMem->A_Table[pTalk->pTran->Target[i].Addr+0-pTalk->OffsetA];
                                pTalk->pTran->Data.Bytes[4*i+1] = pTalk->pMem->A_Table[pTalk->pTran->Target[i].Addr+1-pTalk->OffsetA];
                                pTalk->pTran->Data.Bytes[4*i+2] = pTalk->pMem->A_Table[pTalk->pTran->Target[i].Addr+2-pTalk->OffsetA];
                                pTalk->pTran->Data.Bytes[4*i+3] = pTalk->pMem->A_Table[pTalk->pTran->Target[i].Addr+3-pTalk->OffsetA];
                                break;
                            default: break;
                            }
                        }
                        break;
                    case LK_CMD_FIX_D_WRITE:
                        for (int i=0; i<pTalk->pTran->Num; i++)
                        {
                            switch (pTalk->pTran->Target[i].Device)
                            {
                            case LK_DEV_F: pTalk->pTran->Data.Fixs[i] = pTalk->pMem->F_Table[pTalk->pTran->Target[i].Addr-pTalk->OffsetF]; break;
                            default: break;
                            }
                        }
                        break;
                    default:
                        break;
                    }
                    pTalk->pTran->ErrCode=0x00;
                    pTalk->Section.RetryCnt=0;
                    //準備傳送的資料
                    pTalk->Section.TalkTxBuf = pTalk->Section.TalkTxBufs;
                    pTalk->Section.TalkTxBuf[0]=START_CHAR_TALK;
                    pTalk->Section.TalkTxBuf[2]=(pTalk->Section.PkgID>>0);
                    pTalk->Section.TalkTxBuf[3]=(pTalk->Section.PkgID>>8);
                    pTalk->Section.TalkTxLen=4;
                    if (TransactionToBuf(&pTalk->Section, pTalk->pTran))
                    {
                        pTalk->Section.TalkTxLens = pTalk->Section.TalkTxLen;
                        WriteOutTalk(pTalk);
                        pTalk->Section.TxPkgCnt++;
                    }
                    else
                    {
                        pTalk->pTran->ErrCode=SCIF_ERROR_INVALID_PACKET_SET;
                        pTalk->TalkState = TALK_STATE_ERROR;
                        LogTalkError(pTalk, ERROR_TYPE_POLLING);                //記錄錯誤
                        pTalk->Action=CONNECT_ACTION_TO_DISCONNECT;
                    }

                }
            }
        }
    }                     
    //===================================在等待狀態=====================
    else if (pTalk->TalkState!=TALK_STATE_OVER_RETRY)
    {
        //---------處理重送
        if (pTalk->timeSend > pTalk->Timeout)
        {
            //pTalk->Section.RetryCnt++;

            if (FtpIndex==255)
                pTalk->Section.RetryCnt++;
            if (pTalk->Section.RetryCnt >= pTalk->TalkMaxRetry )
            {
                pTalk->TalkWaiting = 0;
                pTalk->TalkState = TALK_STATE_OVER_RETRY;
                pTalk->ConnState = SC_CONN_STATE_NORESPONSE;
            }
            else
            {
                WriteOutTalk(pTalk);
                pTalk->Section.TxPkgRetryCnt++;
            }
        }
    }
}

void WriteOutTalk(TALK_INFO *pTalk)
{
    WriteOutMessage(pTalk, (char *)pTalk->Section.TalkTxBufs, pTalk->Section.TalkTxLens);

    //記錄傳送時間
    pTalk->timeSend=0;
    pTalk->TalkWaiting=1;

    if (pSes->DebugLevel>=2)
    {
        unsigned int i;
        for (i=0; i<pTalk->Section.TalkTxLens; i++)
        {
            printf(" %02x", pTalk->Section.TalkTxBufs[i]);
        }
        printf("\n");
    }
}


//---------接收資料檢查-----------------------------------------------------
char ReceiveTalk(TALK_INFO *pTalk, unsigned short RxLen, unsigned char *RxBuf)
{
    unsigned char rt=0;

    pTalk->timeSpace=0;

    //--------檢查內容
    if (RxBuf[0]!=pTalk->Section.TalkTxBufs[0]) return 0;
    if (RxBuf[1]!=pTalk->Section.TalkTxBufs[1]) return 0;
    if (RxBuf[2]!=pTalk->Section.TalkTxBufs[2]) return 0;
    if (RxBuf[3]!=pTalk->Section.TalkTxBufs[3]) return 0;

    unsigned short ThisPkgID;
    ThisPkgID = (RxBuf[3]<<8) | RxBuf[2];
    if (ThisPkgID!=pTalk->Section.PkgID)
        return 0;

    rt = ParseRecvive(pTalk, pTalk->pTran, RxLen, RxBuf);
    if (rt==1)  //接收封包完成
    {
        pTalk->Section.RxPkgCnt++;
        if (!pTalk->pTran->ErrCode)
        {
            pTalk->pTran->Cancelled=0;
            TransactionFinish(pTalk, pTalk->pMem, pTalk->QueueFrom);
            pTalk->pTran->State=SC_TRANSACTION_FINISH;
            if      (pTalk->QueueFrom==0) pTalk->LoopQueue.ReadAddr++;
            else if (pTalk->QueueFrom==1) pTalk->DirectQueue.ReadAddr=(pTalk->DirectQueue.ReadAddr+1)&DIRECT_ADDR_MASK;
        }
        else
        {
            LogTalkError(pTalk, ERROR_TYPE_POLLING);                //記錄錯誤
            pTalk->TalkState = TALK_STATE_ERROR;
            if (pTalk->pTran->Cancelled>=3) pTalk->Action=CONNECT_ACTION_TO_DISCONNECT;
        }
    }

    //----------------------------------
    if (rt==1)  //接收封包完成
    {
    	pTalk->Section.PkgID++;
        if (pTalk->TalkState != TALK_STATE_NORMAL)
        {
            printf("[PT] Connection State change to OK! \n");
        }
        //---------------------------------------
        //設定完成及計算反應時間
        pTalk->ResponseTime=pTalk->timeSend;
        pTalk->TalkWaiting = 0;
        pTalk->TalkState = TALK_STATE_NORMAL;
        return 1;
    }
    return 0;
}


