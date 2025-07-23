//#include "stdafx.h"
#include "proc_protocol.h"

LK_PROTOCOL GetProtocol()
{
	return LK_PROTOCOL_FRIEND;
}

unsigned int EncodeBitAddr(LK_TARGET *pTarget)
{
    if      (pTarget->Device==LK_DEV_I)  return I_OFFSET+pTarget->Addr;
    else if (pTarget->Device==LK_DEV_O)  return O_OFFSET+pTarget->Addr;
    else if (pTarget->Device==LK_DEV_C)  return C_OFFSET+pTarget->Addr;
    else if (pTarget->Device==LK_DEV_S)  return S_OFFSET+pTarget->Addr;
    else if (pTarget->Device==LK_DEV_A)  return A_OFFSET+pTarget->Addr;
    else if (pTarget->Device==LK_DEV_TT) return TT_OFFSET+pTarget->Addr;
    else if (pTarget->Device==LK_DEV_CT) return CT_OFFSET+pTarget->Addr;
    else if (pTarget->Device==LK_DEV_RBIT) return RBIT_OFFSET+pTarget->Addr;
    else return 0xffffffff;
}

void DecodeBitAddr(int base, LK_TARGET *pTarget)
{
    if( base >= I_OFFSET && base < I_OFFSET + I_NUM )
    {
    	pTarget->Device =LK_DEV_I;
        pTarget->Addr   =base-I_OFFSET;
    }
    else if( base >= O_OFFSET && base < O_OFFSET + O_NUM )
    {
    	pTarget->Device =LK_DEV_O;
        pTarget->Addr   =base-O_OFFSET;
    }      
    else if( base >= C_OFFSET && base < C_OFFSET + C_NUM )
    {
    	pTarget->Device =LK_DEV_C;
        pTarget->Addr   =base-C_OFFSET;
    }
    else if( base >= S_OFFSET && base < S_OFFSET + S_NUM )
    {
    	pTarget->Device =LK_DEV_S;
        pTarget->Addr   =base-S_OFFSET;
    }
    else if( base >= A_OFFSET && base < A_OFFSET + A_NUM )
    {
    	pTarget->Device =LK_DEV_A;
        pTarget->Addr   =base-A_OFFSET;
    }
    else if( base >= TT_OFFSET && base < TT_OFFSET + TIMER_NUM )
    {
    	pTarget->Device =LK_DEV_TT;
        pTarget->Addr   =base-TT_OFFSET;
    }
    else if( base >= CT_OFFSET && base < CT_OFFSET + COUNTER_NUM )
    {
    	pTarget->Device =LK_DEV_CT;
        pTarget->Addr   =base-CT_OFFSET;
    }
    else if( base >= RBIT_OFFSET && base < RBIT_OFFSET + R_NUM )
    {
    	pTarget->Device =LK_DEV_RBIT;
        pTarget->Addr   =base-RBIT_OFFSET;
    }
}

unsigned int EncodeIntAddr(LK_TARGET *pTarget)
{
    if      (pTarget->Device==LK_DEV_R)  return R_OFFSET+pTarget->Addr; 
    else if (pTarget->Device==LK_DEV_RI) return RI_OFFSET+pTarget->Addr;    
    else if (pTarget->Device==LK_DEV_RO)  return RO_OFFSET+pTarget->Addr;
    else if (pTarget->Device==LK_DEV_RC)  return RC_OFFSET+pTarget->Addr;
    else if (pTarget->Device==LK_DEV_RS)  return RS_OFFSET+pTarget->Addr;
    else if (pTarget->Device==LK_DEV_RA)  return RA_OFFSET+pTarget->Addr;
    else if (pTarget->Device==LK_DEV_RTT) return RTT_OFFSET+pTarget->Addr;
    else if (pTarget->Device==LK_DEV_RCT) return RCT_OFFSET+pTarget->Addr;
    else if (pTarget->Device==LK_DEV_TS) return TS_OFFSET+pTarget->Addr;
    else if (pTarget->Device==LK_DEV_TV) return TV_OFFSET+pTarget->Addr;
    else if (pTarget->Device==LK_DEV_CS) return CS_OFFSET+pTarget->Addr;
    else if (pTarget->Device==LK_DEV_CV) return CV_OFFSET+pTarget->Addr;
    else return 0xffffffff;
}

