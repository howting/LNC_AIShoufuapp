// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lnc_mach_app/global.dart';
import 'package:lnc_mach_app/providers/background_container.dart';
import 'package:lnc_mach_app/providers/recorn.dart';
import 'package:lnc_mach_app/screens/new_machine_screen/widget/machine_dialog.dart';
import 'package:lnc_mach_app/screens/new_machine_screen/widget/machine_provider.dart';
import 'package:provider/provider.dart';

class MachineScreen extends StatelessWidget with MachineDialog {
  const MachineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Start check and count(still not use yet);
    return ChangeNotifierProxyProvider<Recorn, MachineProvider>(
      create: (_) => MachineProvider(recorn: Global.recorn, context: context),
      update: (_, recorn, previousCounter) => previousCounter!,
      builder: (context, _) {
        // start connection detect
        context.read<MachineProvider>().connectionStart();

        return Builder(builder: (context) {
          return WillPopScope(
            child: Material(
              child: BackgroundContainer(
                  child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(children: [
                    resetAndViewSwitcher(context),
                    Expanded(
                      child: context.watch<MachineProvider>().currentPage,
                    ),
                  ]),
                ),
              )),
            ),
            onWillPop: () async {
              Fluttertoast.showToast(
                msg: 'Please disconnect first!',
                backgroundColor: Colors.red,
                gravity: ToastGravity.CENTER,
              );
              return false;
            },
          );
        });
      },
    );
  }

  Widget resetAndViewSwitcher(BuildContext context) => Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              child: Ink(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2.0),
                    image: const DecorationImage(
                        image: AssetImage('assets/Reset_on.png'),
                        fit: BoxFit.cover)),
                height: 78,
                width: 78,
              ),
            ),
          ),
          const SizedBox(width: 20.0),
          Expanded(
              child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                machineDialog(
                    context: context,
                    title: context.read<MachineProvider>().currentPageName,
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 72.0),
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              context
                                  .read<MachineProvider>()
                                  .changePage('Main');
                            },
                            child: const Text('Main')),
                        const SizedBox(height: 24.0),
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              context
                                  .read<MachineProvider>()
                                  .changePage('File');
                            },
                            child: const Text('File')),
                        const Spacer(),
                        TextButton(
                            onPressed: () {
                              context.read<MachineProvider>().handleDisconnect(
                                  msg: 'Successfully Disconnected',
                                  color:
                                      Theme.of(context).colorScheme.secondary);
                            },
                            child: const Text(
                              'Disconnect',
                              style: TextStyle(color: Colors.red),
                            )),
                      ],
                    ));
              },
              child: Ink(
                color: Theme.of(context).colorScheme.primaryContainer,
                height: 50,
                child: Row(
                  children: [
                    Expanded(
                        child: Center(
                            child: Text(
                      context.watch<MachineProvider>().currentPageName,
                      style: const TextStyle(fontSize: 20),
                    ))),
                    const Icon(
                      Icons.arrow_drop_down_rounded,
                      size: 50,
                    ),
                  ],
                ),
              ),
            ),
          ))
        ],
      );
}
