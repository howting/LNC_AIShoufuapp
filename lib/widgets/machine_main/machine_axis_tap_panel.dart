import 'package:flutter/material.dart';
import 'package:lnc_mach_app/global.dart';
import 'package:lnc_mach_app/providers/machine_main/r_value.dart';
import 'package:lnc_mach_app/providers/recorn.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

class MachineAxisTapPanel extends StatefulWidget {
  const MachineAxisTapPanel({Key? key}) : super(key: key);

  @override
  State<MachineAxisTapPanel> createState() => _MachineAxisTapPanelPanel();
}

class _MachineAxisTapPanelPanel extends State<MachineAxisTapPanel> {
  // Timer? _timer;
  bool isPressing = false;
  String currentPressing = '';

  void handleCancelWrite(int R, int bitIdx, {TapUpDetails? detail}) {
    // _timer!.cancel();
    int prevR = 1;
    while (true) {
      // context.read<Recorn>().DWriteRBit(R, bitIdx, 0);
      // context.read<Recorn>().DWaitDone(1);
      // context.read<Recorn>().DReadRBit(R, bitIdx);
      // prevR = context.read<Recorn>().DGetRBit(R, bitIdx);
      Global.recorn.DWriteRBit(R, bitIdx, 0);
      Global.recorn.DWaitDone(1);
      Global.recorn.DReadRBit(R, bitIdx);
      prevR = Global.recorn.DGetRBit(R, bitIdx);

      if (prevR == 0) break;
    }
    // context.read<Recorn>().DClearQueue();

    setState(() {
      isPressing = false;
      currentPressing = '';
    });
  }

  void handleStartWrite(int R, int bitIdx,
      {TapDownDetails? detail, String? label}) {
    // 防止觸發其他按鈕
    if (isPressing) return;

    // 震動提醒
    Vibration.vibrate(duration: 100, amplitude: 128);
    // 可單點
    // context.read<Recorn>().DWriteRBit(R, bitIdx, 1);
    // context.read<Recorn>().DWaitDone(1);
    Global.recorn.DWriteRBit(R, bitIdx, 1);
    Global.recorn.DWaitDone(1);

    setState(() {
      isPressing = true;
      currentPressing = label ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Text(
              '正在操作：',
              style: TextStyle(color: Colors.white60),
            ),
            Text(
              currentPressing,
              style: const TextStyle(
                  color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(
          height: 16.0,
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                  flex: 1,
                  child: axisCard(
                      label: 'Z+',
                      R: RValue.Z_PLUS_R,
                      bitIdx: RValue.Z_PLUS_BIT)),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                  flex: 1,
                  child: axisCard(
                      label: 'Y+',
                      R: RValue.Y_PLUS_R,
                      bitIdx: RValue.Y_PLUS_BIT)),
              const SizedBox(
                width: 16,
              ),
              Expanded(flex: 1, child: axisCard()),
            ],
          ),
        ),
        const SizedBox(height: 16.0),
        Expanded(
          child: Row(
            children: [
              Expanded(
                  flex: 1,
                  child: axisCard(
                      label: 'X-',
                      R: RValue.X_MINUS_R,
                      bitIdx: RValue.X_MINUS_BIT)),
              const SizedBox(
                width: 16,
              ),
              Expanded(flex: 1, child: axisCard()),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                  flex: 1,
                  child: axisCard(
                      label: 'X+',
                      R: RValue.X_PLUS_R,
                      bitIdx: RValue.X_PLUS_BIT)),
            ],
          ),
        ),
        const SizedBox(height: 16.0),
        Expanded(
          child: Row(
            children: [
              Expanded(
                  flex: 1,
                  child: axisCard(
                      label: 'Z-',
                      R: RValue.Z_MINUS_R,
                      bitIdx: RValue.Z_MINUS_BIT)),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                  flex: 1,
                  child: axisCard(
                      label: 'Y-',
                      R: RValue.Y_MINUS_R,
                      bitIdx: RValue.Y_MINUS_BIT)),
              const SizedBox(
                width: 16,
              ),
              Expanded(flex: 1, child: axisCard()),
            ],
          ),
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  Widget axisCard({String? label, int? R, int? bitIdx}) {
    return Container(
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(color: Colors.black38, blurRadius: 10, spreadRadius: .5)
        ],
      ),
      child: Material(
          color: Colors.transparent,
          elevation: 0,
          child: InkWell(
              splashColor: Colors.blue,
              onTapCancel: R == null || bitIdx == null
                  ? null
                  : () {
                      handleCancelWrite(R, bitIdx);
                    },
              onTapUp: R == null || bitIdx == null
                  ? null
                  : (detail) {
                      handleCancelWrite(R, bitIdx, detail: detail);
                    },
              onTapDown: R == null || bitIdx == null
                  ? null
                  : (detail) {
                      handleStartWrite(R, bitIdx, detail: detail, label: label);
                    },
              borderRadius: BorderRadius.circular(3.0),
              child: Ink(
                  width: 20,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(3.0)),
                    color: label == null
                        ? const Color.fromARGB(255, 53, 57, 63)
                        : const Color.fromARGB(255, 72, 76, 83),
                  ),
                  child: Center(
                      child: label == null
                          ? null
                          : Text(
                              label,
                              style: const TextStyle(
                                  color: Color.fromARGB(255, 211, 211, 211),
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold),
                            ))))),
    );
  }
}