void DecodeIntAddr(int base, LK_TARGET *pTarget)
{
    pTarget->Device =LK_DEV_NONE;
    if( base >= R_OFFSET && base < R_OFFSET + R_NUM )
    {
    	pTarget->Device =LK_DEV_R;
        pTarget->Addr   =base-R_OFFSET;
    }
    else if( base >= RI_OFFSET && base < RI_OFFSET + I_NUM )
    {
        pTarget->Device =LK_DEV_RI;
        pTarget->Addr   =base-RI_OFFSET;
    }
    else if( base >= RO_OFFSET && base < RO_OFFSET + O_NUM )
    {
        pTarget->Device =LK_DEV_RO;
        pTarget->Addr   =base-RO_OFFSET;
    }
    else if( base >= RC_OFFSET && base < RC_OFFSET + C_NUM )
    {
        pTarget->Device =LK_DEV_RC;
        pTarget->Addr   =base-RC_OFFSET;
    }
    else if( base >= RS_OFFSET && base < RS_OFFSET + S_NUM )
    {
        pTarget->Device =LK_DEV_RS;
        pTarget->Addr   =base-RS_OFFSET;
    }
    else if( base >= RA_OFFSET && base < RA_OFFSET + A_NUM )
    {
        pTarget->Device =LK_DEV_RA;
        pTarget->Addr   =base-RA_OFFSET;
    }
    else if( base >= RTT_OFFSET && base < RTT_OFFSET + TIMER_NUM )
    {
        pTarget->Device =LK_DEV_RTT;
        pTarget->Addr   =base-RTT_OFFSET;
    }
    else if( base >= RCT_OFFSET && base < RCT_OFFSET + COUNTER_NUM )
    {
        pTarget->Device =LK_DEV_RCT;
        pTarget->Addr   =base-RCT_OFFSET;
    }
    else if( base >= TS_OFFSET && base < TS_OFFSET + TIMER_NUM )
    {
    	pTarget->Device =LK_DEV_TS;
        pTarget->Addr   =base-TS_OFFSET;
    }
    else if( base >= TV_OFFSET && base < TV_OFFSET + TIMER_NUM )
    {
    	pTarget->Device =LK_DEV_TV;
        pTarget->Addr   =base-TV_OFFSET;
    }
    else if( base >= CS_OFFSET && base < CS_OFFSET + COUNTER_NUM )
    {
    	pTarget->Device =LK_DEV_CS;
        pTarget->Addr   =base-CS_OFFSET;
    }
    else if( base >= CV_OFFSET && base < CV_OFFSET + COUNTER_NUM )
    {
    	pTarget->Device =LK_DEV_CV;
        pTarget->Addr   =base-CV_OFFSET;
    }
}


unsigned int EncodeFixAddr(LK_TARGET *pTarget)
{
    if (pTarget->Device==LK_DEV_F)  return F_OFFSET + pTarget->Addr;
    else return 0xffffffff;
}

