import 'package:extended_text/extended_text.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:lnc_mach_app/ai/module/voice_record/customer_chat_voice_record_bar.dart';
import 'package:lnc_mach_app/ai/module/voice_record/customer_chat_voice_record_layout.dart';
import 'package:lnc_mach_app/ai/routes/app_pages.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';


import 'simple_image_view.dart';
import 'manual_chat_controller.dart';

class ManualChatPage extends GetView<ManualChatController> {
  String formatNumberedList(String text) {
    final pattern = RegExp(r'(?=(?:^|\s)\d+\.)');
    final parts = text.split(pattern).where((e) => e.trim().isNotEmpty).toList();
    return parts.join('\n').trim(); // 每段加換行
  }
  @override
  Widget build(BuildContext context) {
    return CustomerChatVoiceRecordLayout(
      onCompleted: (sec, path) {
        if (sec == 0) {
          Fluttertoast.showToast(msg: "語音時間過短。", gravity: ToastGravity.CENTER);
          return;
        }
        print("onCompleted: $sec, $path");
        controller.makeBase64(path);
      },
      builder: (bar) => GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: AnimatedContainer(
          duration: Duration.zero,
          height: MediaQuery.of(context).viewInsets.bottom > 0
              ? Get.height - MediaQuery.of(context).viewInsets.bottom
              : Get.height,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              automaticallyImplyLeading: false,
              title: Row(
                children: [
                  Container(
                      alignment: Alignment.centerLeft,
                      height: 50.h,
                      width: 90.w,
                      child: Image.asset("assets/images/aisalelogo.png")),
                  Expanded(
                    child: Text(
                      "宝元LNC手册查询服务",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 18.sp,
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  InkWell(
                    onTap: () => Get.toNamed(Routes.PROFILE),
                    child: const Icon(
                      Icons.person,
                      color: Colors.grey,
                    ),
                  )
                ],
              ),
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                    child: ObxValue<RxList>(
                            (list) => controller.chatMessageList.isEmpty
                            ? Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30.0),
                          margin: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 5.h),
                          decoration: BoxDecoration(
                              color: const Color.fromARGB(
                                  255, 238, 238, 238),
                              borderRadius: BorderRadius.circular(15)),
                          child: const Text(
                            "范例>>>>> 产业:铣床，控制器型号：MG5800A， G34：可变螺距螺纹切削",
                            style: TextStyle(
                                color: Colors.black26, fontSize: 16),
                          ),
                        )
                            : Container(
                          padding: EdgeInsets.only(top: 12.h),
                          margin: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 5.h),
                          decoration: BoxDecoration(
                              color: const Color.fromARGB(
                                  255, 238, 238, 238),
                              borderRadius: BorderRadius.circular(15)),
                          child: ListView.builder(
                            itemCount: controller.chatMessageList.length,
                            itemBuilder:
                                (BuildContext context, int index) {
                              ChatMessage message =
                              controller.chatMessageList[index];
                              return message.isMe
                                  ? rightbubble(message.data)
                                  : leftbubble(message.data, index,
                                  isAnswering: message.isAnswering);
                            },
                          ),
                        ),
                        controller.chatMessageList)),
                selectRow(),
                buttonRow(bar),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget buildMessageContent(String text) {
    final RegExp imageReg = RegExp(r'(https?:\/\/[^\s]+\.(?:png|jpg|jpeg|gif))');
    final matches = imageReg.allMatches(text);

    if (matches.isEmpty) {
      // 沒有圖片網址，只顯示文字 + 連結
      return SelectableLinkify(
        text: text,
        options: const LinkifyOptions(humanize: false),
        style: const TextStyle(fontSize: 18),
        onOpen: (link) async {
          final uri = Uri.parse(link.url.startsWith('http') ? link.url : 'https://${link.url}');
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            Fluttertoast.showToast(msg: "無法開啟連結：${link.url}");
          }
        },
      );
    } else {
      List<Widget> widgets = [];
      int lastEnd = 0;

      for (final match in matches) {
        final before = text.substring(lastEnd, match.start);
        final imageUrl = match.group(0)!;
        lastEnd = match.end;

        if (before.trim().isNotEmpty) {
          widgets.add(SelectableLinkify(
            text: formatNumberedList(before.trim()),
            options: const LinkifyOptions(humanize: false),
            style: const TextStyle(fontSize: 18),
            onOpen: (link) async {
              final uri = Uri.parse(link.url.startsWith('http') ? link.url : 'https://${link.url}');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                Fluttertoast.showToast(msg: "無法開啟連結：${link.url}");
              }
            },
          ));
        }

        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 6),
            child: GestureDetector(
              onTap: () {
                Get.to(() => SimpleImageView(imageUrl: imageUrl));
              },
              child: Image.network(
                imageUrl,
                width: 200,
                errorBuilder: (_, __, ___) {
                  return Text(
                    "⚠️ 圖片載入失敗：$imageUrl",
                    style: const TextStyle(fontSize: 14, color: Colors.red),
                  );
                },
              ),
            ),
          ),
        );

      }

      final last = text.substring(lastEnd);
      if (last.trim().isNotEmpty) {
        widgets.add(SelectableLinkify(
          text: formatNumberedList(last.trim()),
          options: const LinkifyOptions(humanize: false),
          style: const TextStyle(fontSize: 18),
          onOpen: (link) async {
            final uri = Uri.parse(link.url.startsWith('http') ? link.url : 'https://${link.url}');
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } else {
              Fluttertoast.showToast(msg: "無法開啟連結：${link.url}");
            }
          },
        ));
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets,
      );
    }
  }

  Widget leftbubble(String text, int index, {bool isAnswering = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: Get.width * 0.7, minWidth: 40.w),
          margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 218, 218, 218),
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(15),
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildMessageContent(text), // 🔁 核心處理函式
              ObxValue<RxMap>(
                    (_) => Offstage(
                          offstage: false,
                          child: InkWell(
                            onTap: () {
                              print("播放文本 index: $index, 文本内容: ${controller.chatMessageList[index].data}");
                              controller.textToWav(controller.chatMessageList[index].data, index);
                            },
                            child: controller.files.containsKey(index)
                                ? const Icon(
                                  Icons.play_circle,
                                  color: Colors.brown,
                                  size: 26,
                                  )
                                : const Icon(
                                  Icons.download_for_offline,
                                  color: Colors.brown,
                                  size: 26,
                                  ),
                          ),
                    ),
                    controller.files,
              ),
            ],
          ),
        ),
      ],
    );
  }
  Widget rightbubble(String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          constraints:
          BoxConstraints(maxWidth: Get.width * 0.7, minWidth: 40.w),
          margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          padding:
          EdgeInsets.only(right: 4.w, left: 8.w, top: 8.h, bottom: 8.h),
          decoration: const BoxDecoration(
            color: Colors.blueAccent,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15)),
          ),
          child: ExtendedText(
            text,
            maxLines: 20,
            textAlign: TextAlign.left,
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget inputWidget() {
    return Container(
      alignment: Alignment.center,
      width: Get.width,
      height: 60.h,  // 明確指定高度，比原本高一些
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22.5),
        color: const Color.fromARGB(255, 245, 245, 245),
      ),
      child: ExtendedTextField(
        controller: controller.textController,
        focusNode: controller.textFocusNode,
        minLines: 1,
        maxLines: 4,
        decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: "輸入你的消息...",
            hintStyle: TextStyle(
                color: Colors.grey, fontWeight: FontWeight.w500, fontSize: 16),
            contentPadding: EdgeInsets.only(left: 16, right: 16)),
      ),
    );
  }

  Widget selectRow() {
    return Obx(() => Container(
      margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
      height: 100.h,
      width: Get.width,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: GestureDetector(
                    onTap: () => Get.bottomSheet(
                        optionBottomSheet(OptionsUtils.industrials, (val) {
                          if (val == controller.selectedMachine.value) {
                          } else {
                            controller.selectedMachine(val);
                            controller.selectedModel("请选择机器型号");
                          }
                        }),
                        isScrollControlled: true),
                    child: Container(
                      height: 45.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22.5),
                        color: const Color.fromARGB(255, 245, 245, 245),
                      ),
                      child: Text(
                        controller.selectedMachine.value,
                        style:
                        const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  )),
              SizedBox(width: 10.w),
              Expanded(
                  child: GestureDetector(
                    onTap: () => Get.bottomSheet(optionBottomSheet(
                        OptionsUtils.machineTypeMapping[
                        controller.selectedMachine.value]!,
                            (val) => controller.selectedModel(val))),
                    child: Container(
                      height: 45.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22.5),
                        color: const Color.fromARGB(255, 245, 245, 245),
                      ),
                      child: Text(
                        controller.selectedModel.value,
                        style:
                        const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  )),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                  child: GestureDetector(
                    onTap: () => Get.bottomSheet(
                        optionBottomSheet(OptionsUtils.countries, (val) {
                          if (val == controller.selectedCountry.value) {
                          } else {
                            controller.selectedCountry(val);
                            controller.selectedProvince("请选择省份");
                          }
                        })),
                    child: Container(
                      height: 45.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22.5),
                        color: const Color.fromARGB(255, 245, 245, 245),
                      ),
                      child: Text(
                        controller.selectedCountry.value,
                        style:
                        const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  )),
              SizedBox(width: 10.w),
              Expanded(
                  child: GestureDetector(
                    onTap: () => Get.bottomSheet(optionBottomSheet(
                        OptionsUtils.countryProvinceMapping[
                        controller.selectedCountry.value]!,
                            (val) => controller.selectedProvince(val))),
                    child: Container(
                      height: 45.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22.5),
                        color: const Color.fromARGB(255, 245, 245, 245),
                      ),
                      child: Text(
                        controller.selectedProvince.value,
                        style:
                        const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  )),
            ],
          ),
        ],
      ),
    ));
  }

  Widget optionBottomSheet(
      List<String> options, Function(String option) selectAction) {
    return Container(
      height:
      options.length >= 7 ? Get.height * .6 : options.length * 60.h + 50.h,
      padding: EdgeInsets.only(top: 20.h),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: ListView.builder(
        itemCount: options.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              selectAction(options[index]);
              Get.back();
            },
            child: Container(
              decoration: const BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: Color.fromARGB(255, 247, 247, 247)))),
              height: 60.h,
              width: Get.width,
              child: Center(
                child: Text(
                  options[index],
                  style: const TextStyle(
                      fontSize: 16, color: Color.fromARGB(255, 105, 105, 105)),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buttonRow(CustomerChatVoiceRecordBar bar) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
      width: Get.width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 第一行：輸入框 + 送出按鈕
          Row(
            children: [
              Expanded(child: inputWidget()),
              SizedBox(width: 8.w), // 間距
              sendButton(),
            ],
          ),

          SizedBox(height: 8.h), // 行間距

          // 第二行：其他按鈕排列
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              newQuestionButton(),
              SizedBox(width: 8.w),
              outputAnswerButton(),
              SizedBox(width: 8.w),
              bar,
              SizedBox(width: 8.w),
              cameraButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget sendButton() {
    return GestureDetector(
      onTap: () => controller.canSend.value ? controller.sendAction() : null,
      child: Container(
        height: 36.h,
        width: 36.h,
        margin: EdgeInsets.symmetric(horizontal: 5.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(36.h),
          color: const Color.fromARGB(255, 236, 236, 236),
        ),
        child: const Icon(
          Icons.near_me,
          color: Colors.brown,
          size: 20,
        ),
      ),
    );
  }

  //Widget addButton() {
    //return InkWell(
      //onTap: () => controller.canSend.value
          //? controller.sendAction(isFollowUp: true)
          //: null,
      //child: Container(
        //height: 36.h,
        //width: 36.h,
        //margin: EdgeInsets.symmetric(horizontal: 5.w),
        //decoration: BoxDecoration(
          //borderRadius: BorderRadius.circular(36.h),
          //color: const Color.fromARGB(255, 236, 236, 236),
        //),
        //child: const Icon(
          //Icons.add,
          //color: Colors.brown,
          //size: 20,
        //),
      //),
    //);
  //}

  Widget cameraButton() {
    return InkWell(
      // onTap: () => controller.canSend.value ? controller.sendAction() : null,
      child: Container(
        height: 36.h,
        width: 36.h,
        margin: EdgeInsets.symmetric(horizontal: 5.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(36.h),
          color: const Color.fromARGB(255, 236, 236, 236),
        ),
        child: const Icon(
          Icons.photo_camera,
          color: Colors.brown,
          size: 20,
        ),
      ),
    );
  }
}
Widget newQuestionButton() {
  final controller = Get.find<ManualChatController>();

  return GestureDetector(
    onTap: () {
      print("提出新問題的按鈕被點擊");
      controller.textController.text = "新问";
      controller.textController.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.textController.text.length),
      );
      controller.sendAction(); // 從 controller 呼叫
    },
    child: Container(
      height: 36.h,
      width: 36.w,
      margin: EdgeInsets.symmetric(horizontal: 5.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(18.h),
      ),
      child: const Text(
        "新问",
        style: TextStyle(color: Colors.white, fontSize: 14),
      ),
    ),
  );
}

Widget outputAnswerButton() {
  final controller = Get.find<ManualChatController>();

  return GestureDetector(
    onTap: () {
      print("输出答案按钮被点击");
      controller.textController.text = "输出";
      controller.textController.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.textController.text.length),
      );
      controller.sendAction(); // 從 controller 呼叫
    },
    child: Container(
      height: 36.h,
      width: 36.w,
      margin: EdgeInsets.symmetric(horizontal: 5.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(18.h),
      ),
      child: const Text(
        "输出",
        style: TextStyle(color: Colors.white, fontSize: 14),
      ),
    ),
  );
}