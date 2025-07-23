import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'base_list_controller.dart';

abstract class BaseListView<T extends BaseListController> extends GetView<T> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        backgroundColor: backgroudColor,
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(21, 21, 21, 1),
          title: const Text(
            "寶元智造系統",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: InkWell(
            child: Icon(Icons.chevron_left),
            onTap: () => Get.back(),
          ),
        ),
        body: NestedScrollView(
            headerSliverBuilder: headerSliverBuilder,
            body: controller.obx(
                (state) => ListView.builder(
                    itemCount: controller.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Column(children: [
                        itemBuilder(context, index),
                        separatorBuilder(context, index)
                      ]);
                    }),
                onLoading: CupertinoActivityIndicator(
                  color: Colors.grey,
                )
                // ListView.separated(
                //   itemCount: controller.data.length,
                //   separatorBuilder: (BuildContext context, int index) {
                //     return separatorBuilder(context, index);
                //   },
                //   itemBuilder: (BuildContext context, int index) {
                //     return itemBuilder(context, index);
                //   },
                // ),
                )),
      ),
    );
  }

  Color backgroudColor = Colors.black;

  List<Widget> headerSliverBuilder(BuildContext ctx, bool isbool) {
    return [];
  }

  Widget itemBuilder(BuildContext context, int index);

  Widget separatorBuilder(BuildContext context, int index);
}
