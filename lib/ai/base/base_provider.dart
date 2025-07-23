// ignore_for_file: avoid_print

import 'package:get/get.dart';

import '../../global.dart';

class BaseProvider extends GetConnect {
  @override
  void onInit() {
    allowAutoSignedCert = true;
    httpClient.baseUrl = Global.host;
    httpClient.timeout = const Duration(minutes: 3);

    httpClient.addResponseModifier<dynamic>((request, response) {
      print(response.bodyString);
      return response;
    });

    super.onInit();
  }

  @override
  Future<Response<T>> post<T>(String? url, body,
      {String? contentType,
      Map<String, String>? headers,
      Map<String, dynamic>? query,
      Decoder<T>? decoder,
      Progress? uploadProgress}) {
    Map<String, String> header = headers ?? {};
    // if (Global.profile.userToken != null) {
    //   header.addAll({"Authorization": "Bearer ${Global.profile.userToken}"});
    // }
    return super.post(url, body,
        contentType: contentType,
        headers: header,
        query: query, decoder: (data) {
      if (data is Map) {
        if (data["RC"] != null) {
          // if (data["RC"] == "Unauthorized") {
          //   Fluttertoast.showToast(
          //           msg: "帳號過期請重新登錄。", gravity: ToastGravity.CENTER)
          //       .whenComplete(() => deleteTokenAndReLogin());
          // }
        }
        // else if (data["RC"]["ReqInt"] != null &&
        //     data["RC"]["ReqInt"] == 401) {
        //   if (EasyLoading.isShow) {
        //     EasyLoading.dismiss();
        //   }

        //   Fluttertoast.showToast(
        //           msg: "帳號過期請重新登錄。", gravity: ToastGravity.CENTER)
        //       .whenComplete(() => deleteTokenAndReLogin());
        // }
      }
      return decoder!.call(data);
    }, uploadProgress: uploadProgress);
  }

  // Future<Response<BaseUploadImageResponse>> uploadImage(
  //     List<int> img, String filename) async {
  //   final avatar = MultipartFile(img, filename: filename);
  //   final oldUrl = Global.host;
  //   httpClient.baseUrl = Global.imageHost;

  //   final result = await post(
  //     "/api/file/UploadMobileAppFileTo",
  //     FormData({'file': avatar}),
  //     headers: {"Authorization": "Bearer ${Global.profile.userToken}"},
  //     decoder: (data) => BaseUploadImageResponse.fromJson(data),
  //   );
  //   httpClient.baseUrl = oldUrl;
  //   return result;
  // }

  // Future<Response<BaseUploadImageResponse>> deleteImage(String imageUrl) async {
  //   final oldUrl = Global.host;
  //   httpClient.baseUrl = Global.imageHost;
  //   final result = await post(
  //     "/api/file/DeleSingleFile",
  //     {'FilePath': imageUrl},
  //     headers: {"Authorization": "Bearer ${Global.profile.userToken}"},
  //     decoder: (data) => BaseUploadImageResponse.fromJson(data),
  //   );
  //   httpClient.baseUrl = oldUrl;
  //   return result;
  // }
}
