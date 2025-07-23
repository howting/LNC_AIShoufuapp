import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lnc_mach_app/ai/module/login/login_controller.dart';

class LoginPage extends GetView<LoginController> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Container(
          color: const Color.fromARGB(255, 247, 247, 247),
          child: Column(
            children: [
              SizedBox(
                height: Get.height * .2,
              ),
              Container(
                  width: Get.width - 30.w,
                  margin: EdgeInsets.symmetric(horizontal: 15.w),
                  decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 245, 255, 255),
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 30.h),
                        Text(
                          "宝元AI",
                          style: TextStyle(
                              fontSize: 25.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(255, 51, 51, 51)),
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        inputWidget(controller.usertextController, "工號 :",
                            Icons.person, "請輸入工號"),
                        SizedBox(
                          height: 10.h,
                        ),
                        inputWidget(controller.passtextController, "密碼 :",
                            Icons.key, "請輸入密碼"),
                        SizedBox(
                          height: 20.h,
                        ),
                        GestureDetector(
                          onTap: () => controller.login(),
                          child: Container(
                            height: 50.h,
                            width: 160.w,
                            decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(8.0)),
                            child: Center(
                                child: Text(
                              "登錄",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 16.sp),
                            )),
                          ),
                        ),
                        SizedBox(height: 30.h),
                      ]))
            ],
          ),
        ),
      ),
    );
  }

  Widget inputWidget(TextEditingController controller, String funLabel,
      IconData? iconData, String hintText) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(width: 16.w),
            Icon(
              iconData,
              color: Colors.grey,
              size: 26.sp,
            ),
            SizedBox(width: 5.w),
            Text(
              funLabel,
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500),
            )
          ],
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 236, 236, 236),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
                hintText: hintText,
                border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)))),
          ),
        ),
      ],
    );
  }
}
