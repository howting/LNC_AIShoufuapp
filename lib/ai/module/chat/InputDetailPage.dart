import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lnc_mach_app/ai/module/chat/chat_controller.dart'; // 如果有使用
import 'package:lnc_mach_app/ai/module/chat/chat_provider.dart';   // 如有必要

class InputDetailPage extends StatelessWidget {
  final String defaultText;
  final String originalQuestion;
  final int messageIndex;

  const InputDetailPage({
    super.key,
    required this.defaultText,
    required this.originalQuestion,
    required this.messageIndex,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController textController = TextEditingController(text: defaultText);
    final ChatController controller = Get.find();

    return Scaffold(
      appBar: AppBar(title: const Text("详细输入反馈意见")),
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true, // 避免 overflow
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: textController,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: "请输入更详细内容",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final modifiedText = textController.text.trim();
                  if (modifiedText.isEmpty) return;

                  await controller.sendModifyFeedback(
                    question: originalQuestion,
                    newAnswer: modifiedText,
                  );

                  controller.chatMessageList[messageIndex].data = modifiedText;
                  controller.chatMessageList.refresh();

                  Get.back();
                },
                child: const Text("送出"),
              ),
            ],
          ),
        ),
      ),
    );
  } // ← 加這個
}   // ← 加這個