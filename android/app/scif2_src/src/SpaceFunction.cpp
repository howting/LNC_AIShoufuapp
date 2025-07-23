//#include "stdafx.h"
#include "SpaceFunction.h"


int mEulerType;




//---------------------------------------------------------------------------
double SF::GetXAngle(double dX, double dY)
{
    if (dX==0.0)
    {
        if      (dY==0) return 0;
        else if (dY>=0.0) return PI/2;
        else              return -PI/2;
    }
    else if (dX>0.0)
    {
        return atan(dY/dX);
    }
    else
    {
        double tmp = atan(dY/dX);
        if (tmp>0) return tmp-PI;
        else       return tmp+PI;
    }
}


////---------------------------------------------------------------------------
//double SF::GetYAngle(double dX, double dY)
//{
//    if (dY==0.0)
//    {
//        if      (dX==0) return 0;
//        else if (dX>=0.0) return -PI/2;
//        else              return PI/2;
//    }
//    else if (dY>0.0)
//    {
//        return -atan(dX/dY);
//    }
//    else
//    {
//        double tmp = -atan(dX/dY);
//        if (tmp>0) return tmp-PI;
//        else       return tmp+PI;
//    }
//}

////==========================================================================
//double SF::NormalAngle(double Deg)
//{
//    int iround;
//    double rtVal;
//    if (Deg>0)
//    {
//        iround = (int)(Deg/360+0.5);
//        rtVal= Deg-iround*360;
//    }
//    else
//    {
//        iround = (int)(-Deg/360+0.5);
//        rtVal= Deg+iround*360;
//    }
//    //if ((rtVal>180)||(rtVal<=-180)) printf("rtVal=%f\n", rtVal);
//    return rtVal;
//}

//==========================================================================
void SF::SetVector(VECTOR *P1, VECTOR *P2, VECTOR *Vec12)
{
    Vec12->X = P2->X - P1->X;
    Vec12->Y = P2->Y - P1->Y;
    Vec12->Z = P2->Z - P1->Z;
    SetVectorLen(Vec12);
}

//----------------------------------------------------------------------
// 計算兩向量角度
void SF::SetVectorCross(VECTOR *Vec1, VECTOR *Vec2, VECTOR *CrossVec)
{
    CrossVec->X = Vec1->Y * Vec2->Z - Vec1->Z * Vec2->Y;
    CrossVec->Y = Vec1->Z * Vec2->X - Vec1->X * Vec2->Z;
    CrossVec->Z = Vec1->X * Vec2->Y - Vec1->Y * Vec2->X;

    SetVectorLen(CrossVec);
}


void SF::SetVectorSum(VECTOR *Vec1, VECTOR *Vec2, VECTOR *SumVec)
{
    SumVec->X = Vec1->X + Vec2->X;
    SumVec->Y = Vec1->Y + Vec2->Y;
    SumVec->Z = Vec1->Z + Vec2->Z;
    SetVectorLen(SumVec);
}


//----------------------------------------------------------------------
// 向量正規化
void SF::NormalizeVector(VECTOR *Vec1)
{
    if (Vec1->L>0)
    {
        Vec1->X /= Vec1->L;
        Vec1->Y /= Vec1->L;
        Vec1->Z /= Vec1->L;
        Vec1->L = 1;
    }
    else
    {
        Vec1->X = 0;
        Vec1->Y = 0;
        Vec1->Z = 0;
        Vec1->L = 1;
    }
}

//------------------------------------------------------------------------------
// 計算兩向量角度
double SF::GetVectorDot(VECTOR *Vec1, VECTOR *Vec2)
{
    return Vec1->X*Vec2->X + Vec1->Y*Vec2->Y + Vec1->Z*Vec2->Z;
}

////------------------------------------------------------------------------------
//// 計算兩向量角度，不管正負
//double SF::GetVectorAngle0(VECTOR *Vec1, VECTOR *Vec2)
//{
//    double DotVal = Vec1->X*Vec2->X + Vec1->Y*Vec2->Y + Vec1->Z*Vec2->Z;
//    double Len2 = Vec1->L * Vec2->L;
//    if (Len2<1E-13) return 0;
//    double cosval = DotVal/Len2;
//    if (cosval>1) cosval=1;
//    if (cosval<-1) cosval=-1;
//    return acos(cosval);
//}


////------------------------------------------------------------------------------
//// 計算兩向量角度，考慮正負方向(Nz.z>0朝上時為正)
//double SF::GetVectorAngle1(VECTOR *Vec1, VECTOR *Vec2)
//{
//    double DotVal = Vec1->X*Vec2->X + Vec1->Y*Vec2->Y + Vec1->Z*Vec2->Z;
//    double Len2 = Vec1->L * Vec2->L;
//    if (Len2<1E-13) return 0;
//    double cosval = DotVal/Len2;
//    if (cosval>1) cosval=1;
//    if (cosval<-1) cosval=-1;
//    VECTOR NNz;
//    SetVectorCross(Vec1, Vec2, &NNz);
//    if (NNz.Z>=0) return acos(cosval);
//    else                 return -acos(cosval);
//}

//------------------------------------------------------------------------------
// 計算兩向量角度，考慮正負方向，並回傳平面法向量
double SF::GetVectorAngle2(VECTOR *Vec1, VECTOR *Vec2, VECTOR *Nz)
{
    double DotVal = Vec1->X*Vec2->X + Vec1->Y*Vec2->Y + Vec1->Z*Vec2->Z;
    double Len2 = Vec1->L * Vec2->L;
    if (Len2<1E-13) return 0;
    double cosval = DotVal/Len2;
    if (cosval>1) cosval=1;
    if (cosval<-1) cosval=-1;
    VECTOR NNz;
    SetVectorCross(Vec1, Vec2, &NNz);
    NormalizeVector(&NNz);
    if (GetVectorDot(&NNz, Nz)>=0) return acos(cosval);
    else                           return -acos(cosval);
}

//------------------------------------------------------------------------------
// 計算向量長度並設定
void SF::SetVectorLen(VECTOR *Vec)
{
    double LL;
    if ((Vec->X<1E-14)&&(Vec->X>-1E-14)) Vec->X=0;
    if ((Vec->Y<1E-14)&&(Vec->Y>-1E-14)) Vec->Y=0;
    if ((Vec->Z<1E-14)&&(Vec->Z>-1E-14)) Vec->Z=0;
    LL = Vec->X*Vec->X + Vec->Y*Vec->Y + Vec->Z*Vec->Z;
    if (LL<=1E-13)
        Vec->L = 0;
    else
        Vec->L = sqrt(LL);
}


void SF::SetRotateXCoor(double Deg, COORDINATE *pCoor)
{
    double Ang = Deg*PI/180;
    pCoor->Nx.X=1;         pCoor->Nx.Y=0;         pCoor->Nx.Z=0;         pCoor->Nx.L=1;
    pCoor->Ny.X=0;         pCoor->Ny.Y=cos(Ang);  pCoor->Ny.Z=sin(Ang);  pCoor->Ny.L=1;
    pCoor->Nz.X=0;         pCoor->Nz.Y=-sin(Ang); pCoor->Nz.Z=cos(Ang);  pCoor->Nz.L=1;
}

