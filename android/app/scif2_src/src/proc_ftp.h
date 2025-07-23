//---------------------------------------------------------------------------

#ifndef proc_ftpH
#define proc_ftpH
                     
#include "sc2_memory.h"



void SetUploadFile(FTP_INFO *pFtp);
void SetDownloadFile(FTP_INFO *pFtp);  
void SetDeleteFile(FTP_INFO *pFtp);
void SetListFile(FTP_INFO *pFtp);
void SetUploadFiles(FTP_INFO *pFtp);
void SetDownloadFiles(FTP_INFO *pFtp);
void SetDeleteFiles(FTP_INFO *pFtp); 
void SetMakeDir(FTP_INFO *pFtp);
void SetBuildEncryptFiles(FTP_INFO *pFtp);
void SetDeleteOriginalFiles(FTP_INFO *pFtp);


char InitFtp(FTP_INFO *pFtp);

char ReceiveFtp(FTP_INFO *pFtp, unsigned short RxLen, unsigned char *RxBuf);
//char ReceiveFtpFile(FTP_INFO *pFtp, unsigned short RxLen, unsigned char *RxBuf);
char RegularCallFtp(FTP_INFO *pFtp, unsigned int Interval);

//---------------------------------------------------------------------------
#endif
