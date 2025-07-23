import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lnc_mach_app/ai/const_api.dart';
import 'package:lnc_mach_app/ai/module/manual_chat/manual_chat_provider.dart';
import 'package:lnc_mach_app/global.dart';
import 'package:path_provider/path_provider.dart';

class ManualChatController extends GetxController {
  final ManualChatProvider _provider;
  ManualChatController(this._provider);

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

      final selfMessage = ChatMessage(data: textController.text, isMe: true);
      chatMessageList.add(selfMessage);

      var result = await _provider.qwen2text(TEXT_POST,
          text: textController.text,
          isFollowUp: isFollowUp,
          selectedProvince: selectedProvince.value,
          selectedMachine: selectedMachine.value,
          selectedModel: selectedModel.value,
          selectedCountry: selectedCountry.value);
      textController.clear();
      if (result.body?.code == "success") {
        chatMessageList.add(ChatMessage(
            data: result.body?.data?["message"] ?? "服務器繁忙",
            inquiryId: result.body?.data?["inquiry_id"],
            isMe: false,
            isAnswering: true));
        print(result.body);
      } else {
        chatMessageList.add(ChatMessage(data: "服務器繁忙", isMe: false));
      }
    } catch (e) {
      chatMessageList
          .add(ChatMessage(data: "服務器繁忙", isMe: false, isAnswering: true));
      print(e.toString());

    }
  }

  ///語音提問
  Future<void> makeBase64(String path) async {
    try {
      final selfMessage = ChatMessage(data: "語音輸入", isMe: true);
      chatMessageList.add(selfMessage);

      File file = File(path);
      file.openRead();
      String fileName = path.substring(file.path.lastIndexOf("/") + 1);
      List<int> fileBytes = await file.readAsBytes();
      // String base64String = base64Encode(fileBytes);

      var result = await _provider.wav2text(WAV_POST, fileBytes, fileName,
          selectedProvince: selectedProvince.value,
          selectedMachine: selectedMachine.value,
          selectedModel: selectedModel.value,
          selectedCountry: selectedCountry.value);
      if (result.body?.code == "success") {
        String? question = result.body?.data?["question"];
        chatMessageList.add(ChatMessage(data: question ?? "", isMe: true));
        chatMessageList.add(ChatMessage(
            data: result.body?.data?["message"] ?? "服務器繁忙",
            inquiryId: result.body?.data?["inquiry_id"],
            isMe: false,
            isAnswering: true));
      } else {
        chatMessageList.add(ChatMessage(data: "服務器繁忙", isMe: false));
      }
    } catch (e) {
      chatMessageList
          .add(ChatMessage(data: "服務器繁忙", isMe: false, isAnswering: true));
      print(e.toString());
    }
  }
  final RxSet<int> downloading = <int>{}.obs;
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
    ///'喷涂',
    '切割机',
    '塑料机',
    ///'磨床',
    ///'缝纫机',
    ///'沖床',
    ///'牙雕机',
    ///'APAC WIN',
    ///'鞋机',
    ///'激光加工产业'
  ];
  static final machineTypeMapping = {
    '銑床': [
      '请选择机器型号',
      'MG6850_6800D_2800D',
      'MG5850_5800D',
      'MG5800A',
      'MA2700_MA2600',
      'M3300A',
      'M_MA_MP6850_6800D_6200D_2800D_3110D',
      'M_MA_MP5850_5800D_3200D',
      'M_MA_MP5800A_3200A',
    ],
    '车床': ['请选择机器型号' , "type_A", "type_B"],
    '弹簧机': ['请选择机器型号', 'S2850D3'],
    '关节机器人': [
      '请选择机器型号',
      '搬运机器人',
      '冲压机器人',
      ///'抛光机器人',
      '焊接机器人',
      '喷涂机器人',
      ///'APAC产业机械',
      ///'镜面铣',
      ///'水刀切割机'
    ],
    '滑轨机器人': [
      '请选择机器型号',
      'R6800',
    ],
    '铝型材': ['请选择机器型号', '铝型材(MA)'],
    '木工机': [
      '请选择机器型号',
      ///'实木机',
      ///'开料机',
      ///'隼槽机',
      '封边机',
      '六面鑽',
      '电子锯',
      ///'木工中控系统',
      '门锁机',
      ///'木工五轴产业机械专用机'
    ],
    ///'喷涂': ['请选择机器型号', 'LNC-R8800', 'PMC3003-P', 'RS8800'],
    '切割机': ['请选择机器型号', '切割机(SC)'],
    '塑料机': [
      '请选择机器型号',
      'ELC-6200D3',
      'ELCLCD-5820D3',
      'IN2000',
      'IN5800',
      'IN6800',
    ],
    ///'磨床': ['请选择机器型号', '磨床', '逆向工程机械', '深孔加工机'],
    ///'缝纫机': ['请选择机器型号', '针车', '裁断机'],
    ///'沖床': ['请选择机器型号', '沖床机械'],
    ///'牙雕机': ['请选择机器型号', '牙雕机'],
    ///'APAC WIN': ['请选择机器型号', 'APAC WIN'],
    ///鞋机': ['请选择机器型号', '鞋机'],
    ///'激光加工产业': ['请选择机器型号', '激光切割机'],
    '请选择产业型号': [
      '请选择机器型号',
    ],
  };
}