void SF::SetRotateYCoor(double Deg, COORDINATE *pCoor)
{
    double Ang = Deg*PI/180;
    pCoor->Nx.X=cos(Ang);  pCoor->Nx.Y=0;         pCoor->Nx.Z=-sin(Ang);  pCoor->Nx.L=1;
    pCoor->Ny.X=0;         pCoor->Ny.Y=1;         pCoor->Ny.Z=0;          pCoor->Ny.L=1;
    pCoor->Nz.X=sin(Ang);  pCoor->Nz.Y=0;         pCoor->Nz.Z=cos(Ang);   pCoor->Nz.L=1;
}

void SF::SetRotateZCoor(double Deg, COORDINATE *pCoor)
{
    double Ang = Deg*PI/180;
    pCoor->Nx.X=cos(Ang);  pCoor->Nx.Y=sin(Ang);  pCoor->Nx.Z=0;   pCoor->Nx.L=1;
    pCoor->Ny.X=-sin(Ang); pCoor->Ny.Y=cos(Ang);  pCoor->Ny.Z=0;   pCoor->Ny.L=1;
    pCoor->Nz.X=0;         pCoor->Nz.Y=0;         pCoor->Nz.Z=1;   pCoor->Nz.L=1;
}


////------------------------------------------------------------------------------
//void  SF::CombineRXRYRZ(double aRX, double aRY, double aRZ, COORDINATE *CmbCoor)
//{
//    COORDINATE Rot1Coor, Rot2Coor, Rot3Coor;
//    int abs3 = abs((int)aRX*1000);
//    int abs4 = abs((int)aRY*1000);
//    int abs5 = abs((int)aRZ*1000);

//    if ((abs3>=abs4)&&(abs3>=abs5))
//    {
//        SetRotateXCoor(aRX, &Rot1Coor);
//        if (abs4>=abs5)
//        {
//            SetRotateYCoor(aRY, &Rot2Coor);
//            SetRotateZCoor(aRZ, &Rot3Coor);
//        }
//        else
//        {
//            SetRotateZCoor(aRZ, &Rot2Coor);
//            SetRotateYCoor(aRY, &Rot3Coor);
//        }
//    }
//    else if ((abs4>=abs3)&&(abs4>=abs5))
//    {
//        SetRotateYCoor(aRY, &Rot1Coor);
//        if (abs3>=abs5)
//        {
//            SetRotateXCoor(aRX, &Rot2Coor);
//            SetRotateZCoor(aRZ, &Rot3Coor);
//        }
//        else
//        {
//            SetRotateZCoor(aRZ, &Rot2Coor);
//            SetRotateXCoor(aRX, &Rot3Coor);
//        }
//    }
//    else
//    {
//        SetRotateZCoor(aRZ, &Rot1Coor);
//        if (abs3>=abs4)
//        {
//            SetRotateXCoor(aRX, &Rot2Coor);
//            SetRotateYCoor(aRY, &Rot3Coor);
//        }
//        else
//        {
//            SetRotateYCoor(aRY, &Rot2Coor);
//            SetRotateXCoor(aRX, &Rot3Coor);
//        }
//    }
//    COORDINATE Coor12;
//    CoorConvert(&Rot1Coor, &Rot2Coor, &Coor12);
//    CoorConvert(&Coor12, &Rot3Coor, CmbCoor);

//}

////------------------------------------------------------------------------------
////----三點座標轉為座標系
//int SF::Set3PCoorSrc(COORDINATE_SRC *pVCoor, VECTOR *p0, VECTOR *p1, VECTOR *p2)
//{
//    pVCoor->P0.X = p0->X;
//    pVCoor->P0.Y = p0->Y;
//    pVCoor->P0.Z = p0->Z;
//    SetVectorLen(&pVCoor->P0);
//    //X軸向量
//    pVCoor->Vx.X = p1->X - p0->X;
//    pVCoor->Vx.Y = p1->Y - p0->Y;
//    pVCoor->Vx.Z = p1->Z - p0->Z;
//    SetVectorLen(&pVCoor->Vx);
//    //XY平面上的點
//    pVCoor->Vxy.X = p2->X - p0->X;
//    pVCoor->Vxy.Y = p2->Y - p0->Y;
//    pVCoor->Vxy.Z = p2->Z - p0->Z;
//    SetVectorLen(&pVCoor->Vxy);
//    //向量內積算角度
//    if (pVCoor->Vx.L>0)
//        pVCoor->VecRatio = pVCoor->Vxy.L / pVCoor->Vx.L;
//    else
//        pVCoor->VecRatio = 1;
//    pVCoor->Angle = GetVectorAngle0(&pVCoor->Vx, &pVCoor->Vxy);
//    //二向量轉為座標系
//    return Set2VCoor(&pVCoor->Coor, &pVCoor->Vx, &pVCoor->Vxy);
//}


//int SF::Set3PCenter(VECTOR *p0, VECTOR *p1, VECTOR *p2, VECTOR *pCen, double *pRadius)
//{
//    COORDINATE_SRC VC;
//    int rt = Set3PCoorSrc(&VC, p0, p1, p2);
//    if (rt!=0) return 3;  //無法轉換向量座標系
//    //求平面座標系上的圓心位置--求外心，解二元一次方程式
//    double Pa = cos(VC.Angle);
//    double Pb = sin(VC.Angle);
//    double Pc = (Pa*Pa + Pb*Pb)*VC.Vxy.L/2;
//    VECTOR PO2;
//    PO2.X = VC.Vx.L/2;
//    PO2.Y = (Pc-Pa*PO2.X)/Pb;
//    //將座標系偏移位置移到圓心上
//    pCen->X = VC.P0.X + PO2.X*VC.Coor.Nx.X + PO2.Y*VC.Coor.Ny.X;
//    pCen->Y = VC.P0.Y + PO2.X*VC.Coor.Nx.Y + PO2.Y*VC.Coor.Ny.Y;
//    pCen->Z = VC.P0.Z + PO2.X*VC.Coor.Nx.Z + PO2.Y*VC.Coor.Ny.Z;
//    VECTOR VR;
//    SetVector(pCen, p0, &VR);
//    *pRadius = VR.L;
//    return 0;
//}


////------------------------------------------------------------------------------
//int SF::Set3PCenterSd(VECTOR *pP0, VECTOR *pP1, VECTOR *pP2, STANCE *pSd)
//{
//    //計算三點座標系
//    COORDINATE_SRC VecCoor;
//    Set3PCoorSrc(&VecCoor, pP1, pP0, pP2);
//    //求平面座標系上的圓心位置--求外心，解二元一次方程式
//    double Pa = cos(VecCoor.Angle);
//    double Pb = sin(VecCoor.Angle);
//    double Pc = (Pa*Pa + Pb*Pb)*VecCoor.Vxy.L/2;
//    VECTOR PO2;
//    PO2.X = VecCoor.Vx.L/2;
//    PO2.Y = (Pc-Pa*PO2.X)/Pb;
//    //將座標系偏移位置移到圓心上
//    VecCoor.P0.X += PO2.X*VecCoor.Coor.Nx.X + PO2.Y*VecCoor.Coor.Ny.X;
//    VecCoor.P0.Y += PO2.X*VecCoor.Coor.Nx.Y + PO2.Y*VecCoor.Coor.Ny.Y;
//    VecCoor.P0.Z += PO2.X*VecCoor.Coor.Nx.Z + PO2.Y*VecCoor.Coor.Ny.Z;
//    //使用求出的圓心，重新計算座標系
//    Set3PCoorSrc(&VecCoor, &VecCoor.P0, pP0, pP1);
//    memcpy(&pSd->Pos, &VecCoor.P0, sizeof(VECTOR));
//    memcpy(&pSd->Coor, &VecCoor.Coor, sizeof(COORDINATE));
//    Coor2Abc(&pSd->Coor, &pSd->Dir);
//    return 0;
//}



