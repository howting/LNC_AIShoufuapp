//#include "stdafx.h"
#include "sc2_memory.h"



COMM_SESSION  *pSes=0;
int           *MainSocket;
void  LogTalkError(TALK_INFO *pTalk, int Type);
int   FtpIndex;


//--------------------------------------------------------------------
int WriteOutMessage(TALK_INFO *pTalk, char *Buf, int Len)
{
    int adlen = sizeof(struct sockaddr);
    return sendto(*pTalk->Sck, Buf, Len, 0, (struct sockaddr *)&pTalk->ReconAddr, adlen); //sizeof(struct sockaddr));
}


//========================== Add to Queue ===================================
PTR AddDirectQueue(int TgrConn, LK_TRANSACTION *pTran)
{
    if (pSes==0) return 0;
    if ((TgrConn<0)||(TgrConn>=pSes->ConnectNum)) return 0;
    TALK_INFO *pTalk = &pSes->pTalkInfo[TgrConn];
    if (pTalk->ConnState!=SC_CONN_STATE_OK)
        return 0;

    unsigned char k;
    LK_TRANSACTION* pSync;
    k=(pTalk->DirectQueue.WriteAddr+1)&DIRECT_ADDR_MASK;
    if (k==pTalk->DirectQueue.ReadAddr)
    {
        return 0;
    }
    pSync=&pTalk->DirectQueue.Trans[pTalk->DirectQueue.WriteAddr];
    memcpy(pSync, pTran, sizeof(LK_TRANSACTION));
    pSync->Cancelled=0;
    pSync->State=SC_TRANSACTION_PENDING;
    pTalk->DirectQueue.WriteAddr=k;
    return (PTR)pSync;
}

PTR AddLoopQueue(int TgrConn, LK_TRANSACTION *pTran)
{
    if (pSes==0) return 0;
    if ((TgrConn<0)||(TgrConn>=pSes->ConnectNum)) return 0;
    TALK_INFO *pTalk = &pSes->pTalkInfo[TgrConn];

    LK_TRANSACTION* pSync;
    if (pTalk->LoopQueue.WriteAddr==MAX_LOOP_SIZE)
    {
        return 0;
    }
    pSync=&pTalk->LoopQueue.Trans[pTalk->LoopQueue.WriteAddr];
    memcpy(pSync, pTran, sizeof(LK_TRANSACTION));
    pSync->Cancelled=0;
    pSync->State=SC_TRANSACTION_PENDING;
    pTalk->LoopQueue.WriteAddr++;
    return (PTR)pSync;
}

