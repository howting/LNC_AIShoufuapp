class BaseResponse {
  String? code;
  String? data;
  String? error;

  BaseResponse({this.code, this.data, this.error});

  factory BaseResponse.fromJson(Map<String, dynamic> json) => BaseResponse(
      code: json["code"], data: json["data"], error: json["error"]);
}
//語音返回格式
class BaseWavResponse {
  String? code;
  Map? data;

  BaseWavResponse({this.code, this.data});

  factory BaseWavResponse.fromJson(Map<String, dynamic> json) =>
      BaseWavResponse(code: json["code"], data: json["data"]);
}

//文本返回格式
class MapResponse {
  String? code;
  Map? data;

  MapResponse({this.code, this.data});

  factory MapResponse.fromJson(Map<String, dynamic> json) =>
      MapResponse(code: json["code"], data: json["data"]);
}

class BaseUploadImageResponse {
  int? code;
  String message;
  List? data;

  BaseUploadImageResponse({this.code, this.message = '', this.data});

  factory BaseUploadImageResponse.fromJson(Map<String, dynamic> json) =>
      BaseUploadImageResponse(
          message: json["msg"], code: json["code"], data: json["data"]);
}
class BasefeedResponse {
  final String? message;

  BasefeedResponse({this.message});

  factory BasefeedResponse.fromJson(Map<String, dynamic> json) {
    return BasefeedResponse(
      message: json['message'] ?? json['error'] ?? '',
    );
  }
}