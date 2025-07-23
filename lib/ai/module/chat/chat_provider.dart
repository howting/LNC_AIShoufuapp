import 'package:get/get_connect/http/src/multipart/form_data.dart';
import 'package:get/get_connect/http/src/multipart/multipart_file.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:lnc_mach_app/ai/base/base_response.dart';
import 'package:lnc_mach_app/ai/base/base_provider.dart';
import 'package:lnc_mach_app/global.dart';

class ChatProvider extends BaseProvider {
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
        "selected_country": selectedCountry,
        "selected_province": selectedProvince,
        "selected_machine": selectedMachine,
        "selected_model": selectedModel,
      }),
      decoder: (data) => BaseWavResponse.fromJson(data),
    );
    return result;
  }
  Future<Response<BasefeedResponse>> modifyReply(String path, Map<String, dynamic> data) async {
    final result = await post(
      path,
      data,
      decoder: (data) => BasefeedResponse.fromJson(data),
    );
    return result;
  }
  /// 按讚意見回饋
  Future<Response<BasefeedResponse>> likeReply(String path, Map<String, dynamic> data) async {
    final result = await post(
      path,
      data,
      decoder: (json) => BasefeedResponse.fromJson(json),
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
