import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lnc_mach_app/global.dart';
import 'package:lnc_mach_app/providers/background_container.dart';
import 'package:lnc_mach_app/providers/machine_main/r_value.dart';
import 'package:lnc_mach_app/providers/recorn.dart';
import 'package:lnc_mach_app/screens/machine_main/machine_axis_screen.dart';
import 'package:lnc_mach_app/screens/machine_main/machine_status_screen.dart';
import 'package:lnc_mach_app/screens/machine_main/machine_data_screen.dart';
import 'package:lnc_mach_app/widgets/machine_main/machine_appbar.dart';
import 'package:lnc_mach_app/widgets/machine_main/machine_bottom_nav_item.dart';
import 'package:lnc_mach_app/widgets/machine_main/machine_bottom_navbar.dart';
import 'package:lnc_mach_app/widgets/machine_main/machine_main_drawer.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

class MachineMainScreen extends StatefulWidget {
  const MachineMainScreen(
      {Key? key, required this.ip, required this.machineName})
      : super(key: key);

  final String ip;
  final String machineName;

  @override
  State<MachineMainScreen> createState() => _MachineMainScreenState();
}

class _MachineMainScreenState extends State<MachineMainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Define screens
  final List<Widget> screens = [
    const MachineStatusScreen(),
    const MachineAxisScreen(),
    const MachineDataScreen(),
  ];
  // Screens index
  int currentTabIndex = 0;
  // ignore: non_constant_identifier_names
  int EMCState = 0;
  late Timer _timer;

  // Define change screen index func
  void changeIndex(int value) {
    if (currentTabIndex == value) return;
    setState(() {
      currentTabIndex = value;
    });
  }

  // Check if is EMC on / off
  bool isEMCMode() {
    return EMCState == 1;
  }

  // Get emc button text
  // ignore: non_constant_identifier_names
  String EMCButtonText() {
    return isEMCMode() ? '解鎖' : 'EMG';
  }

  // Get current EMC state
  int getEMCState() {
    // return context.read<Recorn>().DReadRBit(RValue.EMC_R, RValue.EMC_BIT);
    return Global.recorn.DReadRBit(RValue.EMC_R, RValue.EMC_BIT);
  }

  // Set EMC state
  void setEMCState() {
    setState(() {
      EMCState = getEMCState();
    });
  }

  // handle start EMC
  void handleStartEMC() {
    Vibration.vibrate(duration: 2000);
    // context.read<Recorn>().DWriteRBit(RValue.EMC_R, RValue.EMC_BIT, 1);
    Global.recorn.DWriteRBit(RValue.EMC_R, RValue.EMC_BIT, 1);
    setEMCState();
  }

  // handle stop EMC
  void handleStopEMC() {
    Vibration.vibrate(duration: 1000);
    // context.read<Recorn>().DWriteRBit(RValue.EMC_R, RValue.EMC_BIT, 0);
    Global.recorn.DWriteRBit(RValue.EMC_R, RValue.EMC_BIT, 0);
    setEMCState();
  }

  @override
  void initState() {
    // initial current EMC state
    setEMCState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double responsiveHeight = MediaQuery.of(context).size.height * 0.0014;
    return WillPopScope(
        child: SafeArea(
          child: Scaffold(
              extendBody: true,
              key: _scaffoldKey,
              extendBodyBehindAppBar: true,
              // ===================== EMC Button start =====================
              floatingActionButton: GestureDetector(
                  onPanCancel: () => _timer.cancel(),
                  onPanDown: (_) => {
                        _timer = Timer(const Duration(milliseconds: 500), () {
                          if (isEMCMode()) return handleStopEMC();
                          handleStartEMC();
                        })
                      },
                  child: FloatingActionButton(
                    backgroundColor: Colors.red,
                    onPressed: () {},
                    child: Center(
                      child: Text(
                        EMCButtonText(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
              // ===================== EMC Button end =====================
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(100),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    isEMCMode()
                        ? Container(
                            alignment: Alignment.center,
                            width: double.infinity,
                            height: 20,
                            color: Colors.red,
                            child: const Text(
                              '緊急模式啟用中',
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : Container(),
                    MachineAppBar(
                        machineName: widget.machineName, ip: widget.ip),
                  ],
                ),
              ),
              body: Material(
                child: BackgroundContainer(
                    child: SafeArea(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).padding.bottom,
                          left: 16,
                          right: 16),
                      child: Column(children: [
                        SizedBox(
                          height: responsiveHeight * 16,
                        ),
                        screens[currentTabIndex],
                        SizedBox(
                          height: responsiveHeight * 24,
                        )
                      ]),
                    ),
                  ),
                )),
              ),
              bottomNavigationBar: MachineBottomNavBar(
                items: [
                  BottomNavItem(
                      label: const Text(
                        '模式',
                      ),
                      icon: const Icon(
                        Icons.autorenew,
                      ),
                      onTap: () {
                        changeIndex(0);
                      }),
                  BottomNavItem(
                      label: const Text(
                        '座標',
                      ),
                      icon: const Icon(
                        Icons.settings_input_component_outlined,
                      ),
                      onTap: () {
                        changeIndex(1);
                      }),
                  // 這一個是為了佔空間，這樣才可以平分成五分之一
                  BottomNavItem(
                      label: const Text(''),
                      icon: const Icon(Icons.abc),
                      hide: true),
                  BottomNavItem(
                      label: const Text(
                        '指標',
                      ),
                      icon: const Icon(
                        Icons.list_alt,
                      ),
                      onTap: () {
                        changeIndex(2);
                      }),
                  BottomNavItem(
                      label: const Text(
                        '操作',
                      ),
                      icon: const Icon(
                        Icons.flash_on,
                      ),
                      onTap: () {
                        if (isEMCMode()) return;
                        _scaffoldKey.currentState!.openEndDrawer();
                      })
                ],
                currentTabIndex: currentTabIndex,
              ),
              endDrawer: const MachineMainDrawer()),
        ),
        onWillPop: () async {
          Fluttertoast.showToast(
              msg: "請先斷開連接！",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: const Color.fromARGB(221, 255, 60, 60),
              textColor: Colors.white,
              fontSize: 16.0);
          return false;
        });
  }
}
