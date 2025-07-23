import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lnc_mach_app/ai/module/voice_record/customer_chat_voice_record_bar.dart';
import 'package:lnc_mach_app/ai/module/voice_record/ui_locallizations.dart';
import 'package:lnc_mach_app/ai/module/voice_record/voice_record.dart';

typedef SpeakViewChildBuilder = Widget Function(
    CustomerChatVoiceRecordBar recordBar);

class CustomerChatVoiceRecordLayout extends StatefulWidget {
  const CustomerChatVoiceRecordLayout({
    Key? key,
    required this.builder,
    this.locale,
    this.onCompleted,
    this.speakTextStyle,
    this.speakBarColor,
    this.maxRecordSec = 60,
  }) : super(key: key);

  final SpeakViewChildBuilder builder;
  final Locale? locale;
  final Function(int sec, String path)? onCompleted;
  final Color? speakBarColor;
  final TextStyle? speakTextStyle;

  /// 最大记录时长s
  final int maxRecordSec;

  @override
  _CustomerChatVoiceRecordLayoutState createState() =>
      _CustomerChatVoiceRecordLayoutState();
}

class _CustomerChatVoiceRecordLayoutState
    extends State<CustomerChatVoiceRecordLayout> {
  var _selectedCancelArea = false;
  var _selectedSoundToWordArea = false;
  var _selectedPressArea = true;
  var _showVoiceRecordView = false;
  var _showSpeechRecognizing = false;
  var _showRecognizeFailed = false;
  Timer? _timer;
  late VoiceRecord _record;
  String? _path;
  int _sec = 0;
  var _isInterrupt = false;

  @override
  void initState() {
    UILocalizations.set(widget.locale);
    super.initState();
  }

  void callback(int sec, String path) {
    _sec = sec;
    _path = path;
  }

  @override
  void dispose() {
    if (null != _timer) {
      _timer?.cancel();
      _timer = null;
    }
    super.dispose();
  }

  CustomerChatVoiceRecordBar _createSpeakBar() => CustomerChatVoiceRecordBar(
        speakBarColor: widget.speakBarColor,
        speakTextStyle: widget.speakTextStyle,
        onLongPressMoveUpdate: (details) {
          Offset global = details.globalPosition;
          setState(() {
            _selectedPressArea = global.dy >= 683.h;
            _selectedCancelArea = /*global.dy >= 563.h &&*/
                global.dy < 683.h && global.dx < 172.w;
            _selectedSoundToWordArea = global.dy < 683.h && global.dx >= 172.w;
          });
        },
        onLongPressEnd: (details) async {
          if (!_isInterrupt) _stop();
        },
        onLongPressStart: (details) {
          _start();
        },
      );

  @override
  Widget build(BuildContext context) {
    return widget.builder(_createSpeakBar());
  }

  void _callback() {
    if (_sec > 0 && null != _path) {
      widget.onCompleted?.call(_sec, _path!);
    } else if (_sec == 0) {
      widget.onCompleted?.call(0, '');
    }
  }

  void _stop() async {
    if (!_isInterrupt) await _record.stop();
    // 停止记录
    setState(() {
      if (_selectedPressArea) {
        _callback();
      }
      if (_selectedSoundToWordArea) {
        if (null != _timer) {
          _timer?.cancel();
          _timer = null;
        }
        _timer = Timer(const Duration(seconds: 1), () {
          setState(() {
            _showRecognizeFailed = true;
            _showSpeechRecognizing = false;
          });
        });
        _showSpeechRecognizing = true;
        _showVoiceRecordView = true;
        _selectedPressArea = false;
        _selectedCancelArea = false;
        _selectedSoundToWordArea = false;
      } else {
        _showVoiceRecordView = false;
        _selectedPressArea = false;
        _selectedCancelArea = false;
        _selectedSoundToWordArea = false;
      }
    });
  }

  void _start() {
    setState(() {
      // 开始记录
      _isInterrupt = false;
      _record = VoiceRecord(
        onFinished: (sec, path) {
          callback.call(sec, path);
        },
        onInterrupt: (sec, path) {
          _isInterrupt = true;
          callback.call(sec, path);
          _stop();
        },
        maxRecordSec: widget.maxRecordSec,
      );
      _record.start();
      _selectedPressArea = true;
      _showVoiceRecordView = true;
    });
  }
}
