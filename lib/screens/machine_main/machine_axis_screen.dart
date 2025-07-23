import 'package:flutter/material.dart';
import 'package:lnc_mach_app/global.dart';
import 'package:lnc_mach_app/providers/machine_main/coordinate.dart';
import 'package:lnc_mach_app/providers/recorn.dart';
import 'package:lnc_mach_app/widgets/machine_main/machine_axis_content.dart';
import 'package:provider/provider.dart';

class MachineAxisScreen extends StatefulWidget {
  const MachineAxisScreen({Key? key}) : super(key: key);

  @override
  State<MachineAxisScreen> createState() => _MachineAxisScreenState();
}

class _MachineAxisScreenState extends State<MachineAxisScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProxyProvider<Recorn, Coordinate>(
        create: (_) => Coordinate(
            // recorn: Provider.of<Recorn>(context, listen: false)
            recorn: Global.recorn),
        update: (_, recorn, previousCoordinate) => previousCoordinate!,
        builder: (context, child) {
          return const MachineAxisContent();
        });
  }
}
