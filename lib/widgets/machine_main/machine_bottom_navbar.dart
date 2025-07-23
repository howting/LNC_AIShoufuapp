import 'package:flutter/material.dart';
import 'package:lnc_mach_app/widgets/machine_main/machine_bottom_nav_item.dart';

// class MachineBottomNavBar extends StatefulWidget {
//   const MachineBottomNavBar(
//       {Key? key, required this.currentTabIndex, required this.onTap})
//       : super(key: key);

//   final int currentTabIndex;
//   final Function(int) onTap;

//   @override
//   State<MachineBottomNavBar> createState() => MachineBottomNavBarState();
// }

// class MachineBottomNavBarState extends State<MachineBottomNavBar> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(25),
//           topRight: Radius.circular(25),
//         ),
//         gradient: LinearGradient(
//           begin: Alignment.bottomCenter,
//           end: Alignment.topCenter,
//           colors: <Color>[
//             Color.fromARGB(255, 30, 31, 35),
//             Color.fromARGB(255, 13, 14, 16),
//           ],
//           tileMode: TileMode.clamp,
//         ),
//       ),
//       child: ClipRRect(
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(25),
//           topRight: Radius.circular(25),
//         ),
//         child: BottomNavigationBar(
//           elevation: 0,
//           currentTabIndex: widget.currentTabIndex,
//           type: BottomNavigationBarType.fixed,
//           backgroundColor: Colors.transparent,
//           items: const <BottomNavigationBarItem>[
//             BottomNavigationBarItem(
//                 icon: Icon(
//                   Icons.autorenew,
//                   size: 28,
//                 ),
//                 label: '模式'),
//             BottomNavigationBarItem(
//                 icon: Icon(
//                   Icons.settings_input_component_outlined,
//                   size: 28,
//                 ),
//                 label: '座標'),
//             BottomNavigationBarItem(
//                 icon: Icon(
//                   Icons.stop_rounded,
//                   size: 28,
//                   color: Color.fromARGB(255, 42, 42, 42),
//                 ),
//                 label: 'EMG'),
//             BottomNavigationBarItem(
//                 icon: Icon(
//                   Icons.list_alt,
//                   size: 28,
//                 ),
//                 label: '指標'),
//             BottomNavigationBarItem(
//               icon: Icon(
//                 Icons.flash_on,
//                 size: 28,
//               ),
//               label: '操作',
//             ),
//           ],
//           onTap: (int value) {
//             widget.onTap(value);
//           },
//           unselectedItemColor: Colors.white38,
//           selectedItemColor: const Color.fromARGB(255, 72, 139, 255),
//         ),
//       ),
//     );
//   }
// }

class MachineBottomNavBar extends StatefulWidget {
  const MachineBottomNavBar(
      {Key? key, required this.items, required this.currentTabIndex})
      : super(key: key);

  final List<BottomNavItem> items;
  final int currentTabIndex;

  @override
  State<MachineBottomNavBar> createState() => MachineBottomNavBarState();
}

class MachineBottomNavBarState extends State<MachineBottomNavBar> {
  bool isCurrentIndex(index) {
    double sep = widget.items.length / 2;
    if (index < sep) return index == widget.currentTabIndex;
    if (index > sep) return index == widget.currentTabIndex + 1;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // final barItems = <Widget>[];
    final barItems = List.generate(widget.items.length, (index) {
      var item = widget.items[index];

      return item.hide
          ? TextButton(
              onPressed: null,
              style: TextButton.styleFrom(foregroundColor: Colors.transparent),
              child: const SizedBox(),
            )
          : ElevatedButton(
              onPressed: item.onTap == null
                  ? null
                  : () {
                      item.onTap!();
                    },
              style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(4)),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconTheme(
                        data: IconThemeData(
                            color: isCurrentIndex(index)
                                ? Colors.blue
                                : Colors.white24),
                        child: item.icon!),
                    DefaultTextStyle(
                        style: TextStyle(
                            color: isCurrentIndex(index)
                                ? Colors.blue
                                : Colors.white24),
                        child: item.label!)
                  ]));
    });

    return BottomAppBar(
      color: Colors.transparent,
      clipBehavior: Clip.hardEdge,
      shape: const CircularNotchedRectangle(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: <Color>[
                    Color.fromARGB(255, 30, 31, 35),
                    Color.fromARGB(255, 13, 14, 16),
                  ],
                  tileMode: TileMode.clamp,
                ),
              ),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  mainAxisSize: MainAxisSize.min,
                  children: barItems)),
        ],
      ),
    );
  }
}
