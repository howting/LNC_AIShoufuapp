import 'package:flutter/material.dart';

class BottomNavItem {
  Widget? label;
  Icon? icon;
  bool hide;
  Function? onTap;

  BottomNavItem(
      {required this.label, required this.icon, this.onTap, this.hide = false});
}
