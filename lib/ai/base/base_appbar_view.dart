import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class BaseAppBarView<T extends GetxController> extends GetView<T> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Scaffold(
            resizeToAvoidBottomInset: resizeToAvoidBottomInset,
            backgroundColor: const Color.fromRGBO(244, 242, 244, 1),
            appBar: AppBar(
              elevation: elevation ?? 0.5,
              backgroundColor: appbarColor,
              title: Text(
                title,
                style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                    fontSize: 18),
              ),
              centerTitle: true,
              leading: InkWell(
                child: const Padding(
                  padding: EdgeInsets.only(left: 15, top: 3),
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: Color.fromARGB(206, 0, 0, 0),
                    size: 20,
                  ),
                ),
                onTap: () => appbarBackAction,
              ),
              actions: actions,
            ),
            floatingActionButton: floatingActionButton,
            body: body(context)));
  }

  List<Widget>? actions;

  double? elevation;

  Widget? floatingActionButton;

  bool resizeToAvoidBottomInset = true;

  Widget body(BuildContext context);

  void get appbarBackAction => Get.back();

  Color get appbarColor => const Color.fromRGBO(244, 242, 244, 1);

  String get title;
}
