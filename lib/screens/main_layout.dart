import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lnc_mach_app/ai/routes/app_pages.dart';
import 'package:lnc_mach_app/screens/home_screen.dart';
import 'package:lnc_mach_app/utils/app_limit_time.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  AppLimitTime alt = AppLimitTime();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  }

  @override
  Widget build(BuildContext context) {
    // 防止轉向
    return SafeArea(
        child: Scaffold(
      // extendBody: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        elevation: 0,
        centerTitle: true,
        leading: TextButton(
            onPressed: () {
              // Navigator.pop(context);
              Get.back();
            },
            style: TextButton.styleFrom(
                minimumSize: Size.zero, padding: const EdgeInsets.all(0)),
            child: const Text(
              "back",
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.normal,
                color: Colors.white,
              ),
            )),
        shape: Border(
            bottom: BorderSide(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                width: 1)),
        title: Image.asset(
          'assets/JordanT_R_logo.png',
          width: 140,
        ),
        actions: [
          popupButton(context),
        ],
      ),
      body: const HomePage(),
      extendBody: true,
    ));
  }

  PopupMenuButton<dynamic> popupButton(BuildContext context) {
    return PopupMenuButton(
        shape: Border.all(
            color: Theme.of(context).colorScheme.onPrimaryContainer, width: 1),
        color: Theme.of(context).colorScheme.primaryContainer,
        onSelected: (route) {
          switch (route) {
            case "/create-ip":
              // Navigator.pushNamed(context, "$route");
              Get.toNamed(Routes.CREATE_IP);
              break;
            case "/machine-detect":
              // Navigator.pushNamed(context, "$route");
              Get.toNamed(Routes.MAH_MACHINE_DETECT);
              break;
            default:
              break;
          }
        },
        position: PopupMenuPosition.under,
        constraints: const BoxConstraints(maxWidth: 140, minHeight: 0),
        icon: const Icon(
          Icons.add_rounded,
          size: 30,
          color: Colors.white70,
        ),
        itemBuilder: (context) => [
              const PopupMenuItem(
                  value: "/create-ip",
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.white70),
                      SizedBox(
                        width: 8.0,
                      ),
                      Text("MANUAL", style: TextStyle(color: Colors.white70))
                    ],
                  )),
              const PopupMenuItem(
                  value: "/machine-detect",
                  child: Row(
                    children: [
                      Icon(Icons.wifi, color: Colors.white70),
                      SizedBox(
                        width: 8.0,
                      ),
                      Text("SCAN", style: TextStyle(color: Colors.white70))
                    ],
                  )),
            ]);
  }
}
