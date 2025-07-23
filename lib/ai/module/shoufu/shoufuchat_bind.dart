import 'package:get/get.dart';
import 'package:lnc_mach_app/ai/module/shoufu/shoufuchat_controller.dart';
import 'package:lnc_mach_app/ai/module/shoufu/shoufuchat_provider.dart';

class ShoufuChatBind extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ShoufuChatController(Get.find()));
    Get.lazyPut(() => ShoufuChatProvider());
  }
}
