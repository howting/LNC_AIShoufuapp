import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lnc_mach_app/providers/recorn.dart';
import 'package:lnc_mach_app/providers/connection.dart';

//=========== Start: define constants ===========
// response: ok or error
enum ResponseStatus { ok, error }

/// mem: 自動模式, mdi: MDI模式, zrn: 原點模式, mpg: 手輪模式, jog: 寸動模式,
/// rapid: 增量寸動
enum MachineMode { mem, mdi, zrn, mpg, jog, rapid }

const List<MachineMode> machineModeList = MachineMode.values;
const List<int> machineModeBitIndex = [4, 5, 6, 9, 7, 8];
const List<String> machineModeLabels = ['自動', 'MDI', '原點', '手輪', '寸動', '增量寸動'];

/// warmingup: 準備未了, warmedup: 準備完成, beginprod: 啟動加工,
/// pauseprod: 機械暫停, sectionstop: 區段停止
enum MachineStatus { warmingup, warmedup, beginprod, pauseprod, sectionstop }

const List<MachineStatus> machineStatusList = MachineStatus.values;
const List<String> machineStatusLabels = [
  '準備未了',
  '準備完成',
  '啟動加工',
  '機械暫停',
  '區段停止',
];

/// mpgsim: 手輪模擬, sbk: 單節執行
enum MachineFn { mpgsim, sbk }

const List<int> writeMachineFnBitIndex = [3, 0];
const List<int> readMachineFnBitIndex = [7, 11];
//=========== End: define constants ===========

//=========== Start: define MachineStatusScreen class ===========
class MachineStatusScreen extends StatefulWidget {
  const MachineStatusScreen({super.key});

  @override
  State<MachineStatusScreen> createState() => _MachineStatusScreenState();
}
//=========== End: define MachineStatusScreen class ===========

//=========== Start: define _MachineStatusScreenState class ===========
class _MachineStatusScreenState extends State<MachineStatusScreen> {
  // Define properties
  final _recorn = Recorn();
  final _conn = ConnectionProvider();
  late Timer _timer;

  static MachineMode? _currMachineMode;
  static MachineStatus? _currMachineStatus;
  static int? _mpgSimulationStatus;
  static int? _sbkStatus;

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

  /// Initialize page content, e.g. machine mode, status, etc.
  ResponseStatus initPage() {
    try {
      List<int> addrs = [
        _conn.getReadMachineModeRValue(),
        _conn.getReadMachineStatusRValue(),
        _conn.getReadMachineFnRvalue(),
      ];

      _recorn.LReadRList(addrs);

      if (mounted) {
        setState(() {
          _currMachineMode = MachineMode.mem;
          _currMachineStatus = MachineStatus.warmingup;
          _mpgSimulationStatus = 0;
          _sbkStatus = 0;
        });
      }
    } catch (e) {
      return ResponseStatus.error;
    }

    return ResponseStatus.ok;
  }

