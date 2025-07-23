import 'package:get/get.dart';
import 'package:lnc_mach_app/ai/base/base_provider.dart';
import 'package:lnc_mach_app/ai/base/base_response.dart';

class ProfileProvider extends BaseProvider {
  Future<Response<MapResponse>> getProfile(
    String path, {
    required String? employeeid,
  }) async {
    final result = await post(
      path,
      {
        "employeeId": employeeid,
      },
      decoder: (data) => MapResponse.fromJson(data),
    );
    return result;
  }
}
