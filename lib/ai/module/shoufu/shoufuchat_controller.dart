import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lnc_mach_app/ai/const_api.dart';
import 'package:lnc_mach_app/ai/module/shoufu/shoufuchat_provider.dart';
import 'package:lnc_mach_app/global.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;


import 'voice_recorder.dart';

class ShoufuChatController extends GetxController {
  final ShoufuChatProvider _provider;
  ShoufuChatController(this._provider);
  final RxString lastUserQuestion = ''.obs;
  RxBool canSend = false.obs;
  RxList<ChatMessage> chatMessageList = <ChatMessage>[].obs;

  TextEditingController textController = TextEditingController();
  FocusNode textFocusNode = FocusNode();

  final audioplayer = AudioPlayer();

  final _dir = "voice";
  final _ext = ".wav";
  RxMap<int, File> files = <int, File>{}.obs;

  /// 存储 websocket 返回的信息
  Map<String, String> socketMessage = {};

  RxString selectedMachine = '请选择产业型号'.obs;
  RxString selectedModel = '请选择机器型号'.obs;
  RxString selectedCountry = 'Select Language'.obs;

  late WebSocket webSocket;
  ChatMessage? _pendingAssistant;

  void _showPendingAssistant() {
    final m = ChatMessage(
      data: "生成中…",
      isMe: false,
      isAnswering: true,
    );
    chatMessageList.add(m);
    _pendingAssistant = m;
  }

  void _finalizePendingAsError() {
    if (_pendingAssistant != null) {
      _pendingAssistant!
        ..data = "服務器繁忙"
        ..isAnswering = false;
      chatMessageList.refresh();
      _pendingAssistant = null;
    }
  }
  // -----------------------------
  // 初始化與關閉
  // -----------------------------
  @override
  void onInit() {
    super.onInit();
    textController.addListener(() {
      canSend.value = textController.text.trim().isNotEmpty;
    });
    setupWebSocket();
  }

  @override
  void onClose() {
    try {
      webSocket.close();
    } catch (_) {}

    // 建議順便把這些也清掉
    voiceRecorder.dispose();
    audioplayer.dispose();
    textController.dispose();
    textFocusNode.dispose();

    super.onClose();
  }

  // -----------------------------
  // WebSocket 初始化與接收處理
  // -----------------------------
  Future setupWebSocket() async {
    webSocket = await WebSocket.connect(
      "ws://8.138.246.252:8000/ws/chat_qwen_${Global.profile.employeeId}/",
    );

    webSocket.listen((event) {
      if (event is String) {
        final map = json.decode(event);
        final r = map["response"];
        if (r != null) {
          final String inquiryId = r["inquiry_id"];
          final String? replyContent = r["reply_content"];
          final List? replyList = r["reply_list"];

          final msg = chatMessageList.firstWhereOrNull(
                (m) => m.inquiryId == inquiryId,
          );

          if (msg != null) {
            if (replyList is List) {
              msg.replyList = replyList.map((e) => ReplyMessage.fromJson(e)).toList();
              msg.data = ""; // 用 panel 呈現
            } else if (replyContent != null) {
              msg.data = replyContent;
            }

            // ★ 保底把 question 補上（若為空），方便之後 like / modify 用
            //   這行依賴你在 Controller 內有：
            //   final RxString lastUserQuestion = ''.obs;
            //   並在 sendAction()/makeBase64() 把最後一次提問寫進去
            if ((msg.question == null || msg.question!.trim().isEmpty) &&
                lastUserQuestion.value.isNotEmpty) {
              msg.question = lastUserQuestion.value;
            }

            msg.isAnswering = false; // 關閉 loading
            chatMessageList.refresh();
          }
        }
      }
    });
  }
  final VoiceRecorder voiceRecorder = VoiceRecorder();

  Future<void> startVoiceRecord() async {
    await voiceRecorder.startRecord();   // 這裡開始錄
  }

  Future<void> stopVoiceRecordAndSend({int? durationSec}) async {
    final path = await voiceRecorder.stopRecord();
    if (path != null) {
      await makeBase64(path, durationSec: durationSec);
    }
  }



  // -----------------------------
  // 處理文字回答
  // -----------------------------
  void handleTextAnswer({
    required String questionText,
    required Map<String, dynamic> data,
  }) {
    final responseKey = data.containsKey("message") ? "message" : "answer";
    final content = data[responseKey];

    // 判斷是否有最終內容
    final bool hasFinalContent = (content is String && content.trim().isNotEmpty) ||
        (content is List && content.isNotEmpty);

    chatMessageList.add(
      ChatMessage(
        data: content is String ? content : (hasFinalContent ? "" : "處理中..."),
        replyList: (content is List)
            ? content.map((e) => ReplyMessage.fromJson(e)).toList()
            : null,
        question: questionText,
        inquiryId: data["inquiry_id"],
        isMe: false,
        isAnswering: !hasFinalContent,
      ),
    );
    }


