//#include "stdafx.h"
#include "proc_connect_build.h"
                                      


/*
char GetMac(TALK_INFO *pTalk)
{
    pTalk->Step[0] = CONNECT_STEP_GET_MAC;
    pTalk->Step[1] = CONNECT_STEP_GET_MAC_CHECK;
    pTalk->Step[2] = CONNECT_STEP_DONE;
    pTalk->StepIndex=0;
    pTalk->ConnectWaiting=0;
    return 1;
}


char GetReconSetting(TALK_INFO *pTalk)
{
    pTalk->Step[0] = CONNECT_STEP_GET_RECON_SETTING;
    pTalk->Step[1] = CONNECT_STEP_GET_RECON_SETTING_CHECK;
    pTalk->Step[2] = CONNECT_STEP_DONE;
    pTalk->StepIndex=0;
    pTalk->ConnectWaiting=0;
    return 1;
}


char SetReconSetting(TALK_INFO *pTalk)
{
    pTalk->Step[0] = CONNECT_STEP_SET_RECON_SETTING;
    pTalk->Step[1] = CONNECT_STEP_SET_RECON_SETTING_CHECK;
    pTalk->Step[2] = CONNECT_STEP_DONE;
    pTalk->StepIndex=0;
    pTalk->ConnectWaiting=0; 
    return 1;
}
*/


char ReConnect(TALK_INFO *pTalk)
{
    pTalk->ConnectResponse = CONNECT_RESULT_NORESPONSE;
    //pTalk->ConnectWaitTime =1000000;
    pTalk->Step[0] = CONNECT_STEP_CONNECT_LOCAL;
    pTalk->Step[1] = CONNECT_STEP_CONNECT_CHECK;
    pTalk->Step[2] = CONNECT_STEP_DONE;
    pTalk->StepIndex=0;
    pTalk->ConnectWaiting=0;
    return 1;
}

char LocalConnect(TALK_INFO *pTalk)
{
    ConnectSendPackage(pTalk, CONNECT_CMD_DISCONNECT);
    pTalk->ConnectResponse = CONNECT_RESULT_NORESPONSE;
    
    pTalk->Step[0] = CONNECT_STEP_CONNECT_LOCAL;
    pTalk->Step[1] = CONNECT_STEP_CONNECT_CHECK;
    pTalk->Step[2] = CONNECT_STEP_DONE;

    pTalk->StepIndex=0;
    pTalk->ConnectWaiting=0; 
    pTalk->ConnState = SC_CONN_STATE_CONNECTING;
    return 1;
}

char RemoteConnect(TALK_INFO *pTalk)
{
    ConnectSendPackage(pTalk, CONNECT_CMD_DISCONNECT);
    pTalk->ConnectResponse = CONNECT_RESULT_NORESPONSE;

    pTalk->Step[0] = CONNECT_STEP_CONNECT_REMOTE;
    pTalk->Step[1] = CONNECT_STEP_REMOTE_CHECK;
    pTalk->Step[2] = CONNECT_STEP_DONE;

    pTalk->StepIndex=0;
    pTalk->ConnectWaiting=0;
    pTalk->ConnState = SC_CONN_STATE_CONNECTING;
    return 1;
}
    
char TalkDisconnect(TALK_INFO *pTalk)
{
    ConnectSendPackage(pTalk, CONNECT_CMD_DISCONNECT);
    pTalk->ConnectWaiting=0;
    pTalk->ConnState = SC_CONN_STATE_DISCONNECT;
    return 1;
}



char ConnectSendOut(TALK_INFO *pTalk)
{
    WriteOutMessage(pTalk, (char *)pTalk->TxBuf, pTalk->TxLen);
	//printf("ConnectSendOut\n");
    //--------設定在等待中
    pTalk->ConnectWaiting=1;
    pTalk->ConnectTime = 0;
    return 1;
}


