import 'dart:async';

import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

abstract class BaseListController<T> extends GetxController with StateMixin {
  RxList<T> data = <T>[].obs;

  ///用于显示筛选模块和显示更新时间
  RxBool showFilterWidget = true.obs;
  RxString updateTime = DateTime.now().toString().substring(0, 19).obs;

  RefreshController refreshCtl = RefreshController();
  int currentIndex = 1;
  int pageCount = 0;

  @override
  void onReady() {
    loadDataWithIndex().then((value) {
      data.addAll(value);
      change(data, status: RxStatus.success());
    });
    if (isCallAutoMethod) autoCallMethod();
    super.onReady();
  }

  void onRefresh() {
    currentIndex = 1;
    data.clear();
    loadDataWithIndex().then((value) {
      data.addAll(value);
      refreshCtl.refreshCompleted();
      change(data, status: RxStatus.success());
    });
  }

  void onLoading() {
    if (currentIndex >= pageCount) {
      refreshCtl.loadNoData();
      return;
    }
    currentIndex++;
    loadDataWithIndex(index: currentIndex).then((value) {
      data.addAll(value);
    });
    refreshCtl.loadComplete();
    change(data, status: RxStatus.success());
  }

  @override
  void onClose() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }
    super.onClose();
  }

  bool isCallAutoMethod = false;
  Timer? _timer;
  void autoCallMethod() {
    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      change(data, status: RxStatus.loading());
      loadDataWithIndex()
          .whenComplete(() => change(data, status: RxStatus.success()));
    });
  }

  Future<List<T>> loadDataWithIndex({int index = 1});
}
