import 'package:get/get.dart';
import 'package:lnc_mach_app/ai/module/profile/profile_controller.dart';
import 'package:lnc_mach_app/ai/module/profile/profile_provider.dart';

class ProfileBind extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProfileController(Get.find()));
    Get.lazyPut(() => ProfileProvider());
  }
}
