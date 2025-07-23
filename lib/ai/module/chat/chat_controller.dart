import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lnc_mach_app/ai/const_api.dart';
import 'package:lnc_mach_app/ai/module/chat/chat_provider.dart';
import 'package:lnc_mach_app/global.dart';
import 'package:path_provider/path_provider.dart';

class ChatController extends GetxController {
  final ChatProvider _provider;
  ChatController(this._provider);

  RxBool canSend = false.obs;

  RxList<ChatMessage> chatMessageList = <ChatMessage>[].obs;

  TextEditingController textController = TextEditingController();
  FocusNode textFocusNode = FocusNode();

  ///
  final audioplayer = AudioPlayer();
  final _dir = "voice";
  final _ext = ".wav";
  RxMap<int, File> files = <int, File>{}.obs;

  ///存储websocket返回的信息
  Map<String, String> socketMessage = {};

  RxString selectedMachine = '请选择产业型号'.obs;
  RxString selectedModel = '请选择机器型号'.obs;
  RxString selectedCountry = '请选择国家'.obs;
  RxString selectedProvince = '请选择省份'.obs;

  late WebSocket webSocket;

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
    webSocket.close();
    super.onClose();
  }

  Future setupWebSocket() async {
    webSocket = await WebSocket.connect(
      "ws://8.138.246.252:8000/ws/chat_qwen_${Global.profile.employeeId}/",
    );
    webSocket.listen((event) {
      print("---- Socket ----- ");
      print("---- Socket ----- : $event");
      if (event is String) {
        Map<String, dynamic> map = json.decode(event);
        if (map["response"] != null &&
            map["response"]["reply_content"] is String) {
          String inquiryId = map["response"]["inquiry_id"];
          String replyContent = map["response"]["reply_content"];
          socketMessage[inquiryId] = replyContent;
          ChatMessage? message = chatMessageList
              .firstWhereOrNull((element) => element.inquiryId == inquiryId);
          if (message != null) {
            message.data = replyContent;
            message.isAnswering = false;
            chatMessageList.refresh();
          }
        }
      }
    });
  }

  ///文字提問
  Future<void> sendAction({bool isFollowUp = false}) async {
    try {
      if (selectedMachine.value == "请选择产业型号" ||
          selectedModel.value == "请选择机器型号") {
        Get.snackbar("Error", "请选择产业型号和机器型号。");
        return;
      }

      textFocusNode.unfocus();

      final questionText = textController.text.trim(); //  暫存

      final selfMessage = ChatMessage(
        data: questionText,
        question: questionText,
        isMe: true,
      );
      chatMessageList.add(selfMessage);

      var result = await _provider.qwen2text(TEXT_POST,
          text: questionText,
          isFollowUp: isFollowUp,
          selectedProvince: selectedProvince.value,
          selectedMachine: selectedMachine.value,
          selectedModel: selectedModel.value,
          selectedCountry: selectedCountry.value);

      textController.clear();

      if (result.body?.code == "success") {
        chatMessageList.add(ChatMessage(
            data: result.body?.data?["message"] ?? "服務器繁忙",
            question: questionText, // ✅ 用暫存變數
            inquiryId: result.body?.data?["inquiry_id"],
            isMe: false,
            isAnswering: true));
      } else {
        chatMessageList.add(ChatMessage(data: "服務器繁忙", isMe: false));
      }
    } catch (e) {
      chatMessageList.add(
        ChatMessage(data: "服務器繁忙", isMe: false, isAnswering: true),
      );
      print(e.toString());
    }
  }
  ///意見反饋
  Future<void> sendModifyFeedback({
    required String question,
    required String newAnswer,
  }) async {
    final data = {
      "type": "modify",
      "question": question,
      "answer": newAnswer,
      "selected_machine": selectedMachine.value,
      "selectedModel": selectedModel.value,
      "employee_id": Global.profile.employeeId,
    };

    try {
      final result = await _provider.modifyReply("api/modify_reply/", data);
      if (result.body != null) {
        Get.snackbar("成功", result.body!.message ?? "已送出回饋");
      } else {
        Get.snackbar("失敗", "沒有取得伺服器回應");
      }
    } catch (e) {
      print("修改意見失敗: $e");
      Get.snackbar("錯誤", "無法送出意見");
    }
  }

  /// 喜歡回答回饋
  Future<void> sendLikeFeedback({
    required String question,
    required String answer,
  }) async {
    final data = {
      "chatPair": {
        "question": question,
        "answer": answer,
        "selected_machine": selectedMachine.value,
        "selectedModel": selectedModel.value,
        "employee_id": Global.profile.employeeId,
      }
    };

    try {
      final result = await _provider.likeReply("api/like_reply/", data);
      if (result.body != null) {
        Get.snackbar("感謝您的反饋", "已收到您的按讚！");
      } else {
        Get.snackbar("失敗", result.body!.message ?? "回饋失敗");
      }
    } catch (e) {
      Get.snackbar("錯誤", "無法送出按讚");
    }
  }

  ///語音提問
  Future<void> makeBase64(String path) async {
    try {
      File file = File(path);
      String fileName = path.substring(file.path.lastIndexOf("/") + 1);
      List<int> fileBytes = await file.readAsBytes();

      var result = await _provider.wav2text(
        WAV_POST,
        fileBytes,
        fileName,
        selectedProvince: selectedProvince.value,
        selectedMachine: selectedMachine.value,
        selectedModel: selectedModel.value,
        selectedCountry: selectedCountry.value,
      );

      if (result.body?.code == "success") {
        String userQuestion = result.body?.data?["question"] ?? "無法辨識語音內容";

        // ✅ 使用者提問（右邊）
        chatMessageList.add(ChatMessage(
          data: userQuestion,
          isMe: true,
          question: userQuestion,
        ));

        // ✅ 系統回覆（左邊）
        chatMessageList.add(ChatMessage(
          data: result.body?.data?["answer"] ?? "處理中...",
          inquiryId: result.body?.data?["inquiry_id"],
          isMe: false,
          isAnswering: true,
          question: userQuestion,
        ));
      } else {
        chatMessageList.add(ChatMessage(data: "服務器繁忙", isMe: false));
      }
    } catch (e) {
      chatMessageList.add(ChatMessage(data: "服務器繁忙", isMe: false, isAnswering: true));
      print(e.toString());
    }
  }
  ///文字轉語音
  Future<void> textToWav(String text, int index) async {
    if (files.containsKey(index)) {
      if (audioplayer.playing) {
        await audioplayer.stop();
      } else {
        final filePath = files[index]!.path;
        await audioplayer.setFilePath(filePath);
        await audioplayer.play();
      }
    } else {
      var result = await _provider.textToWav(
        WAV_TOTEXT_POST,
        text: text,
      );
      if (result.body?.code == "success" && result.body?.data != null) {
        Uint8List bytes = base64.decode(result.body!.data!);
        var path = (await getApplicationDocumentsDirectory()).path;
        final filePath = '$path/$_dir/$index$_ext';
        File file = File(filePath);
        if (!(await file.exists())) {
          await file.create(recursive: true);
        }
        await file.writeAsBytes(bytes);
        files[index] = file;
      }
    }
  }
}

