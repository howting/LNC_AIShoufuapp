import 'package:flutter/cupertino.dart';

class ScrollProvider extends ChangeNotifier {
  // start -> -1
  // middel -> 0
  // end -> 1
  final double iconSize = 48;
  double scrollHeight = 0;
  double scrollWidth = 0;
  double alignmentY = -1;
  double alignmentX = -1;

  double getOffset(double totalDistance) {
    return iconSize / totalDistance;
  }

  void initAlignmentY(double height) {
    alignmentY += getOffset(height);
    notifyListeners();
  }

  void initAlignmentX(double width) {
    alignmentX += getOffset(width);
    notifyListeners();
  }

  // must call first, to get scroll height
  void setScrollHeight(double height) {
    scrollHeight = height;
    initAlignmentY(height);
  }

  // must call first, to get scroll width
  void setScrollWidth(double width) {
    scrollWidth = width;
    initAlignmentX(width);
  }

  void setAlignmentY(double scrollY, double maxScroll) {
    final double offset = getOffset(scrollHeight);
    final double perScroll = scrollY / maxScroll;
    final double startPoint = -1 + offset;
    final double endPoint = 1 - offset;

    alignmentY = startPoint + perScroll * (endPoint - startPoint);
    if (alignmentY > endPoint) {
      alignmentY = endPoint;
    }
    notifyListeners();
  }

  void setAlignmentX(double scrollX, double maxScroll) {
    final double offset = getOffset(scrollWidth);
    final double perScroll = scrollX / maxScroll;
    final double startPoint = -1 + offset;
    final double endPoint = 1 - offset;

    alignmentX = startPoint + perScroll * (endPoint - startPoint);
    if (alignmentX > endPoint) {
      alignmentX = endPoint;
    }
    notifyListeners();
  }
}
