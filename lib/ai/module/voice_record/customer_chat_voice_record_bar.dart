import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomerChatVoiceRecordBar extends StatefulWidget {
  const CustomerChatVoiceRecordBar({
    Key? key,
    required this.onLongPressStart,
    required this.onLongPressEnd,
    required this.onLongPressMoveUpdate,
    this.speakBarColor,
    this.speakTextStyle,
  }) : super(key: key);
  final Function(LongPressStartDetails details) onLongPressStart;
  final Function(LongPressEndDetails details) onLongPressEnd;
  final Function(LongPressMoveUpdateDetails details) onLongPressMoveUpdate;
  final Color? speakBarColor;
  final TextStyle? speakTextStyle;

  @override
  _CustomerChatVoiceRecordBarState createState() =>
      _CustomerChatVoiceRecordBarState();
}

class _CustomerChatVoiceRecordBarState
    extends State<CustomerChatVoiceRecordBar> {
  bool _pressing = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: (details) {
          setState(() {
            _pressing = true;
          });
        },
        onTapUp: (details) {
          setState(() {
            _pressing = false;
          });
        },
        onTapCancel: () {
          setState(() {
            _pressing = false;
          });
        },
        onLongPressStart: (details) {
          HapticFeedback.heavyImpact();
          widget.onLongPressStart(details);
          EasyLoading.show(status: 'Recording...');
          setState(() {
            _pressing = true;
          });
        },
        onLongPressEnd: (details) {
          EasyLoading.dismiss();
          widget.onLongPressEnd(details);
          setState(() {
            _pressing = false;
          });
        },
        onLongPressMoveUpdate: (details) {
          widget.onLongPressMoveUpdate(details);
        },
        child: Container(
          height: 36.h,
          width: 36.h,
          margin: EdgeInsets.symmetric(horizontal: 5.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(36.h),
            color: _pressing
                ? const Color.fromARGB(167, 218, 155, 132)
                : const Color.fromARGB(255, 236, 236, 236),
          ),
          child: const Icon(
            Icons.mic,
            color: Colors.brown,
            size: 20,
          ),
        )
        // Container(
        //   height: 44.h,
        //   alignment: Alignment.center,
        //   decoration: BoxDecoration(
        //     color: (widget.speakBarColor ?? const Color(0xFF1D6BED))
        //         .withOpacity(_pressing ? 0.3 : 1),
        //     borderRadius: BorderRadius.circular(4),
        //   ),
        //   child: Text(
        //     _pressing ? UILocalizations.releaseSend : UILocalizations.pressSpeak,
        //     style: widget.speakTextStyle ??
        //         TextStyle(
        //           fontSize: 12.sp,
        //           color: Color.fromARGB(255, 255, 255, 255),
        //         ),
        //   ),
        // ),
        );
  }
}
