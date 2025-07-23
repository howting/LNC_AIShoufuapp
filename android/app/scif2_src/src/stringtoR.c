void StringSaveToR(const char *Src,int iLen,int iRNo,int iRCount)
{
  if(iRNo >= 0 && iRCount > 0)
  {
    const int iRTempCount = 100;
    const int ciCount = iLen / sizeof(int) + ((iLen % sizeof(int)) ? 1 : 0);
    int iRValue[iRTempCount];
    memset(iRValue,0,sizeof(iRValue));
    int iIndex = 0;

    for(int i=0; i<ciCount; i++)
    {
      unsigned int iDest = 0;
      for(int k=0; k<(int)sizeof(int); k++)
      {
        int iStrIndex = i * sizeof(int) + k;
        if(iStrIndex < iLen)
        {
          unsigned int iByteData = Src[iStrIndex] & 0x000000FF;
          iDest = iDest | (iByteData << (8 * k));
        }
      }
      if(i<iRTempCount)
        iRValue[i] = iDest;
      iIndex++;
    }

    // 寫入 R 值
    for(int i=0; i<iRCount; i++)
    {
      if(i < iIndex && i < iRTempCount)
      {
        KI_WriteR(iRNo + i, iRValue[i]);
       // printf("StringSaveToR %d %d \n",i,iRValue[i]);
      }
      else
        KI_WriteR(iRNo + i, 0);
    }
  }
}
char *StringReadFromR(int iRNo,int iRCount)
{
  if(iRNo >= 0 && iRCount > 0)
  {
    std::list<int> IntList;

    // 讀取 R 值
    for(int i=0; i<iRCount; i++)
      IntList.push_back(KI_ReadR(iRNo + i));
//printf("StringReadFromR %d \n",IntList.size());
    memset(gReturnChar,'\0',sizeof(gReturnChar));
    int iIndex = 0;

    for (std::list<int>::iterator it = IntList.begin(); it != IntList.end(); it++)
    {
      unsigned int iData = *it;
 // printf("StringReadFromR 1 %d \n",iData);
    for(int k=0; k<(int)sizeof(int); k++)
      {
        char cIntData = (iData >> (8 * k)) & 0xFF;
        if((unsigned int)cIntData >= (unsigned int)' ')
        {
          gReturnChar[iIndex] = cIntData;
          iIndex++;
        }
        // 結束字元
        else if(cIntData == 0)
          break;
      }
    }
    return &gReturnChar[0];
  }

  return NULL;

}