//int SF::SetPosForLine(VECTOR *pSt, VECTOR *pEd, double Ratio, VECTOR *pTgr)
//{
//    pTgr->X = pSt->X + (pEd->X-pSt->X)*Ratio;
//    pTgr->Y = pSt->Y + (pEd->Y-pSt->Y)*Ratio;
//    pTgr->Z = pSt->Z + (pEd->Z-pSt->Z)*Ratio;
//    SetVectorLen(pTgr);
//    return 0;
//}

//int SF::SetPosForCurve(COORDINATE_SRC *pVCoor, double Ratio, VECTOR *pTgr)
//{
//    double Ang1 = pVCoor->Angle * Ratio;
//    double LL = (1 - Ratio*(1-pVCoor->VecRatio)) * pVCoor->Vx.L;
//    VECTOR Vr;
//    Vr.X = LL*cos(Ang1);
//    Vr.Y = LL*sin(Ang1);
//    Vr.Z = 0;
//    //----轉為空間座標
//    SF::VectorConvert(&pVCoor->Coor, &Vr, pTgr);
//    pTgr->X += pVCoor->P0.X;
//    pTgr->Y += pVCoor->P0.Y;
//    pTgr->Z += pVCoor->P0.Z;
//    return 0;
//}

//int SF::SetPosForCurve2(COORDINATE_SRC *pVCoor, double Angle, VECTOR *pTgr)
//{
//    double Ratio, LL;
//    if (pVCoor->Angle==0)
//    {
//        LL = pVCoor->Vx.L;
//    }
//    else
//    {
//        Ratio = Angle/pVCoor->Angle;
//        LL = (1 - Ratio*(1-pVCoor->VecRatio)) * pVCoor->Vx.L;
//    }
//    VECTOR Vr;
//    Vr.X = LL*cos(Angle);
//    Vr.Y = LL*sin(Angle);
//    Vr.Z = 0;
//    //----轉為空間座標
//    SF::VectorConvert(&pVCoor->Coor, &Vr, pTgr);
//    pTgr->X += pVCoor->P0.X;
//    pTgr->Y += pVCoor->P0.Y;
//    pTgr->Z += pVCoor->P0.Z;
//    return 0;
//}


//------------------------------------------------------------------------------
//區域向量轉全域向量
void SF::VectorConvert(COORDINATE *pCoor, VECTOR *pLocal, VECTOR *pGlobal)
{
    pGlobal->X = pLocal->X*pCoor->Nx.X + pLocal->Y*pCoor->Ny.X + pLocal->Z*pCoor->Nz.X;
    pGlobal->Y = pLocal->X*pCoor->Nx.Y + pLocal->Y*pCoor->Ny.Y + pLocal->Z*pCoor->Nz.Y;
    pGlobal->Z = pLocal->X*pCoor->Nx.Z + pLocal->Y*pCoor->Ny.Z + pLocal->Z*pCoor->Nz.Z;
    SetVectorLen(pGlobal);
}


//----向量逆轉換
int  SF::VectorInvert(COORDINATE *pCoor, VECTOR *pGlobal, VECTOR *pLocal)
{
    double d, dx, dy, dz;
    d  = pCoor->Nx.X * pCoor->Ny.Y * pCoor->Nz.Z
       + pCoor->Ny.X * pCoor->Nz.Y * pCoor->Nx.Z
       + pCoor->Nz.X * pCoor->Nx.Y * pCoor->Ny.Z
       - pCoor->Nx.X * pCoor->Nz.Y * pCoor->Ny.Z
       - pCoor->Ny.X * pCoor->Nx.Y * pCoor->Nz.Z
       - pCoor->Nz.X * pCoor->Ny.Y * pCoor->Nx.Z;

    dx = pGlobal->X  * pCoor->Ny.Y * pCoor->Nz.Z
       + pCoor->Ny.X * pCoor->Nz.Y * pGlobal->Z
       + pCoor->Nz.X * pGlobal->Y  * pCoor->Ny.Z
       - pGlobal->X  * pCoor->Nz.Y * pCoor->Ny.Z
       - pCoor->Ny.X * pGlobal->Y  * pCoor->Nz.Z
       - pCoor->Nz.X * pCoor->Ny.Y * pGlobal->Z;

    dy = pCoor->Nx.X * pGlobal->Y  * pCoor->Nz.Z
       + pGlobal->X  * pCoor->Nz.Y * pCoor->Nx.Z
       + pCoor->Nz.X * pCoor->Nx.Y * pGlobal->Z
       - pCoor->Nx.X * pCoor->Nz.Y * pGlobal->Z
       - pGlobal->X  * pCoor->Nx.Y * pCoor->Nz.Z
       - pCoor->Nz.X * pGlobal->Y  * pCoor->Nx.Z;

    dz = pCoor->Nx.X * pCoor->Ny.Y * pGlobal->Z
       + pCoor->Ny.X * pGlobal->Y  * pCoor->Nx.Z
       + pGlobal->X  * pCoor->Nx.Y * pCoor->Ny.Z
       - pCoor->Nx.X * pGlobal->Y  * pCoor->Ny.Z
       - pCoor->Ny.X * pCoor->Nx.Y * pGlobal->Z
       - pGlobal->X  * pCoor->Ny.Y * pCoor->Nx.Z;

    if ((d<1E-13)&&(d>-1E-13))
    {
        pLocal->X = 0;
        pLocal->Y = 0;
        pLocal->Z = 0;
        pLocal->L = 0;
        return 5;
    }
    else
    {
        pLocal->X = dx/d;
        pLocal->Y = dy/d;
        pLocal->Z = dz/d;
        SetVectorLen(pLocal);
        return 0;
    }

}


//-----向量座標系轉換
int  SF::CoorConvert(COORDINATE *pCoor, COORDINATE *pLocal, COORDINATE *pGlobal)
{
    //方向轉換 Nx, Ny, Nz
    VectorConvert(pCoor, &pLocal->Nx, &pGlobal->Nx);
    VectorConvert(pCoor, &pLocal->Ny, &pGlobal->Ny);
    VectorConvert(pCoor, &pLocal->Nz, &pGlobal->Nz);
    return 0;
}