void DecodeFixAddr(unsigned int base, LK_TARGET *pTarget)
{
    if( base >= F_OFFSET && base < F_OFFSET + F_NUM )
    {
    	pTarget->Device =LK_DEV_F;
        pTarget->Addr   =base-F_OFFSET;
    }
}
//============== 交易資料轉為傳送資料 =====================
unsigned char TransactionToBuf(PROTOCOL_SECTION *pSec, LK_TRANSACTION *pTranc)
{
    int i, Addr;
    unsigned char *ptr;
    unsigned short temp;
    
    switch (pTranc->Cmd)
    {
    //================ bit
    case LK_CMD_BIT_N_READ:
    case LK_CMD_BIT_N_WRITE: 
        if (pTranc->Num>MAX_BIT_NUM)
        	return 0;
        if      (pTranc->Cmd==LK_CMD_BIT_N_READ)  pSec->TalkTxBuf[1]=0x64;
        else if (pTranc->Cmd==LK_CMD_BIT_N_WRITE) pSec->TalkTxBuf[1]=0x65;
        Addr=EncodeBitAddr(&pTranc->Target[0]);
        if (Addr==-1)
        	return 0;
        LongToBuf((pSec->TalkTxBuf+pSec->TalkTxLen), &Addr);         pSec->TalkTxLen+=4;
        LongToBuf((pSec->TalkTxBuf+pSec->TalkTxLen), &pTranc->Num);  pSec->TalkTxLen+=4;
        if (pTranc->Cmd==LK_CMD_BIT_N_WRITE)
        {
			for (i=0; i<pTranc->Num; i++)
			{
				pSec->TalkTxBuf[pSec->TalkTxLen++] = pTranc->Data.Bytes[i];
	        }
        }
        pTranc->RxByteCnt=14+pTranc->Num;
    	break;

    //================ int
    case LK_CMD_INT_N_READ:
    case LK_CMD_INT_N_WRITE: 
        if (pTranc->Num>MAX_INT_NUM)
        	return 0;
        if      (pTranc->Cmd==LK_CMD_INT_N_READ)  pSec->TalkTxBuf[1]=0x44;
        else if (pTranc->Cmd==LK_CMD_INT_N_WRITE) pSec->TalkTxBuf[1]=0x41;
        Addr=EncodeIntAddr(&pTranc->Target[0]);  
        if (Addr==-1)
        	return 0;
        LongToBuf((pSec->TalkTxBuf+pSec->TalkTxLen), &Addr);         pSec->TalkTxLen+=4;
        LongToBuf((pSec->TalkTxBuf+pSec->TalkTxLen), &pTranc->Num);  pSec->TalkTxLen+=4;
        if (pTranc->Cmd==LK_CMD_INT_N_WRITE)
        {
			for (i=0; i<pTranc->Num; i++)
			{
        		LongToBuf((pSec->TalkTxBuf+pSec->TalkTxLen), &pTranc->Data.Ints[i]);  pSec->TalkTxLen+=4;
	        }
        }     
        pTranc->RxByteCnt=14+pTranc->Num*4;
    	break;

    //================ fix
    case LK_CMD_FIX_N_READ:
    case LK_CMD_FIX_N_WRITE:  
        if (pTranc->Num>MAX_FIX_NUM)
        	return 0;
        if      (pTranc->Cmd==LK_CMD_FIX_N_READ)  pSec->TalkTxBuf[1]=0x45;
        else if (pTranc->Cmd==LK_CMD_FIX_N_WRITE) pSec->TalkTxBuf[1]=0x42;
        Addr=EncodeFixAddr(&pTranc->Target[0]);
        if (Addr==-1)
        	return 0;
        LongToBuf((pSec->TalkTxBuf+pSec->TalkTxLen), &Addr);         pSec->TalkTxLen+=4;
        LongToBuf((pSec->TalkTxBuf+pSec->TalkTxLen), &pTranc->Num);  pSec->TalkTxLen+=4;
        if (pTranc->Cmd==LK_CMD_FIX_N_WRITE)
        {
			for (i=0; i<pTranc->Num; i++)
			{ 
        		DoubleToBuf((pSec->TalkTxBuf+pSec->TalkTxLen), &pTranc->Data.Fixs[i]);  pSec->TalkTxLen+=8;
	        }
        }    
        pTranc->RxByteCnt=14+pTranc->Num*8;
    	break;


    //==============================discrete Bit
    case LK_CMD_BIT_D_READ:   
    case LK_CMD_BIT_D_WRITE: 
        if (pTranc->Num>MAX_CB_BIT_NUM)
            return 0;
        if (pTranc->Cmd==LK_CMD_BIT_D_READ)
        	pSec->TalkTxBuf[1]=0x66;
        else if (pTranc->Cmd==LK_CMD_BIT_D_WRITE)
        	pSec->TalkTxBuf[1]=0x67;
        pTranc->RxByteCnt=10+pTranc->Num*5;

        LongToBuf((pSec->TalkTxBuf+pSec->TalkTxLen), &pTranc->Num);  pSec->TalkTxLen+=4;
        for (i=0; i<pTranc->Num; i++)
        {
            Addr=EncodeBitAddr(&pTranc->Target[i]);
        	ptr=(unsigned char *)&Addr;
            if (Addr==-1)
                return 0;
        	LongToBuf((pSec->TalkTxBuf+pSec->TalkTxLen), &Addr);  pSec->TalkTxLen+=4;
            if (pTranc->Cmd==LK_CMD_BIT_D_WRITE)
            	pSec->TalkTxBuf[pSec->TalkTxLen++]=pTranc->Data.Bytes[i];
        }
    	break;

    //==============================discrete Int
    case LK_CMD_INT_D_READ:
    case LK_CMD_INT_D_WRITE:  
        if (pTranc->Num>MAX_CB_INT_NUM)
            return 0;
        if (pTranc->Cmd==LK_CMD_INT_D_READ)
        	pSec->TalkTxBuf[1]=0x43;
        else if (pTranc->Cmd==LK_CMD_INT_D_WRITE)
        	pSec->TalkTxBuf[1]=0x4A;
        pTranc->RxByteCnt=10+pTranc->Num*8;

        LongToBuf((pSec->TalkTxBuf+pSec->TalkTxLen), &pTranc->Num);  pSec->TalkTxLen+=4;
        for (i=0; i<pTranc->Num; i++)
        {
            Addr=EncodeIntAddr(&pTranc->Target[i]);
            if (Addr==-1)
                return 0;
        	LongToBuf((pSec->TalkTxBuf+pSec->TalkTxLen), &Addr);  pSec->TalkTxLen+=4;
            if (pTranc->Cmd==LK_CMD_INT_D_WRITE)
            {                       
        		LongToBuf((pSec->TalkTxBuf+pSec->TalkTxLen), &pTranc->Data.Ints[i]);  pSec->TalkTxLen+=4;
            }
        }
    	break;

    //==============================discrete Fix
    case LK_CMD_FIX_D_READ:  
    case LK_CMD_FIX_D_WRITE:
        if (pTranc->Num>MAX_CB_FIX_NUM)
            return 0;
        if (pTranc->Cmd==LK_CMD_FIX_D_READ)
        	pSec->TalkTxBuf[1]=0x48;
        else if (pTranc->Cmd==LK_CMD_FIX_D_WRITE)
        	pSec->TalkTxBuf[1]=0x49;
        pTranc->RxByteCnt=10+pTranc->Num*12;
        LongToBuf((pSec->TalkTxBuf+pSec->TalkTxLen), &pTranc->Num);  pSec->TalkTxLen+=4;
        for (i=0; i<pTranc->Num; i++)
        {
            Addr=EncodeFixAddr(&pTranc->Target[i]);
            if (Addr==-1)
                return 0;
        	LongToBuf((pSec->TalkTxBuf+pSec->TalkTxLen), &Addr);  pSec->TalkTxLen+=4;
            if (pTranc->Cmd==LK_CMD_FIX_D_WRITE)
            { 
        		DoubleToBuf((pSec->TalkTxBuf+pSec->TalkTxLen), &pTranc->Data.Fixs[i]);  pSec->TalkTxLen+=8;
            }
        }
        break;
    default:
    	return 0;
    }
    temp = CRC_16(pSec->TalkTxBuf, pSec->TalkTxLen);
    pSec->TalkTxBuf[pSec->TalkTxLen++] = temp & 0xff;
    pSec->TalkTxBuf[pSec->TalkTxLen++] = (temp >> 8) & 0xff;
    return 1;
}