//=============================================================
PTR cmdBitWriteN(int TgrConn, int type, LK_DEVICE dev, int Addrs, int Nums, int *data)
{
    if (pSes==0) return 0;
    if ((TgrConn<0)||(TgrConn>=pSes->ConnectNum)) return 0;

    int addr, num;
    int i;
    LK_TRANSACTION Tran;
	PTR rt=0;
    while (Nums>0)
    {
        addr = Addrs;
        if (Nums>MAX_BIT_NUM) num=MAX_BIT_NUM;
        else                  num=Nums;
        //-------
        {
            TALK_INFO *pTalk = &pSes->pTalkInfo[TgrConn];
            if ((type==1)&&((!pTalk->DirectWriteCombineFlag)||(dev==LK_DEV_RBIT)))
            {
                Tran.SlaveID=TgrConn;
                Tran.Cmd=LK_CMD_BIT_N_WRITE;
                Tran.Num=num;
                Tran.Target[0].Device=dev;
                Tran.Target[0].Addr=addr;
                for (i=0; i<num; i++) Tran.Data.Bytes[i]=data[i];
                rt = AddDirectQueue(TgrConn, &Tran);
            }
            else if ((type==0)&&((!pTalk->LoopWriteCombineFlag)||(dev==LK_DEV_RBIT)))
            {
                Tran.SlaveID=TgrConn;
                Tran.Cmd=LK_CMD_BIT_N_WRITE;
                Tran.Num=num;
                Tran.Target[0].Device=dev;
                Tran.Target[0].Addr=addr;
                rt = AddLoopQueue(TgrConn, &Tran);
            }
            else if (type==1)
            {
                int num2 = (num-1)/4 +1;
                if ((num2+pTalk->DirectWriteIntNum)>INT_CB_SIZE) break;
                LK_DEVICE dev2;
                switch (dev)
                {
                case LK_DEV_I:  dev2=LK_DEV_RI; break;
                case LK_DEV_O:  dev2=LK_DEV_RO; break;
                case LK_DEV_C:  dev2=LK_DEV_RC; break;
                case LK_DEV_S:  dev2=LK_DEV_RS; break;
                case LK_DEV_A:  dev2=LK_DEV_RA; break;
                case LK_DEV_TT: dev2=LK_DEV_RTT; break;
                case LK_DEV_CT: dev2=LK_DEV_RCT; break;
                default: break;
                }
                for (i=0; i<num2; i++)
                {
                    pTalk->DirectWriteInt[pTalk->DirectWriteIntNum].Device=dev2;
                    pTalk->DirectWriteInt[pTalk->DirectWriteIntNum].Addr=addr+4*i;
                    char *ptr = (char *)&pTalk->DirectWriteIntData[pTalk->DirectWriteIntNum];
                    //if (4*i+0<num) ptr[0]=data[4*i+0];
                    //if (4*i+1<num) ptr[1]=data[4*i+1];
                    //if (4*i+2<num) ptr[2]=data[4*i+2];
                    //if (4*i+3<num) ptr[3]=data[4*i+3];
                    //-----------20180420 
                    ptr[0]= ((4*i+0<num)?0:16) + ((data[4*i+0]!=0)?1:0);
                    ptr[1]= ((4*i+1<num)?0:16) + ((data[4*i+1]!=0)?1:0);
                    ptr[2]= ((4*i+2<num)?0:16) + ((data[4*i+2]!=0)?1:0);
                    ptr[3]= ((4*i+3<num)?0:16) + ((data[4*i+3]!=0)?1:0);
                    pTalk->DirectWriteIntNum++;
                }
                rt = 1;
            }
            else if (type==0)
            {
                int num2 = (num-1)/4 +1;
                if ((num2+pTalk->LoopWriteIntNum)>INT_CB_SIZE) break;
                LK_DEVICE dev2;
                switch (dev)
                {
                case LK_DEV_I:  dev2=LK_DEV_RI; break;
                case LK_DEV_O:  dev2=LK_DEV_RO; break;
                case LK_DEV_C:  dev2=LK_DEV_RC; break;
                case LK_DEV_S:  dev2=LK_DEV_RS; break;
                case LK_DEV_A:  dev2=LK_DEV_RA; break;
                case LK_DEV_TT: dev2=LK_DEV_RTT; break;
                case LK_DEV_CT: dev2=LK_DEV_RCT; break;
                default: break;
                }
                for (i=0; i<num2; i++)
                {
                    pTalk->LoopWriteInt[pTalk->LoopWriteIntNum].Device=dev2;
                    pTalk->LoopWriteInt[pTalk->LoopWriteIntNum].Addr=addr+4*i;
                    pTalk->LoopWriteIntNum++;
                }
                rt = 1;
            }
        }
        Addrs+=num;
        Nums-=num;
        data+=num;
    }
    return rt;
}

