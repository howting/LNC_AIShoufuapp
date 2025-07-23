import 'package:get/get_connect/http/src/multipart/form_data.dart';
import 'package:get/get_connect/http/src/multipart/multipart_file.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:lnc_mach_app/ai/base/base_response.dart';
import 'package:lnc_mach_app/ai/base/base_provider.dart';
import 'package:lnc_mach_app/global.dart';

class ManualChatProvider extends BaseProvider {
  Future<Response<MapResponse>> qwen2text(String path,
      {required String? text,
      bool isFollowUp = false,
      String? selectedCountry,
      String? selectedProvince,
      String? selectedMachine,
      String? selectedModel}) async {
    final result = await post(
      path,
      {
        "input_value": text,
        "employeeId": Global.profile.employeeId,
        "images": [],
        "manual_app": "true",
        "is_follow_up": isFollowUp,
        "selected_country": selectedCountry,
        "selected_province": selectedProvince,
        "selected_machine": selectedMachine,
        "selected_model": selectedModel,
      },
      decoder: (data) => MapResponse.fromJson(data),
    );
    return result;
  }

  Future<Response<BaseWavResponse>> wav2text(
      String path, List<int> data, String filename,
      {String? selectedCountry,
      String? selectedProvince,
      String? selectedMachine,
      String? selectedModel}) async {
    final audio = MultipartFile(data, filename: filename);
    final result = await post(
      path,
      FormData({
        'audio': audio,
        "employeeId": Global.profile.employeeId,
        "images": [],
        "manual_app": "true",
        "selected_country": selectedCountry,
        "selected_province": selectedProvince,
        "selected_machine": selectedMachine,
        "selected_model": selectedModel,
      }),
      decoder: (data) => BaseWavResponse.fromJson(data),
    );
    return result;
  }

  Future<Response<BaseResponse>> textToWav(String path,
      {required String? text}) async {
    final result = await post(
      path,
      {
        "input_value": text,
      },
      decoder: (data) => BaseResponse.fromJson(data),
    );
    return result;
  }
}