//------------定期呼叫
char RegularCallConnect(TALK_INFO *pTalk, long Interval)
{
	if (pTalk->StepIndex>=MAX_STEP) return 0;

    //檢查是否需重送
    //pTalk->ConnectWaitTime += Interval;
    pTalk->ConnectTime += Interval;
    if (pTalk->ConnectWaiting)
    {
        if (pTalk->ConnectTime >= pTalk->Timeout)
        {
            pTalk->ConnectWaiting=0;
            if (pTalk->ConnState==SC_CONN_STATE_CONNECTING)
            {
                pTalk->ConnState = SC_CONN_STATE_FAIL;
            }
            else if (pTalk->Step[pTalk->StepIndex]==CONNECT_STEP_DISCONNECT_CHECK)
            {
                //ClosePort(pTalk->Sck);
                pTalk->ConnState=SC_CONN_STATE_DISCONNECT;
                printf("[PT] Communication Stop! \n");
                pTalk->ConnectWaiting=0;
                pTalk->StepIndex++;
            }
        }
        return 0;
    }

    switch (pTalk->Step[pTalk->StepIndex])
    {
    case CONNECT_STEP_DISCONNECT:
        ConnectSendPackage(pTalk, CONNECT_CMD_DISCONNECT);
        pTalk->ConnectWaiting=0;
        pTalk->StepIndex++;
    	break;
    case CONNECT_STEP_DISCONNECT_CHECK:
        //ClosePort(pTalk->Sck);
        pTalk->ConnState=SC_CONN_STATE_DISCONNECT;
        printf("[PT] Communication Stop! \n");
        pTalk->StepIndex++;
    	break;
	case CONNECT_STEP_CONNECT_LOCAL:
        ConnectSendPackage(pTalk, CONNECT_CMD_SOFTWARE_ID);
        pTalk->Section.TxConnectCnt++;
        pTalk->StepIndex++;
    	break;
	case CONNECT_STEP_CONNECT_CHECK:
        switch (pTalk->ConnectResponse)
        {          
        case CONNECT_RESULT_NORESPONSE:
            pTalk->StepIndex++;
        	break;
        case CONNECT_RESULT_INVALID_SOFTWARE:
        case CONNECT_RESULT_DISABLE_SOFTWARE:
        case CONNECT_RESULT_DISABLE_INTERNET:
        case CONNECT_RESULT_SOFTWARE_INREQ:
        case CONNECT_RESULT_SOFTWARE_REJECTED:
        case CONNECT_RESULT_CLOSED_SOFTWARE:
        case CONNECT_RESULT_CLOSED_INTERNET:
        case CONNECT_RESULT_INVALID_MAKERID:
            pTalk->ConnState = SC_CONN_STATE_FAIL;
            pTalk->StepIndex=255;
            break;
        case CONNECT_RESULT_SOFTWARE_CONNECTED:
            pTalk->ConnState = SC_CONN_STATE_OK;
            pTalk->TalkState = TALK_STATE_NORMAL;
            pTalk->StepIndex=255;
            break;
        case CONNECT_RESULT_OLD_SOFTWARE_CLEAR:
        case CONNECT_RESULT_WAIT_CONFIRM:
        case CONNECT_RESULT_PENDING:
            //MicroSleep(500000); 
            pTalk->AliveRxTime = 0;
            //pTalk->ConnectWaitTime=0;
            pTalk->StepIndex--;
            break;
        default:       
            pTalk->ConnState = SC_CONN_STATE_FAIL;
            pTalk->StepIndex=255;
            break;
        }
        break;
    case CONNECT_STEP_CONNECT_REMOTE:
        ConnectSendPackage(pTalk, MEDIA_CMD_CONNECT_REQ);
        pTalk->Section.TxConnectCnt++;
        pTalk->StepIndex++;
        break;
    case CONNECT_STEP_REMOTE_CHECK:
        break;

    case CONNECT_STEP_DONE:
        pTalk->StepIndex = 255;
    	break;
    default:
        break;
    }
    return 1;
}


char ConnectSendPackage(TALK_INFO *pTalk, MEDIA_CMD ConnCmd)
{
    unsigned short temp;
    //---封包格式----------------------------------------
    // 開始位元(1) : START_CHAR_MEDIA
    // 命令碼  (1) :
    // 封包編號(2) :
    // 封包長度(2) :
    // 封包內容(n) :
    // CRC     (2) :
    pTalk->TxBuf[2]= pTalk->PacketID & 0xff;
    pTalk->TxBuf[3]= (pTalk->PacketID>>8) & 0xff;

    switch (ConnCmd)
    {
    case CONNECT_CMD_DISCONNECT:
        //---------- Request - 封包內容格式
        //Software ID  (4)
        //----------------------------------
        pTalk->MaxRetry=3;
    	pTalk->TxBuf[0]= START_CHAR_CONNECT;
    	pTalk->TxBuf[1]= CONNECT_CMD_DISCONNECT;
        pTalk->TxLen = 6;
    	break;

    case CONNECT_CMD_SOFTWARE_ID:
        //---------- Request - 封包內容格式
        //Software ID  (4)
        //----------------------------------
        pTalk->MaxRetry=3;
    	pTalk->TxBuf[0]= START_CHAR_CONNECT;
    	pTalk->TxBuf[1]= CONNECT_CMD_SOFTWARE_ID;
        LongToBuf((pTalk->TxBuf+6), &pTalk->SoftwareID);
        LongToBuf((pTalk->TxBuf+10), &pSes->Funcs.MakerID);
        pTalk->TxLen = 14;
        if (pTalk->ConnectPwd[0]!=0)
        {
        	memcpy(pTalk->TxBuf+14, pTalk->ConnectPwd, 16);
        	pTalk->TxLen = 30;
        }
    	break;
    case MEDIA_CMD_CONNECT_REQ:
        //---------- Request - 封包內容格式
        //Software ID  (4)
        //----------------------------------
        pTalk->MaxRetry=3;
        pTalk->TxBuf[0]= START_CHAR_MEDIA;
        pTalk->TxBuf[1]= MEDIA_CMD_CONNECT_REQ;
        LongToBuf((pTalk->TxBuf+6), (int *)&pTalk->RemoteIPLong);
        LongToBuf((pTalk->TxBuf+10), &pTalk->RemotePort);
        LongToBuf((pTalk->TxBuf+14), &pTalk->RemotePwd);
        pTalk->TxLen = 18;
        break;
    default:
        return 0;
    }
    //--------------設定長度
    pTalk->TxBuf[4] = pTalk->TxLen & 0xff;
    pTalk->TxBuf[5] = (pTalk->TxLen>>8) & 0xff;
    //----計算CRC
    temp = CRC_16(pTalk->TxBuf, pTalk->TxLen);
    pTalk->TxBuf[pTalk->TxLen++] = temp & 0xff;
    pTalk->TxBuf[pTalk->TxLen++] = (temp >> 8) & 0xff;
    //--------------設定要將資料寫出
    ConnectSendOut(pTalk);
    pTalk->RetryCnt = 0;
    return 1;
}



