import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:lnc_mach_app/ai/routes/app_pages.dart';
import 'package:lnc_mach_app/global.dart';
import 'package:lnc_mach_app/providers/recorn.dart';



class ModuleSelectView extends StatefulWidget {
  const ModuleSelectView({super.key});

  @override
  State<ModuleSelectView> createState() => _ModuleSelectViewState();
}

class _ModuleSelectViewState extends State<ModuleSelectView> {
  // RegExp: ip address regx
  RegExp ipExp = RegExp(
      r"^(?!0)(?!.*\.$)((1?\d?\d|25[0-5]|2[0-4]\d)(\.|$)){4}$",
      caseSensitive: false,
      multiLine: false);
  TextEditingController textCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // 可选：退出前清理
        Global.recorn.clearTestingConnection();
        Global.recorn.disconnect();
        Global.recorn.cleanIsolate();
        return true; // 允许系统执行返回（在根路由上=退出App）
      },
      child: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 80.h),

            // AI售服
            Expanded(
              child: GestureDetector(
                onTap: () => Get.toNamed(Routes.CHAT),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    margin: const EdgeInsets.all(10.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.3),
                          offset: const Offset(1.5, 3),
                          blurRadius: 5,
                          spreadRadius: 0.0,
                        )
                      ],
                      border: Border.all(width: .2, color: Colors.transparent),
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.support_agent, color: Color(0xFF00ABB3), size: 33),
                        SizedBox(height: 10),
                        Text(
                          "售服机器人",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 參數查詢
            Expanded(
              child: GestureDetector(
                onTap: () => Get.toNamed(Routes.MACHINE_CHAT),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    margin: const EdgeInsets.all(10.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.3),
                          offset: const Offset(1.5, 3),
                          blurRadius: 5,
                          spreadRadius: 0.0,
                        )
                      ],
                      border: Border.all(width: .2, color: Colors.transparent),
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.screen_search_desktop, color: Color(0xFF00ABB3), size: 33),
                        SizedBox(height: 10),
                        Text(
                          "參數查詢",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 手冊查詢
            Expanded(
              child: GestureDetector(
                onTap: () => Get.toNamed(Routes.MANUAL_CHAT),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    margin: const EdgeInsets.all(10.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.3),
                          offset: const Offset(1.5, 3),
                          blurRadius: 5,
                          spreadRadius: 0.0,
                        )
                      ],
                      border: Border.all(width: .2, color: Colors.transparent),
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.menu_book, color: Color(0xFF00ABB3), size: 33),
                        SizedBox(height: 10),
                        Text(
                          "手冊查詢",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 售服紀錄（新增）
            Expanded(
              child: GestureDetector(
                onTap: () => Get.toNamed(Routes.SHOUFU_CHAT), // ⚠️ 確保你有在 app_pages.dart 註冊此路由
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    margin: const EdgeInsets.all(10.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.3),
                          offset: const Offset(1.5, 3),
                          blurRadius: 5,
                          spreadRadius: 0.0,
                        )
                      ],
                      border: Border.all(width: .2, color: Colors.transparent),
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, color: Color(0xFF00ABB3), size: 33),
                        SizedBox(height: 10),
                        Text(
                          "AI售服查询",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 80.h),
          ],
        ),
      ),
    );
  }
  Widget addTipsDialog() {
    return GestureDetector(
      onTap: () => FocusScope.of(Get.context!).requestFocus(FocusNode()),
      child: Container(
        height: Get.height,
        width: Get.width,
        color: Colors.black12,
        child: Column(
          children: [
            SizedBox(height: Get.height * .18),
            Container(
              height: Get.height * .3,
              width: Get.width - 60,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(15)),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("输入控制器IP",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 17,
                              color: Color(0xFF00ABB3))),
                      ExtendedTextField(
                        controller: textCtl,
                        minLines: 1,
                        maxLines: 3,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "IP地址",
                            hintStyle: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                                fontSize: 16),
                            contentPadding: EdgeInsets.only(
                                left: 16, top: 13, bottom: 13, right: 16)),
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.all(Colors.white),
                                  shape: WidgetStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15)))),
                              child: const Text("取消",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 17,
                                      color: Color(0xFF00ABB3))),
                              onPressed: () {
                                Get.back();
                                textCtl.clear();
                              }),
                          SizedBox(width: 16.w),
                          ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(
                                      const Color(0xFF00ABB3)),
                                  shape: WidgetStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15)))),
                              child: const Text("確定",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 17,
                                      color: Colors.white)),
                              onPressed: () {}),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function: handle submit and check ip address
  Future<void> handleSubmit() async {
    final String ip = textCtl.value.text;
    if (!ipExp.hasMatch(ip)) {
      Fluttertoast.showToast(
          msg: "Please enter a correct IP address",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black87,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }

    // bool: test connect and return connect status true of false
    bool isConnectStateSuccess = await Global.recorn.testConnection(ip);

    if (isConnectStateSuccess) {
      Fluttertoast.showToast(
          msg: "Connect Successful",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black87,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      Fluttertoast.showToast(
          msg: 'Connection time out',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black87,
          textColor: Colors.white,
          fontSize: 16.0);
    }
    Global.recorn.disconnect();
    Global.recorn.cleanIsolate();
  }

  @override
  void dispose() {
    Global.recorn.clearTestingConnection();
    super.dispose();
  }
}
