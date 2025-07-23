import 'package:flutter/material.dart';
import 'package:lnc_mach_app/screens/new_machine_screen/machine_screen_file/scroll_bars_provider.dart';
import 'package:lnc_mach_app/widgets/widget_size_offset_wrapper.dart';
import 'package:provider/provider.dart';

class HorizonScrollBar extends StatelessWidget {
  const HorizonScrollBar({super.key});

  @override
  Widget build(BuildContext context) {
    // context.read<ScrollProvider>().setScrollWidth(_key);
    return Selector<ScrollProvider, double>(
      shouldRebuild: (previous, next) => previous != next,
      selector: (_, modal) => modal.alignmentX,
      builder: (context, value, child) => WidgetSizeOffsetWrapper(
        onSizeChange: (size) {
          context.read<ScrollProvider>().setScrollWidth(size.width);
        },
        child: Stack(
          children: [
            Container(
              height: 20.0,
              decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.onPrimaryContainer),
                  borderRadius: BorderRadius.circular(2.0)),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FittedBox(
                      child: Icon(
                        Icons.arrow_left_rounded,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    FittedBox(
                      child: Icon(
                        Icons.arrow_right_rounded,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ]),
            ),
            Container(
              alignment: Alignment(context.watch<ScrollProvider>().alignmentX, 1),
              child: RotatedBox(
                quarterTurns: 1,
                child: Image.asset(
                  'assets/ScrollBar_1.png',
                  width: 20.0,
                  height: 28.0,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class VerticalScrollBar extends StatelessWidget {
  const VerticalScrollBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<ScrollProvider, double>(
        shouldRebuild: (previous, next) => previous != next,
        selector: (_, modal) => modal.alignmentY,
        builder: (context, value, child) {
          return WidgetSizeOffsetWrapper(
            onSizeChange: (Size size) {
              context.read<ScrollProvider>().setScrollHeight(size.height);
            },
            child: Stack(
              children: [
                Container(
                  width: 20.0,
                  decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).colorScheme.onPrimaryContainer),
                      borderRadius: BorderRadius.circular(2.0)),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FittedBox(
                          child: Icon(
                            Icons.arrow_drop_up_rounded,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                        FittedBox(
                          child: Icon(
                            Icons.arrow_drop_down_rounded,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ]),
                ),
                Container(
                  alignment: Alignment(1, context.watch<ScrollProvider>().alignmentY),
                  child: Image.asset(
                    'assets/ScrollBar_1.png',
                    width: 20.0,
                    height: 28.0,
                  ),
                )
              ],
            ),
          );
        });
  }
}
