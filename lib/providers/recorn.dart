// ignore_for_file: non_constant_identifier_names

import 'dart:ffi';
import 'dart:async';
import 'dart:isolate';
import 'package:ffi/ffi.dart';
import 'package:flutter/cupertino.dart';
import 'package:lnc_mach_app/providers/connection.dart';
import 'package:lnc_mach_app/recorn/recorn_lib.dart' as rl;
import 'package:lnc_mach_app/recorn/recorn_bindings.dart';

class Recorn with ChangeNotifier {
  // Isolate: define isolate as global
  Isolate? _mpIsolate;
  // Class: get native setting class from recorn lib
  Pointer<DLL_USE_SETTING> setting =
      calloc.call(); // calloc 會把記憶體初始為 0, 但是 malloc 不會
  Pointer<LOCAL_CONTROLLER_INFO> info = calloc.call();
  final Pointer<Utf8> EN_CHAR = ConnectionProvider().getEnChar().toNativeUtf8();
  final int FACTORY_ID = ConnectionProvider().getFactoryID();
  // bool: for clear test connection while loop
  bool isTestingConnection = true;

  // Functoin: call main process with loop, because of isolate, must be static
  static void _mainp(int x) {
    Duration period = const Duration(milliseconds: 20);
    Timer.periodic(period, (timer) {
      rl.MainProcess();
    });
  }

  // Function: isolate the main process
  Future<void> initIsolate() async {
    _mpIsolate = await Isolate.spawn(_mainp, 0);
  }

  // Function: clean Isolate
  void cleanIsolate() async {
    // 清除 MainProcess
    if (_mpIsolate == null) return;
    await Future.delayed(const Duration(seconds: 1));
    _mpIsolate!.kill(priority: Isolate.immediate);
  }

  // Function: init the recorn libray, must be call at app init
  int LibraryInit() {
    // init setting
    setting.ref
      ..SoftwareType = 4
      ..ConnectNum = 1
      ..MemSizeI = 0
      ..MemSizeO = 0
      ..MemSizeC = 0
      ..MemSizeS = 0
      ..MemSizeA = 0
      ..MemSizeR = 4000000
      ..MemSizeF = 0
      ..MemSizeTimer = 0
      ..MemSizeCounter = 0;

    return rl.LibraryInitial(setting, FACTORY_ID, EN_CHAR);
  }

  // Function: to clear loop queue from Recorn lib
  void LClearQueue() {
    rl.LClearQueue(0);
  }

  // Function: to clear direct queue from Recorn lib
  void DClearQueue() {
    rl.DClearQueue(0);
  }

  void DWaitDone(milliseconds) {
    rl.DWaitDone(0, milliseconds);
  }
  void DWriteEnd(){
    rl.DWriteEnd(10000);
  }
}

// Recorn: for R value write functions
extension RecornWrite on Recorn {
  int LWriteNR(int R, int RSize) {
    return rl.LWriteNR(0, R, RSize);
  }

  void LWriteBegin() {
    rl.LWriteBegin(0);
  }

  int LWriteEnd() {
    return rl.LWriteEnd(0);
  }

  int DWriteR(int R, value) {
    return rl.DWrite1R(0, R, value);
  }
  int DWriteO(int R, value) {
    return rl.DWrite1O(0, R, value);
  }
  int DWriteBegin(value){
    return rl.DWriteBegin(value);

  }

  int DWriteRBit(int R, int bitIdx, int bitValue) {
    return rl.DWrite1RBit(0, R, bitIdx, bitValue);
  }

  int memSetR(int R, int value) {
    return rl.memSetR(0, R, value);
  }

  // Async Function: Write RBit directly
  Future<void> dWrite1RBit(int R, int bitIdx, int bitValue) async {
    int pTran = 0;
    while (pTran == 0) {
      // repeat until DReadNR(0, R, 1) returns a value > 0
      await Future.delayed(const Duration(milliseconds: 60), () {
        pTran = rl.DWrite1RBit(0, R, bitIdx, bitValue);
      });
    }
  }
}

