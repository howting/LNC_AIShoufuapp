// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:lnc_mach_app/screens/new_machine_screen/machine_screen_file/scroll_bars.dart';
import 'package:lnc_mach_app/screens/new_machine_screen/machine_screen_file/scroll_bars_provider.dart';
import 'package:provider/provider.dart';

class MachineFile extends StatefulWidget {
  const MachineFile({super.key});

  @override
  State<MachineFile> createState() => _MachineFileState();
}

class _MachineFileState extends State<MachineFile> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const SizedBox(height: 8.0),
      Expanded(
          child: Container(
        color: Theme.of(context).colorScheme.primaryContainer,
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        child: ChangeNotifierProvider(
          create: (context) => ScrollProvider(),
          builder: (context, child) => Column(children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(2.0)),
              height: 25.0,
              child: Text(
                'Profile:',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 15.0),
              ),
            ),
            const SizedBox(height: 5.0),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(2.0)),
              height: 25.0,
              child: const Text(
                'G-Code',
                style: TextStyle(fontSize: 15.0),
              ),
            ),
            const SizedBox(height: 10.0),
            Expanded(
              child: Row(
                children: [
                  // 文字容器
                  Expanded(
                      child: Container(
                    height: double.infinity,
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    child: Row(children: [
                      // 箭頭圖標
                      const Icon(Icons.arrow_right_outlined, size: 40),
                      // 文字部分
                      Expanded(
                          child: Container(
                        alignment: Alignment.topLeft,
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (notification) {
                            final ScrollMetrics metrics = notification.metrics;
                            if (metrics.axis == Axis.horizontal) {
                              context.read<ScrollProvider>().setAlignmentX(
                                  metrics.pixels, metrics.maxScrollExtent);
                            } else {
                              context.read<ScrollProvider>().setAlignmentY(
                                  metrics.pixels, metrics.maxScrollExtent);
                            }
                            return true;
                          },
                          child: const SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('N10M03S240001213211331312313',
                                      style: TextStyle(fontSize: 18)),
                                  Text('N10M03S24000',
                                      style: TextStyle(fontSize: 18)),
                                  Text('N10M03S240002141241241211',
                                      style: TextStyle(fontSize: 18)),
                                  Text(
                                      'N10M03S24000214124124121112321321312312312312',
                                      style: TextStyle(fontSize: 18)),
                                  Text('N10M03S240001213211331312313',
                                      style: TextStyle(fontSize: 18)),
                                  Text('N10M03S24000',
                                      style: TextStyle(fontSize: 18)),
                                  Text('N10M03S240002141241241211',
                                      style: TextStyle(fontSize: 18)),
                                  Text(
                                      'N10M03S24000214124124121112321321312312312312',
                                      style: TextStyle(fontSize: 18)),
                                  Text('N10M03S240001213211331312313',
                                      style: TextStyle(fontSize: 18)),
                                  Text('N10M03S24000',
                                      style: TextStyle(fontSize: 18)),
                                  Text('N10M03S240002141241241211',
                                      style: TextStyle(fontSize: 18)),
                                  Text(
                                      'N10M03S24000214124124121112321321312312312312',
                                      style: TextStyle(fontSize: 18)),
                                  Text('N10M03S240001213211331312313',
                                      style: TextStyle(fontSize: 18)),
                                  Text('N10M03S24000',
                                      style: TextStyle(fontSize: 18)),
                                  Text('N10M03S240002141241241211',
                                      style: TextStyle(fontSize: 18)),
                                  Text(
                                      'N10M03S24000214124124121112321321312312312312',
                                      style: TextStyle(fontSize: 18)),
                                  Text('N10M03S240001213211331312313',
                                      style: TextStyle(fontSize: 18)),
                                  Text('N10M03S24000',
                                      style: TextStyle(fontSize: 18)),
                                  Text('N10M03S240002141241241211',
                                      style: TextStyle(fontSize: 18)),
                                  Text(
                                      'N10M03S24000214124124121112321321312312312312',
                                      style: TextStyle(fontSize: 18)),
                                  Text('N10M03S240001213211331312313',
                                      style: TextStyle(fontSize: 18)),
                                  Text('N10M03S24000',
                                      style: TextStyle(fontSize: 18)),
                                  Text('N10M03S240002141241241211',
                                      style: TextStyle(fontSize: 18)),
                                  Text(
                                      'N10M03S24000214124124121112321321312312312312',
                                      style: TextStyle(fontSize: 18)),
                                  Text('N10M03S240001213211331312313',
                                      style: TextStyle(fontSize: 18)),
                                  Text('N10M03S24000',
                                      style: TextStyle(fontSize: 18)),
                                  Text('N10M03S240002141241241211',
                                      style: TextStyle(fontSize: 18)),
                                  Text(
                                      'N10M03S24000214124124121112321321312312312312',
                                      style: TextStyle(fontSize: 18)),
                                  Text('N10M03S240001213211331312313',
                                      style: TextStyle(fontSize: 18)),
                                  Text('N10M03S24000',
                                      style: TextStyle(fontSize: 18)),
                                  Text('N10M03S240002141241241211',
                                      style: TextStyle(fontSize: 18)),
                                  Text(
                                      'N10M03S24000214124124121112321321312312312312',
                                      style: TextStyle(fontSize: 18)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ))
                    ]),
                  )),
                  // 間隔
                  const SizedBox(width: 10.0),
                  // 滾動條
                  const VerticalScrollBar()
                ],
              ),
            ),
            const SizedBox(width: 8.0),
            const HorizonScrollBar()
          ]),
        ),
      )),
      const SizedBox(height: 15.0),
      HandleFileButtonGroup(),
      const SizedBox(height: 8.0),
      const Modes(),
    ]);
  }
}

