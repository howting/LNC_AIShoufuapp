import 'package:flutter/material.dart';
import 'package:lnc_mach_app/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:lnc_mach_app/screens/create_machine/create_machine_screen_done.dart';
import 'package:lnc_mach_app/screens/create_machine/create_machine_screen_ip.dart';
import 'package:lnc_mach_app/screens/create_machine/create_machine_screen_name.dart';
import 'package:lnc_mach_app/screens/machine_scan_screen.dart';
import 'package:lnc_mach_app/screens/machine_main/machine_main_screen.dart';
import 'package:lnc_mach_app/screens/new_machine_screen/machine_screen.dart';

class MyRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // define arguments
    Map<String, dynamic> arguments = settings.arguments != null ? settings.arguments as Map<String, dynamic> : {};
    // define routes
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const MyApp());
      case '/create-ip':
        return CupertinoPageRoute(builder: (_) => const CreateMahcineIP());
      case '/create-name':
        return CupertinoPageRoute(builder: (_) => CreateMachineName(ip: arguments['ip']));
      case '/create-done':
        return CupertinoPageRoute(builder: (_) => const CreateMachineDone());
      case '/main':
        return CupertinoPageRoute(
            builder: (_) => MachineMainScreen(
                  ip: arguments['ip'],
                  machineName: arguments['machineName'],
                ));
      case '/machine-detect':
        return CupertinoPageRoute(builder: (_) => const MachineScanScreen());
      case '/machine':
        return MaterialPageRoute(settings: RouteSettings(name: settings.name), builder: (_) => const MachineScreen());
      default:
        return CupertinoPageRoute(
            builder: (_) => const Scaffold(
                    body: Center(
                  child: Text('Page Not Found!'),
                )));
    }
  }
}