// Recorn: for R value read functions
extension RecornRead on Recorn {
  // Function: read list of R value in loop
  void LReadRList(List<int> rList) {
    rl.LReadBegin(0);
    for (int rValue in rList) {
      rl.LReadNR(0, rValue, 1);
    }
    rl.LReadEnd(0);
  }
  int LReadR(rValue){
    rl.LReadBegin(0);
    rl.LReadNR(0, rValue, 1);
    rl.LReadEnd(0);
    rl.DWaitDone(0, 2000);
    return rl.memR(0, rValue);
  }

  void DReadBegin() {
    rl.DReadBegin(0);
  }

  void DReadEnd() {
    rl.DReadEnd(0);
  }

  int DReadNR(int R, int RSize) {
    return rl.DReadNR(0, R, RSize);
  }

  int DReadRBit(int R, int BitIdx) {
    rl.DReadNR(0, R, 1);
    rl.DWaitDone(0, 2000);
    int data = rl.memRBit(0, R, BitIdx);
    return data;
  }

  /// Read Register info directly
  Future<int> dReadNR(int R, [int bitIdx = -1]) async {
    int pTran = 0;

    while (pTran == 0) {
      await Future.delayed(const Duration(milliseconds: 60), () {
        pTran = rl.DReadNR(0, R, 1);
        // DWaitDone(0, 2000);
      });
    }

    int data;
    if (bitIdx == -1) {
      data = rl.memR(0, R);
    } else {
      data = rl.memRBit(0, R, bitIdx);
    }

    return data;
  }

  /// Read Register in bundle info directly
  Future<List<int>> dReadBundle(List<int> R) async {
    int pTran = 0;

    while (pTran == 0) {
      await Future.delayed(const Duration(milliseconds: 60), () {
        rl.DReadBegin(0);
        for (final addr in R) {
          rl.DReadNR(0, addr, 1);
          // DWaitDone(0, 2000);
        }
        pTran = rl.DReadEnd(0);
      });
    }

    List<int> data = R.map((e) => rl.memR(0, e)).toList();
    return data;
  }

  // Function: get R value from memory
  int DGetR(int R) {
    return rl.memR(0, R);
  }
  int DGetI(int I) {
    return rl.memI(0, I);
  }
  int DGetO(int O) {
    return rl.memO(0, O);
  }
  // Function: get RBit value from memory
  int DGetRBit(int R, int BitIdx) {
    return rl.memRBit(0, R, BitIdx);
  }
  // Function: get RString value from memory
  String DGetRString(int R, int RSize) {
    Pointer<Int8> buf = "".toNativeUtf8().cast<Int8>();
    rl.memRString(0, R, RSize, buf);
    return buf.cast<Utf8>().toDartString();
  }
}

// Recorn: for connection functions
extension RecornConnection on Recorn {
  int connect(String ip) {
    return rl.ConnectLocalIP(0, ip.toNativeUtf8());
  }

  int disconnect() {
    return rl.Disconnect(0);
  }

  int getConnectStatus() {
    return rl.GetConnectionMsg(0, 2);
  }

  Future<bool> testConnection(String ip) async {
    await initIsolate();
    bool connectStatus = false;
    int count = 0;

    while (!connectStatus && (count * 100 <= 10000) && isTestingConnection) {
      await Future.delayed(const Duration(milliseconds: 100), () {
        connect(ip);
        if (getConnectStatus() == 3) connectStatus = true;
        count++;
      });
    }
    return connectStatus;
  }

  void clearTestingConnection() {
    isTestingConnection = false;
    Future.delayed(const Duration(milliseconds: 300), () {
      isTestingConnection = true;
    });
  }

  int LocalDetectControllers() {
    return rl.LocalDetectControllers();
  }

  int LocalReadControllerCount() {
    return rl.LocalReadControllerCount();
  }

  int LocalReadController() {
    return rl.LocalReadController(0, info);
  }
}
