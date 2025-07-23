//---------------------------------------------------------------------------

#ifndef SpaceDefineH
#define SpaceDefineH

//#include <unistd.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>                                 
#include <math.h>

#define PI   3.14159265358979
#define MULV 100000

//-------------------與專用機構相關的宣告
struct MOTOR_POS    //馬達座標
{
    double M[9];
};

struct JOINT_POS    //關節座標
{
    double J[9];
};

struct VECTOR     //位置、向量
{
    double X;
    double Y;
    double Z;
    double L;
};

struct COORDINATE    //座標系
{
    VECTOR Nx;
    VECTOR Ny;
    VECTOR Nz;
};


struct POSTURE
{
    double A;
    double B;
    double C;
};
      
struct ADD_AXES     //附屬軸
{
    double U;
    double V;
    double W;
};

struct SPACE_POS
{
    VECTOR     Pos;
    COORDINATE Coor;
};

struct STANCE    //座姿
{
    VECTOR     Pos;
    COORDINATE Coor;
    POSTURE    Dir;
    ADD_AXES   AddX;
};

//---------------------------------------------------------------------------
#endif
