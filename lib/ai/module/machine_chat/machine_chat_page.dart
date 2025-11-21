import 'package:extended_text/extended_text.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:lnc_mach_app/ai/module/machine_chat/machine_chat_controller.dart';
import 'package:lnc_mach_app/ai/module/voice_record/customer_chat_voice_record_bar.dart';
import 'package:lnc_mach_app/ai/module/voice_record/customer_chat_voice_record_layout.dart';
import 'package:lnc_mach_app/ai/routes/app_pages.dart';
//import 'package:lnc_mach_app/widgets/machine_main/machine_appbar.dart';

class MachineChatPage extends GetView<MachineChatController> {
  String formatNumberedList(String text) {
    final buffer = StringBuffer();
    final lines = text.split('\n');

    for (var line in lines) {
      final parts = line.split(',');
      for (var part in parts) {
        final trimmed = part.trim();
        if (trimmed.isEmpty) continue;

        if (RegExp(r'^\d+\.\s*').hasMatch(trimmed)) {
          buffer.writeln(trimmed);
        } else {
          buffer.writeln('- $trimmed');
        }
      }
    }

    return buffer.toString().trim();
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
        child: WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: AnimatedContainer(
            duration: Duration.zero,
            height: MediaQuery.of(context).viewInsets.bottom > 0
                ? Get.height - MediaQuery.of(context).viewInsets.bottom
                : Get.height,
            child: Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.grey),
                  onPressed: () => Get.back(),
                ),
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '參數查詢', // 如果要顯示機台名稱，可改成：controller.machineName
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // 想隱藏 IP 就把這個 Text 拿掉
                    Text(
                      '${controller.ip}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    onPressed: () => Get.toNamed(Routes.PROFILE),
                    icon: const Icon(Icons.person, color: Colors.grey),
                  ),
                ],
              ),
              // AppBar(
              //   backgroundColor: Colors.white,
              //   automaticallyImplyLeading: false,
              //   title: Row(
              //     children: [
              //       Container(
              //           alignment: Alignment.centerLeft,
              //           height: 50.h,
              //           width: 90.w,
              //           child: Image.asset("assets/images/aisalelogo.png")),
              //       Expanded(
              //         child: Text(
              //           "參數查詢",
              //           textAlign: TextAlign.center,
              //           style: TextStyle(
              //               fontSize: 18.sp,
              //               color: Colors.blueAccent,
              //               fontWeight: FontWeight.bold),
              //         ),
              //       ),
              //       InkWell(
              //         onTap: () => Get.toNamed(Routes.PROFILE),
              //         child: const Icon(
              //           Icons.person,
              //           color: Colors.grey,
              //         ),
              //       )
              //     ],
              //   ),
              // ),
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
                                    "",
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
                                    itemCount:
                                        controller.chatMessageList.length,
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
      ),
    );
  }

  Widget buildMessageContent(String text) {
    final lines = formatNumberedList(text).split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Text(
            line,
            style: const TextStyle(fontSize: 18),
          ),
        );
      }).toList(),
    );
  }

  Widget leftbubble(String text, int index, {bool isAnswering = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          constraints:
              BoxConstraints(maxWidth: Get.width * 0.7, minWidth: 40.w),
          margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          padding:
              EdgeInsets.only(right: 8.w, left: 8.w, top: 8.h, bottom: 8.h),
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 218, 218, 218),
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(15),
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15)),
          ),
          child: buildMessageContent(text)
        ),
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
            controller.files),
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
            hintText: "输入你的消息...",
            hintStyle: TextStyle(
                color: Colors.grey, fontWeight: FontWeight.w500, fontSize: 16),
            contentPadding: EdgeInsets.only(left: 16, right: 16)),
      ),
    );
  }

  Widget selectRow() {
    return Obx(() => Container(
      margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
      height: 155.h,
      width: Get.width,
      child: Column(
        children: [
          // 第一列：產業 / 機型
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Get.bottomSheet(
                    optionBottomSheet(OptionsUtils.industrials, (val) {
                      if (val != controller.selectedMachine.value) {
                        controller.selectedMachine(val);
                        controller.selectedModel("请选择机器型号");
                      }
                    }),
                    isScrollControlled: true,
                  ),
                  child: Container(
                    height: 45.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22.5),
                      color: const Color.fromARGB(255, 245, 245, 245),
                    ),
                    child: Text(
                      controller.selectedMachine.value,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: GestureDetector(
                  onTap: () => Get.bottomSheet(
                    optionBottomSheet(
                      OptionsUtils
                          .machineTypeMapping[controller.selectedMachine.value]!,
                          (val) => controller.selectedModel(val),
                    ),
                  ),
                  child: Container(
                    height: 45.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22.5),
                      color: const Color.fromARGB(255, 245, 245, 245),
                    ),
                    child: Text(
                      controller.selectedModel.value,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          // 第二列：單一「請選擇語言」按鈕（只設定國家，不動省份）
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Get.bottomSheet(
                    optionBottomSheet(
                      OptionsUtils.countries,
                          (val) => controller.selectedCountry(val),
                    ),
                    isScrollControlled: true,
                  ),
                  child: Container(
                    height: 45.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22.5),
                      color: const Color.fromARGB(255, 245, 245, 245),
                    ),
                    child: Text(
                      (controller.selectedCountry.value.isEmpty ||
                          controller.selectedCountry.value ==
                              OptionsUtils.countries.first)
                          ? '请选择语言'
                          : controller.selectedCountry.value,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          // 第三列：OS 選擇
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Get.bottomSheet(
                    optionBottomSheet(
                      OptionsUtils.osOptions,
                          (val) => controller.selectedOS(val),
                    ),
                    isScrollControlled: true,
                  ),
                  child: Container(
                    height: 45.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22.5),
                      color: const Color.fromARGB(255, 245, 245, 245),
                    ),
                    child: Obx(() => Text(
                      controller.selectedOS.value,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    )),
                  ),
                ),
              ),
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

  Widget addButton() {
    final controller = Get.find<MachineChatController>();
    return InkWell(
      onTap: () {
        print("点击了添加按钮");
        print("canSend 状态: ${controller.canSend.value}");
          // 调用选择文件并上传的方法
          print("准备调用选择文件方法");
          controller.selectFileAndUpload();
      },
      child: Container(
        height: 36.0,
        width: 36.0,
        margin: EdgeInsets.symmetric(horizontal: 5.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(36.0),
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
}
Widget newQuestionButton() {
  final controller = Get.find<MachineChatController>();

  return GestureDetector(
    onTap: () {
      print("輸出答案按鈕被點擊");
      controller.textController.text = "新問";
      controller.textController.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.textController.text.length),
      );
      controller.sendAction(); // 從 controller 呼叫
    },
    child: Container(
      height: 36.h,
      width: 40.w,
      margin: EdgeInsets.symmetric(horizontal: 5.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(18.h),
      ),
      child: const Text(
        "新問",
        style: TextStyle(color: Colors.white, fontSize: 14),
      ),
    ),
  );
}

Widget outputAnswerButton() {
  final controller = Get.find<MachineChatController>();

  return GestureDetector(
    onTap: () {
      print("輸出答案按鈕被點擊");
      controller.textController.text = "輸出";
      controller.textController.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.textController.text.length),
      );
      controller.sendAction(); // 從 controller 呼叫
    },
    child: Container(
      height: 36.h,
      width: 40.w,
      margin: EdgeInsets.symmetric(horizontal: 5.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(18.h),
      ),
      child: const Text(
        "輸出",
        style: TextStyle(color: Colors.white, fontSize: 14),
      ),
    ),
  );
}