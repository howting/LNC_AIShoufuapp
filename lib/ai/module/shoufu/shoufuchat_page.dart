import 'package:extended_text/extended_text.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:lnc_mach_app/ai/module/voice_record/customer_chat_voice_record_bar.dart';
import 'package:lnc_mach_app/ai/module/voice_record/customer_chat_voice_record_layout.dart';
import 'package:lnc_mach_app/ai/routes/app_pages.dart';

import 'shoufuInputDetailPage.dart';
import 'shoufuchat_controller.dart';

class ShoufuChatPage extends GetView<ShoufuChatController> {
  @override
  Widget build(BuildContext context) {
    return CustomerChatVoiceRecordLayout(
      onCompleted: (sec, path) {
        // 不在這裡判斷時間長短，交給 controller 做（會同時看秒數 + 檔案大小）
        print("onCompleted: $sec, $path");
        controller.makeBase64(path, durationSec: sec);
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
                      "宝元 AI售后服务查询",
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
                    child: ObxValue<RxList>((list) => controller.chatMessageList.isEmpty
                        ? Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 238, 238, 238),
                          borderRadius: BorderRadius.circular(15)),
                      child: const Text(
                        "範例>>>>> 产业：铣床，次产业：铣床，问题：IO板通讯错误",
                        style: TextStyle(color: Colors.black26, fontSize: 16),
                      ),
                    )
                        : Container(
                      padding: EdgeInsets.only(top: 12.h),
                      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 238, 238, 238),
                          borderRadius: BorderRadius.circular(15)),
                      child: ListView.builder(
                        itemCount: controller.chatMessageList.length,
                        itemBuilder: (BuildContext context, int index) {
                          ChatMessage message = controller.chatMessageList[index];
                          return message.isMe
                              ? rightbubble(message.data)
                              : leftbubble(message, index, isAnswering: message.isAnswering);
                        },
                      ),
                    ), controller.chatMessageList)),
                selectRow(),
                buttonRow(bar),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget leftbubble(ChatMessage message, int index, {bool isAnswering = false}) {
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
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: isAnswering
                // 👉 生成中（顯示轉圈圈）
                    ? Row(
                  key: const ValueKey('typing'),
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text('生成中…', style: TextStyle(fontSize: 16)),
                  ],
                )
                // 👉 已有內容（文字或面板）
                    : (message.replyList == null
                    ? _buildMaybeImage(message.data)
                    : SingleChildScrollView(
                  key: const ValueKey('panel'),
                  child: buildPanel(
                    message.replyList!,
                    (message.question?.trim().isNotEmpty ?? false)
                        ? message.question!
                        : Get.find<ShoufuChatController>().lastUserQuestion.value,
                  ),
                )),
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(left: 20.w, bottom: 6.h),
          child: Row(
            children: [
              ObxValue<RxMap>((_) => Offstage(
                offstage: isAnswering, // 生成中時隱藏 TTS按鈕
                child: InkWell(
                  onTap: () => controller.textToWav(message.data, index),
                  child: controller.files.containsKey(index)
                      ? const Icon(Icons.play_circle, color: Colors.brown, size: 26)
                      : const Icon(Icons.download_for_offline, color: Colors.brown, size: 26),
                ),
              ), controller.files),
              SizedBox(width: 6.w),
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
          constraints: BoxConstraints(maxWidth: Get.width * 0.7, minWidth: 40.w),
          margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          padding: EdgeInsets.only(right: 4.w, left: 8.w, top: 8.h, bottom: 8.h),
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
            hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500, fontSize: 16),
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
                      OptionsUtils.machineTypeMapping[controller.selectedMachine.value]!,
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

  Widget optionBottomSheet(List<String> options, Function(String option) selectAction) {
    return Container(
      height: options.length >= 7 ? Get.height * .6 : options.length * 60.h + 50.h,
      padding: EdgeInsets.only(top: 20.h),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
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
              decoration:
              const BoxDecoration(border: Border(bottom: BorderSide(color: Color.fromARGB(255, 247, 247, 247)))),
              height: 60.h,
              width: Get.width,
              child: Center(
                child: Text(
                  options[index],
                  style: const TextStyle(fontSize: 16, color: Color.fromARGB(255, 105, 105, 105)),
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
      onTap: () => controller.canSend.value ? controller.sendAction(isFollowUp: true) : null,
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
          replyList[index].isExpanded = isExpanded;
          replyList.refresh();
        },
        children: replyList.map<ExpansionPanel>((ReplyMessage item) {
          final imageUrls = _collectImageUrls(item);
          return ExpansionPanel(
            headerBuilder: (BuildContext context, bool isExpanded) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Text(
                  item.title ?? "",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            },
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: Text(item.comment ?? ""),
                ),

                // 👇 有圖就顯示縮圖列
                if (imageUrls.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: _imageStrip(imageUrls),
                  ),
                  const SizedBox(height: 6),
                ],

                Row(
                  children: [
                    const SizedBox(width: 16),
                    ObxValue<RxMap>((_) => InkWell(
                      onTap: () {
                        // 加入提示
                        Get.snackbar(
                          "語音處理中",
                          "已送出語音轉換請求，請稍候播放",
                          snackPosition: SnackPosition.BOTTOM,
                          duration: const Duration(seconds: 2),
                        );
                        // 用 item.comment 作為內容、index 為該段的唯一識別
                        Get.find<ShoufuChatController>().textToWav(item.comment ?? "", item.hashCode);
                      },
                      child: controller.files.containsKey(item.hashCode)
                          ? const Icon(Icons.play_circle, color: Colors.brown, size: 22)
                          : const Icon(Icons.download_for_offline, color: Colors.brown, size: 22),
                    ), controller.files),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: () {
                        Get.find<ShoufuChatController>().sendLikeFeedback(
                          message: ChatMessage(
                            question: question,
                            replyList: [item],
                            data: item.comment ?? '',
                            isMe: false,
                          ),
                        );
                      },
                      child: const Icon(Icons.thumb_up, color: Colors.green, size: 22),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: () {
                        Get.to(() => ShoufuInputDetailPage(
                          defaultText: item.comment ?? '',
                          originalQuestion: question,
                          messageIndex: -1,
                          //inquiryId: reply?.parentInquiryId ?? message.inquiryId,
                          reply: item,
                        ));
                      },
                      child: const Icon(Icons.edit_note, color: Colors.blueGrey, size: 22),
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

  // ====== 圖片顯示輔助 ======
  /// 如果這條訊息文字本身就是圖片 URL，就直接顯示圖片；否則顯示文字。
  Widget _buildMaybeImage(String data) {
    final text = data.trim();

    // 純圖片 URL（支援 png/jpg/jpeg/gif）
    final isImageUrl = RegExp(r'^https?:\/\/.*\.(png|jpe?g|gif)\$', caseSensitive: false).hasMatch(text);

    // Markdown 單圖 ![](http...)
    final mdMatch = RegExp(r'^!\[[^\]]*\]\((https?:\/\/[^\s)]+\.(?:png|jpe?g|gif))\)\$', caseSensitive: false)
        .firstMatch(text);

    String? url;
    if (isImageUrl) url = text;
    if (mdMatch != null) url = mdMatch.group(1);

    if (url == null) {
      return ExtendedText(
        text,
        key: const ValueKey('text'),
        maxLines: 100,
        textAlign: TextAlign.left,
        style: const TextStyle(fontSize: 18),
      );
    }

    return GestureDetector(
      key: const ValueKey('image'),
      onTap: () => _showImageViewer([url!], 0),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            url!,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child; // ← 載入完成顯示圖片
              return const SizedBox(
                width: 180,
                height: 120,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            },
            errorBuilder: (c, e, s) => Container(
              width: 180,
              height: 120,
              color: const Color(0x11000000),
              child: const Icon(Icons.broken_image, color: Colors.grey),
            ),
          )
      ),
    );
  }

  /// 依序顯示多張縮圖；點擊可進入全螢幕檢視，支援縮放
  Widget _imageStrip(List<String> urls) {
    return SizedBox(
      height: 90.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: urls.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (_, i) {
          final url = urls[i];
          return GestureDetector(
            onTap: () => _showImageViewer(urls, i),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  url,
                  width: 120.w,
                  height: 90.h,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child; // ← 載入完成顯示圖片
                    return SizedBox(
                      width: 120.w,
                      height: 90.h,
                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    );
                  },
                  errorBuilder: (c, e, s) => Container(
                    width: 120.w,
                    height: 90.h,
                    color: const Color(0x11000000),
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                )
            ),
          );
        },
      ),
    );
  }

  void _showImageViewer(List<String> urls, int initialIndex) {
    Get.dialog(
      Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            PageView.builder(
              controller: PageController(initialPage: initialIndex),
              itemCount: urls.length,
              itemBuilder: (_, i) => Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4,
                  child: Image.network(urls[i], fit: BoxFit.contain),
                ),
              ),
            ),
            Positioned(
              top: 40,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Get.back(),
              ),
            ),
          ],
        ),
      ),
      barrierColor: Colors.black87,
    );
  }

  /// 盡量兼容：
  /// 1) 從 ReplyMessage.imageUrls 取（若存在）
  /// 2) 從 comment 文字內擷取 http(s) 圖片連結
  List<String> _collectImageUrls(ReplyMessage item) {
    try {
      final dyn = item as dynamic;
      final v = dyn.imageUrls; // 若模型尚未加欄位，不會崩；catch 吃掉
      if (v is List) {
        final urls = v.map((e) => e.toString()).where((s) => s.trim().isNotEmpty).toList();
        if (urls.isNotEmpty) return urls;
      }
    } catch (_) {}
    return _extractImageUrlsFromText(item.comment);
  }

  List<String> _extractImageUrlsFromText(String? text) {
    if (text == null || text.isEmpty) return const [];
    final t = text;
    final List<String> urls = [];

    // 直接 http(s) 圖片
    final regHttp = RegExp(r'(https?:\/\/[^\s)]+?\.(?:png|jpe?g|gif))', caseSensitive: false);
    urls.addAll(regHttp.allMatches(t).map((m) => m.group(1)!).toList());

    // Markdown 圖片 ![](http...)
    final regMd = RegExp(r'!\[[^\]]*\]\((https?:\/\/[^\s)]+?\.(?:png|jpe?g|gif))\)', caseSensitive: false);
    urls.addAll(regMd.allMatches(t).map((m) => m.group(1)!).toList());

    // 去重保持順序
    final seen = <String>{};
    final dedup = <String>[];
    for (final u in urls) {
      if (!seen.contains(u)) {
        seen.add(u);
        dedup.add(u);
      }
    }
    return dedup;
  }
}
