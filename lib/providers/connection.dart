// ignore_for_file: non_constant_identifier_names

class ConnectionProvider {
  // ip for test
  final String _machineIP = '172.23.10.53';

  final String _enchar = "C4B6F4BBD567825AE16BB5E10F44B1426EDEF7F4B13D9FC2";

  final int _factory_id = 706995;

  // 機台模式 R 值
  final int _readMachineModeRValue = 22000;
  final int _writeMachineModeRValue = 20000;

  // 機台狀態 R 值
  final int _readMachineStatusRValue = 17003; // 17003 for production
  final int _readMachineStatusDuration = 1; // seconds

  // 機台功能 R 值
  final int _readMachineFnRValue = 352;
  final int _writeMachineFnRValue = 20001;

  // 進給率
  final int _readFeedRateRValue = 82066;

  // 進給比
  final int _readFeedRatioRValue = 17001;

  // 主軸轉速
  final int _readSpindleRotationSpeedRValue = 83138;

  // 轉速比
  final int _readSpindleRotationSpeedRatioRValue = 11370;

  // 快進比
  final int _readFastForwardRatioRValue = 1024005;

  // OP面板
  final int _writeMachineOperationRatioRValue = 20001;

  // 主軸啟動/停止
  final int _readSpindleRotationStatusRValue = 356;
  final int _writeSpindleRotationStatusRValue = 20000;

  // F
  final int _readFRValue = 3006196;

  // S
  final int _readSRValue = 21001;

  // 主軸刀號
  final int _readSpindleBladeRValue = 7813;

  // 待命刀號
  final int _readBackUpBladeRValue = 7901;

  // Getters
  String getMachineIP() => _machineIP;
  String getEnChar() => _enchar;
  int getFactoryID() => _factory_id;

  // 機台模式 R 值
  int getReadMachineModeRValue() => _readMachineModeRValue;
  int getWriteMachineModeRValue() => _writeMachineModeRValue;

  // 機台狀態 R 值
  int getReadMachineStatusRValue() => _readMachineStatusRValue;
  int getReadMachineStatusDuration() => _readMachineStatusDuration;

  // 機台功能 R 值
  int getReadMachineFnRvalue() => _readMachineFnRValue;
  int getWriteMachineFnRValue() => _writeMachineFnRValue;

  // 進給率 & 進給比 R 值
  int getReadFeedRateRValue() => _readFeedRateRValue;
  int getReadFeedRatioRValue() => _readFeedRatioRValue;

  // 主軸 R 值
  int getReadSpindleRotationSpeedRValue() => _readSpindleRotationSpeedRValue;
  int getReadSpindleRotationSpeedRatioRValue() =>
      _readSpindleRotationSpeedRatioRValue;

  // 主軸啟動/停止
  int getReadSpindleRotationStatusRValue() =>  _readSpindleRotationStatusRValue;
  int getWriteSpindleRotationStatusRValue() => _writeSpindleRotationStatusRValue;

  // F & S - R 值
  int getReadFRValue() => _readFRValue;
  int getReadSRValue() => _readSRValue;

  // 刀號 R 值
  int getReadSpindleBladeRValue() => _readSpindleBladeRValue;
  int getReadBackUpBladeRValue() => _readBackUpBladeRValue;

  // 快進比 R 值
  int getReadFastForwardRatioRValue() => _readFastForwardRatioRValue;

  // OP面板 R 值
  int getWriteMachineOperationRatioRValue() =>
      _writeMachineOperationRatioRValue;
}
