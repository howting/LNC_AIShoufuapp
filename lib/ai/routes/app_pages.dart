import 'package:get/get.dart';
import 'package:lnc_mach_app/ai/module/chat/chat_bind.dart';
import 'package:lnc_mach_app/ai/module/chat/chat_page.dart';
import 'package:lnc_mach_app/ai/module/login/login_page.dart';
import 'package:lnc_mach_app/ai/module/machine_chat/machine_chat_bind.dart';
import 'package:lnc_mach_app/ai/module/machine_chat/machine_chat_page.dart';
import 'package:lnc_mach_app/ai/module/manual_chat/manual_chat_bind.dart';
import 'package:lnc_mach_app/ai/module/manual_chat/manual_chat_page.dart';
import 'package:lnc_mach_app/ai/module/module_select/module_select_view.dart';
import 'package:lnc_mach_app/ai/module/profile/profile_bind.dart';
import 'package:lnc_mach_app/ai/module/profile/profile_page.dart';
import 'package:lnc_mach_app/screens/create_machine/create_machine_screen_done.dart';
import 'package:lnc_mach_app/screens/create_machine/create_machine_screen_ip.dart';
import 'package:lnc_mach_app/screens/create_machine/create_machine_screen_name.dart';
import 'package:lnc_mach_app/screens/machine_main/machine_main_screen.dart';
import 'package:lnc_mach_app/screens/machine_scan_screen.dart';
import 'package:lnc_mach_app/screens/main_layout.dart';
import 'package:lnc_mach_app/ai/module/shoufu/shoufuchat_page.dart';
import 'package:lnc_mach_app/ai/module/shoufu/shoufuchat_bind.dart';

part 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(name: Paths.LOGIN, page: () => LoginPage()),
    GetPage(name: Paths.CHAT, page: () => ChatPage(), binding: ChatBind()),
    GetPage(name: Paths.MODULE_SELECT, page: () => const ModuleSelectView()),
    GetPage(
        name: Paths.PROFILE, page: () => ProfilePage(), binding: ProfileBind()),
    GetPage(
        name: Paths.MACHINE_CHAT,
        page: () => MachineChatPage(),
        binding: MachineChatBind()),
    GetPage(
      name: Paths.MANUAL_CHAT,
      page: () => ManualChatPage(),
      binding: ManualChatBind(),
    ),
    GetPage(
      name: Paths.SHOUFU_CHAT,
      page: () => ShoufuChatPage(),
      binding: ShoufuChatBind(),
    ),
    GetPage(name: Paths.MAH_HOME, page: () => const MainLayout(), children: [
      GetPage(
          name: Paths.CREATE_IP,
          page: () => const CreateMahcineIP(),
          children: [
            GetPage(
                name: Paths.CREATE_NAME,
                page: () => CreateMachineName(
                      ip: Get.arguments['ip'],
                    ),
                children: [
                  GetPage(
                      name: Paths.CREATE_DONE,
                      page: () => const CreateMachineDone()),
                ]),
          ]),
    ]),
    GetPage(
        name: Paths.MAH_MACHINE_MAIN,
        page: () => MachineMainScreen(
              ip: Get.arguments['ip'],
              machineName: Get.arguments['machineName'],
            )),
    GetPage(
        name: Paths.MAH_MACHINE_DETECT, page: () => const MachineScanScreen()),
  ];
}
