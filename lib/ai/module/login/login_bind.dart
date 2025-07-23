import 'package:get/get.dart';
import 'package:lnc_mach_app/ai/module/login/login_controller.dart';
import 'package:lnc_mach_app/ai/module/login/login_provider.dart';

class LoginBind extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginController(Get.find()));
    Get.lazyPut(() => LoginProvider());
  }
}
