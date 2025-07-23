import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lnc_mach_app/providers/machine_main/r_value.dart';
import 'package:lnc_mach_app/providers/recorn.dart';

class Coordinate extends ChangeNotifier {
  final Recorn recorn;

  // initialize coordinate data
  Coordinate({required this.recorn}) {
    init();
  }

  // define coordinate and timer
  Timer? _timer;
  String mechanicalX = "0.000";
  String mechanicalY1 = "0.000";
  String mechanicalY2 = "0.000";
  String mechanicalZ = "0.000";
  String absoluteX = "0.000";
  String absoluteY1 = "0.000";
  String absoluteY2 = "0.000";
  String absoluteZ = "0.000";

  // ignore: non_constant_identifier_names
  // read R value list
  void readAxisValue() {
    recorn.LReadRList(RValue.COORDINATE_LIST);
  }

  // get R value from memory
  String getAxisValue(R) {
    return (recorn.DGetR(R) / 1000).toStringAsFixed(3);
  }

  // set value to notifier
  void setAxisValues() {
    mechanicalX = getAxisValue(RValue.MECHANICAL_X);
    mechanicalY1 = getAxisValue(RValue.MECHANICAL_Y1);
    mechanicalY2 = getAxisValue(RValue.MECHANICAL_Y2);
    mechanicalZ = getAxisValue(RValue.MECHANICAL_Z);
    absoluteX = getAxisValue(RValue.ABSOLUTE_X);
    absoluteY1 = getAxisValue(RValue.ABSOLUTE_Y1);
    absoluteY2 = getAxisValue(RValue.ABSOLUTE_Y2);
    absoluteZ = getAxisValue(RValue.ABSOLUTE_Z);
    notifyListeners();
  }

  // define init
  void init() {
    readAxisValue();
    _timer = Timer.periodic(const Duration(milliseconds: 60), (_) {
      setAxisValues();
    });
  }

  void destory() {
    _timer?.cancel();
  }
}