int  SF::CoorInvert(COORDINATE *pCoor, COORDINATE *pGlobal, COORDINATE *pLocal)
{
    int rt;
    //方向轉換 Nx, Ny, Nz
    rt = VectorInvert(pCoor, &pGlobal->Nx, &pLocal->Nx);
    if (rt!=0) return rt;
    rt = VectorInvert(pCoor, &pGlobal->Ny, &pLocal->Ny);
    if (rt!=0) return rt;
    rt = VectorInvert(pCoor, &pGlobal->Nz, &pLocal->Nz);
    if (rt!=0) return rt;
    return 0;
}


void SF::PosConvert(SPACE_POS *pBase, VECTOR *pLocal, VECTOR *pGlobal)
{
    //----位置轉換
    VectorConvert(&pBase->Coor, pLocal, pGlobal);
    pGlobal->X += pBase->Pos.X;
    pGlobal->Y += pBase->Pos.Y;
    pGlobal->Z += pBase->Pos.Z;
    SetVectorLen(pGlobal);
}

int  SF::PosInvert(SPACE_POS *pBase, VECTOR *pGlobal, VECTOR *pLocal)
{
    int rt;
    //位置轉換
    VECTOR tmpPos;
    tmpPos.X = pGlobal->X - pBase->Pos.X;
    tmpPos.Y = pGlobal->Y - pBase->Pos.Y;
    tmpPos.Z = pGlobal->Z - pBase->Pos.Z;
    SetVectorLen(&tmpPos);
    rt = VectorInvert(&pBase->Coor, &tmpPos, pLocal);
    return rt;
}

//-----空間座標轉換
void SF::SpaceConvert(SPACE_POS *pBase, SPACE_POS *pLocal, SPACE_POS *pGlobal)
{
    //----位置轉換
    VectorConvert(&pBase->Coor, &pLocal->Pos, &pGlobal->Pos);
    pGlobal->Pos.X += pBase->Pos.X;
    pGlobal->Pos.Y += pBase->Pos.Y;
    pGlobal->Pos.Z += pBase->Pos.Z;
    SetVectorLen(&pGlobal->Pos);
    //----方向轉換
    VectorConvert(&pBase->Coor, &pLocal->Coor.Nx, &pGlobal->Coor.Nx);
    VectorConvert(&pBase->Coor, &pLocal->Coor.Ny, &pGlobal->Coor.Ny);
    VectorConvert(&pBase->Coor, &pLocal->Coor.Nz, &pGlobal->Coor.Nz);
}

int  SF::SpaceInvert(SPACE_POS *pBase, SPACE_POS *pGlobal, SPACE_POS *pLocal)
{
    int rt;
    //位置轉換
    VECTOR tmpPos;
    tmpPos.X = pGlobal->Pos.X - pBase->Pos.X;
    tmpPos.Y = pGlobal->Pos.Y - pBase->Pos.Y;
    tmpPos.Z = pGlobal->Pos.Z - pBase->Pos.Z;
    SetVectorLen(&tmpPos);
    rt = VectorInvert(&pBase->Coor, &tmpPos, &pLocal->Pos);
    if (rt!=0) return rt;
    //方向轉換 Nx, Ny, Nz
    rt = VectorInvert(&pBase->Coor, &pGlobal->Coor.Nx, &pLocal->Coor.Nx);
    if (rt!=0) return rt;
    rt = VectorInvert(&pBase->Coor, &pGlobal->Coor.Ny, &pLocal->Coor.Ny);
    if (rt!=0) return rt;
    rt = VectorInvert(&pBase->Coor, &pGlobal->Coor.Nz, &pLocal->Coor.Nz);
    if (rt!=0) return rt;
    return 0;
}


void SF::PosConvert2(STANCE *pBase, VECTOR *pLocal, VECTOR *pGlobal)
{
    //----位置轉換
    VectorConvert(&pBase->Coor, pLocal, pGlobal);
    pGlobal->X += pBase->Pos.X;
    pGlobal->Y += pBase->Pos.Y;
    pGlobal->Z += pBase->Pos.Z;
    SetVectorLen(pGlobal);
}

int  SF::PosInvert2(STANCE *pBase, VECTOR *pGlobal, VECTOR *pLocal)
{
    int rt;
    //位置轉換
    VECTOR tmpPos;
    tmpPos.X = pGlobal->X - pBase->Pos.X;
    tmpPos.Y = pGlobal->Y - pBase->Pos.Y;
    tmpPos.Z = pGlobal->Z - pBase->Pos.Z;
    SetVectorLen(&tmpPos);
    rt = VectorInvert(&pBase->Coor, &tmpPos, pLocal);
    return rt;
}


//----區域座標轉全域座標
int SF::StanceConvert(STANCE *pCoor, STANCE *pLocal, STANCE *pGlobal)
{
    //位置轉換 Pos
    VectorConvert(&pCoor->Coor, &pLocal->Pos, &pGlobal->Pos);
    pGlobal->Pos.X += pCoor->Pos.X;
    pGlobal->Pos.Y += pCoor->Pos.Y;
    pGlobal->Pos.Z += pCoor->Pos.Z;
    //附加軸
    memcpy(&pGlobal->AddX, &pLocal->AddX, sizeof(ADD_AXES));
//    pGlobal->AddX.U = pLocal->AddX.U + pCoor->AddX.U;
//    pGlobal->AddX.V = pLocal->AddX.V + pCoor->AddX.V;
//    pGlobal->AddX.W = pLocal->AddX.W + pCoor->AddX.W;
    //方向轉換 Nx, Ny, Nz
    VectorConvert(&pCoor->Coor, &pLocal->Coor.Nx, &pGlobal->Coor.Nx);
    VectorConvert(&pCoor->Coor, &pLocal->Coor.Ny, &pGlobal->Coor.Ny);
    VectorConvert(&pCoor->Coor, &pLocal->Coor.Nz, &pGlobal->Coor.Nz);
    //方向逆轉換
    Coor2Abc(&pGlobal->Coor, &pGlobal->Dir);
    return 0;
}


//----全域座標轉區域座標
int  SF::StanceInvert(STANCE *pCoor, STANCE *pGlobal, STANCE *pLocal)
{
    int rt;
    //位置轉換
    VECTOR tmpPos;
    tmpPos.X = pGlobal->Pos.X - pCoor->Pos.X;
    tmpPos.Y = pGlobal->Pos.Y - pCoor->Pos.Y;
    tmpPos.Z = pGlobal->Pos.Z - pCoor->Pos.Z;
    SetVectorLen(&tmpPos);
    rt = VectorInvert(&pCoor->Coor, &tmpPos, &pLocal->Pos);
    if (rt!=0) return rt;
    //附加軸
    memcpy(&pLocal->AddX, &pGlobal->AddX, sizeof(ADD_AXES));
//    pLocal->AddX.U = pGlobal->AddX.U - pCoor->AddX.U;
//    pLocal->AddX.V = pGlobal->AddX.V - pCoor->AddX.V;
//    pLocal->AddX.W = pGlobal->AddX.W - pCoor->AddX.W;
    //方向轉換 Nx, Ny, Nz
    rt = VectorInvert(&pCoor->Coor, &pGlobal->Coor.Nx, &pLocal->Coor.Nx);
    if (rt!=0) return rt;
    rt = VectorInvert(&pCoor->Coor, &pGlobal->Coor.Ny, &pLocal->Coor.Ny);
    if (rt!=0) return rt;
    rt = VectorInvert(&pCoor->Coor, &pGlobal->Coor.Nz, &pLocal->Coor.Nz);
    if (rt!=0) return rt;
    //
    Coor2Abc(&pLocal->Coor, &pLocal->Dir);
    return 0;
}



