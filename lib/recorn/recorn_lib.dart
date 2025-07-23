// ignore_for_file: camel_case_types, non_constant_identifier_names

import 'dart:ffi'; // For FFI
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'recorn_bindings.dart';

// 讀取 librecorn
final DynamicLibrary RecornLib = Platform.isAndroid
    ? DynamicLibrary.open('librecorn.so')
    : DynamicLibrary.process();

// 定義行別，可參考公司 PDF
typedef Native_LibraryInitial = Int Function(
    Pointer<DLL_USE_SETTING>, Int x, Pointer<Utf8> y); // 型別一定要與來源(.so)的函式名稱相同
typedef FFI_LibraryInitial = int Function(
    Pointer<DLL_USE_SETTING>, int x, Pointer<Utf8> y);

typedef Native_ConnectLocalIP = Int Function(Int x, Pointer<Utf8> y);
typedef FFI_ConnectLocalIP = int Function(int x, Pointer<Utf8> y);

typedef Native_GetConnectionMsg = Int Function(Int x, Int y);
typedef FFI_GetConnectionMsg = int Function(int x, int y);

typedef Native_Disconnect = Int Function(Int x);
typedef FFI_Disconnect = int Function(int x);

typedef Native_LibraryDestroy = Void Function();
typedef FFI_LibraryDestroy = void Function();

typedef Native_MainProcess = Int32 Function();
typedef FFI_MainProcess = int Function();

typedef Native_DWrite1R = Int32 Function(Int32, Int32, Int32);
typedef FFI_DWrite1R = int Function(int, int, int);

typedef Native_DWrite1O = Int32 Function(Int32, Int32, Int32);
typedef FFI_DWrite1O = int Function(int, int, int);

typedef Native_DWrite1RBit = Int32 Function(Int32, Int32, Int32, Int32);
typedef FFI_DWrite1RBit = int Function(int, int, int, int);

typedef Native_DReadBegin = Int32 Function(Int32);
typedef FFI_DReadBegin = int Function(int);

typedef Native_DReadEnd = Int32 Function(Int32);
typedef FFI_DReadEnd = int Function(int);

typedef Native_DWriteBegin = Int32 Function(Int32);
typedef FFI_DWriteBegin = int Function(int);

typedef Native_DWriteEnd = Int32 Function(Int32);
typedef FFI_DWriteEnd = int Function(int);

typedef Native_DReadNI = Int32 Function(Int32, Int32, Int32);
typedef FFI_DReadNI = int Function(int, int, int);

typedef Native_DReadNR = Int32 Function(Int32, Int32, Int32);
typedef FFI_DReadNR = int Function(int, int, int);

typedef Native_DWaitDone = Int32 Function(Int32, Int32);
typedef FFI_DWaitDone = int Function(int, int);

typedef Native_DClearQueue = Int32 Function(Int32);
typedef FFI_DClearQueue = int Function(int);

typedef Native_LWriteNR = Int32 Function(Int32, Int32, Int32);
typedef FFI_LWriteNR = int Function(int, int, int);

typedef Native_LWriteBegin = Void Function(Int32);
typedef FFI_LWriteBegin = void Function(int);

typedef Native_LWriteEnd = Int32 Function(Int32);
typedef FFI_LWriteEnd = int Function(int);

typedef Native_LReadNR = Int32 Function(Int32, Int32, Int32);
typedef FFI_LReadNR = int Function(int, int, int);

typedef Native_LReadBegin = Int32 Function(Int32);
typedef FFI_LReadBegin = int Function(int);

typedef Native_LReadEnd = Int32 Function(Int32);
typedef FFI_LReadEnd = int Function(int);

typedef Native_LClearQueue = Int32 Function(Int32);
typedef FFI_LClearQueue = int Function(int);

typedef Native_memR = Int32 Function(Int32, Int32);
typedef FFI_memR = int Function(int, int);

typedef Native_memW = Int32 Function(Int32, Int32);
typedef FFI_memW = int Function(int, int);

typedef Native_memRBit = Int32 Function(Int32, Int32, Int32);
typedef FFI_memRBit = int Function(int, int, int);

typedef Native_memI = Int32 Function(Int32, Int32);
typedef FFI_memI = int Function(int, int);

typedef Native_memRString = Int32 Function(Int32, Int32, Int32, Pointer<Int8>);
typedef FFI_memRString = int Function(int, int, int, Pointer<Int8>);

typedef Native_memSetR = Int32 Function(Int32, Int32, Int32);
typedef FFI_memSetR = int Function(int, int, int);

typedef Native_LocalDetectControllers = Int32 Function();
typedef FFI_LocalDetectControllers = int Function();

typedef Native_LocalReadControllerCount = Int32 Function();
typedef FFI_LocalReadControllerCount = int Function();

typedef Native_LocalReadController = Int32 Function(
    Int32, Pointer<LOCAL_CONTROLLER_INFO>);
typedef FFI_LocalReadController = int Function(
    int, Pointer<LOCAL_CONTROLLER_INFO>);

// howting額外寫的
typedef Native_DReadNO = Int32 Function(Int32, Int32, Int32);
typedef FFI_DReadNO = int Function(int, int, int);

typedef Native_LReadNI = Int32 Function(Int32, Int32, Int32);
typedef FFI_LReadNI = int Function(int, int, int);

typedef Native_LReadNO = Int32 Function(Int32, Int32, Int32);
typedef FFI_LReadNO = int Function(int, int, int);

// 定義函式
final FFI_LibraryInitial LibraryInitial =
    RecornLib.lookup<NativeFunction<Native_LibraryInitial>>(
            'LibraryInitial') // 括弧內的名稱一定要與來源(.so)的函式名稱相同
        .asFunction();
