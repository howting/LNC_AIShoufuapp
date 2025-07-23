import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lnc_mach_app/ai/module/chat/chat_controller.dart';
import 'package:lnc_mach_app/ai/module/chat/chat_provider.dart';
import 'package:lnc_mach_app/ai/module/login/login_controller.dart';
import 'package:lnc_mach_app/ai/module/login/login_provider.dart';
import 'package:lnc_mach_app/utils/app_limit_time.dart';
import 'package:provider/provider.dart';
import 'package:lnc_mach_app/utils/routes.dart';
import 'package:lnc_mach_app/providers/recorn.dart';
import 'package:lnc_mach_app/screens/home_screen.dart';

import 'ai/routes/app_pages.dart';
import 'global.dart';

// // Register the RouteObserver as a navigation observer.
// final RouteObserver<ModalRoute<void>> routeObserver =
//     RouteObserver<ModalRoute<void>>();

// void main() async {
//   runApp(const MyApp());
//   Recorn recorn = Recorn();
//   recorn.LibraryInit();
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (context) => Recorn(),
//       builder: (context, child) => MaterialApp(
//         theme: ThemeData(
//             colorScheme: ThemeData().colorScheme.copyWith(
//                 primary: const Color.fromARGB(255, 30, 148, 212),
//                 background: const Color.fromARGB(255, 11, 24, 32),
//                 secondary: const Color.fromARGB(255, 135, 184, 40),
//                 primaryContainer: const Color.fromARGB(255, 36, 40, 43),
//                 secondaryContainer: const Color.fromARGB(255, 7, 7, 15),
//                 onPrimaryContainer: const Color.fromARGB(255, 93, 92, 92)),
//             textTheme: Theme.of(context)
//                 .textTheme
//                 .apply(bodyColor: const Color.fromARGB(255, 239, 239, 239)),
//             iconTheme: Theme.of(context)
//                 .iconTheme
//                 .copyWith(color: const Color.fromARGB(255, 158, 158, 160))),
//         title: 'JordanT&R',
//         home: const MainLayout(),
//         onGenerateRoute: MyRouter.generateRoute,
//         navigatorObservers: [routeObserver],
//       ),
//     );
//   }
// }

void main() {
  Global.init(() => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375.0, 812.0),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (BuildContext context, Widget? child) => GetMaterialApp(
        theme: ThemeData(
            colorScheme: ThemeData().colorScheme.copyWith(
                primary: const Color.fromARGB(255, 30, 148, 212),
                background: const Color.fromARGB(255, 11, 24, 32),
                secondary: const Color.fromARGB(255, 135, 184, 40),
                primaryContainer: const Color.fromARGB(255, 36, 40, 43),
                secondaryContainer: const Color.fromARGB(255, 7, 7, 15),
                onPrimaryContainer: const Color.fromARGB(255, 93, 92, 92))),
        debugShowCheckedModeBanner: false,
        builder: EasyLoading.init(),
        enableLog: true,
        getPages: AppPages.routes,
        initialBinding: InitBinding(),
        initialRoute: Global.profile.employeeId == null
            ? Routes.LOGIN
            : Routes.MODULE_SELECT,
      ),
    );
  }
}

class InitBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginController(Get.find()));
    Get.lazyPut(() => LoginProvider());
  }
}