////---------------------------------------------------------
//int SF::Set3PCoorCali(STANCE *pP0, STANCE *pP1, STANCE *pP2, AXES_SEL P1Sel, AXES_SEL P2Sel)
//{
//    int rt;
//    COORDINATE Coor, tmpCoor;
//    rt = Set3PCoor(&tmpCoor, &pP0->Pos, &pP1->Pos, &pP2->Pos);
//    if (rt!=0)
//    {
//        pP0->Dir.A = 0;
//        pP0->Dir.B = 0;
//        pP0->Dir.C = 0;
//        return rt;
//    }
//    //變更向量
//    int XFrom, YFrom, ZFrom, XMul, YMul, ZMul;
//    switch (P1Sel)
//    {
//    //+X -- OK
//    case AXES_PX:
//        if      (P2Sel==AXES_PY) { XFrom=1; XMul= 1;  YFrom=2; YMul= 1;  ZFrom=3; ZMul= 1; }
//        else if (P2Sel==AXES_NY) { XFrom=1; XMul= 1;  YFrom=2; YMul=-1;  ZFrom=3; ZMul=-1; }
//        else if (P2Sel==AXES_PZ) { XFrom=1; XMul= 1;  YFrom=3; YMul=-1;  ZFrom=2; ZMul= 1; }
//        else if (P2Sel==AXES_NZ) { XFrom=1; XMul= 1;  YFrom=3; YMul= 1;  ZFrom=2; ZMul=-1; }
//        else                     { XFrom=0; XMul= 1;  YFrom=0; YMul= 1;  ZFrom=0; ZMul= 1; }
//        break;
//    //-X -- OK
//    case AXES_NX:
//        if      (P2Sel==AXES_PY) { XFrom=1; XMul=-1;  YFrom=2; YMul= 1;  ZFrom=3; ZMul=-1; }
//        else if (P2Sel==AXES_NY) { XFrom=1; XMul=-1;  YFrom=2; YMul=-1;  ZFrom=3; ZMul= 1; }
//        else if (P2Sel==AXES_PZ) { XFrom=1; XMul=-1;  YFrom=3; YMul= 1;  ZFrom=2; ZMul= 1; }
//        else if (P2Sel==AXES_NZ) { XFrom=1; XMul=-1;  YFrom=3; YMul=-1;  ZFrom=2; ZMul=-1; }
//        else                     { XFrom=0; XMul= 1;  YFrom=0; YMul= 1;  ZFrom=0; ZMul= 1; }
//        break;
//    //+Y -- OK
//    case AXES_PY:
//        if      (P2Sel==AXES_PZ) { XFrom=3; XMul= 1;  YFrom=1; YMul= 1;  ZFrom=2; ZMul= 1; }
//        else if (P2Sel==AXES_NZ) { XFrom=3; XMul=-1;  YFrom=1; YMul= 1;  ZFrom=2; ZMul=-1; }
//        else if (P2Sel==AXES_PX) { XFrom=2; XMul= 1;  YFrom=1; YMul= 1;  ZFrom=3; ZMul=-1; }
//        else if (P2Sel==AXES_NX) { XFrom=2; XMul=-1;  YFrom=1; YMul= 1;  ZFrom=3; ZMul= 1; }
//        else                     { XFrom=0; XMul= 1;  YFrom=0; YMul= 1;  ZFrom=0; ZMul= 1; }
//        break;
//    //-Y -- OK
//    case AXES_NY:
//        if      (P2Sel==AXES_PZ) { XFrom=3; XMul=-1;  YFrom=1; YMul=-1;  ZFrom=2; ZMul= 1; }
//        else if (P2Sel==AXES_NZ) { XFrom=3; XMul= 1;  YFrom=1; YMul=-1;  ZFrom=2; ZMul=-1; }
//        else if (P2Sel==AXES_PX) { XFrom=2; XMul= 1;  YFrom=1; YMul=-1;  ZFrom=3; ZMul= 1; }
//        else if (P2Sel==AXES_NX) { XFrom=2; XMul=-1;  YFrom=1; YMul=-1;  ZFrom=3; ZMul=-1; }
//        else                     { XFrom=0; XMul= 1;  YFrom=0; YMul= 1;  ZFrom=0; ZMul= 1; }
//        break;
//    //+Z -- OK
//    case AXES_PZ:
//        if      (P2Sel==AXES_PX) { XFrom=2; XMul= 1;  YFrom=3; YMul= 1;  ZFrom=1; ZMul= 1; }
//        else if (P2Sel==AXES_NX) { XFrom=2; XMul=-1;  YFrom=3; YMul=-1;  ZFrom=1; ZMul= 1; }
//        else if (P2Sel==AXES_PY) { XFrom=3; XMul=-1;  YFrom=2; YMul= 1;  ZFrom=1; ZMul= 1; }
//        else if (P2Sel==AXES_NY) { XFrom=3; XMul= 1;  YFrom=2; YMul=-1;  ZFrom=1; ZMul= 1; }
//        else                     { XFrom=0; XMul= 1;  YFrom=0; YMul= 1;  ZFrom=0; ZMul= 1; }
//        break;
//    //-Z -- OK
//    case AXES_NZ:
//        if      (P2Sel==AXES_PX) { XFrom=2; XMul= 1;  YFrom=3; YMul=-1;  ZFrom=1; ZMul=-1; }
//        else if (P2Sel==AXES_NX) { XFrom=2; XMul=-1;  YFrom=3; YMul= 1;  ZFrom=1; ZMul=-1; }
//        else if (P2Sel==AXES_PY) { XFrom=3; XMul= 1;  YFrom=2; YMul= 1;  ZFrom=1; ZMul=-1; }
//        else if (P2Sel==AXES_NY) { XFrom=3; XMul=-1;  YFrom=2; YMul=-1;  ZFrom=1; ZMul=-1; }
//        else                     { XFrom=0; XMul= 1;  YFrom=0; YMul= 1;  ZFrom=0; ZMul= 1; }
//        break;
//    }
//    if (XFrom==1) memcpy(&Coor.Nx, &tmpCoor.Nx, sizeof(VECTOR));
//    if (XFrom==2) memcpy(&Coor.Nx, &tmpCoor.Ny, sizeof(VECTOR));
//    if (XFrom==3) memcpy(&Coor.Nx, &tmpCoor.Nz, sizeof(VECTOR));
//    if (YFrom==1) memcpy(&Coor.Ny, &tmpCoor.Nx, sizeof(VECTOR));
//    if (YFrom==2) memcpy(&Coor.Ny, &tmpCoor.Ny, sizeof(VECTOR));
//    if (YFrom==3) memcpy(&Coor.Ny, &tmpCoor.Nz, sizeof(VECTOR));
//    if (ZFrom==1) memcpy(&Coor.Nz, &tmpCoor.Nx, sizeof(VECTOR));
//    if (ZFrom==2) memcpy(&Coor.Nz, &tmpCoor.Ny, sizeof(VECTOR));
//    if (ZFrom==3) memcpy(&Coor.Nz, &tmpCoor.Nz, sizeof(VECTOR));
//    Coor.Nx.X *= XMul;
//    Coor.Nx.Y *= XMul;
//    Coor.Nx.Z *= XMul;
//    Coor.Ny.X *= YMul;
//    Coor.Ny.Y *= YMul;
//    Coor.Ny.Z *= YMul;
//    Coor.Nz.X *= ZMul;
//    Coor.Nz.Y *= ZMul;
//    Coor.Nz.Z *= ZMul;
//    return Coor2Abc(&Coor, &pP0->Dir);
//}



