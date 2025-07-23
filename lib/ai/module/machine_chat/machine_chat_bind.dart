import 'package:get/get.dart';
import 'package:lnc_mach_app/ai/module/machine_chat/machine_chat_controller.dart';
import 'package:lnc_mach_app/ai/module/machine_chat/machine_chat_provider.dart';

class MachineChatBind extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MachineChatController(Get.find()));
    Get.lazyPut(() => MachineChatProvider());
  }
}
