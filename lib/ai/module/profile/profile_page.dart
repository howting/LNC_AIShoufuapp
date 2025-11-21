import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lnc_mach_app/ai/base/base_appbar_view.dart';
import 'package:lnc_mach_app/ai/module/profile/profile_controller.dart';
import 'package:lnc_mach_app/ai/module/profile/profile_model.dart';

class ProfilePage extends BaseAppBarView<ProfileController> {
  @override
  Widget body(BuildContext context) {
    return NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: buildProfile(),
            )
          ];
        },
        body: controller.obx(
            (_) => ListView.builder(
                  itemCount: controller.historyQuestions.length,
                  itemBuilder: (BuildContext context, int index) {
                    HistoryQuestionModel item =
                        controller.historyQuestions[index];
                    return buildHistoryQuestion(item);
                  },
                ),
            onLoading: const Center(
              child: CupertinoActivityIndicator(
                color: Colors.grey,
              ),
            )));
  }

  Widget buildProfile() {
    return Container(
      width: Get.width - 40.w,
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      padding: EdgeInsets.symmetric(vertical: 19.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          rowTextWidget("工号 : ", controller.profile.employeeId),
          rowTextWidget("用户名 : ", controller.profile.userName),
          rowTextWidget("手机号 : ", controller.profile.phoneNumber),
          rowTextWidget(
              "在线时长 : ", controller.profile.onlineDuration.toString()),
          rowTextWidget("上次登录 : ", controller.profile.lastLoginTime),
          SizedBox(height: 20.h),
          Container(
            height: 45.h,
            width: Get.width - 64.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "修改密码",
              style: TextStyle(color: Colors.white, fontSize: 16.sp),
            ),
          ),
          SizedBox(height: 10.h),
          GestureDetector(
            onTap: () => Get.defaultDialog(
              titlePadding: const EdgeInsets.all(12.0),
              titleStyle: TextStyle(fontSize: 19.sp),
              middleTextStyle: TextStyle(fontSize: 16.sp),
              title: "确定要退出当前账号吗?",
              middleText: "",
              onConfirm: () async => controller.logout(),
              onCancel: () {},
              cancelTextColor: Colors.black,
              confirmTextColor: Colors.white,
            ),
            child: Container(
              height: 45.h,
              width: Get.width - 64.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "退出账号",
                style: TextStyle(color: Colors.white, fontSize: 16.sp),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget rowTextWidget(String leftText, String? rightText) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Row(children: [
        Text(
          leftText,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
        ),
        Text(
          rightText ?? "",
          maxLines: 3,
          style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16.sp),
        )
      ]),
    );
  }

  Widget buildHistoryQuestion(HistoryQuestionModel historyQuestion) {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          RichText(
            // maxLines: 20,
            text: TextSpan(
              text: "问题内容: ",
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              children: [
                TextSpan(
                  text: historyQuestion.questionContent ?? "",
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 9.h),
          RichText(
            // maxLines: 20,
            text: TextSpan(
              text: "回复内容: ",
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              children: [
                TextSpan(
                  text: historyQuestion.replyContent ?? "",
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 9.h),
          RichText(
            maxLines: 2,
            text: TextSpan(
              text: "提问时间: ",
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              children: [
                TextSpan(
                  text: historyQuestion.questionTime ?? "",
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 9.h),
          RichText(
            maxLines: 2,
            text: TextSpan(
              text: "产业: ",
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              children: [
                TextSpan(
                  text: historyQuestion.selectedMachine ?? "",
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 9.h),
          RichText(
            maxLines: 2,
            text: TextSpan(
              text: "类型: ",
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              children: [
                TextSpan(
                  text: historyQuestion.selectedModel ?? "",
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ]));
  }

  @override
  String get title => "个人中心";
}
