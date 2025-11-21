import 'package:extended_text/extended_text.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:lnc_mach_app/ai/module/voice_record/customer_chat_voice_record_bar.dart';
import 'package:lnc_mach_app/ai/module/voice_record/customer_chat_voice_record_layout.dart';
import 'package:lnc_mach_app/ai/routes/app_pages.dart';
import 'dart:io';
import 'InputDetailPage.dart';
import 'chat_controller.dart';

import 'package:image_picker/image_picker.dart';



class SpinnerGif extends StatelessWidget {
  final double size;
  const SpinnerGif({super.key, this.size = 20});
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/gifs/Spinner-2.gif',
      width: size,
      height: size,
      gaplessPlayback: true, // GIF 切換時更順
    );
  }
}

class ChatPage extends GetView<ChatController> {
  final ImagePicker _picker = ImagePicker();
  List<String> imageFiles = []; // Base64 字串列表
  @override
  Widget build(BuildContext context) {
    precacheImage(const AssetImage('assets/gifs/Spinner-2.gif'), context);
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
                      "宝元CNC AI售后服务机器人",
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
                                        ? rightbubble(message)
                                        : leftbubble(message, index,
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
  Widget buildPanel(List<ReplyMessage> replies, String question) {
    RxList<ReplyMessage> replyList = RxList(replies);

    return ObxValue<RxList<ReplyMessage>>(
          (list) => ExpansionPanelList(
        elevation: 0,
        dividerColor: Colors.transparent,
        expandIconColor: Colors.blue,
        materialGapSize: 0,
        expandedHeaderPadding: EdgeInsets.zero,
        expansionCallback: (int index, bool isExpanded) {
          replyList[index].isExpanded = !isExpanded;
          replyList.refresh();
        },
        children: replyList.map<ExpansionPanel>((ReplyMessage item) {
          return ExpansionPanel(
            headerBuilder: (context, isExpanded) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Text(
                item.title ?? "",
                style: const TextStyle(fontSize: 14, color: Colors.blue, fontWeight: FontWeight.w500),
              ),
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: Text(item.comment ?? ""),
                ),
                Row(
                  children: [
                    const SizedBox(width: 16),
                    ObxValue<RxMap>(
                          (_) => InkWell(
                        onTap: () => controller.textToWav(item.comment ?? "", item.hashCode),
                        child: controller.files.containsKey(item.hashCode)
                            ? const Icon(Icons.play_circle, color: Colors.brown, size: 22)
                            : const Icon(Icons.download_for_offline, color: Colors.brown, size: 22),
                      ),
                      controller.files,
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: () => controller.sendLikeFeedback(
                        question: question,
                        answer: item.comment ?? "",
                      ),
                      child: const Icon(Icons.thumb_up, color: Colors.green, size: 22),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
              ],
            ),
            isExpanded: item.isExpanded,
            backgroundColor: Colors.transparent,
          );
        }).toList(),
      ),
      replyList,
    );
  }


  Widget leftbubble(ChatMessage message, int index, {bool isAnswering = false}) {
    final content = (message.replyList == null)
        ? ExtendedText(
      message.data,
      maxLines: 100,
      textAlign: TextAlign.left,
      style: const TextStyle(fontSize: 18),
    )
        : SingleChildScrollView(
      child: buildPanel(message.replyList!, message.question ?? ""),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: Get.width * 0.7, minWidth: 40.w),
              margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              child: isAnswering
              // 等待中：顯示轉圈圈 +（可選）一小段提示文字
                  ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SpinnerGif(size: 20),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      (message.data.isEmpty) ? "生成中…" : message.data,
                      style: const TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ),
                ],
              )
              // 已回覆：顯示真正內容
                  : content,
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(left: 20.w, bottom: 6.h),
          child: Row(
            children: [
              // 等待中就先不顯示語音下載/播放
              ObxValue<RxMap>(
                    (_) => Offstage(
                  offstage: isAnswering,
                  child: InkWell(
                    onTap: () => controller.textToWav(message.data, index),
                    child: controller.files.containsKey(index)
                        ? const Icon(Icons.play_circle, color: Colors.brown, size: 26)
                        : const Icon(Icons.download_for_offline, color: Colors.brown, size: 26),
                  ),
                ),
                controller.files,
              ),
              SizedBox(width: 6.w),
            ],
          ),
        ),
      ],
    );
  }
  Widget rightbubble(ChatMessage message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: Get.width * 0.7, minWidth: 40.w),
              margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              padding: EdgeInsets.only(right: 4.w, left: 8.w, top: 8.h, bottom: 8.h),
              decoration: const BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              child: ExtendedText(
                message.data,
                maxLines: 20,
                textAlign: TextAlign.left,
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),

        // ✅ 顯示上傳的圖片（僅限 isMe=true 時顯示）
        if (message.isMe && message.images != null && message.images!.isNotEmpty)
          Container(
            height: 80.h,
            margin: EdgeInsets.only(right: 12.w, bottom: 8.h),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: message.images!.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(left: 8.w),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(message.images![index].path),
                      width: 80.w,
                      height: 80.h,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
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
      height: 100.h,
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
                      OptionsUtils.countries, // 使用語系代碼清單
                          (val) {
                        controller.selectedCountry(val);
                        // 不重置 province
                      },
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
                          controller.selectedCountry.value == 'Select Language')
                          ? '请选择语言'
                          : controller.selectedCountry.value,
                      // 👇 少的就是這個逗號
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
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
      onTap: () async {
        await controller.pickImages();;
        Get.snackbar("圖片上傳", "共選擇 ${controller.base64Images.length} 張圖片");
      },
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


