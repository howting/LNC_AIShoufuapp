import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lnc_mach_app/providers/recorn.dart';
import 'package:lnc_mach_app/providers/connection.dart';

//=========== Start: define constants ===========
// response: ok or error
enum ResponseStatus { ok, error }

// 快進比
enum FastForwardRatio { zero, quarter, half, full }
const List<int> fastForwardRatioBitIndex = [16, 17, 18, 19];

// 進給比及轉速比
enum TuningRange { minusonetenth, hundred, plusonetenth }
const List<int> feedRatioBitIndex = [20, 21, 22];
const List<int> spindleRotationRatioBitIndex = [23, 24, 25];

// 主軸啓動/停止
enum SpindleRotationStatus { start, stop }
const List<int> readSpindleRotationStatusBitIndex = [0, 8];
const List<int> writeSpindleRotationStatusBitIndex = [23, 25];

//=========== End: define constants ===========

// define MachineDataScreen class
class MachineDataScreen extends StatefulWidget {
  const MachineDataScreen({super.key});

  @override
  State<MachineDataScreen> createState() => _MachineDataScreenState();
}

// Define machine status screen state class
class _MachineDataScreenState extends State<MachineDataScreen> {
  // Define properties
  final _recorn = Recorn();
  final _conn = ConnectionProvider();

  late Timer _timer;
  static bool? _startSpindleRotation; // 主軸啟動
  static bool? _stopSpindleRotation;  // 主軸停止

  static int? _fValue;  // F值
  static int? _sValue;  // S值
  static int? _spindleBlade;  // 主軸刀號
  static int? _backUpBlade; // 備用刀號
  static int? _feedRate;  // 進給率
  static int? _spindleRotationSpeed;  // 主軸轉速
  static int? _fastForwardRatio;  // 快進比
  static int? _feedRatio; // 進給比
  static int? _spindleRotationSpeedRatio; // 主軸轉速比

    // Handle page mount
  @override
  void initState() {
    super.initState();
    initPage();
    backgroundRefresh();
  }

  @override
  void deactivate() {
    _recorn.DClearQueue();
    super.deactivate();
  }

  // Handle page unmount
  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  /// Initialize page content, e.g. F value, S Value, etc.
  ResponseStatus initPage() {
    try {
      List<int> addrs = [
        _conn.getReadBackUpBladeRValue(),
        _conn.getReadFRValue(),
        _conn.getReadFastForwardRatioRValue(),
        _conn.getReadFeedRateRValue(),
        _conn.getReadFeedRatioRValue(),
        _conn.getReadSpindleBladeRValue(),
        _conn.getReadSpindleRotationStatusRValue(),
        _conn.getReadSpindleRotationSpeedRValue(),
        _conn.getReadSpindleRotationSpeedRatioRValue(),
        _conn.getReadSRValue(),
      ];

      _recorn.LReadRList(addrs);

      if (mounted) {
        setState(() {
          _backUpBlade = 0;
          _fastForwardRatio = 0;
          _feedRate = 0;
          _feedRatio = 0;
          _fValue = 0;
          _spindleBlade = 0;
          _spindleRotationSpeed = 0;
          _spindleRotationSpeedRatio = 0;
          _startSpindleRotation = false;
          _stopSpindleRotation = false;
          _sValue = 0;
        });
      }
    } catch (e) {
      return ResponseStatus.error;
    }

    return ResponseStatus.ok;
  }

  // Periodically fetch machine operation data from backend
  void backgroundRefresh() {
    _timer = Timer.periodic(
      const Duration(milliseconds: 20), 
      (timer) {
        setState(() {
          _backUpBlade = _recorn.DGetR(_conn.getReadBackUpBladeRValue());
          _fastForwardRatio = _recorn.DGetR(_conn.getReadFastForwardRatioRValue());
          _feedRate = _recorn.DGetR(_conn.getReadFeedRateRValue());
          _feedRatio = _recorn.DGetR(_conn.getReadFeedRatioRValue());
          _fValue = _recorn.DGetR(_conn.getReadFRValue());
          _spindleBlade = _recorn.DGetR(_conn.getReadSpindleBladeRValue());
          _spindleRotationSpeed = _recorn.DGetR(_conn.getReadSpindleRotationSpeedRValue());
          _spindleRotationSpeedRatio = _recorn.DGetR(_conn.getReadSpindleRotationSpeedRValue());
          _startSpindleRotation = _recorn.DGetRBit(
            _conn.getReadSpindleRotationStatusRValue(),
            readSpindleRotationStatusBitIndex[SpindleRotationStatus.start.index]
          ) == 1 ? true : false;
          _stopSpindleRotation = _recorn.DGetRBit(
            _conn.getReadSpindleRotationStatusRValue(),
            readSpindleRotationStatusBitIndex[SpindleRotationStatus.stop.index]
          ) == 1 ? true : false;
          _sValue = _recorn.DGetR(_conn.getReadSRValue());
        });
      }
    );
  }