//============== 收到的資料轉為 交易資料
//void BufToTransaction(PROTOCOL_SECTION *pSec, LK_TRANSACTION *pTranc)
void BufToTransaction(short RxLen, unsigned char *RxBuf, LK_TRANSACTION *pTranc)
{
    int i;
    unsigned char *ptr;
    unsigned short k;
    k=4;
	switch (pTranc->Cmd)
    {
    //================ bit
    case LK_CMD_BIT_N_READ:
    case LK_CMD_BIT_N_WRITE:
        k+=8;
        for (i=0; i<pTranc->Num; i++)
        {
            pTranc->Data.Bytes[i] = RxBuf[k++];
        }
    	break;

    //================ int
    case LK_CMD_INT_N_READ:
    case LK_CMD_INT_N_WRITE:
        k+=8;
        for (i=0; i<pTranc->Num; i++)
        {
            BufToLong(&pTranc->Data.Ints[i], (RxBuf+k));  k+=4;
        }
    	break;

    //================ fix
    case LK_CMD_FIX_N_READ:
    case LK_CMD_FIX_N_WRITE:
        k+=8;
        for (i=0; i<pTranc->Num; i++)
        {
        	BufToDouble(&pTranc->Data.Fixs[i], (RxBuf+k));  k+=8;
        }
    	break;
    //==============================discrete
    case LK_CMD_BIT_D_READ:   
    case LK_CMD_BIT_D_WRITE:
        k+=4;
        for (i=0; i<pTranc->Num; i++)
        {
            k+=4;
            pTranc->Data.Bytes[i]=RxBuf[k++];
        }
        break;
    case LK_CMD_INT_D_READ:  
    case LK_CMD_INT_D_WRITE:
        k+=4;
        for (i=0; i<pTranc->Num; i++)
        {
            k+=4;
            BufToLong(&pTranc->Data.Ints[i], (RxBuf+k));  k+=4;
        }
        break;
    case LK_CMD_FIX_D_READ:  
    case LK_CMD_FIX_D_WRITE:
        k+=4;
        for (i=0; i<pTranc->Num; i++)
        {
            k+=4;             
        	BufToDouble(&pTranc->Data.Fixs[i], (RxBuf+k));  k+=8;
        }
        break;
    default:
        break;
    }
}


//============== RTU 模式 接收檢查
unsigned char ParseRecvive(TALK_INFO *pTalk, LK_TRANSACTION *pTranc, unsigned short RxLen, unsigned char *RxBuf)
{
    unsigned char FunCode;
    unsigned short TotalByte;

    if (pTranc==NULL) return 0;
    
    FunCode = RxBuf[1];
    if (FunCode&0x80) TotalByte=7;
    else              TotalByte=pTranc->RxByteCnt;
    if (RxLen>=TotalByte)
    {
        if (CheckCRC(RxBuf, TotalByte)) //檢查CRC
        {
            //統計資料--未處理完的資料，記錄長度，直接丟掉
            //pSec->RxUseByteCnt+=TotalByte;
            //pSec->RxUnuseByteCnt+=(RxLen-TotalByte);
            //搬移資料
            if (FunCode&0x80)
                pTranc->ErrCode=RxBuf[4];
            else
                BufToTransaction(RxLen, RxBuf, pTranc);
            return 1;
        }
        else
        {
            //pSec->RxUnuseByteCnt+=RxLen;
            pTalk->Section.RxCrcPkgCnt++;
        }
    }
    return 0;
}




