
import 'package:lnc_mach_app/global.dart';
import 'package:lnc_mach_app/providers/recorn.dart';

// package_handler.dart

class PackageHandler {
  Object? handlePackage(String type) {
    final operation = _getOperationsForType(type);
    if (operation != null) {
      return operation(); // 返回函数执行结果
    } else {
      print("Unknown type: $type");
      return null;
    }
  }

  // 获取对应type的操作
  Object Function()? _getOperationsForType(String type) {
    final operations = {
      "all": _handleAll,
      "InchMode": _setInchMode,               //寸動模式
      "AutoMode": _setAutoMode,              //自動模式
      "MDIMode" : _setMDIMode,              //MDI模式
      "HandwheelMode": _setHandwheelMode,  // 手輪模式
      "JogInchMode": _setJogInchMode,      // 增量寸動
      "HomeMode": _setHomeMode,            // 原點模式
      "XAxisMachineCoord": _getXAxisMachineCoord,
      "Y1AxisMachineCoord": _getY1AxisMachineCoord,
      "ZAxisMachineCoord": _getZAxisMachineCoord,
      "Y2AxisMachineCoord": _getY2AxisMachineCoord,
      "XAxisAbsoluteCoord": _getXAxisAbsoluteCoord,
      "Y1AxisAbsoluteCoord": _getY1AxisAbsoluteCoord,
      "ZAxisAbsoluteCoord": _getZAxisAbsoluteCoord,
      "Y2AxisAbsoluteCoord": _getY2AxisAbsoluteCoord,
      "Feedrate": _getFeedrate,
      "SpindleSpeed": _getSpindleSpeed,
      "FeedrateOverride": _getFeedrateOverride,
      "RapidOverride": _getRapidOverride,
      "SpindleOverride": _getSpindleOverride,
      "CommandF": _getCommandF,
      "CommandS": _getCommandS,
      "CurrentToolNo": _getCurrentToolNo,
      "StandbyToolNo": _getStandbyToolNo,
      "HandwheelSimulateStatus": _getHandwheelSimulateStatus,
      "SingleStepExecuteStatus": _getSingleStepExecuteStatus,
      "writeXAxisMachineCoord":_writeXAxisMachineCoord,
    };
    return operations[type];
  }

  // 返回所有参数
  String _handleAll() {
    //调用公共的读取函数
    final machineStatus = _readMachineStatus();
    final runStatus = _readRunStatus();

    final xAxisMachineCoord = _readAxisCoord(11564);
    final y1AxisMachineCoord = _readAxisCoord(11565);
    final zAxisMachineCoord = _readAxisCoord(11566);
    final y2AxisMachineCoord = _readAxisCoord(11569);

    final xAxisAbsoluteCoord = _readAxisCoord(12032);
    final y1AxisAbsoluteCoord = _readAxisCoord(12033);
    final zAxisAbsoluteCoord = _readAxisCoord(12034);
    final y2AxisAbsoluteCoord = _readAxisCoord(12037);

    final feedrate = _readParameter(82066);
    final spindleSpeed = _readParameter(83138);
    final feedrateOverride = _readParameter(17001);
    final rapidOverride = _readParameter(1024005);
    final spindleOverride = _readParameter(11370);

    final commandF = _readParameter(3006196);
    final commandS = _readParameter(21001);

    final currentToolNo = _readParameter(7813);
    final standbyToolNo = _readParameter(7901);

    final handwheelSimulateStatus = _readBit(352, 7);
    final singleStepExecuteStatus = _readBit(352, 11);

    return '''
机器状态: $machineStatus
运行状态: $runStatus
X轴机械坐标: $xAxisMachineCoord
Y1轴机械坐标: $y1AxisMachineCoord
Z轴机械坐标: $zAxisMachineCoord
Y2轴机械坐标: $y2AxisMachineCoord
X轴绝对坐标: $xAxisAbsoluteCoord
Y1轴绝对坐标: $y1AxisAbsoluteCoord
Z轴绝对坐标: $zAxisAbsoluteCoord
Y2轴绝对坐标: $y2AxisAbsoluteCoord
进给率: $feedrate
主轴转速: $spindleSpeed
进给比: $feedrateOverride
快进比: $rapidOverride
主轴转速比: $spindleOverride
指令F值: $commandF
指令S值: $commandS
当前刀号: $currentToolNo
待命刀号: $standbyToolNo
手轮模拟状态: $handwheelSimulateStatus
单节执行状态: $singleStepExecuteStatus
''';
  }

  // 读取机器状态
  String _readMachineStatus() {
    final machineStatus = Global.recorn.DGetR(22000);
    switch (machineStatus) {
      case 0: return "自動模式";
      case 1: return "MDI模式";
      case 2: return "原點模式";
      case 3: return "原點模式";
      case 4: return "寸動模式";
      case 5: return "增量模式";
      case 6: return "快速模式";
      default: return "未知机器状态";
    }
  }

  // 读取运行状态
  String _readRunStatus() {
    final runStatus = Global.recorn.DGetR(17003);
    switch (runStatus) {
      case 0: return "準備未了";
      case 1: return "準備完成";
      case 2: return "啟動加工";
      case 3: return "機械暫停";
      case 4: return "區段停止";
      default: return "未知运行状态";
    }
  }

