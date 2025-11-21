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



extension IterableWhereOrNullX<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E element) test) {
    for (final e in this) {
      if (test(e)) return e;
    }
    return null;
  }

  E? lastWhereOrNull(bool Function(E element) test) {
    final list = this is List<E> ? (this as List<E>) : toList(growable: false);
    for (var i = list.length - 1; i >= 0; i--) {
      final e = list[i];
      if (test(e)) return e;
    }
    return null;
  }
}
// 展平一層常見包裝：response_data / response / data
Map<String, dynamic> _unwrapOnce(Map<String, dynamic> src) {
  final v = (src['response_data'] ?? src['response'] ?? src['data']);
  if (v is Map) return Map<String, dynamic>.from(v as Map);
  return src;
}

// 取文字答案：依序嘗試常見 key
String? _pickText(Map<String, dynamic> d) {
  for (final k in ['reply_content', 'message', 'text_output', 'answer', 'data']) {
    final v = d[k];
    if (v is String && v.trim().isNotEmpty) return v;
  }
  return null;
}

// 取清單答案（例如 reply_list 或 message: List）
List<Map<String, dynamic>>? _pickList(Map<String, dynamic> d) {
  final v = d['reply_list'] ?? d['message'] ?? d['list'];
  if (v is List) {
    return v.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }
  return null;
}



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
  // RxString selectedCountry = '请选择国家'.obs;
  // RxString selectedProvince = '请选择省份'.obs;
  RxString selectedCountry = 'Select Language'.obs;


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
      try {
        if (event is! String) return;
        final root = json.decode(event);
        if (root is! Map) return;

        final d = _unwrapOnce(Map<String, dynamic>.from(root));
        final String? inquiryId = d['inquiry_id']?.toString();

        final list = _pickList(d);
        final txt  = _pickText(d);

        // 鎖定要更新的那顆泡泡：先用 inquiryId 找，找不到就用最後一顆 pending
        ChatMessage? msg;
        if (inquiryId != null && inquiryId.isNotEmpty) {
          msg = chatMessageList.firstWhereOrNull((m) => m.inquiryId == inquiryId);
        }
        msg ??= chatMessageList.lastWhereOrNull((m) => !m.isMe && m.isAnswering);

        // 找不到就新增一顆，避免內容消失
        msg ??= (() {
          final neu = ChatMessage(data: '', isMe: false, isAnswering: true, inquiryId: inquiryId);
          chatMessageList.add(neu);
          return neu;
        })();

        // 更新內容 + 關轉圈
        if (list != null && list.isNotEmpty) {
          msg.data = list.map((e) {
            final t = (e['title'] ?? e['header'] ?? e['name'] ?? '').toString();
            final c = (e['comment'] ?? e['formatted_text'] ?? e['text'] ?? e['content'] ?? '').toString();
            return (t.isNotEmpty ? '【$t】\n' : '') + c;
          }).join('\n\n');
          msg.isAnswering = false;
        } else if ((txt ?? '').trim().isNotEmpty) {
          msg.data = txt!;
          msg.isAnswering = false;
        } else {
          // 心跳或中間狀態，先不動
          return;
        }

        // 若這次才拿到 inquiryId，也綁上
        if (inquiryId != null && (msg.inquiryId ?? '').isEmpty) {
          msg.inquiryId = inquiryId;
        }

        chatMessageList.refresh();
      } catch (e) {
        print('WS parse error: $e');
      }
    });
  }

  ///文字提問
  Future<void> sendAction({bool isFollowUp = false}) async {
    try {
      if (selectedMachine.value == "请选择产业型号" || selectedModel.value == "请选择机器型号") {
        Get.snackbar("Error", "请选择产业型号和机器型号。");
        return;
      }
      textFocusNode.unfocus();

      final ask = textController.text.trim();
      if (ask.isEmpty) return;

      // 右側：使用者訊息
      chatMessageList.add(ChatMessage(data: ask, isMe: true));

      // 左側：先放等待中的泡泡
      final pending = ChatMessage(data: '生成中…', isMe: false, isAnswering: true);
      chatMessageList.add(pending);

      final result = await _provider.qwen2text(
        TEXT_POST,
        text: ask,
        isFollowUp: isFollowUp,
        selectedMachine: selectedMachine.value,
        selectedModel: selectedModel.value,
        selectedCountry: selectedCountry.value,
      );
      textController.clear();

      if (result.body?.code == "success" && result.body?.data != null) {
        final raw = Map<String, dynamic>.from(result.body!.data!);
        final d = _unwrapOnce(raw);

        // 綁 inquiryId 讓 WS 能對到
        final inquiryId = (d['inquiry_id'] ?? raw['inquiry_id'])?.toString();
        if (inquiryId != null && inquiryId.isNotEmpty) {
          pending.inquiryId = inquiryId;
        }

        // 若 HTTP 已經有最終內容 → 直接關轉圈
        final list = _pickList(d);
        final txt  = _pickText(d);
        final hasFinal = (list != null && list.isNotEmpty) || (txt != null && txt.trim().isNotEmpty);

        if (hasFinal) {
          if (list != null && list.isNotEmpty) {
            // 這裡是「面板模式」（多筆回覆）
            // 你若在 ManualChatPage 只走文字流，可把 list 轉文字後塞回 pending.data
            pending.data = list.map((e) {
              final t = (e['title'] ?? e['header'] ?? e['name'] ?? '').toString();
              final c = (e['comment'] ?? e['formatted_text'] ?? e['text'] ?? e['content'] ?? '').toString();
              return (t.isNotEmpty ? '【$t】\n' : '') + c;
            }).join('\n\n');
          } else {
            pending.data = txt ?? '';
          }
          pending.isAnswering = false;    // ← 關轉圈
        } else {
          // 還要等 WS → 保持轉圈
          pending.data = '生成中…';
          pending.isAnswering = true;
        }
        chatMessageList.refresh();
      } else {
        pending.data = "服務器繁忙";
        pending.isAnswering = false;
        chatMessageList.refresh();
      }
    } catch (e) {
      // 找到最後一顆 pending，收掉轉圈顯示錯誤
      for (int i = chatMessageList.length - 1; i >= 0; i--) {
        final m = chatMessageList[i];
        if (!m.isMe && m.isAnswering) {
          m.data = "服務器繁忙";
          m.isAnswering = false;
          chatMessageList.refresh();
          return;
        }
      }
      chatMessageList.add(ChatMessage(data: "服務器繁忙", isMe: false));
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
          // selectedProvince: selectedProvince.value,
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
    '请选择产业型号',
    '铣床',
    '车床',
    '关节机器人',
    '滑轨机器人',
    '木工机',
    '塑胶机',
    '弹簧机',
    '切割机',
    '铝型材',
    'ES9',
  ];

  static final machineTypeMapping = {
    '铣床': [
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
    '车床': ['请选择机器型号', 'type_A', 'type_B'],
    '关节机器人': [
      '请选择机器型号',
      '搬运机器人',
      '冲压机器人',
      '焊接机器人',
      '喷涂机器人',
    ],
    '滑轨机器人': [
      '请选择机器型号',
      'R6800',
    ],
    '木工机': [
      '请选择机器型号',
      '封边机',
      '六面鑽',
      '电子锯',
      '门锁机',
    ],
    '塑胶机': [
      '请选择机器型号',
      'ELC-6200D3',
      'ELCLCD-5820D3',
      'IN2000',
      'IN5800',
      'IN6800',
    ],
    '弹簧机': ['请选择机器型号', 'S2850D3'],
    '切割机': ['请选择机器型号', '切割机(SC)'],
    '铝型材': ['请选择机器型号', '铝型材(MA)'],
    'ES9': ['请选择机器型号', 'ES9'],
    '请选择产业型号': ['请选择机器型号'],
  };
}