  // Toggle spindle rotation
  Future<void> toggleSpindleRotation(SpindleRotationStatus spindleStatus) async {
    int addr = _conn.getWriteSpindleRotationStatusRValue();
    if (spindleStatus == SpindleRotationStatus.start) {
      await _recorn.dWrite1RBit(
        addr, 
        writeSpindleRotationStatusBitIndex[SpindleRotationStatus.stop.index], 
        0
      );
      await _recorn.dWrite1RBit(
        addr, 
        writeSpindleRotationStatusBitIndex[SpindleRotationStatus.start.index], 
        1
      );
    } else if (spindleStatus == SpindleRotationStatus.stop) {
      await _recorn.dWrite1RBit(
        addr, 
        writeSpindleRotationStatusBitIndex[SpindleRotationStatus.start.index], 
        0
      );
      await _recorn.dWrite1RBit(
        addr, 
        writeSpindleRotationStatusBitIndex[SpindleRotationStatus.stop.index], 
        1
      );
    }

    setState(() {
      if (spindleStatus == SpindleRotationStatus.start) {
        _startSpindleRotation = true;
        _stopSpindleRotation = false;
      } else if (spindleStatus == SpindleRotationStatus.stop) {
        _startSpindleRotation = false;
        _stopSpindleRotation = true;
      }
    });
  }

  /// Tune machine operation ratio
  void tuneMachineOperationRatio(int addr, int bitIdx, int bitValue) {
    _recorn.dWrite1RBit(addr, bitIdx, bitValue);
  }

    /// Get machine function status color
  Color getSpindleRotationStatusColor(SpindleRotationStatus spindleStatus) {
    Color color = Colors.white54;
    if (spindleStatus == SpindleRotationStatus.start) {
      if (_startSpindleRotation!) color = Colors.lightBlue;
    } else if (spindleStatus == SpindleRotationStatus.stop) {
      if (_stopSpindleRotation!) color = Colors.lightBlue;
    }

    return color;
  }