  // -----------------------------
  // 文字提問
  // -----------------------------
  @override
  Future<void> sendAction({bool isFollowUp = false}) async {
    try {
      if (selectedMachine.value == "请选择产业型号" ||
          selectedModel.value == "请选择机器型号") {
        Get.snackbar("Error", "请选择产业型号和机器型号。");
        return;
      }

      textFocusNode.unfocus();
      final questionText = textController.text.trim();
      if (questionText.isNotEmpty) {
        lastUserQuestion.value = questionText;      // ← 新增
      }

      // 先把使用者訊息加上去
      chatMessageList.add(
        ChatMessage(data: questionText, question: questionText, isMe: true),
      );

      // 👉 立刻加一則「生成中…」占位訊息
      _showPendingAssistant();

      final res = await _provider.qwen2text(
        TEXT_POST,
        text: questionText,
        isFollowUp: isFollowUp,
        selectedMachine: selectedMachine.value,
        selectedModel: selectedModel.value,
        selectedCountry: selectedCountry.value,
      );

      textController.clear();

      if (res.body?.code == "success" && res.body?.data != null) {
        final data = Map<String, dynamic>.from(res.body!.data!);

        // 綁上 inquiryId，之後 WS 會靠它更新同一則訊息
        _pendingAssistant?.inquiryId = data["inquiry_id"];

        // 若 API 已經給了最終內容，就直接塞進占位訊息並關閉轉圈圈
        final responseKey = data.containsKey("message") ? "message" : "answer";
        final content = data[responseKey];
        final bool hasFinalContent =
            (content is String && content.trim().isNotEmpty) ||
                (content is List && content.isNotEmpty);

        if (hasFinalContent) {
          if (content is String) {
            _pendingAssistant!
              ..data = content
              ..isAnswering = false;
          } else if (content is List) {
            _pendingAssistant!
              ..data = "" // 用你的 panel 呈現
              ..replyList =
              content.map((e) => ReplyMessage.fromJson(e)).toList()
              ..isAnswering = false;
          }
          chatMessageList.refresh();
          _pendingAssistant = null;
        }
        // 否則維持「生成中…」，等待 WebSocket 來關閉轉圈圈
      } else {
        _finalizePendingAsError();
      }
    } catch (e) {
      _finalizePendingAsError();
      print(e);
    }
  }

  // -----------------------------
  // 按讚回饋
  // -----------------------------
  Future<void> sendLikeFeedback({
    required ChatMessage message,
    ReplyMessage? reply,
  }) async {
    final combinedAnswer = reply?.comment ?? _combineReplyList(message);

    if (combinedAnswer.trim().isEmpty ||
        combinedAnswer.contains("服務器繁忙")) {
      Get.snackbar("錯誤", "回答內容無效，無法回饋。");
      return;
    }

    final data = {
      "chatPair": {
        "question": message.question ?? '',
        "answer": combinedAnswer,
        "selected_machine": selectedMachine.value,
        "selectedModel": selectedModel.value,
        "employee_id": Global.profile.employeeId,
      }
    };

    try {
      final result = await _provider.likeReply("api/shoufulike_reply/", data);
      if (result.body != null) {
        Get.snackbar("感謝您的反饋", "已收到您的按讚！");
      } else {
        Get.snackbar("失敗", result.body?.message ?? "回饋失敗");
      }
    } catch (e) {
      Get.snackbar("錯誤", "無法送出按讚");
    }
  }

  // -----------------------------
  // 修改回答回饋
  // -----------------------------
  Future<void> sendModifyFeedback({
    required String question,
    required String newAnswer,
    String? title,
    List<String>? images,
  }) async {
    if (newAnswer.trim().isEmpty || newAnswer.contains("服務器繁忙")) {
      Get.snackbar("錯誤", "修改內容無效，請重新編輯。");
      return;
    }

    final data = {
      "type": "modify",
      "question": question,
      "answer": newAnswer,
      "selected_machine": selectedMachine.value,
      "selected_model": selectedModel.value,
      "employee_id": Global.profile.employeeId,
      if (title != null) "title": title,
      // if (images != null && images.isNotEmpty) "images": images,
    };

    try {
      print("送出修改內容：$data");
      final result = await _provider.modifyReply("api/shoufumodify_reply/", data);
      if (result.body != null) {
        final message = result.body?.message ?? "已送出回饋";
        Get.snackbar("成功", message);
      } else {
        Get.snackbar("失敗", "沒有取得伺服器回應");
      }
    } catch (e) {
      print("錯誤發生：$e");
      Get.snackbar("錯誤", "無法送出意見");
    }
  }