  // 读取坐标
  int _readAxisCoord(int address) {
    return Global.recorn.DGetR(address);
  }

  // 读取普通参数
  int _readParameter(int address) {
    return Global.recorn.DGetR(address);
  }

  // 读取位
  int _readBit(int address, int bitIndex) {
    return Global.recorn.DReadRBit(address, bitIndex);
  }
  // 写测试
  int _writeR(int address, value){
    return Global.recorn.DWriteR(address, value);
  }
  // 读 I1000
  int _readR(int address) {
    return Global.recorn.DGetR(address);
  }
  // 读 I0001
  int _readI(int address) {
    return Global.recorn.DGetI(address);
  }
  // 读 O1000
  int _readO(int address) {
    return Global.recorn.DGetO(address);
  }
//----------------------读单独--------------------------
  String _getXAxisMachineCoord() {
    final coord = _readAxisCoord(11564);
    return "X轴机械坐标: $coord";
  }

  String _getY1AxisMachineCoord() {
    final coord = _readAxisCoord(11565);
    return "Y1轴机械坐标: $coord";
  }

  String _getZAxisMachineCoord() {
    final coord = _readAxisCoord(11566);
    return "Z轴机械坐标: $coord";
  }

  String _getY2AxisMachineCoord() {
    final coord = _readAxisCoord(11569);
    return "Y2轴机械坐标: $coord";
  }

// 绝对坐标的
  String _getXAxisAbsoluteCoord() {
    final coord = _readAxisCoord(12032);
    return "X轴绝对坐标: $coord";
  }

  String _getY1AxisAbsoluteCoord() {
    final coord = _readAxisCoord(12033);
    return "Y1轴绝对坐标: $coord";
  }

  String _getZAxisAbsoluteCoord() {
    final coord = _readAxisCoord(12034);
    return "Z轴绝对坐标: $coord";
  }

  String _getY2AxisAbsoluteCoord() {
    final coord = _readAxisCoord(12037);
    return "Y2轴绝对坐标: $coord";
  }
// --- 单独读取进给率 ---
  String _getFeedrate() {
    final value = _readParameter(82066);
    return "进给率: $value";
  }

// --- 单独读取主轴转速 ---
  String _getSpindleSpeed() {
    final value = _readParameter(83138);
    return "主轴转速: $value";
  }

// --- 单独读取进给比 ---
  String _getFeedrateOverride() {
    final value = _readParameter(17001);
    return "进给比: $value";
  }

// --- 单独读取快进比 ---
  String _getRapidOverride() {
    final value = _readParameter(1024005);
    return "快进比: $value";
  }

// --- 单独读取主轴转速比 ---
  String _getSpindleOverride() {
    final value = _readParameter(11370);
    return "主轴转速比: $value";
  }

// --- 单独读取指令F值 ---
  String _getCommandF() {
    final value = _readParameter(3006196);
    return "指令F值: $value";
  }

// --- 单独读取指令S值 ---
  String _getCommandS() {
    final value = _readParameter(21001);
    return "指令S值: $value";
  }

// --- 单独读取当前刀号 ---
  String _getCurrentToolNo() {
    final value = _readParameter(7813);
    return "当前刀号: $value";
  }

// --- 单独读取待命刀号 ---
  String _getStandbyToolNo() {
    final value = _readParameter(7901);
    return "待命刀号: $value";
  }

// --- 单独读取手轮模拟状态 ---
  String _getHandwheelSimulateStatus() {
    final value = _readBit(352, 7);
    return "手轮模拟状态: $value";
  }

// --- 单独读取单节执行状态 ---
  String _getSingleStepExecuteStatus() {
    final value = _readBit(352, 11);
    return "单节执行状态: $value";
  }
  //----写测试---------
  String _writeXAxisMachineCoord() {
    final value = _writeR(11564, 400);
    return "已经写入x轴机械坐标";
  }

// --- 单独读取R/I/O值 ---
  String getRegisterStatus(String prefix, int number) {
    int value;
    switch (prefix.toUpperCase()) {
      case 'R':
        value = _readR(number);  // 你已有的 R 寄存器读取函数
        break;
      case 'I':
        value = _readI(number);  // 你已有的 I 寄存器读取函数
        break;
      case 'O':
        value = _readO(number);  // 你已有的 O 寄存器读取函数
        break;
      default:
        return '不支持的寄存器类型: $prefix';
    }
    return "$prefix$number: $value";
  }

  //-------------------------写R和bit和读，主要是两个模式切换---------------------------------------------

