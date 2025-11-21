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
import 'package:image_picker/image_picker.dart';
import 'package:get/get_connect/http/src/multipart/multipart_file.dart';
import 'package:path/path.dart' as p;



class ChatController extends GetxController {
  final ChatProvider _provider;
  ChatController(this._provider);
  static final _ackRegex = RegExp(
    r'(查詢已提交|查询已提交|透過\s*WebSocket\s*接收結果|通过\s*WebSocket\s*接收结果|处理中|處理中)',
    caseSensitive: false,
  );

  RxBool canSend = false.obs;
  final ImagePicker _picker = ImagePicker();
  RxList<ChatMessage> chatMessageList = <ChatMessage>[].obs;
  final RxList<XFile> selectedImages = <XFile>[].obs;

  final List<String> base64Images = [];
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
  // RxString selectedCountry = '请选择国家'.obs;
  // RxString selectedProvince = '请选择省份'.obs;
  RxString selectedCountry = 'Select Language'.obs;

  late WebSocket webSocket;

  void handleTextAnswer({
    required String questionText,
    required Map<String, dynamic> data,
  }) {
    final responseKey = data.containsKey("message") ? "message" : "answer";
    final content = data[responseKey];

    final bool isAck = (content is String) && _ackRegex.hasMatch(content.trim());
    final bool hasFinalList = (content is List) && content.isNotEmpty;
    final bool hasFinalString = (content is String) && content.trim().isNotEmpty && !isAck;

    final bool isLoading = !(hasFinalList || hasFinalString);

    chatMessageList.add(ChatMessage(
      data: hasFinalList ? "" : (isAck ? "生成中…" : (content is String ? content : "")),
      replyList: hasFinalList
          ? (content as List).map((e) => ReplyMessage.fromJson(Map<String, dynamic>.from(e))).toList()
          : null,
      question: questionText,
      inquiryId: data["inquiry_id"],
      isMe: false,
      isAnswering: isLoading, // ACK 也會是 true → 顯示轉圈圈
    ));
  }

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
      if (event is! String) return;
      final map = json.decode(event);
      final r = map["response"];
      if (r == null) return;

      final String inquiryId = r["inquiry_id"];
      final msg = chatMessageList.firstWhereOrNull((m) => m.inquiryId == inquiryId);
      if (msg == null) return;