// 結束
final FFI_LibraryDestroy LibraryDestroy =
    RecornLib.lookup<NativeFunction<Native_LibraryDestroy>>('LibraryDestroy')
        .asFunction();
// 直接連線到指定IP的控制器
final FFI_ConnectLocalIP ConnectLocalIP =
    RecornLib.lookup<NativeFunction<Native_ConnectLocalIP>>('ConnectLocalIP')
        .asFunction();
// 取得連線資訊
final FFI_GetConnectionMsg GetConnectionMsg =
    RecornLib.lookup<NativeFunction<Native_GetConnectionMsg>>(
            'GetConnectionMsg')
        .asFunction();
// 中斷連線
final FFI_Disconnect Disconnect =
    RecornLib.lookup<NativeFunction<Native_Disconnect>>('Disconnect')
        .asFunction();
// 呼叫函示庫主程序
final FFI_MainProcess MainProcess =
    RecornLib.lookup<NativeFunction<Native_MainProcess>>('MainProcess')
        .asFunction();
//
final FFI_DWrite1R DWrite1R =
    RecornLib.lookup<NativeFunction<Native_DWrite1R>>('DWrite1R').asFunction();

final FFI_DWrite1RBit DWrite1RBit =
    RecornLib.lookup<NativeFunction<Native_DWrite1RBit>>('DWrite1RBit')
        .asFunction();
final FFI_DWrite1O DWrite1O =
     RecornLib.lookup<NativeFunction<Native_DWrite1R>>('DWrite1O').asFunction();
final FFI_DReadBegin DReadBegin =
    RecornLib.lookup<NativeFunction<Native_DReadBegin>>('DReadBegin')
        .asFunction();

final FFI_DReadEnd DReadEnd =
    RecornLib.lookup<NativeFunction<Native_DReadEnd>>('DReadEnd').asFunction();

final FFI_DReadNR DReadNR =
    RecornLib.lookup<NativeFunction<Native_DReadNR>>('DReadNR').asFunction();

final FFI_DReadNI DReadNI =
    RecornLib.lookup<NativeFunction<Native_DReadNI>>('DReadNI').asFunction();

final FFI_DWaitDone DWaitDone =
    RecornLib.lookup<NativeFunction<Native_DWaitDone>>('DWaitDone')
        .asFunction();

final FFI_DWriteEnd DWriteEnd =
RecornLib.lookup<NativeFunction<Native_DWriteEnd>>('DWriteEnd')
    .asFunction();

final FFI_DClearQueue DClearQueue =
    RecornLib.lookup<NativeFunction<Native_DClearQueue>>('DClearQueue')
        .asFunction();

final FFI_LWriteNR LWriteNR =
    RecornLib.lookup<NativeFunction<Native_LWriteNR>>('LWriteNR').asFunction();

final FFI_LWriteBegin LWriteBegin =
    RecornLib.lookup<NativeFunction<Native_LWriteBegin>>('LWriteBegin')
        .asFunction();

final FFI_LWriteEnd LWriteEnd =
    RecornLib.lookup<NativeFunction<Native_LWriteEnd>>('LWriteEnd')
        .asFunction();

final FFI_LReadNR LReadNR =
    RecornLib.lookup<NativeFunction<Native_LReadNR>>('LReadNR').asFunction();

final FFI_LReadBegin LReadBegin =
    RecornLib.lookup<NativeFunction<Native_LReadBegin>>('LReadBegin')
        .asFunction();

final FFI_LReadEnd LReadEnd =
    RecornLib.lookup<NativeFunction<Native_LReadEnd>>('LReadEnd').asFunction();

final FFI_LClearQueue LClearQueue =
    RecornLib.lookup<NativeFunction<Native_LClearQueue>>('LClearQueue')
        .asFunction();

final FFI_memR memR =
    RecornLib.lookup<NativeFunction<Native_memR>>('memR').asFunction();

final FFI_memW memW =
RecornLib.lookup<NativeFunction<Native_memW>>('memW').asFunction();

final FFI_memRBit memRBit =
    RecornLib.lookup<NativeFunction<Native_memRBit>>('memRBit').asFunction();

final FFI_memRString memRString =
    RecornLib.lookup<NativeFunction<Native_memRString>>('memRString')
        .asFunction();
final FFI_memSetR memSetR =
    RecornLib.lookup<NativeFunction<Native_memSetR>>('memSetR').asFunction();

final FFI_memI memI =
    RecornLib.lookup<NativeFunction<Native_memR>>('memI').asFunction();
final FFI_memI memO =
    RecornLib.lookup<NativeFunction<Native_memR>>('memO').asFunction();
final FFI_LocalDetectControllers LocalDetectControllers =
    RecornLib.lookup<NativeFunction<Native_LocalDetectControllers>>(
            'LocalDetectControllers')
        .asFunction();

final FFI_LocalReadControllerCount LocalReadControllerCount =
    RecornLib.lookup<NativeFunction<Native_LocalReadControllerCount>>(
            'LocalReadControllerCount')
        .asFunction();

final FFI_LocalReadController LocalReadController =
    RecornLib.lookup<NativeFunction<Native_LocalReadController>>(
            'LocalReadController')
        .asFunction();

// howting修改
final FFI_DReadNO DReadNO =
    RecornLib.lookup<NativeFunction<Native_DReadNO>>('DReadNO').asFunction();

final FFI_LReadNO LReadNO =
    RecornLib.lookup<NativeFunction<Native_LReadNO>>('LReadNO').asFunction();

final FFI_LReadNI LReadNI =
    RecornLib.lookup<NativeFunction<Native_LReadNI>>('LReadNI').asFunction();

final FFI_DWriteBegin DWriteBegin =
      RecornLib.lookup<NativeFunction<Native_DWriteBegin>>('DWriteBegin').asFunction();