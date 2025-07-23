import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';

// 此 Widget 可以用來拿到 Widget's Size 在 render 期間
// SingleChildRenderObjectWidget 是讓這個 WigetSizeOffsetWrapper 有 child 可以使用，接著把 child 加到渲染樹中
class WidgetSizeOffsetWrapper extends SingleChildRenderObjectWidget {
  final dynamic onSizeChange;

  const WidgetSizeOffsetWrapper({
    Key? key,
    required this.onSizeChange,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return WidgetSizeRenderObject(onSizeChange);
  }
}

class WidgetSizeRenderObject extends RenderProxyBox {
  final dynamic onSizeChange;
  Size? currentSize;

  WidgetSizeRenderObject(this.onSizeChange);

  @override
  void performLayout() {
    super.performLayout();

    try {
      Size? newSize = child?.size;

      if (newSize != null && currentSize != newSize) {
        currentSize = newSize;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onSizeChange(newSize);
        });
      }
    } catch (e) {
      rethrow;
    }
  }
}