////------------------------------------------------------------------------------
//int SF::Set2VCoor(COORDINATE *pCoor, VECTOR *pVx, VECTOR *pVy)
//{
//    if (pVx->L<0.002) return 3;
//    if (pVy->L<0.002) return 3;
//    memcpy(&pCoor->Nx, pVx, sizeof(VECTOR));
//    NormalizeVector(&pCoor->Nx);
//    SetVectorCross(&pCoor->Nx, pVy, &pCoor->Nz);
//    if (pCoor->Nz.L<0.002) return 3;
//    NormalizeVector(&pCoor->Nz);
//    SetVectorCross(&pCoor->Nz, &pCoor->Nx, &pCoor->Ny);
//    return 0;
//}


////------------------------------------------------------------------------------
//int SF::Set3PCoor(COORDINATE *pCoor, VECTOR *p0, VECTOR *p1, VECTOR *p2)
//{
//    VECTOR Vx, Vxy;
//    SetVector(p0, p1, &Vx);
//    SetVector(p0, p2, &Vxy);
//    return Set2VCoor(pCoor, &Vx, &Vxy);
//}


//------------------------------------------------------------------------------
// ABC角度轉為姿態座標系
int SF::Abc2Coor(POSTURE *pPosture, COORDINATE *pCoor)
{
    if      (mEulerType==0) return Zxz2Coor(pPosture, pCoor);  //ZXZ
    else if (mEulerType==1) return Zyz2Coor(pPosture, pCoor);  //ZYZ
    else if (mEulerType==2) return Zyx2Coor(pPosture, pCoor);  //ZYX
    else if (mEulerType==3) return Xyz2Coor(pPosture, pCoor);  //XYZ
    return -2;
}

//------------------------------------------------------------------------------
// 姿態座標系轉為ABC角度
int SF::Coor2Abc(COORDINATE *pCoor, POSTURE *pPosture)
{
    if      (mEulerType==0) return Coor2Zxz(pCoor, pPosture);  //ZXZ
    else if (mEulerType==1) return Coor2Zyz(pCoor, pPosture);  //ZYZ
    else if (mEulerType==2) return Coor2Zyx(pCoor, pPosture);  //ZYX
    else if (mEulerType==3) return Coor2Xyz(pCoor, pPosture);  //XYZ
    return -2;
}

//------------------------------------------------------------------------------
int SF::Zxz2Coor(POSTURE *pPosture, COORDINATE *pCoor)
{
    double wA = pPosture->A*PI/180;
    double wB = pPosture->B*PI/180;
    double wC = pPosture->C*PI/180;
    COORDINATE tmpCoor;
    //pCoor->Nz
    tmpCoor.Nz.X = sin(wB)*sin(wA);
    tmpCoor.Nz.Y = sin(wB)*cos(wA)*(-1);
    tmpCoor.Nz.Z = cos(wB);
    SetVectorLen(&tmpCoor.Nz);
    memcpy(&pCoor->Nz, &tmpCoor.Nz, sizeof(VECTOR));

    //Nx
    tmpCoor.Nx.X = cos(wA);
    tmpCoor.Nx.Y = sin(wA);
    tmpCoor.Nx.Z = 0;
    tmpCoor.Nx.L = 1;
    //Ny
    SetVectorCross(&tmpCoor.Nz, &tmpCoor.Nx, &tmpCoor.Ny);

    //pCoor->Nx
    VECTOR VX;
    VX.X = cos(wC);
    VX.Y = sin(wC);
    VX.Z = 0;
    VX.L = 1;
    VectorConvert(&tmpCoor, &VX, &pCoor->Nx);
    SetVectorCross(&pCoor->Nz, &pCoor->Nx, &pCoor->Ny);
    return 0;
}


//------------------------------------------------------------------------------
int SF::Coor2Zxz(COORDINATE *pCoor, POSTURE *pPosture)
{
    //----------------ABC座標轉換
    double wA, wB, wC;
    //--------B
    if      (pCoor->Nz.Z>1) pCoor->Nz.Z=1;
    else if (pCoor->Nz.Z<-1) pCoor->Nz.Z=-1;
    wB = acos(pCoor->Nz.Z);
    if ((wB<0.001)||(wB>(PI-0.001)))
    {
        wA = 0;
        //wA = pPosture->A * 180/PI;
        if (pCoor->Nx.X==0)
        {
            if (pCoor->Nx.Y>0) wC = PI/2;
            else               wC = -PI/2;
        }
        else
        {
            wC = atan(pCoor->Nx.Y/pCoor->Nx.X);
        }
        if (pCoor->Nx.X<0) wC+=PI;

        if      (wC>PI) wC-=(2*PI);
        else if (wC<-PI) wC+=(2*PI);
        if      (wC>PI) wC-=(2*PI);
        else if (wC<-PI) wC+=(2*PI);
        if (wB > PI/2) wC *= (-1);
    }
    else
    {
        if (pCoor->Nz.Y==0)
        {
            if (pCoor->Nz.X>0) wA = PI/2;
            else               wA = -PI/2;
        }
        else
        {
            wA = atan(pCoor->Nz.X/pCoor->Nz.Y*(-1));
            if (pCoor->Nz.Y>0) wA+=PI;
            if (wA>PI) wA -= (2*PI);
        }
        //Nx
        VECTOR Nx;
        Nx.X = cos(wA);
        Nx.Y = sin(wA);
        Nx.Z = 0;
        Nx.L = 1;
        // A*B = |A||B|cos(c)
        wC = GetVectorAngle2(&Nx, &pCoor->Nx, &pCoor->Nz);
    }
    pPosture->A = wA*180/PI;
    pPosture->B = wB*180/PI;
    pPosture->C = wC*180/PI;
    return 0;
}




