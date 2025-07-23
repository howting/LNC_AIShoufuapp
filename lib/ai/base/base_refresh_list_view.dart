import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'base_list_controller.dart';

abstract class BaseRefreshListView<T extends BaseListController>
    extends GetView<T> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: controller.obx(
          (state) => Column(
                children: [
                  unreadNotificationWidget(),
                  Expanded(
                    child: SmartRefresher(
                        controller: controller.refreshCtl,
                        onRefresh: controller.onRefresh,
                        onLoading: controller.onLoading,
                        enablePullUp: true,
                        header: WaterDropMaterialHeader(
                            backgroundColor:
                                Theme.of(context).appBarTheme.backgroundColor),
                        footer: CustomFooter(
                          loadStyle: LoadStyle.ShowWhenLoading,
                          builder: (BuildContext context, LoadStatus? mode) {
                            if (mode == LoadStatus.noMore) {
                              return const SizedBox(
                                height: 60.0,
                                child: Center(
                                    child: Text(
                                  '沒有更多數據啦。',
                                  style: TextStyle(color: Color(0xFFB2B2B2)),
                                )),
                              );
                            }
                            return const SizedBox(
                              height: 55.0,
                              child:
                                  Center(child: CupertinoActivityIndicator()),
                            );
                          },
                        ),
                        child: ListView.builder(
                            itemCount: controller.data.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Column(children: [
                                itemBuilder(context, index),
                                separatorBuilder(context, index)
                              ]);
                            })),
                  ),
                ],
              ),
          onLoading: const CupertinoActivityIndicator(
            color: Color(0xFF00ABB3),
          )),
    );
  }

  Color backgroudColor = Colors.white;

  List<Widget> headerSliverBuilder(BuildContext ctx, bool isbool) {
    return [];
  }

  Widget unreadNotificationWidget();

  Widget itemBuilder(BuildContext context, int index);

  Widget separatorBuilder(BuildContext context, int index);
}