PTR cmdIntWriteN(int TgrConn, int type, LK_DEVICE dev, int Addrs, int Nums, int *data)
{
    if (pSes==0) return 0;
    if ((TgrConn<0)||(TgrConn>=pSes->ConnectNum)) return 0;
    int addr, num;
    int i;
    LK_TRANSACTION Tran;
	PTR rt=0;

    while (Nums>0)
    {
        addr = Addrs;
        if (Nums>MAX_INT_NUM) num=MAX_INT_NUM;
        else                  num=Nums;
        {
            TALK_INFO *pTalk = &pSes->pTalkInfo[TgrConn];
            if ((type==1)&&(!pTalk->DirectWriteCombineFlag))
            {
                Tran.SlaveID=TgrConn;
                Tran.Cmd=LK_CMD_INT_N_WRITE;
                Tran.Num=num;
                Tran.Target[0].Device=dev;
                Tran.Target[0].Addr=addr;
                for (i=0; i<num; i++) Tran.Data.Ints[i]=data[i];
                rt = AddDirectQueue(TgrConn, &Tran);
            }
            else if ((type==0)&&(!pTalk->LoopWriteCombineFlag))
            {
                Tran.SlaveID=TgrConn;
                Tran.Cmd=LK_CMD_INT_N_WRITE;
                Tran.Num=num;
                Tran.Target[0].Device=dev;
                Tran.Target[0].Addr=addr;
                rt = AddLoopQueue(TgrConn, &Tran);
            }
            else if (type==1)
            {
                if ((num+pTalk->DirectWriteIntNum)>INT_CB_SIZE) break;
                for (i=0; i<num; i++)
                {
                    pTalk->DirectWriteInt[pTalk->DirectWriteIntNum].Device=dev;
                    pTalk->DirectWriteInt[pTalk->DirectWriteIntNum].Addr=addr+i;
                    pTalk->DirectWriteIntData[pTalk->DirectWriteIntNum]=data[i];
                    pTalk->DirectWriteIntNum++;
                }
                rt = 1;
            }
            else if (type==0)
            {
                if ((num+pTalk->LoopWriteIntNum)>INT_CB_SIZE) break;
                for (i=0; i<num; i++)
                {
                    pTalk->LoopWriteInt[pTalk->LoopWriteIntNum].Device=dev;
                    pTalk->LoopWriteInt[pTalk->LoopWriteIntNum].Addr=addr+i;
                    pTalk->LoopWriteIntNum++;
                }
                rt = 1;
            }
        }
        Addrs+=num;
        Nums-=num;
        data+=num;
    }
    return rt;
}

PTR cmdFixWriteN(int TgrConn, int type, LK_DEVICE dev, int Addrs, int Nums, double *data)
{
    if (pSes==0) return 0;
    if ((TgrConn<0)||(TgrConn>=pSes->ConnectNum)) return 0;
    int addr, num;
    int i;
    LK_TRANSACTION Tran;
	PTR rt=0;

    //if (num>MAX_FIX_NUM) return 0;
    while (Nums>0)
    {
        addr = Addrs;
        if (Nums>MAX_FIX_NUM) num=MAX_FIX_NUM;
        else                  num=Nums;
        //-------
        {
            TALK_INFO *pTalk = &pSes->pTalkInfo[TgrConn];
            if ((type==1)&&(!pTalk->DirectWriteCombineFlag))
            {
                Tran.SlaveID=TgrConn;
                Tran.Cmd=LK_CMD_FIX_N_WRITE;
                Tran.Num=num;
                Tran.Target[0].Device=dev;
                Tran.Target[0].Addr=addr;
                for (i=0; i<num; i++) Tran.Data.Fixs[i]=data[i];
                rt = AddDirectQueue(TgrConn, &Tran);
            }
            else if ((type==0)&&(!pTalk->LoopWriteCombineFlag))
            {
                Tran.SlaveID=TgrConn;
                Tran.Cmd=LK_CMD_FIX_N_WRITE;
                Tran.Num=num;
                Tran.Target[0].Device=dev;
                Tran.Target[0].Addr=addr;
                rt = AddLoopQueue(TgrConn, &Tran);
            }
            else if (type==1)
            {
                if ((num+pTalk->DirectWriteFixNum)>FIX_CB_SIZE) break;
                for (i=0; i<num; i++)
                {
                    pTalk->DirectWriteFix[pTalk->DirectWriteFixNum].Device=dev;
                    pTalk->DirectWriteFix[pTalk->DirectWriteFixNum].Addr=addr+i;
                    pTalk->DirectWriteFixData[pTalk->DirectWriteFixNum]=data[i];
                    pTalk->DirectWriteFixNum++;
                }
                rt = 1;
            }
            else if (type==0)
            {
                if ((num+pTalk->LoopWriteFixNum)>FIX_CB_SIZE) break;
                for (i=0; i<num; i++)
                {
                    pTalk->LoopWriteFix[pTalk->LoopWriteFixNum].Device=dev;
                    pTalk->LoopWriteFix[pTalk->LoopWriteFixNum].Addr=addr+i;
                    pTalk->LoopWriteFixNum++;
                }
                rt = 1;
            }
        }
        Addrs+=num;
        Nums-=num;
        data+=num;
    }
    return rt;
}