  // -----------------------------
  // 語音提問
  // -----------------------------
  @override
  Future<void> makeBase64(String path, {int? durationSec}) async {
    try {
      final file = File(path);
      if (!await file.exists()) {
        chatMessageList.add(ChatMessage(data: "語音檔案不存在", isMe: false));
        return;
      }

      final fileName = p.basename(path);
      final bytes = await file.readAsBytes();

      // 🔸 這裡先不要 _showPendingAssistant()，等拿到 question 再加

      final res = await _provider.wav2text(
        WAV_POST,
        bytes,
        fileName,
        selectedMachine: selectedMachine.value,
        selectedModel: selectedModel.value,
        selectedCountry: selectedCountry.value,
      );

      if (res.body?.code == "success" && res.body?.data != null) {
        final data = Map<String, dynamic>.from(res.body!.data!);
        final questionText = (data["question"] ?? "").toString().trim();

        // 1) 先把語音辨識出的文字當作使用者訊息加上去
        if (questionText.isNotEmpty) {
          lastUserQuestion.value = questionText;
          chatMessageList.add(
            ChatMessage(
              data: questionText,
              question: questionText,
              isMe: true,
            ),
          );
        }

        // 2) 再加一則「生成中…」的 AI 占位訊息
        _showPendingAssistant();                          // ★ 移到這裡
        _pendingAssistant?.inquiryId = data["inquiry_id"];

        // 3) 判斷是否有最終內容，有的話直接填進去
        final responseKey = data.containsKey("message") ? "message" : "answer";
        final content = data[responseKey];
        final bool hasFinalContent =
            (content is String && content.trim().isNotEmpty) ||
                (content is List && content.isNotEmpty);

        if (hasFinalContent) {
          if (content is String) {
            _pendingAssistant!
              ..data = content
              ..isAnswering = false;
          } else if (content is List) {
            _pendingAssistant!
              ..data = ""
              ..replyList =
              content.map((e) => ReplyMessage.fromJson(e)).toList()
              ..isAnswering = false;
          }
          chatMessageList.refresh();
          _pendingAssistant = null;
        }
        // 沒內容就保持「生成中…」，等 WebSocket 或後續補上
      } else {
        _finalizePendingAsError();
      }
    } catch (e) {
      _finalizePendingAsError();
      print("makeBase64 error: $e");
    }
  }

  // -----------------------------
  // 文字轉語音
  // -----------------------------
  Future<void> textToWav(String text, int index, {ReplyMessage? reply}) async {
    final id = reply != null ? reply.hashCode : index;

    if (files.containsKey(id)) {
      if (audioplayer.playing) {
        await audioplayer.stop();
      } else {
        final filePath = files[id]!.path;
        await audioplayer.setFilePath(filePath);
        await audioplayer.play();
      }
    } else {
      var result = await _provider.textToWav(WAV_TOTEXT_POST, text: text);

      if (result.body?.code == "success" && result.body?.data != null) {
        Uint8List bytes = base64.decode(result.body!.data!);
        var path = (await getApplicationDocumentsDirectory()).path;

        final filePath = '$path/$_dir/$id$_ext';
        File file = File(filePath);
        if (!(await file.exists())) {
          await file.create(recursive: true);
        }

        await file.writeAsBytes(bytes);
        files[id] = file;

        await audioplayer.setFilePath(filePath);
        await audioplayer.play();
      }
    }
  }
}

// =====================================================
// Data Models
// =====================================================
class ChatMessage {
  String data;
  List<ReplyMessage>? replyList;
  String? question;
  String? inquiryId;
  bool isMe;
  bool isAnswering;

  ChatMessage({
    required this.data,
    required this.isMe,
    this.replyList,
    this.inquiryId,
    this.question,
    this.isAnswering = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      data: json['data'],
      replyList: json['message'] == null
          ? null
          : (json['message'] as List)
          .map((e) => ReplyMessage.fromJson(e))
          .toList(),
      question: json['question'],
      inquiryId: json['inquiry_id'],
      isMe: json['isMe'],
      isAnswering: json['isAnswering'],
    );
  }
}

class ReplyMessage {
  String? title;
  String? comment;
  bool isExpanded;
  List<String> imageUrls; // 👈 新增