class ChatMessage {
  String data;
  String? question;
  String? inquiryId;
  bool isMe;
  bool isAnswering;

  ChatMessage(
      {required this.data,
      required this.isMe,
      this.inquiryId,
      this.question,
      this.isAnswering = false});

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      data: json['data'],
      question: json['question'],
      inquiryId: json['inquiry_id'],
      isMe: json['isMe'],
      isAnswering: json['isAnswering'],
    );
  }
}

class OptionsUtils {
  ///
  static final countries = ['请选择国家', "中国", "美国", "日本", "德国", "法国"];
  static Map<String, List<String>> countryProvinceMapping = {
    '请选择国家': ['请选择省份'],
    '中国': ['请选择省份', '广东', '江苏', '山东', '浙江', '河南'],
    '美国': ['请选择省份', 'California', 'Texas', 'New York'],
    '日本': ['请选择省份', '东京', '大阪', '京都'],
    '德国': ['请选择省份', 'Bavaria', 'Berlin', 'Hamburg'],
    '法国': ['请选择省份', 'Île-de-France', 'Provence-Alpes-Côte d\'Azur', 'Brittany'],
  };
  static final industrials = [
    '请选择产业型号',
    '銑床',
    '车床',
    '弹簧机',
    '关节机器人',
    '滑轨机器人',
    '铝型材',
    '木工机',
    '喷涂',
    '切割机',
    '塑料机',
    '磨床',
    '缝纫机',
    '沖床',
    '牙雕机',
    'APAC WIN',
    '鞋机',
    '激光加工产业'
  ];
  static final machineTypeMapping = {
    '銑床': [
      '请选择机器型号',
      '中心机',
      '钻攻机',
      '雕铣机',
      '高光机',
      '玻璃磨边机',
      '鞋底抛光机',
      '抛光机',
      '石材加工机',
      "铝型材加工机",
      "五轴产业机械专用机",
      "金属五轴产业机械专用机",
      "双头铣",
      "倒角机"
    ],
    '车床': ['请选择机器型号' '一般车床', "车铣复合", "车床双系统", "车床双回授", "批花机", "滚齿机"],
    '弹簧机': ['请选择机器型号', '弹簧机'],
    '关节机器人': [
      '请选择机器型号',
      '搬运机器人',
      '冲床机器人',
      '抛光机器人',
      '焊接机器人',
      '喷涂机器人',
      'APAC产业机械',
      '镜面铣',
      '水刀切割机'
    ],
    '滑轨机器人': [
      '请选择机器型号',
      '自动化机器人',
      "冲床机器人",
      "射出机器人",
      "车床机器人",
      "A3300自动化机械",
      "固定触屏桁架式机械手"
    ],
    '铝型材': ['请选择机器型号', '鋁型材机', '门锁机'],
    '木工机': [
      '请选择机器型号',
      '实木机',
      '开料机',
      '隼槽机',
      '封边机',
      '六面鑽',
      '电子锯',
      '木工中控系统',
      '门锁机',
      '木工五轴产业机械专用机'
    ],
    '喷涂': ['请选择机器型号', 'LNC-R8800', 'PMC3003-P', 'RS8800'],
    '切割机': ['请选择机器型号', '石材切割机', '压克力切割机', '玻璃切割机'],
    '塑料机': [
      '请选择机器型号',
      '油压立式塑料机',
      '油压卧式塑料机',
      '油压专用机',
      '立式全电机',
      '卧式全电机',
      '刨槽机',
      '圆锯机'
    ],
    '磨床': ['请选择机器型号', '磨床', '逆向工程机械', '深孔加工机'],
    '缝纫机': ['请选择机器型号', '针车', '裁断机'],
    '沖床': ['请选择机器型号', '沖床机械'],
    '牙雕机': ['请选择机器型号', '牙雕机'],
    'APAC WIN': ['请选择机器型号', 'APAC WIN'],
    '鞋机': ['请选择机器型号', '鞋机'],
    '激光加工产业': ['请选择机器型号', '激光切割机'],
    '请选择产业型号': [
      '请选择机器型号',
    ],
  };
}