  // Build widget
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTitleBar('F/S 及刀具資訊'),
          _buildDashboard(
            children: [
              _buildDashboardItem(label: 'F', data: (_fValue!/1000).toStringAsFixed(3)),
              _buildVerticalDivider(),
              _buildDashboardItem(label: 'S', data: _sValue.toString()),
            ],
          ),
          _buildDashboard(
            children: [
              _buildDashboardItem(label: '主軸刀號', data: _spindleBlade.toString()),
              _buildVerticalDivider(),
              _buildDashboardItem(label: '備用刀號', data: _backUpBlade.toString()),
            ],
          ),
          Row(
            children: [
              _buildToggleButton('主軸啟動', SpindleRotationStatus.start),
              const SizedBox(width: 2),
              _buildToggleButton('主軸停止', SpindleRotationStatus.stop),
            ],
          ),
          _buildTitleBar('機台數據及調控'),
          _buildDashboard(
            children: [
              _buildDashboardItem(label: '進給率', data: _feedRate.toString()),
              _buildVerticalDivider(),
              _buildDashboardItem(label: '主軸轉速', data: _spindleRotationSpeed.toString()),
            ],
          ),
          _buildDashboard(
            height: 110,
            children: [
              _buildDashboardItem(
                label: '快進比',
                data: '${(_fastForwardRatio!/100).toStringAsFixed(0)}%',
                isPercentage: true,
              ),
              _buildVerticalDivider(),
              Flexible(
                fit: FlexFit.tight,
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: <Widget>[
                        _buildButton(
                          label: '0%',
                          addr: _conn.getWriteMachineOperationRatioRValue(),
                          bitIdx:
                              fastForwardRatioBitIndex[FastForwardRatio.zero.index],
                        ),
                        _buildButton(
                          label: '25%',
                          addr: _conn.getWriteMachineOperationRatioRValue(),
                          bitIdx: fastForwardRatioBitIndex[
                              FastForwardRatio.quarter.index],
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        _buildButton(
                          label: '50%',
                          addr: _conn.getWriteMachineOperationRatioRValue(),
                          bitIdx:
                              fastForwardRatioBitIndex[FastForwardRatio.half.index],
                        ),
                        _buildButton(
                          label: '100%',
                          addr: _conn.getWriteMachineOperationRatioRValue(),
                          bitIdx:
                              fastForwardRatioBitIndex[FastForwardRatio.full.index],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          _buildDashboard(
            height: 90,
            children: [
              _buildDashboardItem(
                label: '進給比',
                data: '${(_feedRatio!/100).toStringAsFixed(0)}%',
                isPercentage: true,
              ),
              _buildVerticalDivider(),
              Flexible(
                fit: FlexFit.tight,
                flex: 3,
                child: Row(
                  children: <Widget>[
                    _buildButton(
                        label: '-10%',
                        addr: _conn.getWriteMachineOperationRatioRValue(),
                        bitIdx:
                            feedRatioBitIndex[TuningRange.minusonetenth.index]),
                    _buildButton(
                        label: '100%',
                        addr: _conn.getWriteMachineOperationRatioRValue(),
                        bitIdx: feedRatioBitIndex[TuningRange.hundred.index]),
                    _buildButton(
                        label: '+10%',
                        addr: _conn.getWriteMachineOperationRatioRValue(),
                        bitIdx:
                            feedRatioBitIndex[TuningRange.plusonetenth.index]),
                  ],
                ),
              ),
            ],
          ),
          _buildDashboard(
            height: 90,
            children: [
              _buildDashboardItem(
                label: '轉速比',
                data: '${(_spindleRotationSpeedRatio!/100).toStringAsFixed(0)}%',
                isPercentage: true,
              ),
              _buildVerticalDivider(),
              Flexible(
                fit: FlexFit.tight,
                flex: 3,
                child: Row(
                  children: <Widget>[
                    _buildButton(
                        label: '-10%',
                        addr: _conn.getWriteMachineOperationRatioRValue(),
                        bitIdx: spindleRotationRatioBitIndex[
                            TuningRange.minusonetenth.index]),
                    _buildButton(
                        label: '100%',
                        addr: _conn.getWriteMachineOperationRatioRValue(),
                        bitIdx: spindleRotationRatioBitIndex[
                            TuningRange.hundred.index]),
                    _buildButton(
                        label: '+10%',
                        addr: _conn.getWriteMachineOperationRatioRValue(),
                        bitIdx: spindleRotationRatioBitIndex[
                            TuningRange.plusonetenth.index]),
                  ],
                ),
              ),
            ],
          ),
        ],
      );

  //=========== Define widgets ===========

  // Title bar
  Widget _buildTitleBar(String title) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(
          title,
          style: const TextStyle(
              fontSize: 20.0, color: Color.fromARGB(255, 231, 231, 231)),
        ),
      );

  Widget _buildDashboardItem(
          {required String label,
          required String data,
          bool isPercentage = false}) =>
      Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 16, color: Colors.lightBlue),
              ),
              Text(
                data,
                // isPercentage ? '${data/100}%' : data.toString(),
                style: const TextStyle(fontSize: 20, color: Colors.white),
              ),
            ],
          ),
        ),
      );

  Widget _buildVerticalDivider() => const VerticalDivider(
        width: 20,
        thickness: 1,
        indent: 10,
        endIndent: 10,
        color: Colors.white,
      );

  Widget _buildDashboard(
          {double height = 66, required List<Widget> children}) =>
      SizedBox(
        height: height,
        child: Card(
          color: const Color.fromARGB(255, 19, 20, 22),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: children,
          ),
        ),
      );

  // Button
  Widget _buildButton({
    required String label,
    required int addr,
    required int bitIdx,
  }) =>
      Expanded(
        child: Card(
          color: Colors.lightBlue,
          // onPressed: () {},
          child: InkWell(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            onTapDown: (TapDownDetails? details) {
              tuneMachineOperationRatio(addr, bitIdx, 1);
            },
            onTapUp: (TapUpDetails? details) {
              tuneMachineOperationRatio(addr, bitIdx, 0);
            },
          ),
        ),
      );

  // Button
  Widget _buildToggleButton(String label, SpindleRotationStatus spindleStatus) => Expanded(
    child: SizedBox(
      height: 100,
      child: Card(
            color: const Color.fromARGB(255, 19, 20, 22),
            child: InkWell(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label, 
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    Icon(
                      Icons.lightbulb,
                      color: getSpindleRotationStatusColor(spindleStatus),
                    ),
                  ],
                ),
              ),
              onTapDown: (TapDownDetails? details) async {
                await toggleSpindleRotation(spindleStatus);
              },
            ),
          ),
    ),
  );  
}