//------------------------------------------------------------------------------
int SF::Zyz2Coor(POSTURE *pPosture, COORDINATE *pCoor)
{
    double wA = pPosture->A*PI/180;
    double wB = pPosture->B*PI/180;
    double wC = pPosture->C*PI/180;
    COORDINATE tmpCoor;
    //pCoor->Nz
    tmpCoor.Nz.X = sin(wB)*cos(wA);
    tmpCoor.Nz.Y = sin(wB)*sin(wA);
    tmpCoor.Nz.Z = cos(wB);
    SetVectorLen(&tmpCoor.Nz);
    memcpy(&pCoor->Nz, &tmpCoor.Nz, sizeof(VECTOR));

    //Ny
    tmpCoor.Ny.X = -sin(wA);
    tmpCoor.Ny.Y = cos(wA);
    tmpCoor.Ny.Z = 0;
    tmpCoor.Ny.L = 1;
    //Nx
    SetVectorCross(&tmpCoor.Ny, &tmpCoor.Nz, &tmpCoor.Nx);

    //pCoor->Nx
    VECTOR VX;
    VX.X = cos(wC);
    VX.Y = sin(wC);
    VX.Z = 0;
    VX.L = 1;
    VectorConvert(&tmpCoor, &VX, &pCoor->Nx);
    SetVectorCross(&pCoor->Nz, &pCoor->Nx, &pCoor->Ny);
    return 0;
}


//------------------------------------------------------------------------------
int SF::Coor2Zyz(COORDINATE *pCoor, POSTURE *pPosture)
{
    double wA, wB, wC;
    //--------B
    if      (pCoor->Nz.Z>1) pCoor->Nz.Z=1;
    else if (pCoor->Nz.Z<-1) pCoor->Nz.Z=-1;
    wB = acos(pCoor->Nz.Z);
    if ((wB<0.001)||(wB>(PI-0.001)))
    {
        wA = 0;
        if (pCoor->Nx.X==0)
        {
            if (pCoor->Nx.Y>0) wC = PI/2;
            else               wC = -PI/2;
        }
        else
        {
            wC = atan(pCoor->Nx.Y/pCoor->Nx.X);
        }
        if (pCoor->Nx.X<0) wC+=PI;

        if      (wC>PI) wC-=(2*PI);
        else if (wC<-PI) wC+=(2*PI);
        if      (wC>PI) wC-=(2*PI);
        else if (wC<-PI) wC+=(2*PI);
        if (wB > PI/2) wC *= (-1);
    }
    else
    {
        if (pCoor->Nz.Y==0)
        {
            if (pCoor->Nz.X>0) wA = 0;
            else               wA = PI;
        }
        else
        {
            wA = atan(pCoor->Nz.Y/pCoor->Nz.X);
            if (pCoor->Nz.X<0) wA+=PI;
            if (wA>PI) wA -= (2*PI);
        }
        //Ny
        VECTOR Ny;
        Ny.X = -sin(wA);
        Ny.Y = cos(wA);
        Ny.Z = 0;
        Ny.L = 1;
        // A*B = |A||B|cos(c)
        wC = GetVectorAngle2(&Ny, &pCoor->Ny, &pCoor->Nz);
    }
    pPosture->A = wA*180/PI;
    pPosture->B = wB*180/PI;
    pPosture->C = wC*180/PI;
    return 0;
}


//------------------------------------------------------------------------------
int SF::Zyx2Coor(POSTURE *pPosture, COORDINATE *pCoor)
{
    COORDINATE CoorA, CoorB, CoorC, CoorAB;
    SetRotateZCoor(pPosture->A, &CoorA);
    SetRotateYCoor(pPosture->B, &CoorB);
    CoorConvert(&CoorA, &CoorB, &CoorAB);
    SetRotateXCoor(pPosture->C, &CoorC);
    CoorConvert(&CoorAB, &CoorC, pCoor);
    return 0;
}

//------------------------------------------------------------------------------
int SF::Coor2Zyx(COORDINATE *pCoor, POSTURE *pPosture)
{
    double wA, wB, wC;
    //--------A
    wA = GetXAngle(pCoor->Nx.X, pCoor->Nx.Y);
    //--------B
    if      (pCoor->Nx.Z>1) pCoor->Nx.Z=1;
    else if (pCoor->Nx.Z<-1) pCoor->Nx.Z=-1;
    wB = -asin(pCoor->Nx.Z);
    //-------C
    pPosture->A = wA*180/PI;
    pPosture->B = wB*180/PI;
    COORDINATE CoorA, CoorB, CoorC, CoorAB;
    SetRotateZCoor(pPosture->A, &CoorA);
    SetRotateYCoor(pPosture->B, &CoorB);
    CoorConvert(&CoorA, &CoorB, &CoorAB);
    CoorInvert(&CoorAB, pCoor, &CoorC);
    wC = GetXAngle(CoorC.Ny.Y, CoorC.Ny.Z);
    pPosture->C = wC*180/PI;
    return 0;
}


//------------------------------------------------------------------------------
int SF::Xyz2Coor(POSTURE *pPosture, COORDINATE *pCoor)
{
    COORDINATE CoorA, CoorB, CoorC, CoorAB;
    SetRotateXCoor(pPosture->A, &CoorA);
    SetRotateYCoor(pPosture->B, &CoorB);
    CoorConvert(&CoorA, &CoorB, &CoorAB);
    SetRotateZCoor(pPosture->C, &CoorC);
    CoorConvert(&CoorAB, &CoorC, pCoor);
    return 0;
}

//------------------------------------------------------------------------------
int SF::Coor2Xyz(COORDINATE *pCoor, POSTURE *pPosture)
{
    double wA, wB, wC;
    //--------A
    wA = GetXAngle(pCoor->Nz.Z, -pCoor->Nz.Y);
    //--------B
    if      (pCoor->Nz.X>1) pCoor->Nz.X=1;
    else if (pCoor->Nz.X<-1) pCoor->Nz.X=-1;
    wB = asin(pCoor->Nz.X);
    //-------C
    pPosture->A = wA*180/PI;
    pPosture->B = wB*180/PI;
    COORDINATE CoorA, CoorB, CoorC, CoorAB;
    SetRotateXCoor(pPosture->A, &CoorA);
    SetRotateYCoor(pPosture->B, &CoorB);
    CoorConvert(&CoorA, &CoorB, &CoorAB);
    CoorInvert(&CoorAB, pCoor, &CoorC);
    wC = GetXAngle(CoorC.Nx.X, CoorC.Nx.Y);
    pPosture->C = wC*180/PI;
    return 0;
}



////------------------------------------------------------------------------------
////計算姿態變化的改變資料
//int SF::SetCoorChangeForLine(COORDINATE_CHANGE *pCoorC, COORDINATE *pSrc, COORDINATE *pTgr)
//{
//    memcpy(&pCoorC->StCoor, pSrc, sizeof(COORDINATE));
//    COORDINATE LoTgr;
//    CoorInvert(pSrc, pTgr, &LoTgr);
//    Coor2Zxz(&LoTgr, &pCoorC->DirTgr);

//    pCoorC->DirSrc.A = pCoorC->DirTgr.A;
//    pCoorC->DirSrc.B = 0;
//    pCoorC->DirSrc.C = -pCoorC->DirSrc.A;

//    pCoorC->DirCg.A = NormalAngle(pCoorC->DirTgr.A - pCoorC->DirSrc.A);
//    pCoorC->DirCg.B = NormalAngle(pCoorC->DirTgr.B - pCoorC->DirSrc.B);
//    pCoorC->DirCg.C = NormalAngle(pCoorC->DirTgr.C - pCoorC->DirSrc.C);

//    pCoorC->NzAngle = pCoorC->DirCg.B;
//    pCoorC->NxAngle = pCoorC->DirCg.C;

