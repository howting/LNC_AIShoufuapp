// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'base_list_controller.dart';

abstract class BaseListFilterView<T extends BaseListController>
    extends GetView<T> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(46, 46, 46, 1),
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(21, 21, 21, 1),
          title: const Text(
            "寶元智造系統",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: InkWell(
            child: const Icon(Icons.chevron_left),
            onTap: () => Get.back(),
          ),
        ),
        body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: Text(title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                SliverToBoxAdapter(
                  child: GestureDetector(
                    onTap: () => controller.showFilterWidget.toggle(),
                    child: const Padding(
                      padding: EdgeInsets.only(left: 12, bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.timer,
                            color: Colors.grey,
                            size: 32,
                          ),
                          SizedBox(width: 5),
                          Text('資料篩選',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
                ObxValue<RxBool>((show) {
                  return SliverToBoxAdapter(
                    child:
                        Offstage(offstage: !show.value, child: filterWidget()),
                  );
                }, controller.showFilterWidget),
                SliverToBoxAdapter(
                  child: extraWidget(),
                ),
                ObxValue<RxString>((updateTime) {
                  return SliverToBoxAdapter(
                    child: Container(
                      alignment: Alignment.centerRight,
                      padding:
                          const EdgeInsets.only(right: 12, top: 8, bottom: 8),
                      child: Text('最後更新時間：${updateTime.value}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          )),
                    ),
                  );
                }, controller.updateTime)
              ];
            },
            body: controller.obx(
                (state) => ListView.builder(
                    itemCount: controller.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Column(children: [
                        itemBuilder(context, index),
                        separatorBuilder(context, index)
                      ]);
                    }),
                onLoading: const CupertinoActivityIndicator(
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

  Widget extraWidget() {
    return Container();
  }

  Widget filterWidget();

  String get title;

  Widget itemBuilder(BuildContext context, int index);

  Widget separatorBuilder(BuildContext context, int index) {
    return const SizedBox(
      height: 16,
    );
  }
}