  ReplyMessage({
    this.title,
    this.comment,
    this.isExpanded = false,
    List<String>? imageUrls,
  }) : imageUrls = imageUrls ?? [];

  factory ReplyMessage.fromJson(Map<String, dynamic> json) {
    return ReplyMessage(
      title: json['title'] as String?,
      // 你的後端有時用 content_preview、有時用 comment，兼容一下
      comment: (json['content_preview'] ?? json['comment']) as String?,
      imageUrls: (json['image_url'] as List?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
    );
  }
}

// =====================================================
// 工具函式
// =====================================================
String combineReplyList(ChatMessage message) {
  if (message.replyList == null || message.replyList!.isEmpty) {
    return message.data;
  }

  return message.replyList!
      .map((reply) =>
  "【${reply.title ?? '無標題'}】\n${reply.comment ?? '無內容'}")
      .join("\n\n");
}

String _combineReplyList(ChatMessage message) {
  if (message.replyList == null || message.replyList!.isEmpty) {
    return message.data;
  }

  final validReplies = message.replyList!
      .where((reply) =>
  (reply.comment?.trim().isNotEmpty ?? false) &&
      !(reply.comment?.contains("服務器繁忙") ?? false))
      .toList();

  if (validReplies.isEmpty) return "";

  return validReplies
      .map((reply) =>
  "【${reply.title ?? '無標題'}】\n${reply.comment ?? '無內容'}")
      .join("\n\n");
}

// =====================================================
// Options 工具類別
// =====================================================
class OptionsUtils {
  static final countries = [
    'Select Language',
    '简体中文',
    '繁體中文',
    'English',
    'Tiếng Việt',
    '日本语',
    '한국어',
    'हिन्दी',
  ];

  static final industrials = [
    '请选择产业',
    '铣床',
    '车床',
    '木工机',
    '关节机器人',
    '滑轨机器人',
    '注塑机',
    '五轴产业',
    '喷涂',
    '切割机',
    '磨床',
    '缝纫机',
    '冲床',
    '牙凋机',
    'APAC WIN',
    '鞋机',
    '雷射加工产业',
    '弹簧机',
  ];

  static final machineTypeMapping = {
    '铣床': [
      '请选择机器型号',
      '铣床',
      '中心机',
      '鑽攻机',
      '凋铣机',
      '高光机',
      '玻璃磨边机',
      '鞋底抛光机',
      '抛光机',
      '石材加工机',
      '铝型材加工机',
      '双头铣',
      '倒角机',
      '加工中心',
    ],
    '车床': [
      '请选择机器型号',
      '一般车床',
      '车铣複合',
      '车床双系统',
      '车床双回授',
      '批花机',
      '滚齿机',
      '飞刀机',
    ],
    '木工机': [
      '请选择机器型号',
      '实木机',
      '开料机',
      '榫槽机',
      '封边机',
      '六面鑽',
      '电子锯',
      '木工中控系统',
      '门锁机',
    ],
    '关节机器人': [
      '请选择机器型号',
      '搬运机器人',
      '冲床机器人',
      '抛光机器人',
      '焊接机器人',
      '喷涂机器人',
      'APAC产业机械',
      '镜面铣',
      '水刀切割机',
    ],
    '滑轨机器人': [
      '请选择机器型号',
      '自动化机器人',
      '冲床机器人',
      '射出机器人',
      '车床机器人',
      'A3300自动化机械',
      '固定触控桁架式机械手',
    ],
    '注塑机': [
      '请选择机器型号',
      '油压立式塑胶机',
      '油压卧式塑胶机',
      '油压专用机',
      '立式全电机',
      '卧式全电机',
    ],
    '五轴产业': ['木工五轴', '木工金属五轴', '非木工金属五轴'],
    '喷涂': ['请选择机器型号', 'LNC-R8800', 'PMC3003-P', 'RS8800'],
    '切割机': ['请选择机器型号', '石材切割机', '压克力切割机', '玻璃切割机'],
    '磨床': ['请选择机器型号', '磨床', '逆向工程机械', '深孔加工机'],
    '缝纫机': ['请选择机器型号', '针车', '裁断机'],
    '冲床': ['请选择机器型号', '冲床机械'],
    '牙凋机': ['请选择机器型号', '牙凋机'],
    'APAC WIN': ['请选择机器型号', 'APAC WIN'],
    '鞋机': ['请选择机器型号', '鞋机'],
    '雷射加工产业': ['请选择机器型号', '雷射切割机'],
    '弹簧机': ['请选择机器型号', '弹簧机'],
    '请选择产业': ['请选择机器'],
  };
}