// Modes
class Modes extends StatelessWidget {
  const Modes({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ModeImgModal(),
      builder: (context, _) {
        return Container(
          width: double.infinity,
          alignment: Alignment.center,
          color: Theme.of(context).colorScheme.primaryContainer,
          padding: const EdgeInsets.symmetric(vertical: 9.0),
          child: Material(
            color: Colors.transparent,
            child: Wrap(spacing: 14, children: [
              imageButton(
                  id: 1,
                  onTap: () {
                    context.read<ModeImgModal>().changeImage(1);
                  }),
              imageButton(
                  id: 2,
                  onTap: () {
                    context.read<ModeImgModal>().changeImage(2);
                  }),
              imageButton(
                  id: 1,
                  onTap: () {
                    context.read<ModeImgModal>().changeImage(1);
                  })
            ]),
          ),
        );
      },
    );
  }

  Widget imageButton({void Function()? onTap, required int id}) {
    return Selector<ModeImgModal, String>(
      shouldRebuild: (previous, next) => previous != next,
      selector: (ctx, model) => model.imageMap[id],
      builder: (context, value, child) {
        return InkWell(
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2.0),
                image: DecorationImage(
                    image:
                        AssetImage(context.watch<ModeImgModal>().imageMap[id]),
                    fit: BoxFit.cover)),
            height: 82,
            width: 82,
          ),
        );
      },
    );
  }
}

class ModeImgModal extends ChangeNotifier {
  Map imageMap = {1: 'assets/WorkCoordinate.png', 2: 'assets/Cont.png'};

  void changeImage(int id) {
    imageMap[id] = imageMap[id] == 'assets/Run_SpindleCW_off.png'
        ? 'assets/HomeAll_on.png'
        : 'assets/Run_SpindleCW_off.png';
    notifyListeners();
  }
}

class HandleFileButtonGroup extends StatelessWidget {
  HandleFileButtonGroup({super.key});

  final List imageList = [
    'assets/LoadFile_off.png',
    'assets/RewindFile_off.png',
    'assets/CloseFile_off.png',
    'assets/EditFile_off.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      color: Theme.of(context).colorScheme.primaryContainer,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Material(
        color: Colors.transparent,
        child: Wrap(
            spacing: 12,
            children: imageList
                .map((path) => imageButton(imgPath: path, onTap: () {}))
                .toList()),
      ),
    );
  }

  Widget imageButton({void Function()? onTap, required String imgPath}) {
    return InkWell(
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2.0),
            image:
                DecorationImage(image: AssetImage(imgPath), fit: BoxFit.cover)),
        height: 78,
        width: 78,
      ),
    );
  }
}
