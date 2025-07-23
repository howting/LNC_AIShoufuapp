//#include "stdafx.h"
#include "proc_sync_handle.h"

//===========================================
char TransactionFinish(TALK_INFO *pTalk, MIRROR_MEMORY *pMem, int QueueFrom)
{
    LK_TRANSACTION *pTran = pTalk->pTran;
    int i, k;
    //unsigned char p, q;
    //unsigned char byteV;
    //unsigned short shortV;
    //unsigned int intV;

    switch (pTran->Cmd)
    {
    //--------------------------- bit data
    case LK_CMD_BIT_1_READ:
    case LK_CMD_BIT_N_READ:
    case LK_CMD_BIT_1_WRITE:
    case LK_CMD_BIT_N_WRITE:
        if ((QueueFrom==0)&&((pTran->Cmd==LK_CMD_BIT_1_WRITE)||(pTran->Cmd==LK_CMD_BIT_N_WRITE)))
            break;
        if (pTran->Target[0].Device==LK_DEV_I)
        {
            for (i=0; i<pTran->Num; i++)
            {
                k = pTran->Target[0].Addr+i-pTalk->OffsetI;
                if ((k>=0)&&(k<pMem->SizeI))
                	pMem->I_Table[k]=pTran->Data.Bytes[i];
            }
        }
        else if (pTran->Target[0].Device==LK_DEV_O)
        {
            for (i=0; i<pTran->Num; i++)
            {              
                k = pTran->Target[0].Addr+i-pTalk->OffsetO;
                if ((k>=0)&&(k<pMem->SizeO))
                	pMem->O_Table[k]=pTran->Data.Bytes[i];
            }
        }    
        else if (pTran->Target[0].Device==LK_DEV_C)
        {
            for (i=0; i<pTran->Num; i++)
            {
                k = pTran->Target[0].Addr+i-pTalk->OffsetC;
                if ((k>=0)&&(k<pMem->SizeC))
                	pMem->C_Table[k]=pTran->Data.Bytes[i];
            }
        }
        else if (pTran->Target[0].Device==LK_DEV_S)
        {
            for (i=0; i<pTran->Num; i++)
            {
                k = pTran->Target[0].Addr+i-pTalk->OffsetS;
                if ((k>=0)&&(k<pMem->SizeS))
                	pMem->S_Table[k]=pTran->Data.Bytes[i];
            }
        }
        else if (pTran->Target[0].Device==LK_DEV_A)
        {
            for (i=0; i<pTran->Num; i++)
            {
                k = pTran->Target[0].Addr+i-pTalk->OffsetA;
                if ((k>=0)&&(k<pMem->SizeA))
                	pMem->A_Table[k]=pTran->Data.Bytes[i];
            }
        }
        else if (pTran->Target[0].Device==LK_DEV_TT)
        {
            for (i=0; i<pTran->Num; i++)
            {
                k=pTran->Target[0].Addr+i-pTalk->OffsetTimer;
                if ((k>=0)&&(k<pMem->SizeTimer))
                	pMem->TT_Table[k]=pTran->Data.Bytes[i];
            }
        }
        else if (pTran->Target[0].Device==LK_DEV_CT)
        {
            for (i=0; i<pTran->Num; i++)
            {                        
                k=pTran->Target[0].Addr+i-pTalk->OffsetCounter;
                if ((k>=0)&&(k<pMem->SizeCounter))
                	pMem->CT_Table[k]=pTran->Data.Bytes[i];
            }
        }
        else if (pTran->Target[0].Device==LK_DEV_RBIT)
        {
            //此指令不做覆寫動作
        }

        break;

    //--------------------------- byte data
    case LK_CMD_BYTE_1_READ:
    case LK_CMD_BYTE_N_READ:
    case LK_CMD_BYTE_1_WRITE:
    case LK_CMD_BYTE_N_WRITE:
        break;

    //--------------------------- word data
    case LK_CMD_WORD_1_READ:
    case LK_CMD_WORD_N_READ:
    case LK_CMD_WORD_1_WRITE:
    case LK_CMD_WORD_N_WRITE:
        break;

    //--------------------------- INT data
    case LK_CMD_INT_1_READ:
    case LK_CMD_INT_N_READ:
    case LK_CMD_INT_1_WRITE:
    case LK_CMD_INT_N_WRITE:
        if ((QueueFrom==0)&&((pTran->Cmd==LK_CMD_INT_1_WRITE)||(pTran->Cmd==LK_CMD_INT_N_WRITE)))
            break;
        if (pTran->Target[0].Device==LK_DEV_R)
        {
            for (i=0; i<pTran->Num; i++)
            {
                k = pTran->Target[0].Addr+i-pTalk->OffsetR;
                if ((k>=0)&&(k<pMem->SizeR))
                	pMem->R_Table[k] = pTran->Data.Ints[i];
            }
        }
        else if (pTran->Target[0].Device==LK_DEV_TT)
        {
            for (i=0; i<pTran->Num; i++)
            {
                k=pTran->Target[0].Addr+i-pTalk->OffsetTimer;
                if ((k>=0)&&(k<pMem->SizeTimer))
                	pMem->TT_Table[pTran->Target[0].Addr+i] = pTran->Data.Ints[i];
            }
        }
        else if (pTran->Target[0].Device==LK_DEV_CT)
        {
            for (i=0; i<pTran->Num; i++)
            {                    
                k=pTran->Target[0].Addr+i-pTalk->OffsetCounter;
                if ((k>=0)&&(k<pMem->SizeCounter))
                	pMem->CT_Table[k] = pTran->Data.Ints[i];
            }
        }
        else if (pTran->Target[0].Device==LK_DEV_RI)
        {
            for (i=0; i<pTran->Num; i++)
            {
                k=pTran->Target[0].Addr+i-pTalk->OffsetI;
                if ((k>=0)&&(k<pMem->SizeI+3))
                {
                	pMem->I_Table[k+0] = (pTran->Data.Ints[i]>>0) & 0xff;  
                	pMem->I_Table[k+1] = (pTran->Data.Ints[i]>>8) & 0xff;
                	pMem->I_Table[k+2] = (pTran->Data.Ints[i]>>16) & 0xff;
                	pMem->I_Table[k+3] = (pTran->Data.Ints[i]>>24) & 0xff;
                }
            }
        }
        else if (pTran->Target[0].Device==LK_DEV_RO)
        {
            for (i=0; i<pTran->Num; i++)
            {
                k=pTran->Target[0].Addr+i-pTalk->OffsetO;
                if ((k>=0)&&(k<pMem->SizeO+3))
                {
                	pMem->O_Table[k+0] = (pTran->Data.Ints[i]>>0) & 0xff;
                	pMem->O_Table[k+1] = (pTran->Data.Ints[i]>>8) & 0xff;
                	pMem->O_Table[k+2] = (pTran->Data.Ints[i]>>16) & 0xff;
                	pMem->O_Table[k+3] = (pTran->Data.Ints[i]>>24) & 0xff;
                }
            }
        }  
        else if (pTran->Target[0].Device==LK_DEV_RC)
        {
            for (i=0; i<pTran->Num; i++)
            {
                k=pTran->Target[0].Addr+i-pTalk->OffsetC;
                if ((k>=0)&&(k<pMem->SizeC+3))
                {
                	pMem->C_Table[k+0] = (pTran->Data.Ints[i]>>0) & 0xff;
                	pMem->C_Table[k+1] = (pTran->Data.Ints[i]>>8) & 0xff;
                	pMem->C_Table[k+2] = (pTran->Data.Ints[i]>>16) & 0xff;
                	pMem->C_Table[k+3] = (pTran->Data.Ints[i]>>24) & 0xff;
                }
            }
        }  
        else if (pTran->Target[0].Device==LK_DEV_RS)
        {
            for (i=0; i<pTran->Num; i++)
            {
                k=pTran->Target[0].Addr+i-pTalk->OffsetS;
                if ((k>=0)&&(k<pMem->SizeS+3))
                {
                	pMem->S_Table[k+0] = (pTran->Data.Ints[i]>>0) & 0xff;
                	pMem->S_Table[k+1] = (pTran->Data.Ints[i]>>8) & 0xff;
                	pMem->S_Table[k+2] = (pTran->Data.Ints[i]>>16) & 0xff;
                	pMem->S_Table[k+3] = (pTran->Data.Ints[i]>>24) & 0xff;
                }
            }
        }  
        else if (pTran->Target[0].Device==LK_DEV_RA)
        {
            for (i=0; i<pTran->Num; i++)
            {
                k=pTran->Target[0].Addr+i-pTalk->OffsetA;
                if ((k>=0)&&(k<pMem->SizeA+3))
                {
                	pMem->A_Table[k+0] = (pTran->Data.Ints[i]>>0) & 0xff;
                	pMem->A_Table[k+1] = (pTran->Data.Ints[i]>>8) & 0xff;
                	pMem->A_Table[k+2] = (pTran->Data.Ints[i]>>16) & 0xff;
                	pMem->A_Table[k+3] = (pTran->Data.Ints[i]>>24) & 0xff;
                }
            }
        }
        else if (pTran->Target[0].Device==LK_DEV_RTT)
        {
            for (i=0; i<pTran->Num; i++)
            {                    
                k=pTran->Target[0].Addr+i-pTalk->OffsetTimer;
                if ((k>=0)&&(k<pMem->SizeTimer+3))
                {
                	pMem->TT_Table[k+0] = (pTran->Data.Ints[i]>>0) & 0xff;
                	pMem->TT_Table[k+1] = (pTran->Data.Ints[i]>>8) & 0xff;
                	pMem->TT_Table[k+2] = (pTran->Data.Ints[i]>>16) & 0xff;
                	pMem->TT_Table[k+3] = (pTran->Data.Ints[i]>>24) & 0xff;
                }
            }
        }     
        else if (pTran->Target[0].Device==LK_DEV_RCT)
        {
            for (i=0; i<pTran->Num; i++)
            {
                k=pTran->Target[0].Addr+i-pTalk->OffsetCounter;
                if ((k>=0)&&(k<pMem->SizeCounter+3))
                {
                	pMem->CT_Table[k+0] = (pTran->Data.Ints[i]>>0) & 0xff;
                	pMem->CT_Table[k+1] = (pTran->Data.Ints[i]>>8) & 0xff;
                	pMem->CT_Table[k+2] = (pTran->Data.Ints[i]>>16) & 0xff;
                	pMem->CT_Table[k+3] = (pTran->Data.Ints[i]>>24) & 0xff;
                }
            }
        }
        break;

    //--------------------------- fix data
    case LK_CMD_FIX_1_READ:
    case LK_CMD_FIX_N_READ:
    case LK_CMD_FIX_1_WRITE:
    case LK_CMD_FIX_N_WRITE:
        if ((QueueFrom==0)&&((pTran->Cmd==LK_CMD_FIX_1_WRITE)||(pTran->Cmd==LK_CMD_FIX_N_WRITE)))
            break;
        if (pTran->Target[0].Device==LK_DEV_F)
        {
            for (i=0; i<pTran->Num; i++)
            {
                k=pTran->Target[0].Addr+i-pTalk->OffsetF;
                if ((k>=0)&&(k<pMem->SizeF))
                	pMem->F_Table[k] = pTran->Data.Fixs[i];
            }
        }
        break;

    //--------------------------- bit data
    case LK_CMD_BIT_D_READ:
    case LK_CMD_BIT_D_WRITE:
        if ((QueueFrom==0)&&(pTran->Cmd==LK_CMD_BIT_D_WRITE))
            break;
        for (i=0; i<pTran->Num; i++)
        {
            if (pTran->Target[i].Device==LK_DEV_I)
            {
                k = pTran->Target[i].Addr - pTalk->OffsetI;
                if ((k>=0)&&(k<pMem->SizeI))
                    pMem->I_Table[k] = pTran->Data.Bytes[i];
            }
            else if (pTran->Target[i].Device==LK_DEV_O)
            {
                k = pTran->Target[i].Addr - pTalk->OffsetO;
                if ((k>=0)&&(k<pMem->SizeO))
                    pMem->O_Table[k] = pTran->Data.Bytes[i];
            }
            else if (pTran->Target[i].Device==LK_DEV_C)
            {
                k = pTran->Target[i].Addr - pTalk->OffsetC;
                if ((k>=0)&&(k<pMem->SizeC))
                    pMem->C_Table[k] = pTran->Data.Bytes[i];
            }
            else if (pTran->Target[i].Device==LK_DEV_S)
            {
                k = pTran->Target[i].Addr - pTalk->OffsetS;
                if ((k>=0)&&(k<pMem->SizeS))
                    pMem->S_Table[k] = pTran->Data.Bytes[i];
            }
            else if (pTran->Target[i].Device==LK_DEV_A)
            {
                k = pTran->Target[i].Addr - pTalk->OffsetA;
                if ((k>=0)&&(k<pMem->SizeA))
                    pMem->A_Table[k] = pTran->Data.Bytes[i];
            }
            else if (pTran->Target[i].Device==LK_DEV_TT)
            {
                k = pTran->Target[i].Addr - pTalk->OffsetTimer;
                if ((k>=0)&&(k<pMem->SizeTimer))
                	pMem->TT_Table[pTran->Target[i].Addr] = pTran->Data.Bytes[i];
            }
            else if (pTran->Target[i].Device==LK_DEV_CT)
            {
                k = pTran->Target[i].Addr - pTalk->OffsetCounter;
                if ((k>=0)&&(k<pMem->SizeCounter))
                	pMem->CT_Table[pTran->Target[i].Addr] = pTran->Data.Bytes[i];
            }
            else if (pTran->Target[i].Device==LK_DEV_RBIT)
            {
                //不會有此動作
            }
        }
        break;

    //--------------------------- byte data
    case LK_CMD_BYTE_D_READ:
    case LK_CMD_BYTE_D_WRITE:
        break;

    //--------------------------- word data
    case LK_CMD_WORD_D_READ:
    case LK_CMD_WORD_D_WRITE:
        break;

    //--------------------------- int data
    case LK_CMD_INT_D_READ:
    case LK_CMD_INT_D_WRITE:
        if ((QueueFrom==0)&&(pTran->Cmd==LK_CMD_INT_D_WRITE))
            break;
        for (i=0; i<pTran->Num; i++)
        {
            if (pTran->Target[i].Device==LK_DEV_R)
            {
                k = pTran->Target[i].Addr - pTalk->OffsetR;
                if ((k>=0)&&(k<pMem->SizeR))
                    pMem->R_Table[k] = pTran->Data.Ints[i];
            }
            else if (pTran->Target[i].Device==LK_DEV_TS)
            {
                k = pTran->Target[i].Addr - pTalk->OffsetTimer;
                if ((k>=0)&&(k<pMem->SizeTimer))
                	pMem->TS_Table[pTran->Target[i].Addr] = pTran->Data.Ints[i];
            }
            else if (pTran->Target[i].Device==LK_DEV_TV)
            {
                k = pTran->Target[i].Addr - pTalk->OffsetTimer;
                if ((k>=0)&&(k<pMem->SizeTimer))
                	pMem->TV_Table[pTran->Target[i].Addr] = pTran->Data.Ints[i];
            }
            else if (pTran->Target[i].Device==LK_DEV_CS)
            {
                k = pTran->Target[i].Addr - pTalk->OffsetCounter;
                if ((k>=0)&&(k<pMem->SizeCounter))
                	pMem->CS_Table[pTran->Target[i].Addr] = pTran->Data.Ints[i];
            }
            else if (pTran->Target[i].Device==LK_DEV_CV)
            {
                k = pTran->Target[i].Addr - pTalk->OffsetCounter;
                if ((k>=0)&&(k<pMem->SizeCounter))
                	pMem->CV_Table[pTran->Target[i].Addr] = pTran->Data.Ints[i];
            }
            else if (pTran->Target[i].Device==LK_DEV_RI)
            {
                k = pTran->Target[i].Addr - pTalk->OffsetI;
                if ((k>=0)&&(k<pMem->SizeI+3))
                {
                	pMem->I_Table[k+0] = (pTran->Data.Ints[i]>>0) & 0xff;
                	pMem->I_Table[k+1] = (pTran->Data.Ints[i]>>8) & 0xff;
                	pMem->I_Table[k+2] = (pTran->Data.Ints[i]>>16) & 0xff;
                	pMem->I_Table[k+3] = (pTran->Data.Ints[i]>>24) & 0xff;
                }
            }
            else if (pTran->Target[i].Device==LK_DEV_RO)
            {
                k = pTran->Target[i].Addr - pTalk->OffsetO;
                if ((k>=0)&&(k<pMem->SizeO+3))
                {
                	pMem->O_Table[k+0] = (pTran->Data.Ints[i]>>0) & 0xff;
                	pMem->O_Table[k+1] = (pTran->Data.Ints[i]>>8) & 0xff;
                	pMem->O_Table[k+2] = (pTran->Data.Ints[i]>>16) & 0xff;
                	pMem->O_Table[k+3] = (pTran->Data.Ints[i]>>24) & 0xff;
                }
            }
            else if (pTran->Target[i].Device==LK_DEV_RC)
            {
                k = pTran->Target[i].Addr - pTalk->OffsetC;
                if ((k>=0)&&(k<pMem->SizeC+3))
                {
                	pMem->C_Table[k+0] = (pTran->Data.Ints[i]>>0) & 0xff;
                	pMem->C_Table[k+1] = (pTran->Data.Ints[i]>>8) & 0xff;
                	pMem->C_Table[k+2] = (pTran->Data.Ints[i]>>16) & 0xff;
                	pMem->C_Table[k+3] = (pTran->Data.Ints[i]>>24) & 0xff;
                }
            }
            else if (pTran->Target[i].Device==LK_DEV_RS)
            {
                k = pTran->Target[i].Addr - pTalk->OffsetS;
                if ((k>=0)&&(k<pMem->SizeS+3))
                {
                	pMem->S_Table[k+0] = (pTran->Data.Ints[i]>>0) & 0xff;
                	pMem->S_Table[k+1] = (pTran->Data.Ints[i]>>8) & 0xff;
                	pMem->S_Table[k+2] = (pTran->Data.Ints[i]>>16) & 0xff;
                	pMem->S_Table[k+3] = (pTran->Data.Ints[i]>>24) & 0xff;
                }
            }
            else if (pTran->Target[i].Device==LK_DEV_RA)
            {
                k = pTran->Target[i].Addr - pTalk->OffsetA;
                if ((k>=0)&&(k<pMem->SizeA+3))
                {
                	pMem->A_Table[k+0] = (pTran->Data.Ints[i]>>0) & 0xff;
                	pMem->A_Table[k+1] = (pTran->Data.Ints[i]>>8) & 0xff;
                	pMem->A_Table[k+2] = (pTran->Data.Ints[i]>>16) & 0xff;
                	pMem->A_Table[k+3] = (pTran->Data.Ints[i]>>24) & 0xff;
                }
            }
            else if (pTran->Target[i].Device==LK_DEV_RTT)
            {
                k = pTran->Target[i].Addr - pTalk->OffsetTimer;
                if ((k>=0)&&(k<pMem->SizeTimer+3))
                {
                	pMem->TT_Table[k+0] = (pTran->Data.Ints[i]>>0) & 0xff;
                	pMem->TT_Table[k+1] = (pTran->Data.Ints[i]>>8) & 0xff;
                	pMem->TT_Table[k+2] = (pTran->Data.Ints[i]>>16) & 0xff;
                	pMem->TT_Table[k+3] = (pTran->Data.Ints[i]>>24) & 0xff;
                }
            }
            else if (pTran->Target[i].Device==LK_DEV_RCT)
            {
                k = pTran->Target[i].Addr - pTalk->OffsetCounter;
                if ((k>=0)&&(k<pMem->SizeCounter+3))
                {
                	pMem->CT_Table[k+0] = (pTran->Data.Ints[i]>>0) & 0xff;
                	pMem->CT_Table[k+1] = (pTran->Data.Ints[i]>>8) & 0xff;
                	pMem->CT_Table[k+2] = (pTran->Data.Ints[i]>>16) & 0xff;
                	pMem->CT_Table[k+3] = (pTran->Data.Ints[i]>>24) & 0xff;
                }
            }
        }
        break;

    //--------------------------- fix data
    case LK_CMD_FIX_D_READ:
    case LK_CMD_FIX_D_WRITE:
        if ((QueueFrom==0)&&(pTran->Cmd==LK_CMD_FIX_D_WRITE))
            break;
        for (i=0; i<pTran->Num; i++)
        {
            if (pTran->Target[i].Device==LK_DEV_F)
            {
                k = pTran->Target[i].Addr - pTalk->OffsetF;
                if ((k>=0)&&(k<pMem->SizeF))
                	pMem->F_Table[k] = pTran->Data.Fixs[i];
            }
        }
        break;
    }
    //---------end switch
    return 1;
}

