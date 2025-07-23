import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:lnc_mach_app/ai/const_api.dart';
import 'package:lnc_mach_app/ai/module/login/login_provider.dart';
import 'package:lnc_mach_app/ai/module/profile/profile_model.dart';
import 'package:lnc_mach_app/ai/routes/app_pages.dart';
import 'package:lnc_mach_app/global.dart';

class LoginController extends GetxController {
  final LoginProvider _provider;
  LoginController(this._provider);

  TextEditingController usertextController = TextEditingController();
  TextEditingController passtextController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  Future<void> login() async {
    if (usertextController.text.isEmpty || passtextController.text.isEmpty) {
      Get.snackbar("Error", "工號或密碼不能為空！");
    }

    final result = await _provider.login(LOGIN_POST,
        employeeid: usertextController.text, password: passtextController.text);
    if (result.body?.data != null && result.body?.code == "success") {
      final userProfile = ProfileModel.fromJson(result.body?.data?["user"]);
      Global.saveProfile(userProfile);
      Get.toNamed(Routes.MODULE_SELECT);
    } else {
      Get.snackbar("Error", "登入失敗！");
    }
    print(result);
  }
}
