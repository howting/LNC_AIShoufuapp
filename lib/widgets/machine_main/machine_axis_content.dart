import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lnc_mach_app/providers/machine_main/coordinate.dart';
import 'package:lnc_mach_app/widgets/machine_main/machine_axis_row_item.dart';
import 'package:lnc_mach_app/widgets/machine_main/machine_axis_tap_panel.dart';

class MachineAxisContent extends StatefulWidget {
  const MachineAxisContent({Key? key}) : super(key: key);

  @override
  State<MachineAxisContent> createState() => _MachineAxisContentState();
}

class _MachineAxisContentState extends State<MachineAxisContent> {
  @override
  void deactivate() {
    // destroy the loop when the Widget is deactivate
    // 'Not use dispose' because it will be called after other widget init, may cause some bug
    // context.read<Coordinate>().destory();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        axisTitle('機械座標'),
        const SizedBox(
          height: 8.0,
        ),
        mechanicalRow(),
        const SizedBox(
          height: 8.0,
        ),
        axisTitle('絕對座標'),
        const SizedBox(
          height: 8.0,
        ),
        absoluteRow(),
        tapPanelContainer(),
      ],
    );
  }

  // title widget
  Widget axisTitle(String title) {
    return Builder(
        builder: (context) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              height: 24,
              child: FittedBox(
                child: Row(
                  children: [
                    const Icon(
                      Icons.notes_rounded,
                      color: Colors.white60,
                      size: 24,
                    ),
                    const SizedBox(
                      width: 8.0,
                    ),
                    Text(
                      title,
                      style: const TextStyle(
                          fontSize: 24.0,
                          color: Color.fromARGB(255, 231, 231, 231)),
                    ),
                  ],
                ),
              ),
            ));
  }

  // mechanical coordinate row
  Widget mechanicalRow() {
    return Consumer<Coordinate>(
      builder: (context, coor, child) => Container(
        padding: const EdgeInsets.symmetric(
          vertical: 16.0,
        ),
        decoration: BoxDecoration(
            color: const Color.fromARGB(255, 23, 24, 28),
            borderRadius: BorderRadius.circular(5.0)),
        child: Row(children: [
          Expanded(
              flex: 1,
              child: MachineAxisRowItem(label: 'X', value: coor.mechanicalX)),
          Expanded(
              flex: 1,
              child: MachineAxisRowItem(label: 'Y1', value: coor.mechanicalY1)),
          Expanded(
              flex: 1,
              child: MachineAxisRowItem(label: 'Y2', value: coor.mechanicalY2)),
          Expanded(
              flex: 1,
              child: MachineAxisRowItem(
                label: 'Z',
                value: coor.mechanicalZ,
                last: true,
              )),
        ]),
      ),
    );
  }

  // absolute coordinate row
  Widget absoluteRow() {
    return Consumer<Coordinate>(
      builder: (context, coor, child) => Container(
        padding: const EdgeInsets.symmetric(
          vertical: 16.0,
        ),
        decoration: BoxDecoration(
            color: const Color.fromARGB(255, 23, 24, 28),
            borderRadius: BorderRadius.circular(5.0)),
        child: Row(children: [
          Expanded(
              flex: 1,
              child: MachineAxisRowItem(label: 'X', value: coor.absoluteX)),
          Expanded(
              flex: 1,
              child: MachineAxisRowItem(label: 'Y1', value: coor.absoluteY1)),
          Expanded(
              flex: 1,
              child: MachineAxisRowItem(label: 'Y2', value: coor.absoluteY2)),
          Expanded(
              flex: 1,
              child: MachineAxisRowItem(
                label: 'Z',
                value: coor.absoluteZ,
                last: true,
              )),
        ]),
      ),
    );
  }

  // tap panel wrapper and set height / width
  Widget tapPanelContainer() {
    return Builder(
        builder: (context) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  // decoration: const BoxDecoration(
                  //     color: Color.fromARGB(255, 13, 14, 16),
                  //     borderRadius: BorderRadius.all(Radius.circular(5))),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28.0, vertical: 8.0),
                  height: MediaQuery.of(context).size.height / 2.3,
                  width: MediaQuery.of(context).size.height / 2.3,
                  child: const MachineAxisTapPanel(),
                ),
              ],
            ));
  }
}
