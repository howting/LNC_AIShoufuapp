
#include "sc2_memory.h"
                       

//-------------------protocol的制式界面
LK_PROTOCOL   GetProtocol();
unsigned char TransactionToBuf(PROTOCOL_SECTION *pSection, LK_TRANSACTION *pTranc);
//void          BufToTransaction(PROTOCOL_SECTION *pSection, LK_TRANSACTION *pTranc);
void          BufToTransaction(short RxLen, unsigned char *RxBuf, LK_TRANSACTION *pTranc);
unsigned char ParseRecvive(TALK_INFO *pTalk, LK_TRANSACTION *pTranc, unsigned short n, unsigned char *tmpBuf);

