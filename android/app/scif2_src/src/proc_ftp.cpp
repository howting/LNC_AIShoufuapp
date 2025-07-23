//#include "stdafx.h"
#include "proc_ftp.h"
        
char InitFtp(FTP_INFO *pFtp)
{
	pFtp->StepIndex = 255;
    pFtp->Timeout = 500000;
    pFtp->MaxRetry = 15;
    return 1;
}

void SetUploadFile(FTP_INFO *pFtp)
{
	pFtp->Result = FTP_RESULT_PROCESSING;
    pFtp->State = FTP_STATE_UPLOAD;
    pFtp->Step[0] = FTP_STEP_REQ_UPLOAD;
    pFtp->Step[1] = FTP_STEP_REQ_UPLOAD_CHECK;
    pFtp->Step[2] = FTP_STEP_UPLOAD_MEM;
    pFtp->Step[3] = FTP_STEP_UPLOAD_MEM_CHECK;
    pFtp->Step[4] = FTP_STEP_TELL_UPLOAD_DONE;
    pFtp->Step[5] = FTP_STEP_TELL_UPLOAD_DONE_CHECK;
    pFtp->Step[6] = FTP_STEP_DONE;
    pFtp->FtpDone = 0;
    pFtp->StepIndex = 0;
}
       
void SetDownloadFile(FTP_INFO *pFtp)
{
	pFtp->Result = FTP_RESULT_PROCESSING;
    pFtp->State = FTP_STATE_DOWNLOAD;
    pFtp->Step[0] = FTP_STEP_REQ_DOWNLOAD;
    pFtp->Step[1] = FTP_STEP_REQ_DOWNLOAD_CHECK;
    pFtp->Step[2] = FTP_STEP_DOWNLOAD_MEM;
    pFtp->Step[3] = FTP_STEP_DOWNLOAD_MEM_CHECK;
    pFtp->Step[4] = FTP_STEP_TELL_DOWNLOAD_DONE;
    pFtp->Step[5] = FTP_STEP_TELL_DOWNLOAD_DONE_CHECK;
    pFtp->Step[6] = FTP_STEP_DONE;
    pFtp->FtpDone = 0;
    pFtp->StepIndex = 0;
}

void SetDeleteFile(FTP_INFO *pFtp)
{
	pFtp->Result = FTP_RESULT_PROCESSING;
    pFtp->State = FTP_STATE_DELETE;
    pFtp->Step[0] = FTP_STEP_REQ_DELETE;
    pFtp->Step[1] = FTP_STEP_REQ_DELETE_CHECK;
    pFtp->Step[2] = FTP_STEP_DONE;
    pFtp->FtpDone = 0;
    pFtp->StepIndex = 0;
}

void SetUploadFiles(FTP_INFO *pFtp)
{
	pFtp->Result = FTP_RESULT_PROCESSING;
    pFtp->State = FTP_STATE_UPLOAD_MANY;
    pFtp->Step[0] = FTP_STEP_SET_MANY;
    pFtp->Step[1] = FTP_STEP_REQ_UPLOAD;
    pFtp->Step[2] = FTP_STEP_REQ_UPLOAD_CHECK;
    pFtp->Step[3] = FTP_STEP_UPLOAD_MEM;
    pFtp->Step[4] = FTP_STEP_UPLOAD_MEM_CHECK;
    pFtp->Step[5] = FTP_STEP_TELL_UPLOAD_DONE;
    pFtp->Step[6] = FTP_STEP_TELL_UPLOAD_DONE_CHECK;
    pFtp->Step[7] = FTP_STEP_CHECK_MANY;
    pFtp->Step[8] = FTP_STEP_DONE;
    pFtp->FtpDone = 0;
    pFtp->StepIndex = 0;
}

