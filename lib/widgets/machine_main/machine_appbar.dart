import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lnc_mach_app/global.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lnc_mach_app/providers/recorn.dart';

class MachineAppBar extends StatefulWidget {
  const MachineAppBar({Key? key, required this.machineName, required this.ip})
      : super(key: key);
  final String machineName;
  final String ip;

  @override
  State<MachineAppBar> createState() => _MachineAppBarState();
}

class _MachineAppBarState extends State<MachineAppBar> {
  late Recorn _recorn;
  late int status;
  Timer? _connectStatusTimer;

  void handleDisconnect(toastString) {
    _recorn.disconnect();
    _recorn.cleanIsolate();
    _connectStatusTimer?.cancel();

    Navigator.pop(context);

    Fluttertoast.showToast(
        msg: toastString,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black87,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  // check connection, if disconnection sustained 1 second, than pop this page
  void checkConnectionStatus() {
    // check disconnection sustained seconds
    int disconnectCount = 0;
    _connectStatusTimer =
        Timer.periodic(const Duration(milliseconds: 500), (timer) {
      // continued get connection, 3 is success, others is failed
      status = _recorn.getConnectStatus();
      if (status != 3) {
        disconnectCount++;
        // when disconnect for 1 seconds(500ms * 2), than dispose
        if (disconnectCount == 2) {
          timer.cancel();
          handleDisconnect('連線中斷，請檢查連線');
        }
        return;
      }
      disconnectCount = 0;
    });
  }

  @override
  void didChangeDependencies() {
    // _recorn = Provider.of<Recorn>(context, listen: false);
    _recorn = Global.recorn;
    checkConnectionStatus();
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    // connection time counter and keep write R value to hold connection
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: const BoxDecoration(
            // color: Color.fromARGB(255, 20, 21, 24),

            border:
                Border(bottom: BorderSide(color: Colors.white24, width: 1))),
        clipBehavior: Clip.hardEdge,
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [Container()],
          title: appBarRow(),
        ),
      );

  Widget appBarRow() => Builder(builder: (context) {
        double responsiveWidth = MediaQuery.of(context).size.width * 0.0024;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                flex: 4,
                child: Container(
                    alignment: Alignment.topLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.machineName,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                              fontSize: 20.0,
                              color: Color.fromARGB(255, 163, 55, 55),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1),
                        ),
                        Text(
                          'IP：${widget.ip}',
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                              fontSize: 12.0,
                              color: Color.fromARGB(77, 156, 50, 50),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1),
                        ),
                      ],
                    ))),
            Expanded(
              flex: 3,
              child: FittedBox(
                child: ElevatedButton(
                  onPressed: () {
                    handleDisconnect("成功斷開連線");
                  },
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      backgroundColor: Colors.red[700],
                      shape: const StadiumBorder()),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.link_off_rounded,
                        size: 14,
                      ),
                      SizedBox(
                        width: responsiveWidth * 10,
                      ),
                      Text(
                        '斷開連接',
                        style: TextStyle(fontSize: responsiveWidth * 12),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        );
      });
}
