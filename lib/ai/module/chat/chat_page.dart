import 'package:extended_text/extended_text.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:lnc_mach_app/ai/module/voice_record/customer_chat_voice_record_bar.dart';
import 'package:lnc_mach_app/ai/module/voice_record/customer_chat_voice_record_layout.dart';
import 'package:lnc_mach_app/ai/routes/app_pages.dart';

import 'InputDetailPage.dart';
import 'chat_controller.dart';

class ChatPage extends GetView<ChatController> {
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
                      "寶元CNC AI售後服務",
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
                                  "範例>>>>> 产业:滑轨机器人，副产业: 车床机器人，控制器型号：RT6200，软件版本：03.03.01.06.58.01， 问题：R11198.2 z轴移动反向无法在R值里进行修改",
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

  Widget leftbubble(String text, int index, {bool isAnswering = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              constraints:
              BoxConstraints(maxWidth: Get.width * 0.7, minWidth: 40.w),
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
              child: ExtendedText(
                _insertLineBreaks(text),
                maxLines: 100,
                textAlign: TextAlign.left,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(left: 20.w, bottom: 6.h),
          child: Row(
            children: [
              ObxValue<RxMap>(
                    (_) => Offstage(
                  offstage: isAnswering,
                  child: InkWell(
                    onTap: () => controller.textToWav(text, index),
                    child: controller.files.containsKey(index)
                        ? const Icon(Icons.play_circle, color: Colors.brown, size: 26)
                        : const Icon(Icons.download_for_offline, color: Colors.brown, size: 26),
                  ),
                ),
                controller.files,
              ),
              SizedBox(width: 6.w),
              InkWell(
                onTap: () {
                  final msg = controller.chatMessageList[index];
                  Get.to(() => InputDetailPage(
                    defaultText: text,
                    originalQuestion: msg.question ?? '未知問題',
                    messageIndex: index,
                  ));
                },
                child: const Icon(Icons.edit_note, color: Colors.blueGrey, size: 26),
              ),
              SizedBox(width: 6.w),
              InkWell(
                onTap: () {
                  final msg = controller.chatMessageList[index];
                  controller.sendLikeFeedback(
                    question: msg.question ?? '未知問題',
                    answer: text,
                  );
                },
                child: const Icon(Icons.sentiment_satisfied_alt, color: Colors.red, size: 26),
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
      height: 55.h,
      width: Get.width,
      child: Row(
        children: [
          Expanded(child: inputWidget()),
          sendButton(),
          addButton(),
          bar,
          cameraButton()
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

  Widget addButton() {
    return InkWell(
      onTap: () => controller.canSend.value
          ? controller.sendAction(isFollowUp: true)
          : null,
      child: Container(
        height: 36.h,
        width: 36.h,
        margin: EdgeInsets.symmetric(horizontal: 5.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(36.h),
          color: const Color.fromARGB(255, 236, 236, 236),
        ),
        child: const Icon(
          Icons.add,
          color: Colors.brown,
          size: 20,
        ),
      ),
    );
  }

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
  String _insertLineBreaks(String text) {
    final pattern = RegExp(r'(?=\d+\.)'); // 例如 1. 2. 3.
    return text
        .split(pattern)
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .join('\n');
  }
}