void SetDownloadFiles(FTP_INFO *pFtp)
{
	pFtp->Result = FTP_RESULT_PROCESSING;
    pFtp->State = FTP_STATE_DOWNLOAD_MANY;
    pFtp->Step[0] = FTP_STEP_SET_MANY;
    pFtp->Step[1] = FTP_STEP_REQ_DOWNLOAD;
    pFtp->Step[2] = FTP_STEP_REQ_DOWNLOAD_CHECK;
    pFtp->Step[3] = FTP_STEP_DOWNLOAD_MEM;
    pFtp->Step[4] = FTP_STEP_DOWNLOAD_MEM_CHECK;
    pFtp->Step[5] = FTP_STEP_TELL_DOWNLOAD_DONE;
    pFtp->Step[6] = FTP_STEP_TELL_DOWNLOAD_DONE_CHECK;
    pFtp->Step[7] = FTP_STEP_CHECK_MANY;
    pFtp->Step[8] = FTP_STEP_DONE;
    pFtp->FtpDone = 0;
    pFtp->StepIndex = 0;
}

void SetDeleteFiles(FTP_INFO *pFtp)
{
	pFtp->Result = FTP_RESULT_PROCESSING;
    pFtp->State = FTP_STATE_DELETE_MANY;
    pFtp->Step[0] = FTP_STEP_SET_MANY;
    pFtp->Step[1] = FTP_STEP_REQ_DELETE;
    pFtp->Step[2] = FTP_STEP_REQ_DELETE_CHECK;
    pFtp->Step[3] = FTP_STEP_CHECK_MANY;
    pFtp->Step[4] = FTP_STEP_DONE;
    pFtp->FtpDone = 0;
    pFtp->StepIndex = 0;
}
    
void SetMakeDir(FTP_INFO *pFtp)
{
	pFtp->Result = FTP_RESULT_PROCESSING;
    pFtp->State = FTP_STATE_MAKE_DIR;
    pFtp->Step[0] = FTP_STEP_REQ_MAKE_DIR;
    pFtp->Step[1] = FTP_STEP_REQ_MAKE_DIR_CHECK;
    pFtp->Step[2] = FTP_STEP_DONE;
    pFtp->FtpDone = 0;
    pFtp->StepIndex = 0;
}

void SetListFile(FTP_INFO *pFtp)
{
	pFtp->Result = FTP_RESULT_PROCESSING;
    pFtp->State = FTP_STATE_LIST;
    pFtp->Step[0] = FTP_STEP_REQ_LIST;
    pFtp->Step[1] = FTP_STEP_REQ_LIST_CHECK;
    pFtp->Step[2] = FTP_STEP_GET_FILE_LIST;
    pFtp->Step[3] = FTP_STEP_GET_FILE_LIST_CHECK;
    pFtp->Step[4] = FTP_STEP_DONE;
    pFtp->FtpDone = 0;
    pFtp->StepIndex = 0;
}




char AddPacketID(FTP_INFO *pFtp)
{
	pFtp->TxBuf[2] = pFtp->PacketID & 0xff;  
	pFtp->TxBuf[3] = (pFtp->PacketID>>8) & 0xff;
    pFtp->PacketID++;
    return 1;
}

char FtpSendOut(FTP_INFO *pFtp)
{
    //--------設定要將資料寫出
    TALK_INFO* pTalk = &pSes->pTalkInfo[pSes->FtpTalkIdx];
    WriteOutMessage(pTalk, (char *)pFtp->TxBuf, pFtp->TxLen);
    //--------設定在等待中
    pFtp->TryTimes++;
    pFtp->TimeSend = 0;
    return 1;
}