  /// Get machine status every 60 milliseconds
  void backgroundRefresh() {
    _timer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
      setState(() {
        // update current machine mode
        final modeIndex = _recorn.DGetR(_conn.getReadMachineModeRValue());
        _currMachineMode = machineModeList[modeIndex];

        // update current machin status
        _currMachineStatus = machineStatusList[
            _recorn.DGetR(_conn.getReadMachineStatusRValue())];

        // update 手輪模擬功能狀態
        _mpgSimulationStatus = _recorn.DGetRBit(_conn.getReadMachineFnRvalue(),
            readMachineFnBitIndex[MachineFn.mpgsim.index]);

        // update 單節執行功能狀態
        _sbkStatus = _recorn.DGetRBit(_conn.getReadMachineFnRvalue(),
            readMachineFnBitIndex[MachineFn.sbk.index]);
      });
    });
  }

  /// Write machine mode
  Future<ResponseStatus> setMachineMode(MachineMode selectedMode) async {
    try {
      int addr = _conn.getWriteMachineModeRValue();
      // set the selected mode to 1
      await _recorn.dWrite1RBit(
          addr, machineModeBitIndex[selectedMode.index], 1);
    } catch (e) {
      return ResponseStatus.error;
    }

    return ResponseStatus.ok;
  }

  /// Write machine function
  Future<ResponseStatus> setMachineFnStatus(MachineFn fn, int bitValue) async {
    try {
      int addr = _conn.getWriteMachineFnRValue();
      await _recorn.dWrite1RBit(
          addr, writeMachineFnBitIndex[fn.index], bitValue);
    } catch (e) {
      return ResponseStatus.error;
    }

    return ResponseStatus.ok;
  }

  /// Get machine function status color
  Color getMachineFnStatusColor(MachineFn fn) {
    Color color = Colors.white54;
    if (fn == MachineFn.mpgsim) {
      if (_mpgSimulationStatus == 1) color = Colors.lightBlue;
    } else if (fn == MachineFn.sbk) {
      if (_sbkStatus == 1) color = Colors.lightBlue;
    }

    return color;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _buildDashboard(
          machineModeLabels[_currMachineMode!.index],
          machineStatusLabels[_currMachineStatus!.index],
        ),
        _buildTitleBar('機台模式'),
        _buildRadioListTile('自動模式', MachineMode.mem),
        _buildRadioListTile('MDI模式', MachineMode.mdi),
        _buildRadioListTile('手輪模式', MachineMode.mpg),
        _buildRadioListTile('寸動模式', MachineMode.jog),
        _buildRadioListTile('增量寸動', MachineMode.rapid),
        _buildRadioListTile('原點模式', MachineMode.zrn),
        _buildTitleBar('機台功能'),
        Row(
          children: [
            _buildButton('手輪模擬', MachineFn.mpgsim),
            const SizedBox(width: 2),
            _buildButton('單節執行', MachineFn.sbk),
          ],
        ),
      ],
    );
  }

  //=========== Start: define widgets ===========

  // Title bar
  Widget _buildTitleBar(String title) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(
          title,
          style: const TextStyle(
              fontSize: 20.0, color: Color.fromARGB(255, 231, 231, 231)),
        ),
      );

  // Dashboard item
  Widget _buildDashboardItem(String label, String caption) => Expanded(
        child: Center(
          child: Column(
            children: [
              Text(
                caption,
                style: const TextStyle(fontSize: 14, color: Colors.lightBlue),
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 20, color: Colors.white),
              ),
            ],
          ),
        ),
      );

  // Top dashboard
  Widget _buildDashboard(String mode, String status) => Card(
        color: const Color.fromARGB(255, 19, 20, 22),
        child: SizedBox(
          height: 54,
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _buildDashboardItem(mode, '模式'),
            const VerticalDivider(
              width: 20,
              thickness: 1,
              indent: 10,
              endIndent: 10,
              color: Colors.white,
            ),
            _buildDashboardItem(status, '狀態'),
          ]),
        ),
      );

  // Radio list tile
  Widget _buildRadioListTile(String label, MachineMode mode) => Card(
        color: const Color.fromARGB(255, 19, 20, 22),
        child: RadioListTile<MachineMode>(
          title: Text(label, style: const TextStyle(color: Colors.white)),
          value: mode,
          groupValue: _currMachineMode,
          secondary: Icon(
            (mode == _currMachineMode)
                ? Icons.lightbulb
                : Icons.lightbulb_outline_sharp,
            color:
                (mode == _currMachineMode) ? Colors.lightBlue : Colors.white54,
          ),
          onChanged: (MachineMode? value) async {
            final response = await setMachineMode(value!);
            if (response == ResponseStatus.ok) {
              setState(() {
                _currMachineMode = value;
              });
            }
          },
        ),
      );

  // Button
  Widget _buildButton(String label, MachineFn fn) => Expanded(
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
                      color: getMachineFnStatusColor(fn),
                    ),
                  ],
                ),
              ),
              onTapDown: (TapDownDetails? details) async {
                await setMachineFnStatus(fn, 1);
              },
              onTapUp: (TapUpDetails? details) async {
                await setMachineFnStatus(fn, 0);
              },
            ),
          ),
        ),
      );
  //=========== End: define widgets ===========
}