  // 设置寸动模式状态
  String _setInchMode() {
    Global.recorn.DWriteBegin(0);
    Global.recorn.DWriteRBit(20000, 7, 1);
    Global.recorn.DWriteRBit(20000, 4, 0);
    Global.recorn.DWriteRBit(20000, 5, 0);
    Global.recorn.DWriteRBit(20000, 6, 0);
    Global.recorn.DWriteRBit(20000, 8, 0);
    Global.recorn.DWriteRBit(20000, 9, 0);
    Global.recorn.DWriteO(1000, 10);
    Global.recorn.DWriteEnd();
    Global.recorn.DWaitDone(1000);
    Global.recorn.DReadNR(22000, 1);
    Global.recorn.DWaitDone(1000);
    return '寸动模式已开启';
  }
  // 设置MDI模式状态
  String _setMDIMode() {
    Global.recorn.DWriteBegin(0);
    Global.recorn.DWriteRBit(20000, 7, 0);
    Global.recorn.DWriteRBit(20000, 4, 0);
    Global.recorn.DWriteRBit(20000, 5, 1);
    Global.recorn.DWriteRBit(20000, 6, 0);
    Global.recorn.DWriteRBit(20000, 8, 0);
    Global.recorn.DWriteRBit(20000, 9, 0);
    Global.recorn.DWriteO(1000, 10);
    Global.recorn.DWriteEnd();
    Global.recorn.DWaitDone(1000);
    Global.recorn.DReadNR(22000, 1);
    Global.recorn.DWaitDone(1000);
    return 'MDI模式已开启';
  }
  // 设置手轮模式状态
  String _setHandwheelMode() {
    Global.recorn.DWriteBegin(0);
    Global.recorn.DWriteRBit(20000, 7, 0);
    Global.recorn.DWriteRBit(20000, 4, 0);
    Global.recorn.DWriteRBit(20000, 5, 1);
    Global.recorn.DWriteRBit(20000, 6, 0);
    Global.recorn.DWriteRBit(20000, 8, 0);
    Global.recorn.DWriteRBit(20000, 9, 0);
    Global.recorn.DWriteO(1000, 10);
    Global.recorn.DWriteEnd();
    Global.recorn.DWaitDone(1000);
    Global.recorn.DReadNR(22000, 1);
    Global.recorn.DWaitDone(1000);
    return '手轮模式已开启';
  }
  // 设置增量寸动状态
  String _setJogInchMode() {
    Global.recorn.DWriteBegin(0);
    Global.recorn.DWriteRBit(20000, 7, 0);
    Global.recorn.DWriteRBit(20000, 4, 0);
    Global.recorn.DWriteRBit(20000, 5, 1);
    Global.recorn.DWriteRBit(20000, 6, 0);
    Global.recorn.DWriteRBit(20000, 8, 0);
    Global.recorn.DWriteRBit(20000, 9, 0);
    Global.recorn.DWriteO(1000, 10);
    Global.recorn.DWriteEnd();
    Global.recorn.DWaitDone(1000);
    Global.recorn.DReadNR(22000, 1);
    Global.recorn.DWaitDone(1000);
    return '增量寸动已开启';
  }
  // 设置原点状态
  String _setHomeMode() {
    Global.recorn.DWriteBegin(0);
    Global.recorn.DWriteRBit(20000, 7, 0);
    Global.recorn.DWriteRBit(20000, 4, 0);
    Global.recorn.DWriteRBit(20000, 5, 1);
    Global.recorn.DWriteRBit(20000, 6, 0);
    Global.recorn.DWriteRBit(20000, 8, 0);
    Global.recorn.DWriteRBit(20000, 9, 0);
    Global.recorn.DWriteO(1000, 10);
    Global.recorn.DWriteEnd();
    Global.recorn.DWaitDone(1000);
    Global.recorn.DReadNR(22000, 1);
    Global.recorn.DWaitDone(1000);
    return '原点模式已开启';
  }
  // 设置自动模式状态
  String _setAutoMode() {
    Global.recorn.DWriteBegin(0);
    Global.recorn.DWriteRBit(20000, 7, 0);
    Global.recorn.DWriteRBit(20000, 4, 1);
    Global.recorn.DWriteRBit(20000, 5, 0);
    Global.recorn.DWriteRBit(20000, 6, 0);
    Global.recorn.DWriteRBit(20000, 8, 0);
    Global.recorn.DWriteRBit(20000, 9, 0);
    Global.recorn.DWriteO(1000, 10);
    Global.recorn.DWriteEnd();
    Global.recorn.DWaitDone(1000);
    Global.recorn.DReadNR(22000, 1);
    Global.recorn.DWaitDone(1000);
    return '自动模式已开启';
  }
}


class RegisterReader {
  // 读取 R 寄存器
  int _readR(int address) {
    return Global.recorn.DGetR(address);
  }

  // 读取 I 寄存器
  int _readI(int address) {
    return Global.recorn.DGetI(address);
  }

  // 读取 O 寄存器
  int _readO(int address) {
    return Global.recorn.DGetO(address);
  }

  // 获取 R/I/O 寄存器状态
  String getRegisterStatus(String prefix, int number) {
    int value;
    switch (prefix.toUpperCase()) {
      case 'R':
        value = _readR(number);  // 调用 R 寄存器读取函数
        break;
      case 'I':
        value = _readI(number);  // 调用 I 寄存器读取函数
        break;
      case 'O':
        value = _readO(number);  // 调用 O 寄存器读取函数
        break;
      default:
        return '不支持的寄存器类型: $prefix';
    }
    return "$prefix$number: $value";
  }
}