char ReceiveFtp(FTP_INFO *pFtp, unsigned short RxLen, unsigned char *RxBuf)
{
    if (pFtp->TryTimes==0) return 0;

    if ( (RxBuf[0]!=pFtp->TxBuf[0])
       ||(RxBuf[1]!=pFtp->TxBuf[1])
       ||(RxBuf[2]!=pFtp->TxBuf[2])
       ||(RxBuf[3]!=pFtp->TxBuf[3]) )
       return 0;
                    
    unsigned short *pIdx, *pNum; //, *pCRC;
    //unsigned int *pLong;
    pFtp->TryTimes = 0;
    if (RxBuf[5]==0)
    {
    	pFtp->CmdResult = 2;
        return 1;
    }
    else
    {
    	pFtp->CmdResult = 1;
    }
    switch (RxBuf[1])
    {
	case FTP_CMD_ENUM_FOLDER:
        pNum = (unsigned short *)(RxBuf+8);
        pFtp->FileCount = *pNum;
    	break;
	case FTP_CMD_GET_FILE_LIST:
        pIdx = (unsigned short *)(RxBuf+6);
        pNum = (unsigned short *)(RxBuf+8);
    	pFtp->FileIndex = *pIdx + *pNum;
        memcpy(&pFtp->FileLists[*pIdx], RxBuf+10, *pNum*sizeof(FTP_FILE));
    	break;
        
	case FTP_CMD_SET_DOWNLOAD_FILE:
        BufToLong(&pFtp->FileSize, (RxBuf+10));  
        BufToShort(&pFtp->FileCRC, (RxBuf+14));
        //pLong = (unsigned int *)(RxBuf+10);
        //pFtp->FileSize = *pLong;
        //pCRC = (unsigned short *)(RxBuf+14);
        //pFtp->FileCRC = *pCRC;
    	break;
	case FTP_CMD_DOWNLOAD_FILE_DONE:
    	break;
	case FTP_CMD_SET_UPLOAD_FILE:
    	break;
	case FTP_CMD_UPLOAD_FILE_DONE:
    	break;
	case FTP_CMD_DOWNLOAD_FILE_MEM:
        pIdx = (unsigned short *)(RxBuf+6);
        pNum = (unsigned short *)(RxBuf+8);
        memcpy(pFtp->pFileMem+(*pIdx<<FTP_PAGE_SHIFT), RxBuf+10, *pNum);
    	break;
	case FTP_CMD_UPLOAD_FILE_MEM:
    	break;
    case FTP_CMD_SET_DELETE_FILE:
    	break;
    }
    return 1;
}



//比較字串
bool strCompare(char *s1, char *s2)
{
    while(*s1 && *s2)
    {
        if(*s1<*s2) return true;
        if(*s1>*s2) return false;
        ++s1, ++s2;
    }
    if(*s1 <= *s2) return true;
    return false;
}




