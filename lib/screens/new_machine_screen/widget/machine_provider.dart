import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lnc_mach_app/providers/machine_main/r_value.dart';
import 'package:lnc_mach_app/providers/recorn.dart';
import 'package:lnc_mach_app/screens/new_machine_screen/machine_screen_file/machine_screen_file.dart';
import 'package:lnc_mach_app/screens/new_machine_screen/machine_screen_main/machine_screen_main.dart';

class MachineProvider extends ChangeNotifier {
  MachineProvider({required this.recorn, required this.context});
  final Recorn recorn;
  final BuildContext context;

  String currentPageName = "Main";
  BackgroundConnectionChecker? connectionChecker;

  Map pages = {
    "Main": const MachineMain(),
    "File": const MachineFile(),
  };

  // get page widget
  Widget get currentPage => pages[currentPageName];

  // change page by currentPageName
  void changePage(String pageName) {
    if (pageName == currentPageName) return;
    currentPageName = pageName;
    notifyListeners();
  }

  void handleDisconnect({required String msg, required Color color}) {
    recorn.disconnect();
    recorn.cleanIsolate();
    connectionStop();
    Navigator.popUntil(context, (route) => route.isFirst);

    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: color,
        textColor: Colors.white,
        fontSize: 14.0);
  }

  // start count with keep connection writing
  void connectionStart() {
    connectionChecker = BackgroundConnectionChecker(recorn: recorn);
    // connectionChecker!.addPostDisconnectCallback(() {
    //   handleDisconnect(msg: 'Disconnected, please check your internet!', color: Colors.red);
    // });
    connectionChecker!.check();
  }

  // stop count
  void connectionStop() {
    connectionChecker?.stop();
  }
}

/// contain all connection checker, include read and write
/// read -> get connection status from recorn
/// write -> keep writing R value, let controller know we are still connecting
class BackgroundConnectionChecker {
  BackgroundConnectionChecker({required this.recorn});
  Recorn recorn;
  int lostConnectionCount = 0;
  int? status;
  Timer? _connectionTimer;
  Timer? _keepConnectionTimer;
  VoidCallback? postDisconnectCallback;

  /// keep writing R value, let controller know we are still connecting
  /// if write stop, you cannot write anything into controller side
  void _keepConnect() {
    recorn.LWriteBegin();
    recorn.LWriteNR(RValue.KEEP_CONNECTION, 1);
    recorn.LWriteEnd();

    _keepConnectionTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      recorn.memSetR(RValue.KEEP_CONNECTION, timer.tick);
    });
  }

  /// add a action, it will call after checker detect disconnection
  void addPostDisconnectCallback(VoidCallback? callback) {
    postDisconnectCallback = callback;
  }

  /// start check connection status
  /// check every 500 ms, return value 3 : ok, not 3 : faild
  /// if sustain disconnecting for 1 seconds(it means continully return falid two times), it will call [addPostDisconnectCallback]
  void check() {
    _keepConnect();
    _connectionTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      // continued get connection, 3 is success, others is failed
      status = recorn.getConnectStatus();
      if (status != 3) {
        lostConnectionCount++;
        // when disconnect for 1 seconds(500ms * 2), than dispose
        if (lostConnectionCount == 2) {
          timer.cancel();
          if (postDisconnectCallback == null) return;
          postDisconnectCallback!();
        }
        return;
      }
      lostConnectionCount = 0;
    });
  }

  /// cancel all timers, reset recorn Queue, and reset all variable
  void stop() {
    _connectionTimer?.cancel();
    _keepConnectionTimer?.cancel();
    recorn.LClearQueue();
    lostConnectionCount = 0;
    status = null;
    postDisconnectCallback = null;
  }
}

/// *** Future Release
/// 
// class Counter {
//   int _count = 0;
//   Timer? countTimer;
//   void startCount() {
//     countTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       _count++;
//     });
//   }
//   void stopCount() {
//     countTimer?.cancel();
//     _count = 0;
//   }
//   String _formatTime(int num) {
//     return num < 10 ? '0$num' : '$num';
//   }
//   // get count value
//   int get count {
//     return _count;
//   }
//   // get format time 'hh:mm:ss'
//   String get time {
//     int seconds = _count % 60;
//     int minutes = _count ~/ 60 % 60;
//     int hours = _count ~/ 3600;
//     return '${_formatTime(hours)}:${_formatTime(minutes)}:${_formatTime(seconds)}';
//   }
// }