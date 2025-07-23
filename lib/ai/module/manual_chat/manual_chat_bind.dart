import 'package:get/get.dart';
import 'package:lnc_mach_app/ai/module/manual_chat/manual_chat_controller.dart';
import 'package:lnc_mach_app/ai/module/manual_chat/manual_chat_provider.dart';

class ManualChatBind extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ManualChatController(Get.find()));
    Get.lazyPut(() => ManualChatProvider());
  }
}
