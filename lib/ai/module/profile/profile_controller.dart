import 'package:get/get.dart';
import 'package:lnc_mach_app/ai/const_api.dart';
import 'package:lnc_mach_app/ai/const_values.dart';
import 'package:lnc_mach_app/ai/module/login/login_controller.dart';
import 'package:lnc_mach_app/ai/module/login/login_provider.dart';
import 'package:lnc_mach_app/ai/module/profile/profile_model.dart';
import 'package:lnc_mach_app/ai/module/profile/profile_provider.dart';
import 'package:lnc_mach_app/ai/utils/storage.dart';
import 'package:lnc_mach_app/global.dart';

class ProfileController extends GetxController with StateMixin {
  final ProfileProvider _provider;
  ProfileController(this._provider);

  ProfileModel profile = ProfileModel();
  List<HistoryQuestionModel> historyQuestions = [];

  @override
  void onInit() {
    super.onInit();
    profile = Global.profile;
    getProfileNHistroy();
  }

  Future<void> getProfileNHistroy() async {
    final result = await _provider.getProfile(
      USER_PROFILE,
      employeeid: Global.profile.employeeId,
    );
    if (result.body?.code == "success") {
      if (result.body?.data?["inquiries"] != null) {
        historyQuestions.clear();
        result.body?.data?["inquiries"].forEach((element) {
          historyQuestions.add(HistoryQuestionModel.fromJson(element));
        });
      }
      change(historyQuestions, status: RxStatus.success());
    } else {
      Get.snackbar("Error", "请求失敗！");
    }
  }

  Future<void> logout() async {
    await LocalStorage().remove(STORAGE_USER_PROFILE_KEY);
    Get.lazyPut(() => LoginController(Get.find()));
    Get.lazyPut(() => LoginProvider());
    Get.offAndToNamed('/login');
  }
}
