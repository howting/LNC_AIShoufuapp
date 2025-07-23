import 'package:get/get.dart';
import 'package:lnc_mach_app/ai/module/chat/chat_controller.dart';
import 'package:lnc_mach_app/ai/module/chat/chat_provider.dart';

class ChatBind extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ChatController(Get.find()));
    Get.lazyPut(() => ChatProvider());
  }
}