//----------------------------------------------------------------
char RegularCallFtp(FTP_INFO *pFtp, unsigned int Interval)
{             
	FILE *f;
    struct stat buf;
    int i, j, k, n;
    //============檢查是否需重送一般控制封包=========
    if (pFtp->TryTimes)
    {
    	pFtp->TimeSend += Interval;
        //if (pFtp->TimeSend >= pSes->pTalkInfo[pSes->FtpTalkIdx].Timeout)
        if (pFtp->TimeSend >= pFtp->Timeout)
        {
            //if (pFtp->TryTimes > pSes->pTalkInfo[pSes->FtpTalkIdx].MaxRetry)
            if (pFtp->TryTimes > pFtp->MaxRetry)
            {
                pFtp->CmdResult = 3;
                pFtp->TryTimes = 0;
            }
            else
            {
        		FtpSendOut(pFtp);
            }
        }
    }
    //==========================================================================
                                       
    FtpIndex = pFtp->StepIndex;
    if (pFtp->StepIndex==255) return 0;
                  
    //========Req格式=====
    // RxBuf[2]: packet id
    // RxBuf[3]: packet id
    // RxBuf[4]: 資料夾代碼
    // RxBuf[5]: 動作回應成功或失敗
    // RxBuf[6]: 索引 L
    // RxBuf[7]: 索引 H
    // RxBuf[8]: 數目 L
    // RxBuf[9]: 數目 H
    //====================
    //========Rsp格式=====
    // TxBuf[2]: packet id
    // TxBuf[3]: packet id
    // TxBuf[4]: 資料夾代碼
    // TxBuf[5]: 動作回應成功或失敗
    // TxBuf[6]: 索引 L
    // TxBuf[7]: 索引 H
    // TxBuf[8]: 數目 L
    // TxBuf[9]: 數目 H
    //====================
    //-----依目前步驟執行      
    unsigned short tSize;
    switch (pFtp->Step[pFtp->StepIndex])
    {

    //=======================要求列舉資料夾檔案
    case FTP_STEP_REQ_LIST: 
    	pFtp->TxBuf[0] = START_CHAR_FTP;
        pFtp->TxBuf[1] = FTP_CMD_ENUM_FOLDER;
        pFtp->TxBuf[4] = pFtp->Folder; 
        memcpy(pFtp->TxBuf+10, pFtp->HeadFilter, 10);
        memcpy(pFtp->TxBuf+20, pFtp->TailFilter, 10);
        pFtp->TxLen = 30;
        if (pFtp->SubFolder[0]!=0)
        {
            memcpy(pFtp->TxBuf+pFtp->TxLen, pFtp->SubFolder, 32);
            pFtp->TxLen += 32;
        }
        
        pFtp->TryTimes = 0;
        pFtp->CmdResult = 0;
        AddPacketID(pFtp);
        FtpSendOut(pFtp);

        pFtp->StepIndex++;
        break;
    case FTP_STEP_REQ_LIST_CHECK:
        if (pFtp->CmdResult==1)
        {
            if (pFtp->FileCount==0)
            {
                pFtp->StepIndex+=3;
            }
            else
            {
                pFtp->FileIndex = 0;
                pFtp->StepIndex++;
            }
        }
        else if (pFtp->CmdResult==2)
        {
            pFtp->Result = FTP_RESULT_FAIL_TO_SET_COMMAND;
        	pFtp->StepIndex=255;
        }
        else if (pFtp->CmdResult==3)
        {                       
            pFtp->Result = FTP_RESULT_FAIL_TO_COMMUNICATION;
        	pFtp->StepIndex=255;
        }
    	break;
                  
    //=======================取得列舉的檔案
    case FTP_STEP_GET_FILE_LIST:
    	pFtp->TxBuf[0] = START_CHAR_FTP;
        pFtp->TxBuf[1] = FTP_CMD_GET_FILE_LIST;
        pFtp->TxBuf[4] = pFtp->Folder;
        pFtp->TxBuf[6] = pFtp->FileIndex & 0xff;
        pFtp->TxBuf[7] = (pFtp->FileIndex>>8) & 0xff;      
        pFtp->TxBuf[8] = 30;
        pFtp->TxBuf[9] = 0;
        pFtp->TxLen = 10;

        pFtp->TryTimes = 0;
        pFtp->CmdResult = 0;
        AddPacketID(pFtp);
        FtpSendOut(pFtp);

        pFtp->StepIndex++;
    	break;

    case FTP_STEP_GET_FILE_LIST_CHECK: 
        if (pFtp->CmdResult==1)
        {
            if (pFtp->FileIndex>=pFtp->FileCount)
            {
                //對檔案清單進行排序
                FTP_FILE tmpLists[MAX_FILE_LIST_NUM];
                memcpy(tmpLists, pFtp->FileLists, pFtp->FileCount*sizeof(FTP_FILE));
                n = 0;
                for (i=0; i<pFtp->FileCount; i++)
                {
                    k=i;
                    for (j=i+1; j<pFtp->FileCount; j++)
                    {
                        if (strCompare(tmpLists[j].filename, tmpLists[k].filename)) k=j;
                    }
                    memcpy(&pFtp->FileLists[n++], &tmpLists[k], sizeof(FTP_FILE));
                    if (k!=i)
                        memcpy(&tmpLists[k], &tmpLists[i], sizeof(FTP_FILE));
                }
                //跳到下一步驟
                pFtp->StepIndex++;
            }
            else
                pFtp->StepIndex--;
        }
        else if (pFtp->CmdResult==2)
        {
            pFtp->Result = FTP_RESULT_FAIL_TO_SET_COMMAND;
        	pFtp->StepIndex=255;
        }
        else if (pFtp->CmdResult==3)
        {                       
            pFtp->Result = FTP_RESULT_FAIL_TO_COMMUNICATION;
        	pFtp->StepIndex=255;
        }
    	break;
    //=========================================================

    //=========================傳送多個檔案的設定
    case FTP_STEP_SET_MANY:
        if (pFtp->TransferIndex < pFtp->TransferCount)
        {
        	pFtp->Folder = pFtp->TransferFiles[pFtp->TransferIndex].Folder;
            strcpy(pFtp->SubFolder, pFtp->TransferFiles[pFtp->TransferIndex].SubFolder); 
            strcpy(pFtp->FileName, pFtp->TransferFiles[pFtp->TransferIndex].Filename);
            strcpy(pFtp->LocalName, pFtp->TransferFiles[pFtp->TransferIndex].LocalFilename);
            pFtp->StepIndex++;
        }
        else
        {
            pFtp->Result = FTP_RESULT_SUCCESS;
            pFtp->StepIndex = 255;
        }
    	break;
    case FTP_STEP_CHECK_MANY:
        pFtp->TransferIndex++;
        if (pFtp->TransferIndex>=pFtp->TransferCount) pFtp->StepIndex++;
        else                                          pFtp->StepIndex=0;
    	break;
    //=========================================================

    //=========================刪除檔案==================
    case FTP_STEP_REQ_DELETE:
        //========Req格式=====
        // TxBuf[10~13]: 檔案大小
        // RxBuf[14~]:   完整檔案名稱
        //====================
        //========Rsp格式=====
        // TxBuf[10~13]: 檔案大小
        //====================
    	pFtp->TxBuf[0] = START_CHAR_FTP;
        pFtp->TxBuf[1] = FTP_CMD_SET_DELETE_FILE;
        pFtp->TxBuf[4] = pFtp->Folder;
        memcpy((char *)(pFtp->TxBuf+14), pFtp->FileName, 32);
        pFtp->TxLen = 14+FILENAME_LENGTH;
        if (pFtp->SubFolder[0]!=0)
        {
            memcpy(pFtp->TxBuf+pFtp->TxLen, pFtp->SubFolder, 32);
            pFtp->TxLen += 32;
        }

        pFtp->TryTimes = 0;
        pFtp->CmdResult = 0;
        AddPacketID(pFtp);
        FtpSendOut(pFtp);

        pFtp->StepIndex++;
    	break;

    case FTP_STEP_REQ_DELETE_CHECK:
        if (pFtp->CmdResult==1)
        {
        	pFtp->StepIndex++;
        }
        else if (pFtp->CmdResult==2)
        {
            pFtp->Result = FTP_RESULT_FAIL_TO_SET_COMMAND;
        	pFtp->StepIndex=255;
        }
        else if (pFtp->CmdResult==3)
        {
            pFtp->Result = FTP_RESULT_FAIL_TO_COMMUNICATION;
        	pFtp->StepIndex=255;
        }
        break;
    //=========================================================


           
    //=========================刪除檔案==================
    case FTP_STEP_REQ_MAKE_DIR:
        //========Req格式=====
        // TxBuf[10~13]: 檔案大小
        // RxBuf[14~]:   完整檔案名稱
        //====================
        //========Rsp格式=====
        // TxBuf[10~13]: 檔案大小
        //====================
    	pFtp->TxBuf[0] = START_CHAR_FTP;
        pFtp->TxBuf[1] = FTP_CMD_SET_MAKE_DIR;
        pFtp->TxBuf[4] = pFtp->Folder;
        strcpy((char *)(pFtp->TxBuf+14), pFtp->FileName);
        pFtp->TxLen = 14+FILENAME_LENGTH;

        pFtp->TryTimes = 0;
        pFtp->CmdResult = 0;
        AddPacketID(pFtp);
        FtpSendOut(pFtp);

        pFtp->StepIndex++;
    	break;

    case FTP_STEP_REQ_MAKE_DIR_CHECK:
        if (pFtp->CmdResult==1)
        {
        	pFtp->StepIndex++;
        }
        else if (pFtp->CmdResult==2)
        {
            pFtp->Result = FTP_RESULT_FAIL_TO_SET_COMMAND;
        	pFtp->StepIndex=255;
        }
        else if (pFtp->CmdResult==3)
        {
            pFtp->Result = FTP_RESULT_FAIL_TO_COMMUNICATION;
        	pFtp->StepIndex=255;
        }
        break;



    //=========================要求上傳檔案，Remote先建立記憶體
    case FTP_STEP_REQ_UPLOAD:
        if (stat(pFtp->LocalName, &buf)<0)
        {
        	pFtp->Result =  FTP_RESULT_FAIL_TO_READ_LOCAL_FILE;
            pFtp->StepIndex = 255;
        	break;
        }
        //{
            f=fopen(pFtp->LocalName, "rb");
            if (f==NULL)
            {
            	pFtp->Result =  FTP_RESULT_FAIL_TO_READ_LOCAL_FILE;
                pFtp->StepIndex = 255;
            	fclose(f);
                break;
            }
            
            if (stat(pFtp->LocalName, &buf)>=0)
            {
                pFtp->FileSize = buf.st_size;
                pFtp->pFileMem = (unsigned char*) malloc(pFtp->FileSize); //new unsigned char[buf.st_size];
                fread(pFtp->pFileMem, 1, buf.st_size, f);
            }
            fclose(f);
        //}
        //========Req格式=====
        // TxBuf[10~13]: 檔案大小
        // RxBuf[14~]:   完整檔案名稱
        //====================
        //========Rsp格式=====
        // TxBuf[10~13]: 檔案大小
        //====================
    	pFtp->TxBuf[0] = START_CHAR_FTP;
        pFtp->TxBuf[1] = FTP_CMD_SET_UPLOAD_FILE;
        pFtp->TxBuf[4] = pFtp->Folder;
        unsigned int *pLong;
        pLong = (unsigned int *)(pFtp->TxBuf+10);
        *pLong = pFtp->FileSize;
        memcpy((char *)(pFtp->TxBuf+14), pFtp->FileName, 32);
        pFtp->TxLen = 14+FILENAME_LENGTH;
        if (pFtp->SubFolder[0]!=0)
        {
            memcpy(pFtp->TxBuf+pFtp->TxLen, pFtp->SubFolder, 32);
            pFtp->TxLen += 32;
        }

        pFtp->TryTimes = 0;
        pFtp->CmdResult = 0;
        AddPacketID(pFtp);
        FtpSendOut(pFtp);

        pFtp->StepIndex++;
    	break;
    //-----------------檢查命令
    case FTP_STEP_REQ_UPLOAD_CHECK:
        if (pFtp->CmdResult==1)
        {
            pFtp->CurrentIdx = 0;
            pFtp->TotalIdx = ((pFtp->FileSize-1)>>FTP_PAGE_SHIFT)+1;
        	pFtp->StepIndex++;
        }
        else if (pFtp->CmdResult==2)
        {
            pFtp->Result = FTP_RESULT_FAIL_TO_SET_COMMAND;
            free(pFtp->pFileMem);
        	pFtp->StepIndex=255;
        }
        else if (pFtp->CmdResult==3)
        {                       
            pFtp->Result = FTP_RESULT_FAIL_TO_COMMUNICATION;
            free(pFtp->pFileMem);
        	pFtp->StepIndex=255;
        }
    	break;
    //=========================
                             
    //===========================上傳檔案內容    
    case FTP_STEP_UPLOAD_MEM:
        if (pFtp->CurrentIdx>=pFtp->TotalIdx)
        	pFtp->StepIndex+=2;
        else
        {
            if (pFtp->CurrentIdx == (pFtp->TotalIdx-1))
            {
                tSize = pFtp->FileSize & FTP_PAGE_MASK;
                if (tSize==0) tSize=1<<FTP_PAGE_SHIFT;
            }
            else
            {
                tSize = 1<<FTP_PAGE_SHIFT;
            }
            pFtp->TxBuf[0] = START_CHAR_FTP;
            pFtp->TxBuf[1] = FTP_CMD_UPLOAD_FILE_MEM;
            pFtp->TxBuf[6] = pFtp->CurrentIdx & 0xff;
            pFtp->TxBuf[7] = (pFtp->CurrentIdx>>8) & 0xff;
            pFtp->TxBuf[8] = tSize & 0xff;
            pFtp->TxBuf[9] = (tSize>>8) & 0xff;
            memcpy(pFtp->TxBuf+10, pFtp->pFileMem+(pFtp->CurrentIdx<<FTP_PAGE_SHIFT), tSize);
            pFtp->TxLen = 10+tSize;

            pFtp->TryTimes = 0;
            pFtp->CmdResult = 0;
            AddPacketID(pFtp);
            FtpSendOut(pFtp);

            pFtp->StepIndex++;
        }
        break;

    case FTP_STEP_UPLOAD_MEM_CHECK:
        if (pFtp->CmdResult==1)
        {                
            pFtp->CurrentIdx++;
        	pFtp->StepIndex--;
        }
        else if (pFtp->CmdResult==2)
        {
            pFtp->Result = FTP_RESULT_FAIL_TO_SET_COMMAND;
            free(pFtp->pFileMem);
        	pFtp->StepIndex=255;
        }
        else if (pFtp->CmdResult==3)
        {                       
            pFtp->Result = FTP_RESULT_FAIL_TO_COMMUNICATION;
            free(pFtp->pFileMem);
        	pFtp->StepIndex=255;
        }
    	break;

    //===========================通知上傳檔案完成
    case FTP_STEP_TELL_UPLOAD_DONE:
        //========Req格式=====
        //====================
        //========Rsp格式=====
        //====================
    	pFtp->TxBuf[0] = START_CHAR_FTP;
        pFtp->TxBuf[1] = FTP_CMD_UPLOAD_FILE_DONE;
        unsigned short *pCRC;
        pCRC = (unsigned short *)(pFtp->TxBuf+10);
        *pCRC = CRC_16(pFtp->pFileMem, pFtp->FileSize);
        pFtp->TxLen = 12;
        
        pFtp->TryTimes = 0;
        pFtp->CmdResult = 0; 
        AddPacketID(pFtp);
        FtpSendOut(pFtp);

        pFtp->StepIndex++;
    	break;
    //-----------------檢查命令
    case FTP_STEP_TELL_UPLOAD_DONE_CHECK:
        if (pFtp->CmdResult==1)
        //if ((pFtp->CmdResult==1)||(pFtp->CmdResult==3))
        {
            free(pFtp->pFileMem);
        	pFtp->StepIndex++;
        }
        else if (pFtp->CmdResult==2)
        {
            pFtp->Result = FTP_RESULT_FAIL_TO_WRITE_REMOTE_FILE;
            free(pFtp->pFileMem);
        	pFtp->StepIndex=255;
        }
        else if (pFtp->CmdResult==3)
        {
            pFtp->Result = FTP_RESULT_FAIL_TO_COMMUNICATION;
            free(pFtp->pFileMem);
        	pFtp->StepIndex=255;
        }
    	break;

    //===========================要求下載檔案
    case FTP_STEP_REQ_DOWNLOAD:
    	pFtp->TxBuf[0] = START_CHAR_FTP;
        pFtp->TxBuf[1] = FTP_CMD_SET_DOWNLOAD_FILE;
        pFtp->TxBuf[4] = pFtp->Folder;
        memcpy((char *)(pFtp->TxBuf+14), pFtp->FileName, 32);
        pFtp->TxLen = 14+FILENAME_LENGTH;
        if (pFtp->SubFolder[0]!=0)
        {
            memcpy(pFtp->TxBuf+pFtp->TxLen, pFtp->SubFolder, 32);
            pFtp->TxLen += 32;
        }

        pFtp->TryTimes = 0;
        pFtp->CmdResult = 0;
        AddPacketID(pFtp);
        FtpSendOut(pFtp);

        pFtp->StepIndex++;
    	break;
    //-----------------檢查命令
    case FTP_STEP_REQ_DOWNLOAD_CHECK:
        if (pFtp->CmdResult==1)
        {                 
            pFtp->CurrentIdx = 0;
            pFtp->TotalIdx = ((pFtp->FileSize-1)>>FTP_PAGE_SHIFT)+1;
            pFtp->pFileMem = (unsigned char*) malloc(pFtp->FileSize);
        	pFtp->StepIndex++;
        }
        else if (pFtp->CmdResult==2)
        {
            pFtp->Result = FTP_RESULT_FAIL_TO_READ_REMOTE_FILE;
        	pFtp->StepIndex=255;
        }
        else if (pFtp->CmdResult==3)
        {
            pFtp->Result = FTP_RESULT_FAIL_TO_COMMUNICATION;
        	pFtp->StepIndex=255;
        }
    	break;

    //===========================下載檔案內容
    case FTP_STEP_DOWNLOAD_MEM:
        if (pFtp->CurrentIdx>=pFtp->TotalIdx)
        	pFtp->StepIndex+=2;
        else
        {
            if (pFtp->CurrentIdx == (pFtp->TotalIdx-1))
                tSize = pFtp->FileSize & FTP_PAGE_MASK;
            else
                tSize = 1<<FTP_PAGE_SHIFT;
            pFtp->TxBuf[0] = START_CHAR_FTP;
            pFtp->TxBuf[1] = FTP_CMD_DOWNLOAD_FILE_MEM;
            pFtp->TxBuf[6] = pFtp->CurrentIdx & 0xff;
            pFtp->TxBuf[7] = (pFtp->CurrentIdx>>8) & 0xff;
            pFtp->TxBuf[8] = tSize & 0xff;
            pFtp->TxBuf[9] = (tSize>>8) & 0xff;
            pFtp->TxLen = 10;

            pFtp->TryTimes = 0;
            pFtp->CmdResult = 0;
            AddPacketID(pFtp);
            FtpSendOut(pFtp);

            pFtp->StepIndex++;
        }
        break;

    case FTP_STEP_DOWNLOAD_MEM_CHECK:
        if (pFtp->CmdResult==1)
        {                
            pFtp->CurrentIdx++;
        	pFtp->StepIndex--;
        }
        else if (pFtp->CmdResult==2)
        {
            pFtp->Result = FTP_RESULT_FAIL_TO_SET_COMMAND;
            free(pFtp->pFileMem);
        	pFtp->StepIndex=255;
        }
        else if (pFtp->CmdResult==3)
        {                       
            pFtp->Result = FTP_RESULT_FAIL_TO_COMMUNICATION;
            free(pFtp->pFileMem);
        	pFtp->StepIndex=255;
        }
    	break;
    //===========================通知下載檔案完成
    case FTP_STEP_TELL_DOWNLOAD_DONE:
        //========Req格式=====
        //====================
        //========Rsp格式=====
        //====================
    	pFtp->TxBuf[0] = START_CHAR_FTP;
        pFtp->TxBuf[1] = FTP_CMD_DOWNLOAD_FILE_DONE;
        pFtp->TxLen = 10;
        
        pFtp->TryTimes = 0;
        pFtp->CmdResult = 0;
        AddPacketID(pFtp);
        FtpSendOut(pFtp);

        pFtp->StepIndex++;
    	break;        
    //-----------------檢查命令
    case FTP_STEP_TELL_DOWNLOAD_DONE_CHECK:
        if (pFtp->CmdResult==1)
        {        
            //檢查 CRC 是否相同
            short CRC;
            CRC = CRC_16(pFtp->pFileMem, pFtp->FileSize);
    		if (CRC == pFtp->FileCRC)
            {
                f=fopen(pFtp->LocalName, "wb");
                if (f==NULL)
                {
                    pFtp->Result =  FTP_RESULT_FAIL_TO_WRITE_LOCAL_FILE;
                    free(pFtp->pFileMem);
                    pFtp->StepIndex = 255;
                    fclose(f);
                    break;
                }
                fwrite(pFtp->pFileMem, 1, pFtp->FileSize, f);
                fclose(f);
        		pFtp->StepIndex++;
            }
            else
            {                  
            	pFtp->Result = FTP_RESULT_FILE_MISMATCH;
        		pFtp->StepIndex=255;
            }
            free(pFtp->pFileMem);
        }
        else if (pFtp->CmdResult==2)
        {
            pFtp->Result = FTP_RESULT_FAIL_TO_SET_COMMAND;
            free(pFtp->pFileMem);
        	pFtp->StepIndex=255;
        }
        else if (pFtp->CmdResult==3)
        {
            pFtp->Result = FTP_RESULT_FAIL_TO_COMMUNICATION;
            free(pFtp->pFileMem);
        	pFtp->StepIndex=255;
        }
    	break;

               
    case FTP_STEP_DONE:
    	pFtp->Result = FTP_RESULT_SUCCESS;
        pFtp->StepIndex = 255;
    	break;
    }
    //if (pFtp->StepIndex==255) pFtp->State = FTP_STATE_IDLE;
    if (pFtp->StepIndex==255) pFtp->FtpDone = 1;
    return 1;
}
