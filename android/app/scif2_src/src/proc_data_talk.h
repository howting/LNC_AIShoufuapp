//---------------------------------------------------------------------------

#ifndef proc_data_talkH
#define proc_data_talkH


#include "sc2_memory.h"

void WriteOutTalk(TALK_INFO *pTalk);
void InitTalk(TALK_INFO *pTalk);
void ResetTalk(TALK_INFO *pTalk);
void RegularCallTalk(TALK_INFO *pTalk, unsigned int Interval);
char ReceiveTalk(TALK_INFO *pTalk, unsigned short RxLen, unsigned char *RxBuf);

//---------------------------------------------------------------------------
#endif
