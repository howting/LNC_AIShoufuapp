import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'dart:convert';
import 'dart:io';
import 'package:lnc_mach_app/ai/module/shoufu/shoufuchat_controller.dart'; // 如果有使用

import 'package:lnc_mach_app/ai/module/shoufu/shoufuchat_provider.dart';   // 如有必要





class ShoufuInputDetailPage extends StatelessWidget {
  final String defaultText;
  final String originalQuestion;
  final int messageIndex;          // 仍保留，但會加邊界保護
  final ReplyMessage? reply;       // 單筆回覆的修改
  final int? replyIndex;           // 若有就精準更新
  final ImagePicker _picker = ImagePicker();
  final RxList<XFile> _pickedImages = <XFile>[].obs;   // 預覽用
  final RxList<String> _base64Images = <String>[].obs; // 送後端用（含 data URL 前綴）


  ShoufuInputDetailPage({
    super.key,
    required this.defaultText,
    required this.originalQuestion,
    required this.messageIndex,
    this.reply,
    this.replyIndex,
  });
  Future<void> _pickImages() async {
    final files = await _picker.pickMultiImage(maxWidth: 1600, imageQuality: 85);
    if (files == null || files.isEmpty) return;

    for (final f in files) {
      final bytes = await File(f.path).readAsBytes();
      final ext = p.extension(f.path).toLowerCase();
      var mime = 'image/jpeg';
      if (ext == '.png') mime = 'image/png';
      if (ext == '.webp') mime = 'image/webp';

      final b64 = base64Encode(bytes);
      final withPrefix = 'data:$mime;base64,$b64';

      _pickedImages.add(f);
      _base64Images.add(withPrefix);
    }
  }
  void _removeImageAt(int i) {
    if (i < 0 || i >= _pickedImages.length) return;
    _pickedImages.removeAt(i);
    _base64Images.removeAt(i);
  }

  @override
  Widget build(BuildContext context) {
    final titleController = TextEditingController(text: reply?.title ?? "");
    final textController  = TextEditingController(text: defaultText);
    final ShoufuChatController controller = Get.find();

    void safeRefresh() {
      try {
        controller.chatMessageList.refresh();
      } catch (_) {}
    }

    return Scaffold(
      appBar: AppBar(title: const Text("详细输入反馈意见")),
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 標題輸入（可選）
              TextField(
                controller: titleController,
                maxLines: 1,
                decoration: const InputDecoration(
                  labelText: "标题（可选）",
                  hintText: "请输入标题",
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: textController,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: "请输入更详细内容",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickImages,
                    icon: const Icon(Icons.photo_library),
                    label: const Text("選擇圖片"),
                  ),
                  const SizedBox(width: 12),
                  Obx(() => _pickedImages.isEmpty
                      ? const SizedBox()
                      : Text("已選擇 ${_pickedImages.length} 張")),
                ],
              ),
              const SizedBox(height: 10),

              // ✅ 新增：預覽縮圖 + 刪除
              Obx(() => _pickedImages.isEmpty
                  ? const SizedBox.shrink()
                  : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(_pickedImages.length, (i) {
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_pickedImages[i].path),
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        right: -10,
                        top: -10,
                        child: IconButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.white),
                            elevation: MaterialStateProperty.all(2),
                          ),
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => _removeImageAt(i),
                        ),
                      ),
                    ],
                  );
                }),
              )),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final modifiedText  = textController.text.trim();
                  final modifiedTitle = titleController.text.trim();
                  if (modifiedText.isEmpty) return;

                  try {
                    final ctrl = Get.find<ShoufuChatController>();
                    final q = originalQuestion.trim().isNotEmpty
                        ? originalQuestion
                        : ctrl.lastUserQuestion.value;

                    await controller.sendModifyFeedback(
                      question: q,
                      newAnswer: modifiedText,
                      title: modifiedTitle.isEmpty ? null : modifiedTitle,
                      images: _base64Images.toList(),
                    );

                    // ====== 本地 UI 安全更新（全部帶邊界保護，不再丟 RangeError）======
                    // 1) 更新整段訊息文字（僅當非單筆回覆）
                    if (reply == null) {
                      if (messageIndex >= 0 &&
                          messageIndex < controller.chatMessageList.length) {
                        controller.chatMessageList[messageIndex].data = modifiedText;
                        safeRefresh();
                      }
                    } else {
                      // 2) 單筆回覆：需要同時更新 title / comment（若有提供 replyIndex）
                      if (messageIndex >= 0 &&
                          messageIndex < controller.chatMessageList.length) {
                        final msg = controller.chatMessageList[messageIndex];
                        final list = msg.replyList;
                        if (list != null &&
                            replyIndex != null &&
                            replyIndex! >= 0 &&
                            replyIndex! < list.length) {
                          if (modifiedTitle.isNotEmpty) {
                            list[replyIndex!].title = modifiedTitle;
                          }
                          list[replyIndex!].comment = modifiedText;
                          safeRefresh();
                        }
                        // 若沒有 replyIndex，就靜默略過本地更新，避免找錯對象
                      }
                    }
                    // ===========================================================

                    Get.snackbar(
                      "成功",
                      "已送出修改意见",
                      snackPosition: SnackPosition.BOTTOM,
                      duration: const Duration(seconds: 2),
                      backgroundColor: Colors.green.shade100,
                      colorText: Colors.black87,
                    );
                  } catch (e) {
                    // 只有後端送失敗才視為失敗
                    Get.snackbar(
                      "失败",
                      "送出时发生问题：$e",
                      snackPosition: SnackPosition.BOTTOM,
                      duration: const Duration(seconds: 3),
                      backgroundColor: Colors.red.shade100,
                      colorText: Colors.black87,
                    );
                  }
                },
                child: const Text("送出"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}