//    //printf("pCoorC->DirCg A=%.3f B=%.3f C=%.3f\n", pCoorC->DirCg.A, pCoorC->DirCg.B, pCoorC->DirCg.C);
//    return 0;
//}


////------------------------------------------------------------------------------
////計算姿態變化的改變資料
//int SF::SetCoorChangeForCurve(COORDINATE_CHANGE *pCoorC, COORDINATE *pSrc, COORDINATE *pTgr, COORDINATE *pCurve)
//{
//    memcpy(&pCoorC->StCoor, pCurve, sizeof(COORDINATE));
//    COORDINATE Lo2Src, Lo2Tgr;
//    CoorInvert(pCurve, pSrc, &Lo2Src);
//    CoorInvert(pCurve, pTgr, &Lo2Tgr);
//    Coor2Zxz(&Lo2Src, &pCoorC->DirSrc);
//    Coor2Zxz(&Lo2Tgr, &pCoorC->DirTgr);

//    if (pCoorC->DirTgr.B<0.001)
//    {
//        pCoorC->DirTgr.C += pCoorC->DirTgr.A;
//        pCoorC->DirTgr.C -= pCoorC->DirSrc.A;
//        pCoorC->DirTgr.A = pCoorC->DirSrc.A;
//    }
//    else if (pCoorC->DirSrc.B<0.001)
//    {
//        pCoorC->DirSrc.C += pCoorC->DirSrc.A;
//        pCoorC->DirSrc.C -= pCoorC->DirTgr.A;
//        pCoorC->DirSrc.A = pCoorC->DirTgr.A;
//    }
//    //----計算C軸旋轉角
//    COORDINATE LoTgr;
//    POSTURE    LoDir;
//    CoorInvert(pSrc, pTgr, &LoTgr);
//    Coor2Zxz(&LoTgr, &LoDir);
//    //----計算方向變化的值
//    pCoorC->DirCg.A = NormalAngle(pCoorC->DirTgr.A - pCoorC->DirSrc.A);
//    pCoorC->DirCg.B = NormalAngle(pCoorC->DirTgr.B - pCoorC->DirSrc.B);
//    pCoorC->DirCg.C = NormalAngle(pCoorC->DirTgr.C - pCoorC->DirSrc.C);
//    //printf("before pCoorC->DirCg A=%.3f B=%.3f C=%.3f\n", pCoorC->DirCg.A, pCoorC->DirCg.B, pCoorC->DirCg.C);
//    if (pCoorC->DirCg.A<-5.0)
//    {
//        pCoorC->DirCg.A+=360;
//        pCoorC->DirCg.C-=360;
//    }
//    //printf(" after pCoorC->DirCg A=%.3f B=%.3f C=%.3f\n", pCoorC->DirCg.A, pCoorC->DirCg.B, pCoorC->DirCg.C);
//    pCoorC->NzAngle = GetVectorAngle1(&pSrc->Nz, &pTgr->Nz)*180/PI;
//    pCoorC->NxAngle = pCoorC->DirCg.C;
//    return 0;
//}



////------------------------------------------------------------------------------
//int SF::SetCoorValue(COORDINATE_CHANGE *pCoorC, double ChangeRatio, COORDINATE *pCoor)
//{
//    POSTURE CgDir;
//    COORDINATE CgCoor;
//    CgDir.A = pCoorC->DirSrc.A + ChangeRatio*pCoorC->DirCg.A;
//    CgDir.B = pCoorC->DirSrc.B + ChangeRatio*pCoorC->DirCg.B;
//    CgDir.C = pCoorC->DirSrc.C + ChangeRatio*pCoorC->DirCg.C;
//    Zxz2Coor(&CgDir, &CgCoor);
//    CoorConvert(&pCoorC->StCoor, &CgCoor, pCoor);
//    return 0;
//}



////------------------------------------------
////--推導 水平面三點的直交點與P1,P2的方向角
//int SF::CalHorizontal3P_XYC(VECTOR *pP1, VECTOR *pP2, VECTOR *pP3, VECTOR *pPc, double *Ang)
//{
//    VECTOR P1, P2, P3, V12, V13;
//    memcpy(&P1, pP1, sizeof(VECTOR)); P1.Z=0;
//    memcpy(&P2, pP2, sizeof(VECTOR)); P2.Z=0;
//    memcpy(&P3, pP3, sizeof(VECTOR)); P3.Z=0;
//    SF::SetVector(&P1, &P2, &V12);
//    SF::SetVector(&P1, &P3, &V13);
//    //-----交點座標與旋轉
//    double A1 = SF::GetVectorAngle0(&V12, &V13);
//    double L1 = V13.L * cos(A1);
//    pPc->X = P1.X + L1*V12.X/V12.L;
//    pPc->Y = P1.Y + L1*V12.Y/V12.L;
//    pPc->Z = P1.Z + L1*V12.Z/V12.L;
//    double Ang1 = SF::GetXAngle(V12.X, V12.Y)*180/PI;
//    int n = Ang1/90;
//    Ang1 -= (90*n);
//    if (Ang1>45) Ang1-=90;
//    if (Ang1<=-45) Ang1+=90;
//    *Ang = Ang1;
//    return 0;
//}

////------------------------------------------
//int SF::CalLineCross(VECTOR *p1, VECTOR *p2, VECTOR *p3, VECTOR *p4, VECTOR *pc)
//{
//    double a, b, p;
//    double c, d, q;
//    a = p2->Y - p1->Y;
//    b = p1->X - p2->X;
//    p = a*p2->X + b*p2->Y;

//    c = p4->Y - p3->Y;
//    d = p3->X - p4->X;
//    q = c*p4->X + d*p4->Y;
//    //printf("a=%f b=%f p=%f\n", a, b, p);
//    //printf("c=%f d=%f q=%f\n", c, d, q);

//    double delta = a*d - b*c;
//    if (delta==0) return 777;
//    pc->X = (d*p-b*q)/delta;
//    pc->Y = (a*q-c*p)/delta;
//    pc->Z = 0;
//    //printf("X=%f Y=%f Z=%f\n", pc->X, pc->Y, pc->Z);
//    return 0;
//}



////------------------------------------------
//int SF::CalLineCross3D(VECTOR *p1, VECTOR *p2, VECTOR *p3, VECTOR *p4, SPACE_POS *SP)
//{
//    VECTOR V12, V34;
//    VECTOR cP3, cP4;
//    SetVector(p1, p2, &V12);
//    SetVector(p3, p4, &V34);
//    memcpy(&SP->Pos, p1, sizeof(VECTOR));
//    Set2VCoor(&SP->Coor, &V12, &V34);
//    PosInvert(SP, p3, &cP3);
//    PosInvert(SP, p4, &cP4);
//    double Y34 = cP4.Y - cP3.Y;
//    double Y3c = cP3.Y;
//    VECTOR P2D, P3D;
//    P2D.X = cP3.X - (cP4.X - cP3.X)/Y34*Y3c;
//    P2D.Y = 0;
//    P2D.Z = 0;
//    PosConvert(SP, &P2D, &P3D);
//    //----移到投影交點上
//    memcpy(&SP->Pos, &P3D, sizeof(VECTOR));
//    return 0;
//}