//--------接收媒介主機的資料檢查---------------------------------------------------
char ReceiveConnect(TALK_INFO *pTalk, long RxLen, unsigned char *RxBuf)
{
    unsigned short TotalByte;

    if (!pTalk->ConnectWaiting)
    {
        pTalk->Section.RxUnExpectCnt++;
        return 0;
    }

    if ( (RxBuf[0]!=pTalk->TxBuf[0])
       ||(RxBuf[1]!=pTalk->TxBuf[1])
       ||(RxBuf[2]!=pTalk->TxBuf[2])
       ||(RxBuf[3]!=pTalk->TxBuf[3]) )
    {
        pTalk->Section.RxErrFmtCnt++;
        return 0;
    }

    //讀取封包長度
    TotalByte = RxBuf[4] | (RxBuf[5]<<8);
    if (RxLen!=(TotalByte+2))
    {
        pTalk->Section.RxErrFmtCnt++;
        return 0;
    }

    //檢查CRC
    if( !CheckCRC(RxBuf, RxLen) )
    {
        pTalk->Section.RxCrcPkgCnt++;
        return 0;
    }


    //==============收到封包，編號++                                     
    pTalk->PacketID++;
    pTalk->ConnectWaiting=0;
    
	switch (RxBuf[1])
    {
    case CONNECT_CMD_SOFTWARE_ID:
        pTalk->ConnectResponse = RxBuf[6];
        pTalk->Section.RxConnectCnt++;
    	break;
    case MEDIA_CMD_TELL_MY_PORT:
        pTalk->MediaResponseCount++;
        {
            //---------- Reply - 封包內容格式
            //詢問者的IP (4)
            //詢問者的Port(4)
            //----------------------------------
            pTalk->MyInternetIPLong = *(unsigned int *)(RxBuf+6);
            pTalk->MyInternetPort   = *(unsigned int *)(RxBuf+10);
        }
        break;
    case MEDIA_CMD_CONNECT_REQ:
        pTalk->MediaResponseCount++;
    {
//    #ifdef __QT
//        QString IPStr;
//        IPStr.asprintf("%s", pTalk->RemoteIP);
//        pTalk->ReconAddr.setAddress(IPStr);
//        pTalk->ReconPort = pTalk->RemotePort;
//    #else
        pTalk->ReconAddr.sin_family = AF_INET;
        pTalk->ReconAddr.sin_addr.s_addr = pTalk->RemoteIPLong;
        pTalk->ReconAddr.sin_port = htons(pTalk->RemotePort);	  // short, network byte order
        memset(&(pTalk->ReconAddr.sin_zero), '\0', 8); // zero the rest of the struct
//    #endif
        //-----
        ConnectSendPackage(pTalk, CONNECT_CMD_SOFTWARE_ID);
        MicroSleep(20000);
        ConnectSendPackage(pTalk, CONNECT_CMD_SOFTWARE_ID);
        MicroSleep(20000);
        ConnectSendPackage(pTalk, CONNECT_CMD_SOFTWARE_ID);
        MicroSleep(20000);
        //----
        pTalk->ConnState = SC_CONN_STATE_OK;
        pTalk->TalkState = TALK_STATE_NORMAL;
        break;
    }
    default:
        pTalk->Section.RxErrFmtCnt++;
        return 0;
    }
    return 1;

}
