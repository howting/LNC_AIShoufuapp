import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lnc_mach_app/global.dart';
import 'package:lnc_mach_app/providers/machine_main/r_value.dart';
import 'package:lnc_mach_app/providers/recorn.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

class MachineMainDrawer extends StatefulWidget {
  const MachineMainDrawer({Key? key}) : super(key: key);

  @override
  State<MachineMainDrawer> createState() => _MachineMainDrawer();
}

class _MachineMainDrawer extends State<MachineMainDrawer> {
  late Timer malipulateTimer;

  void handleCancel(int R, int bitIdx) {
    // malipulateTimer.cancel();
    Global.recorn.DWriteRBit(R, bitIdx, 0);
    Future.delayed(
        const Duration(milliseconds: 500), Global.recorn.DClearQueue);
  }

  void handleTrigger(int R, int bitIdx) async {
    int status = 0;
    Vibration.vibrate(amplitude: 128);
    status = Global.recorn.DWriteRBit(R, bitIdx, 1);
    Fluttertoast.cancel();
    if (status != 0) {
      Fluttertoast.showToast(
          msg: "命令成功",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black87,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
    Fluttertoast.showToast(
        msg: "命令失敗",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black87,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 250,
      decoration: const BoxDecoration(
          color: Color.fromARGB(255, 37, 41, 46),
          borderRadius: BorderRadius.all(Radius.circular(15.0)),
          boxShadow: [
            BoxShadow(
                color: Color.fromARGB(246, 10, 10, 10),
                spreadRadius: .1,
                blurRadius: 15),
          ]),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        child: Drawer(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            malipulateIcon(MalipulateIcon(
                label: '啟動加工',
                icon: Icons.play_arrow_rounded,
                index: 2,
                R: RValue.START_R,
                bitIdx: RValue.START_BIT)),
            seperator(),
            malipulateIcon(MalipulateIcon(
                label: '程序暫停',
                icon: Icons.pause_rounded,
                index: 3,
                R: RValue.STOP_R,
                bitIdx: RValue.STOP_BIT)),
            seperator(),
            malipulateIcon(MalipulateIcon(
                label: '復位',
                icon: Icons.refresh_outlined,
                index: 0,
                R: RValue.RETURN_R,
                bitIdx: RValue.RETURN_BIT)),
          ]),
        ),
      ),
    );
  }

  Widget malipulateIcon(MalipulateIcon mi) {
    return Builder(
      builder: (context) => GestureDetector(
        onPanDown: (_) {
          handleTrigger(mi.R, mi.bitIdx);
        },
        onPanCancel: () {
          handleCancel(mi.R, mi.bitIdx);
        },
        onPanEnd: (_) {
          handleCancel(mi.R, mi.bitIdx);
        },
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Colors.transparent,
                padding: const EdgeInsets.all(16.0),
              ),
              child: Column(
                children: [
                  Icon(
                    mi.icon,
                    color: Colors.grey[400],
                  ),
                  Text(
                    mi.label,
                    style: TextStyle(
                      color: Colors.grey[400],
                    ),
                  )
                ],
              )),
        ),
      ),
    );
  }

  Widget seperator() {
    return Container(
      height: 2,
      color: Colors.white30,
    );
  }
}

class MalipulateIcon {
  String label;
  IconData icon;
  int index;
  int R;
  int bitIdx;

  MalipulateIcon(
      {required this.label,
      required this.icon,
      required this.index,
      required this.R,
      required this.bitIdx});
}
