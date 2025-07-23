// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:lnc_mach_app/screens/new_machine_screen/widget/machine_dialog.dart';
import 'package:lnc_mach_app/screens/new_machine_screen/machine_screen_main/coordinate_table.dart';
import 'package:lnc_mach_app/screens/new_machine_screen/machine_screen_main/machine_modes.dart';

class MachineMain extends StatelessWidget with MachineDialog {
  const MachineMain({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8.0),
        const CoordinateTable(),
        const SizedBox(height: 8.0),
        IndicatorIcons(),
        const SizedBox(height: 8.0),
        const MachineModes(),
        const SizedBox(height: 8.0),
        StepAxis(context),
        const SizedBox(height: 8.0),
        Expanded(
          child: CoordinateTapPanel(context),
        ),
      ],
    );
  }

  Widget IndicatorIcons() {
    final List<String> GImageList = [
      'assets/Offset_G54_on.png',
      'assets/Offset_G55_off.png',
      'assets/Offset_G56_off.png',
      'assets/Offset_G57_off.png',
      'assets/Offset_G58_off.png',
      'assets/Offset_G59_off.png'
    ];
    return Wrap(
        direction: Axis.horizontal,
        spacing: 16.0,
        children: GImageList.map((path) => Image.asset(
              path,
              height: 40,
            )).toList());
  }

  Widget StepAxis(BuildContext context) {
    return Row(
      children: [
        // Axis Container
        Expanded(
            child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              machineDialog(
                  context: context,
                  title: 'Axis',
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 72.0),
                      TextButton(onPressed: () {}, child: const Text('X axis')),
                      const SizedBox(height: 24.0),
                      TextButton(onPressed: () {}, child: const Text('Y axis')),
                    ],
                  ));
            },
            child: Ink(
              color: Theme.of(context).colorScheme.primaryContainer,
              height: 45,
              child: const Row(
                children: [
                  Expanded(
                      child: Center(
                          child: Text(
                    'X axis',
                    style: TextStyle(fontSize: 15),
                  ))),
                  Icon(
                    Icons.arrow_drop_down_rounded,
                    size: 45,
                  ),
                ],
              ),
            ),
          ),
        )),
        // gap
        const SizedBox(
          width: 4,
        ),
        // Step Container
        Expanded(
            child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              machineDialog(
                  context: context,
                  title: 'Step dist.',
                  content: Wrap(
                    direction: Axis.vertical,
                    runAlignment: WrapAlignment.center,
                    spacing: 20.0,
                    children: [
                      const SizedBox(height: 72.0),
                      TextButton(onPressed: () {}, child: const Text('100')),
                      TextButton(onPressed: () {}, child: const Text('10')),
                      TextButton(onPressed: () {}, child: const Text('1')),
                      TextButton(onPressed: () {}, child: const Text('0.1')),
                      TextButton(onPressed: () {}, child: const Text('0.01')),
                      TextButton(onPressed: () {}, child: const Text('0.001'))
                    ],
                  ));
            },
            child: Ink(
              color: Theme.of(context).colorScheme.primaryContainer,
              height: 45,
              child: Row(
                children: [
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Step'),
                            Text('dist.'),
                          ]),
                    ),
                  ),
                  const Center(
                      child: Text(
                    '0.001',
                    style: TextStyle(fontSize: 15),
                  )),
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: const Icon(
                        Icons.arrow_drop_down_rounded,
                        size: 45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ))
      ],
    );
  }

  Widget CoordinateTapPanel(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          InkWell(
            onTap: () {},
            child: AspectRatio(
              aspectRatio: 1 / 1,
              child: Ink(
                color: Theme.of(context).colorScheme.primary,
                height: 96.0,
                width: 96.0,
                child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("-",
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                      Text("X",
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                    ]),
              ),
            ),
          ),
          InkWell(
            onTap: () {},
            child: AspectRatio(
              aspectRatio: 1 / 1,
              child: Ink(
                color: Theme.of(context).colorScheme.primary,
                height: 96.0,
                width: 96.0,
                child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("+",
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                      Text("X",
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                    ]),
              ),
            ),
          )
        ]),
      ),
    );
  }
}
