import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:lnc_mach_app/res_fuc/package_handler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lnc_mach_app/ai/const_api.dart';
import 'package:lnc_mach_app/ai/module/machine_chat/machine_chat_provider.dart';
import 'package:lnc_mach_app/global.dart';
import 'package:lnc_mach_app/providers/machine_main/r_value.dart';
import 'package:lnc_mach_app/providers/recorn.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
class MachineChatController extends GetxController {
  final MachineChatProvider _provider;
  MachineChatController(this._provider);
  String? inquiryId;
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
  RxString selectedProvince = '请选择地区'.obs;
  RxString selectedOS = '请选择RIO'.obs;
  late WebSocket webSocket;

  String ip = "";
  String machineName = "";

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments != null && Get.arguments["ip"] != null) {
      ip = Get.arguments["ip"];
    }
    if (Get.arguments != null && Get.arguments["machineName"] != null) {
      machineName = Get.arguments["machineName"];
    }

    textController.addListener(() {
      canSend.value = textController.text.trim().isNotEmpty;
    });

    setupWebSocket();

    ///
    Global.recorn.LReadRList(RValue.COORDINATE_LIST);
  }

  @override
  void onClose() {
    webSocket.close();
    super.onClose();
  }
  // 上传文件方法
  Future<Map<String, dynamic>> uploadFile(String url, {required File file}) async {
    try {
      // 读取文件数据
      final bytes = await file.readAsBytes();
      final fileName = file.uri.pathSegments.last;

      // 创建 multipart 请求
      var uri = Uri.parse(url);
      var request = http.MultipartRequest('POST', uri);

      // 设置请求头
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
      });

      // 将文件附加到请求中
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',  // 上传字段名
          bytes,
          filename: fileName,
        ),
      );

      // 发送请求并获取响应
      var response = await request.send();

      // 获取响应内容
      var responseData = await http.Response.fromStream(response);

      // 解析 JSON 响应
      Map<String, dynamic> responseBody = jsonDecode(responseData.body);

      return responseBody;
    } catch (e) {
      print("文件上传失败: $e");
      throw Exception("文件上传失败");
    }
  }

  // 选择文件并上传
  Future<void> selectFileAndUpload() async {
    print("開始選擇文件");
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      try {
        File file = File(result.files.single.path!);
        String url = 'http://8.138.246.252:8000/api/upload_json/';

        // 上传
        final response = await uploadFile(url, file: file);

        // 上传成功提示
        Get.snackbar(
          "上傳成功",
          "文件已成功上传",
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 2),
        );
        print("上傳返回數據: $response");

      } catch (e) {
        // 上传失败提示
        Get.snackbar(
          "上傳失敗",
          "請檢查網絡或文件格式",
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 2),
        );
        print("上傳失敗: $e");
      }
    } else {
      print("用戶取消了文件選擇");
      Get.snackbar(
        "已取消",
        "用戶取消文件選擇",
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
      );
    }
  }

  Future<void> testFilePicker() async {
    try {
      print("測試文件選擇器...");
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        print("選中的文件路徑: ${result.files.single.path}");
      } else {
        print("沒有選擇文件或選擇被取消");
      }
    } catch (e) {
      print("文件選擇失敗: $e");
    }
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
      textFocusNode.unfocus();

      final selfMessage = ChatMessage(data: textController.text, isMe: true);
      chatMessageList.add(selfMessage);

      var result = await _provider.qwen2text(TEXT_POST,
        text: textController.text,
        isFollowUp: isFollowUp,
        selectedProvince: selectedProvince.value,
        selectedMachine: selectedMachine.value,
        selectedModel: selectedModel.value,
        selectedCountry: selectedCountry.value,
        selectedOS: selectedOS.value,
        inquiryId: inquiryId,
        machineName: machineName,
      );

      print(result);
      textController.clear();
      if (result.body?.code == "success") {
        // 获取返回的 query
        String? query = result.body?.data?["query"];
        this.inquiryId = result.body?.data?["inquiry_id"];
        print("inquiryId123123123123: $inquiryId");
        print(query);
        // 根据 query 的值来决定是否继续执行原有逻辑
        if (query == "search_machine") {
          print("🟢 query == search_machine matched");
          String? mode = result.body?.data?["selected_recorn_mode"];  // 返回指令（all/inchmode）
          String? type = result.body?.data?["type"]; // 这个是RIO
          int? rValue = result.body?.data?["Rvalue"]; // 这个是RIO的值，如果存在。
          print(mode);
          print(123123123123);
          String value;
          if (mode == null) {
            value = RegisterReader().getRegisterStatus(type!, rValue!);
            print("The 'mode' value is null.");
          } else {
            value = PackageHandler().handlePackage(mode) as String; // 在 package_handler 处理后的结果
            print(value);
          }
          chatMessageList.add(ChatMessage(
              data: value != null ? value.toString() : "服務器繁忙",
              inquiryId: result.body?.data?["inquiry_id"],
              isMe: false,
              isAnswering: true));
        } else if (query == "rag") {
               // 如果 query 是 "rag"，你可以根据需求添加其他逻辑
              var rawData = result.body?.data;
              var content = rawData?["data"];
// 输出
              String value;
              if (content is List) {
                 value = content.join("\n");
           } else if (content is String) {
                 value = content;
           } else {
                 value = "服务繁忙";
          }
          chatMessageList.add(ChatMessage(
              data: value != null ? value.toString() : "服務器繁忙",
              inquiryId: result.body?.data?["inquiry_id"],
              isMe: false,
              isAnswering: true));
        } else {
          // 其他 query 情况的处理逻辑
          print('Query is not recognized.');
          chatMessageList.add(ChatMessage(data: "服務繁忙，請稍後再試。", isMe: false));
        }
      } else {
        chatMessageList.add(ChatMessage(data: "服務器繁忙", isMe: false));
      }
    } catch (e) {
      chatMessageList.add(ChatMessage(data: "服務器繁忙", isMe: false, isAnswering: true));
      print(e.toString());
    }
  }


  ///語音提問
  Future<void> makeBase64(String path) async {
    try {
      File file = File(path);
      file.openRead();
      String fileName = path.substring(file.path.lastIndexOf("/") + 1);
      List<int> fileBytes = await file.readAsBytes();
      // String base64String = base64Encode(fileBytes);

      var result = await _provider.wav2text(WAV_POST, fileBytes, fileName,
          selectedProvince: selectedProvince.value,
          selectedMachine: selectedMachine.value,
          selectedModel: selectedModel.value,
          selectedCountry: selectedCountry.value,
          selectedOS:selectedOS.value,
          inquiryId: inquiryId,
          machineName: machineName,
      );
      print(result);
      if (result.body?.code == "success") {
        String? question = result.body?.data?["question"];  //返回指令（all/inchmode）
        String? mode = result.body?.data?["selected_recorn_mode"];  //返回指令（all/inchmode）
        String? type = result.body?.data?["type"]; // 这个是RIO
        int? rValue = result.body?.data?["Rvalue"]; //这个是RIO的值，如果存在。
        String? message = result.body?.data?["message"]; //暂时用来替换rag的返回
        this.inquiryId = result.body?.data?["inquiry_id"];
        print(question);
        print(rValue);
        print(type);
        print(mode);
        print(this.inquiryId);
        String value;
        if (mode == null) {
          value =  RegisterReader().getRegisterStatus(type!, rValue!);
          print("The 'mode' value is null.");
        } else {
          value = PackageHandler().handlePackage(mode)as String; //在package_handler处理后的结果
          print(value);
        }
        chatMessageList.add(ChatMessage(data: question ?? "", isMe: true));
        chatMessageList.add(ChatMessage(
            data: message != null ? message.toString() : "服務器繁忙",
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

  ///文字轉語音
  Future<void> textToWav(String text, int index) async {
    print("🎤 textToWav triggered for index $text text");
    if (files.containsKey(index)) {
      if (audioplayer.playing) {
        await audioplayer.stop();
      } else {
        final filePath = files[index]!.path;
        await audioplayer.setFilePath(filePath);
        await audioplayer.play();
      }
    } else {
      print("發送的文本內容: '${text}'");
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

  static final countries = [
    '请选择国家',
    "中国",
    "美国",
    "日本",
    "德国",
    "法国"
  ];
  static Map<String, List<String>> countryProvinceMapping = {
    '请选择国家': ['请选择省份'],
    '中国': ['请选择省份', '广东', '江苏', '山东', '浙江', '河南'],
    '美国': ['请选择省份', 'California', 'Texas', 'New York'],
    '日本': ['请选择省份', '东京', '大阪', '京都'],
    '德国': ['请选择省份', 'Bavaria', 'Berlin', 'Hamburg'],
    '法国': [
      '请选择省份',
      'Île-de-France',
      'Provence-Alpes-Côte d\'Azur',
      'Brittany'
    ],
  };
  static final industrials = [
    '请选择产业型号',
    '铣床',
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
    '冲床',
    '牙雕机',
    'APAC WIN',
    '鞋机',
    '激光加工产业'
  ];
  static final machineTypeMapping = {
    '铣床': [
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
    '车床': [
      '请选择机器型号',
      '一般车床',
      "车铣复合",
      "车床双系统",
      "车床双回授",
      "批花机",
      "滚齿机"
    ],
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
      "固定触控桁架式机械手"
    ],
    '铝型材': ['请选择机器型号', '铝型材机', '门锁机'],
    '木工机': [
      '请选择机器型号',
      '实木机',
      '开料机',
      '榫槽机',
      '封边机',
      '六面钻',
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
    '冲床': ['请选择机器型号', '冲床机械'],
    '牙雕机': ['请选择机器型号', '牙雕机'],
    'APAC WIN': ['请选择机器型号', 'APAC WIN'],
    '鞋机': ['请选择机器型号', '鞋机'],
    '激光加工产业': ['请选择机器型号', '激光切割机'],
    '请选择产业型号': ['请选择机器型号'],
  };
  static final osOptions = [
    '请选择RIO',
    'R',
    'I',
    'O',
    '其他'
  ];
}