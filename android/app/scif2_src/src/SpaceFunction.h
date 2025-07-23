//---------------------------------------------------------------------------

#ifndef SpaceFunctionH
#define SpaceFunctionH

//#include <unistd.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>                                 
#include <math.h>

#include "SpaceDefine.h"





enum AXES_SEL
{
    AXES_PX,
    AXES_NX,
    AXES_PY,
    AXES_NY,
    AXES_PZ,
    AXES_NZ,
};


struct COORDINATE_SRC     //兩向量組成的座標系
{
    VECTOR P0;        //原點
    VECTOR Vx;
    VECTOR Vxy;
    double Angle;     //提供座標系的二向量的夾角
    double VecRatio;  //向量長度比例
    COORDINATE Coor;
};

struct COORDINATE_CHANGE           //姿態變化參數
{
    double            NzAngle;       //起點與終點的夾角變化量
    double            NxAngle;       //起點與終點的夾角變化量
    COORDINATE        StCoor;      //起點的座標系
    POSTURE           DirSrc;
    POSTURE           DirTgr;
    POSTURE           DirCg;       //姿態變化的值
};




//extern int MULV;
extern int mEulerType;

class SF
{
public:

    //=============================空間轉換函式
    //----兩向量運算
    static void   SetVector(VECTOR *P1, VECTOR *P2, VECTOR *Vec12);
    static void   SetVectorLen(VECTOR *Vec);
    static void   SetVectorCross(VECTOR *Vec1, VECTOR *Vec2, VECTOR *CrossVec);
    static void   SetVectorSum(VECTOR *Vec1, VECTOR *Vec2, VECTOR *SumVec);
    static double GetVectorDot(VECTOR *Vec1, VECTOR *Vec2);
    static void   NormalizeVector(VECTOR *Vec1);

//    //----取角度
//    static double GetVectorAngle0(VECTOR *Vec1, VECTOR *Vec2);
//    static double GetVectorAngle1(VECTOR *Vec1, VECTOR *Vec2);
    static double GetVectorAngle2(VECTOR *Vec1, VECTOR *Vec2, VECTOR *Nz);
    static double GetXAngle(double dX, double dY);
//    static double GetYAngle(double dX, double dY);
//    static double NormalAngle(double Deg);

    //-----設定繞軸轉換後的座標系
    static void   SetRotateXCoor(double Deg, COORDINATE *pCoor);
    static void   SetRotateYCoor(double Deg, COORDINATE *pCoor);
    static void   SetRotateZCoor(double Deg, COORDINATE *pCoor);

    //----ABC 與 座標系 互換
    static int Abc2Coor(POSTURE *pPosture, COORDINATE *pCoor);
    static int Zxz2Coor(POSTURE *pPosture, COORDINATE *pCoor);
    static int Zyz2Coor(POSTURE *pPosture, COORDINATE *pCoor);
    static int Zyx2Coor(POSTURE *pPosture, COORDINATE *pCoor);
    static int Xyz2Coor(POSTURE *pPosture, COORDINATE *pCoor);

    static int Coor2Abc(COORDINATE *pCoor, POSTURE *pPosture);
    static int Coor2Zxz(COORDINATE *pCoor, POSTURE *pPosture);
    static int Coor2Zyz(COORDINATE *pCoor, POSTURE *pPosture);
    static int Coor2Zyx(COORDINATE *pCoor, POSTURE *pPosture);
    static int Coor2Xyz(COORDINATE *pCoor, POSTURE *pPosture);

    // ----向量轉換
    static void VectorConvert(COORDINATE *pCoor, VECTOR *pLocal, VECTOR *pGlobal);
    static int  VectorInvert(COORDINATE *pCoor, VECTOR *pGlobal, VECTOR *pLocal);

    //-----向量座標系轉換
    static int  CoorConvert(COORDINATE *pCoor, COORDINATE *pLocal, COORDINATE *pGlobal);
    static int  CoorInvert(COORDINATE *pCoor, COORDINATE *pGlobal, COORDINATE *pLocal);
    //-----空間座標、座姿轉換
    static void PosConvert(SPACE_POS *pBase, VECTOR *pLocal, VECTOR *pGlobal);
    static int  PosInvert(SPACE_POS *pBase, VECTOR *pGlobal, VECTOR *pLocal);
    static void SpaceConvert(SPACE_POS *pBase, SPACE_POS *pLocal, SPACE_POS *pGlobal);
    static int  SpaceInvert(SPACE_POS *pBase, SPACE_POS *pGlobal, SPACE_POS *pLocal);

    static void PosConvert2(STANCE *pBase,    VECTOR *pLocal, VECTOR *pGlobal);
    static int  PosInvert2(STANCE *pBase,    VECTOR *pGlobal, VECTOR *pLocal);
    static int  StanceConvert(STANCE *pCoor, STANCE *pLocal, STANCE *pGlobal);
    static int  StanceInvert(STANCE *pCoor, STANCE *pGlobal, STANCE *pLocal);



//    //=================================插值函式
//    //----轉換3P座標系
//    static int Set2VCoor(COORDINATE *pCoor, VECTOR *pVx, VECTOR *pVy);
//    static int Set3PCoor(COORDINATE *pCoor, VECTOR *p0, VECTOR *p1, VECTOR *p2);
//    static int Set3PCoorCali(STANCE *pP0, STANCE *pP1, STANCE *pP2, AXES_SEL P1Sel, AXES_SEL P2Sel);

//    //----圓弧資訊計算
//    static int Set3PCenter(VECTOR *p0, VECTOR *p1, VECTOR *p2, VECTOR *pCen, double *pRadius);
//    static int Set3PCenterSd(VECTOR *pP0, VECTOR *pP1, VECTOR *pP2, STANCE *pSd);

//    //----位置插值
//    static int Set3PCoorSrc(COORDINATE_SRC *pVCoor, VECTOR *p0, VECTOR *p1, VECTOR *p2);
//    static int SetPosForLine(VECTOR *pSt, VECTOR *pEd, double Ratio, VECTOR *pTgr);
//    static int SetPosForCurve(COORDINATE_SRC *pVCoor, double Ratio, VECTOR *pTgr);
//    static int SetPosForCurve2(COORDINATE_SRC *pVCoor, double Angle, VECTOR *pTgr);

//    //----姿態插值
//    static int SetCoorChangeForLine(COORDINATE_CHANGE *pCoorC, COORDINATE *pSrc, COORDINATE *pTgr);
//    static int SetCoorChangeForCurve(COORDINATE_CHANGE *pCoorC, COORDINATE *pSrc, COORDINATE *pTgr, COORDINATE *pCurve);
//    static int SetCoorValue(COORDINATE_CHANGE *pCoorC, double ChangeRatio, COORDINATE *pCoor);

//    //----求兩線交點
//    static int CalHorizontal3P_XYC(VECTOR *pP1, VECTOR *pP2, VECTOR *pP3, VECTOR *pPc, double *Ang);
//    static int CalLineCross(VECTOR *p1, VECTOR *p2, VECTOR *p3, VECTOR *p4, VECTOR *pc);
//    static int CalLineCross3D(VECTOR *p1, VECTOR *p2, VECTOR *p3, VECTOR *p4, SPACE_POS *SP);
//    //-----合併 RX, RY, RZf旋轉向量
//    static void  CombineRXRYRZ(double aRX, double aRY, double aRZ, COORDINATE *CmbCoor);

};
//---------------------------------------------------------------------------
#endif