//  ============================= continue read ============
PTR cmdBitReadN(int TgrConn, int type, LK_DEVICE dev, int Addrs, int Nums)
{
    if (pSes==0) return 0;
    if ((TgrConn<0)||(TgrConn>=pSes->ConnectNum)) return 0;

    int addr, num;
    int i;
    LK_TRANSACTION Tran;
	PTR rt=0;
    while (Nums>0)
    {
        addr = Addrs;
        if (Nums>MAX_BIT_NUM) num=MAX_BIT_NUM;
        else                  num=Nums;
        //-------
        {
            TALK_INFO *pTalk = &pSes->pTalkInfo[TgrConn];
            if ((type==1)&&(!pTalk->DirectReadCombineFlag))
            {
                Tran.SlaveID=TgrConn;
                Tran.Cmd=LK_CMD_BIT_N_READ;
                Tran.Num=num;
                Tran.Target[0].Device=dev;
                Tran.Target[0].Addr=addr;
                rt = AddDirectQueue(TgrConn, &Tran);
            }
            else if ((type==0)&&(!pTalk->LoopReadCombineFlag))
            {
                Tran.SlaveID=TgrConn;
                Tran.Cmd=LK_CMD_BIT_N_READ;
                Tran.Num=num;
                Tran.Target[0].Device=dev;
                Tran.Target[0].Addr=addr;
                AddLoopQueue(TgrConn, &Tran);
            }
            else if (type==1)
            {
                //
                num-=1;
                num>>=2;
                num+=1;
                if ((num+pTalk->DirectReadIntNum)>INT_CB_SIZE) break;
                LK_DEVICE dev2;
                switch (dev)
                {
                case LK_DEV_I:  dev2=LK_DEV_RI; break;
                case LK_DEV_O:  dev2=LK_DEV_RO; break;
                case LK_DEV_C:  dev2=LK_DEV_RC; break;
                case LK_DEV_S:  dev2=LK_DEV_RS; break;
                case LK_DEV_A:  dev2=LK_DEV_RA; break;
                case LK_DEV_TT: dev2=LK_DEV_RTT; break;
                case LK_DEV_CT: dev2=LK_DEV_RCT; break;
                default: break;
                }
                for (i=0; i<num; i++)
                {
                    pTalk->DirectReadInt[pTalk->DirectReadIntNum].Device=dev2;
                    pTalk->DirectReadInt[pTalk->DirectReadIntNum].Addr=addr+i*4;
                    pTalk->DirectReadIntNum++;
                }
                rt = 1;
            }
            else if (type==0)
            {
                num-=1;
                num>>=2;
                num+=1;
                if ((num+pTalk->LoopReadIntNum)>INT_CB_SIZE) break;
                LK_DEVICE dev2;
                switch (dev)
                {
                case LK_DEV_I:  dev2=LK_DEV_RI; break;
                case LK_DEV_O:  dev2=LK_DEV_RO; break;
                case LK_DEV_C:  dev2=LK_DEV_RC; break;
                case LK_DEV_S:  dev2=LK_DEV_RS; break;
                case LK_DEV_A:  dev2=LK_DEV_RA; break;
                case LK_DEV_TT: dev2=LK_DEV_RTT; break;
                case LK_DEV_CT: dev2=LK_DEV_RCT; break;
                default: break;
                }
                for (i=0; i<num; i++)
                {
                    pTalk->LoopReadInt[pTalk->LoopReadIntNum].Device=dev2;
                    pTalk->LoopReadInt[pTalk->LoopReadIntNum].Addr=addr+i*4;
                    pTalk->LoopReadIntNum++;
                }
                rt = 1;
            }
        }
        Addrs+=num;
        Nums-=num;
    }
    return rt;
}

