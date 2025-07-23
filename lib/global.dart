// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:lnc_mach_app/ai/const_values.dart';
import 'package:lnc_mach_app/ai/module/profile/profile_model.dart';
import 'package:lnc_mach_app/providers/recorn.dart';

import 'ai/utils/storage.dart';

/// 全局配置
class Global {
  static String BaseUrl = "http://8.138.246.252:8000/";

  static String host = BaseUrl;

  /// user
  static late ProfileModel profile;

  ///
  static late Recorn recorn;

  /// init
  static Future init(Function() runApp) async {
    // 运行初始
    WidgetsFlutterBinding.ensureInitialized();

    // 本地存储初始化
    await LocalStorage.init();
    // 读取用户信息
    var profileJSON = LocalStorage().getJSON(STORAGE_USER_PROFILE_KEY);
    if (profileJSON != null) {
      profile = ProfileModel.fromJson(profileJSON);
    } else {
      profile = ProfileModel();
    }

    runApp();

    ///
    recorn = Recorn();
    recorn.LibraryInit();
  }

  // 持久化 用户信息
  static Future<bool> saveProfile(ProfileModel userResponse) {
    profile = userResponse;
    return LocalStorage()
        .setJSON(STORAGE_USER_PROFILE_KEY, userResponse.toJson());
  }
}
