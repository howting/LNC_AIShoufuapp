//---------------------------------------------------------------------------

#ifndef proc_connect_buildH
#define proc_connect_buildH
  
#include "sc2_memory.h"

char ConnectSendPackage(TALK_INFO *pTalk, MEDIA_CMD ConnCmd);

char LocalConnect(TALK_INFO *pTalk);
char RemoteConnect(TALK_INFO *pTalk);
char ReConnect(TALK_INFO *pTalk);    
char TalkDisconnect(TALK_INFO *pTalk);

char ReceiveConnect(TALK_INFO *pTalk, long RxLen, unsigned char *RxBuf);
char RegularCallConnect(TALK_INFO *pTalk, long Interval);
            
//char GetMac(TALK_INFO *pTalk);
//char GetReconSetting(TALK_INFO *pTalk);
//char SetReconSetting(TALK_INFO *pTalk);  
//char GetReconR(TALK_INFO *pTalk);
//char SetReconR(TALK_INFO *pTalk);

#endif