PTR cmdIntReadN(int TgrConn, int type, LK_DEVICE dev, int Addrs, int Nums)
{
    if (pSes==0) return 0;
    if ((TgrConn<0)||(TgrConn>=pSes->ConnectNum)) return 0;
    int addr, num;
    int i;
    LK_TRANSACTION Tran;
    unsigned char pt, st, ed;
	PTR rt=0;


    while (Nums>0)
    {
        addr = Addrs;
        if (Nums>MAX_INT_NUM) num=MAX_INT_NUM;
        else                  num=Nums;
        {
            TALK_INFO *pTalk = &pSes->pTalkInfo[TgrConn];
            if ((type==1)&&(!pTalk->DirectReadCombineFlag))
            {
                Tran.SlaveID=TgrConn;
                Tran.Cmd=LK_CMD_INT_N_READ;
                Tran.Num=num;
                Tran.Target[0].Device=dev;
                Tran.Target[0].Addr=addr;
                rt = AddDirectQueue(TgrConn, &Tran);
            }
            else if ((type==0)&&(!pTalk->LoopReadCombineFlag))
            {
                Tran.SlaveID=TgrConn;
                Tran.Cmd=LK_CMD_INT_N_READ;
                Tran.Num=num;
                Tran.Target[0].Device=dev;
                Tran.Target[0].Addr=addr;
                rt = AddLoopQueue(TgrConn, &Tran);
            }
            else if (type==1)
            {
                if ((num+pTalk->DirectReadIntNum)>INT_CB_SIZE) break;
                for (i=0; i<num; i++)
                {
                    pTalk->DirectReadInt[pTalk->DirectReadIntNum].Device=dev;
                    pTalk->DirectReadInt[pTalk->DirectReadIntNum].Addr=addr+i;
                    pTalk->DirectReadIntNum++;
                }
                rt = 1;
            }
            else if (type==0)
            {
                if ((num+pTalk->LoopReadIntNum)>INT_CB_SIZE) break;
                for (i=0; i<num; i++)
                {
                    pTalk->LoopReadInt[pTalk->LoopReadIntNum].Device=dev;
                    pTalk->LoopReadInt[pTalk->LoopReadIntNum].Addr=addr+i;
                    pTalk->LoopReadIntNum++;
                }
				rt = 1;
            }
        }
        Addrs+=num;
        Nums-=num;
    }
    return rt;
}


PTR cmdFixReadN(int TgrConn, int type, LK_DEVICE dev, int Addrs, int Nums)
{
    if (pSes==0) return 0;
    if ((TgrConn<0)||(TgrConn>=pSes->ConnectNum)) return 0;
    int addr, num;
    int i;
    LK_TRANSACTION Tran;
	PTR rt=0;

    //if (num>MAX_FIX_NUM) return 0;
    while (Nums>0)
    {
        addr = Addrs;
        if (Nums>MAX_FIX_NUM) num=MAX_FIX_NUM;
        else                  num=Nums;
        {
            TALK_INFO *pTalk = &pSes->pTalkInfo[TgrConn];
            if ((type==1)&&(!pTalk->DirectReadCombineFlag))
            {
                Tran.SlaveID=TgrConn;
                Tran.Cmd=LK_CMD_FIX_N_READ;
                Tran.Num=num;
                Tran.Target[0].Device=dev;
                Tran.Target[0].Addr=addr;
                rt = AddDirectQueue(TgrConn, &Tran);
            }
            else if ((type==0)&&(!pTalk->LoopReadCombineFlag))
            {
                Tran.SlaveID=TgrConn;
                Tran.Cmd=LK_CMD_FIX_N_READ;
                Tran.Num=num;
                Tran.Target[0].Device=dev;
                Tran.Target[0].Addr=addr;
                rt = AddLoopQueue(TgrConn, &Tran);
            }
            else if (type==1)
            {
                if ((num+pTalk->DirectReadFixNum)>FIX_CB_SIZE) break;
                for (i=0; i<num; i++)
                {
                    pTalk->DirectReadFix[pTalk->DirectReadFixNum].Device=dev;
                    pTalk->DirectReadFix[pTalk->DirectReadFixNum].Addr=addr+i;
                    pTalk->DirectReadFixNum++;
                }
                rt = 1;
            }
            else if (type==0)
            {
                if ((num+pTalk->LoopReadFixNum)>FIX_CB_SIZE) break;
                for (i=0; i<num; i++)
                {
                    pTalk->LoopReadFix[pTalk->LoopReadFixNum].Device=dev;
                    pTalk->LoopReadFix[pTalk->LoopReadFixNum].Addr=addr+i;
                    pTalk->LoopReadFixNum++;
                }
                rt = 1;
            }
        }
        Addrs+=num;
        Nums-=num;
    }
    return rt;
}