      if (r["reply_list"] is List) {
        msg.replyList = (r["reply_list"] as List)
            .map((e) => ReplyMessage.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        msg.data = ""; // 用面板顯示
      } else if (r["reply_content"] is String) {
        msg.data = r["reply_content"];
      }

      msg.isAnswering = false;           // ✅ 關閉轉圈圈
      chatMessageList.refresh();
    });
  }

  ///文字提問
  Future<void> sendAction({bool isFollowUp = false, bool autoImageUpload = false}) async {
    try {
      if (selectedMachine.value == "请选择产业型号" || selectedModel.value == "请选择机器型号") {
        Get.snackbar("Error", "请选择产业型号和机器型号。");
        return;
      }

      textFocusNode.unfocus();
      var questionText = textController.text.trim();

      // ✅ 顯示自己那側的泡泡＋縮圖
      chatMessageList.add(ChatMessage(
        data: questionText.isEmpty && selectedImages.isNotEmpty ? "(已上傳圖片)" : questionText,
        question: questionText,
        isMe: true,
        images: selectedImages.toList(),
      ));

      final res = await _provider.qwen2text(
        TEXT_POST,
        text: questionText,
        isFollowUp: isFollowUp,
        selectedMachine: selectedMachine.value,
        selectedModel: selectedModel.value,
        selectedCountry: selectedCountry.value,
        base64Images: (autoImageUpload && base64Images.isNotEmpty) ? base64Images : null,
      );

      textController.clear();

      if (res.body?.code == "success" && res.body?.data != null) {
        final data = Map<String, dynamic>.from(res.body!.data!);
        handleTextAnswer(questionText: questionText, data: data); // 這裡會開啟/關閉轉圈
      } else {
        chatMessageList.add(ChatMessage(data: "服務器繁忙", isMe: false));
      }
    } catch (e) {
      chatMessageList.add(ChatMessage(data: "服務器繁忙", isMe: false, isAnswering: true));
    } finally {
      // ✅ 避免下次又自動帶上舊圖片
      if (autoImageUpload) {
        base64Images.clear();
        selectedImages.clear();
      }
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
      final file = File(path);
      if (!await file.exists()) {
        chatMessageList.add(ChatMessage(data: "語音檔案不存在", isMe: false));
        return;
      }

      final fileName = p.basename(path);
      final bytes = await file.readAsBytes();

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

        if (questionText.isNotEmpty) {
          chatMessageList.add(ChatMessage(data: questionText, question: questionText, isMe: true));
        }

        handleTextAnswer(questionText: questionText, data: data);
      } else {
        chatMessageList.add(ChatMessage(data: "服務器繁忙", isMe: false));
      }
    } catch (e) {
      chatMessageList.add(ChatMessage(data: "服務器繁忙", isMe: false, isAnswering: true));
      print("makeBase64 error: $e");
    }
  }
  Future<void> pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage(); // 多選

    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      base64Images.clear();  // 這裡是 controller 的成員，不是新定義
      selectedImages.assignAll(pickedFiles);
      for (var file in pickedFiles) {
        final bytes = await File(file.path).readAsBytes();
        final base64Str = base64Encode(bytes);
        base64Images.add(base64Str);  // 加到 controller 的 List
      }

      print("實際加入 base64Images 數量：${base64Images.length}");

      // 可選：立即發送圖片
      await sendAction(isFollowUp: false, autoImageUpload: true);
    } else {
      print("未選取任何圖片");
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
  List<XFile>? images;

  // ✅ 新增：支援面板列表
  List<ReplyMessage>? replyList;

  ChatMessage({
    required this.data,
    required this.isMe,
    this.inquiryId,
    this.question,
    this.isAnswering = false,
    this.images,
    this.replyList, // ✅ 新增
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      data: json['data'] ?? '',
      question: json['question'],
      inquiryId: json['inquiry_id'],
      isMe: json['isMe'] ?? false,
      isAnswering: json['isAnswering'] ?? false,
      // ✅ 新增：如果後端回傳的是面板(List)，轉成 ReplyMessage
      replyList: (json['message'] is List)
          ? (json['message'] as List)
          .map((e) => ReplyMessage.fromJson(e as Map<String, dynamic>))
          .toList()
          : null,
    );
  }
}

// ✅ 新增：面板用的資料模型
class ReplyMessage {
  String? title;
  String? comment;
  bool isExpanded = false;
  String? parentInquiryId;

  ReplyMessage({this.title, this.comment});

  factory ReplyMessage.fromJson(Map<String, dynamic> json) {
    return ReplyMessage(
      title: json['title'] as String?,
      comment: json['comment'] as String?,
    );
  }
}


class OptionsUtils {
  ///
  static final countries = [
    'Select Language', // 預設提示
    '简体中文',
    '繁體中文',
    'English',
    'Tiếng Việt',
    '日本语',
    '한국어',
    'हिन्दी',
  ];

// static Map<String, List<String>> countryProvinceMapping = {
//   'Select Country': ['Select Province'],

//   'China': [
//     'Select Province',
//     '北京',
//     '上海',
//     '广州',
//     '深圳',
//     '重庆',
//     '天津',
//     '成都',
//     '杭州',
//     '武汉',
//     '西安'
//   ],

//   'United States': [
//     'Select Province',
//     'California',
//     'New York',
//     'Texas',
//     'Florida',
//     'Illinois',
//     'Washington',
//     'Georgia',
//     'Massachusetts',
//     'North Carolina'
//   ],

//   'Japan': [
//     'Select Province',
//     '東京',
//     '大阪',
//     '京都',
//     '北海道',
//     '名古屋',
//     '福岡',
//     '沖縄',
//     '神奈川',
//     '広島'
//   ],

//   'Vietnam': [
//     'Select Province',
//     'Hà Nội',
//     'Thành phố Hồ Chí Minh',
//     'Hải Phòng',
//     'Đà Nẵng',
//     'Cần Thơ'
//   ],

//   'South Korea': [
//     'Select Province',
//     '서울',
//     '부산',
//     '인천',
//     '대구',
//     '광주',
//     '수원'
//   ],

//   'India': [
//     'Select Province',
//     'दिल्ली',
//     'मुंबई',
//     'बेंगलुरु',
//     'कोलकाता',
//     'चेन्नई',
//     'हैदराबाद',
//     'पुणे'
//   ],
// };
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
    '车床': ['请选择机器型号', '一般车床', '车铣複合', '车床双系统', '车床双回授', '批花机', '滚齿机', '飞刀机'],
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