PTR CombineIntRead(int TgrConn, int type, int num, int StIdx)
{
    if (pSes==0) return 0;
    if (num>MAX_CB_INT_NUM) return 0;
    LK_TRANSACTION Tran;
    Tran.SlaveID=TgrConn;
    Tran.Cmd=LK_CMD_INT_D_READ;
    Tran.Num=num;
    if (type==0)
    {
        memcpy(Tran.Target, &pSes->pTalkInfo[TgrConn].LoopReadInt[StIdx], sizeof(LK_TARGET)*num);
        return AddLoopQueue(TgrConn, &Tran);
    }
    else
    {
        memcpy(Tran.Target, &pSes->pTalkInfo[TgrConn].DirectReadInt[StIdx], sizeof(LK_TARGET)*num);
        return AddDirectQueue(TgrConn, &Tran);
    }
}

PTR CombineFixRead(int TgrConn, int type, int num, int StIdx)
{
    if (pSes==0) return 0;
    if (num>MAX_CB_FIX_NUM) return 0;
    LK_TRANSACTION Tran;
    Tran.SlaveID=TgrConn;
    Tran.Cmd=LK_CMD_FIX_D_READ;
    Tran.Num=num;
    if (type==0)
    {
        memcpy(Tran.Target, &pSes->pTalkInfo[TgrConn].LoopReadFix[StIdx], sizeof(LK_TARGET)*num);
        return AddLoopQueue(TgrConn, &Tran);
    }
    else
    {
        memcpy(Tran.Target, &pSes->pTalkInfo[TgrConn].DirectReadFix[StIdx], sizeof(LK_TARGET)*num);
        return AddDirectQueue(TgrConn, &Tran);
    }
}


PTR CombineIntWrite(int TgrConn, int type, int num, int StIdx)
{
    if (pSes==0) return 0;
    if (num>MAX_CB_INT_NUM) return 0;
    LK_TRANSACTION Tran;
    Tran.SlaveID=TgrConn;
    Tran.Cmd=LK_CMD_INT_D_WRITE;
    Tran.Num=num;
    if (type==0)
    {
        memcpy(Tran.Target, &pSes->pTalkInfo[TgrConn].LoopWriteInt[StIdx], sizeof(LK_TARGET)*num);
        return AddLoopQueue(TgrConn, &Tran);
    }
    else
    {
        memcpy(Tran.Target, &pSes->pTalkInfo[TgrConn].DirectWriteInt[StIdx], sizeof(LK_TARGET)*num);
        memcpy(Tran.Data.Ints, &pSes->pTalkInfo[TgrConn].DirectWriteIntData[StIdx], sizeof(int)*num);
        return AddDirectQueue(TgrConn, &Tran);
    }
}

PTR CombineFixWrite(int TgrConn, int type, int num, int StIdx)
{
    if (pSes==0) return 0;
    if (num>MAX_CB_FIX_NUM) return 0;
    LK_TRANSACTION Tran;
    Tran.SlaveID=TgrConn;
    Tran.Cmd=LK_CMD_FIX_D_WRITE;
    Tran.Num=num;
    if (type==0)
    {
        memcpy(Tran.Target, &pSes->pTalkInfo[TgrConn].LoopWriteFix[StIdx], sizeof(LK_TARGET)*num);
        return AddLoopQueue(TgrConn, &Tran);
    }
    else
    {
        memcpy(Tran.Target, &pSes->pTalkInfo[TgrConn].DirectWriteFix[StIdx], sizeof(LK_TARGET)*num);
        memcpy(Tran.Data.Ints, &pSes->pTalkInfo[TgrConn].DirectWriteFixData[StIdx], sizeof(double)*num);
        return AddDirectQueue(TgrConn, &Tran);
    }
}
