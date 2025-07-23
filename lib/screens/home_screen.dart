import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lnc_mach_app/providers/background_container.dart';
import 'package:lnc_mach_app/utils/storage.dart';
import 'package:lnc_mach_app/widgets/machine_info_list_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  List<MachineInfo> machineInfoList = [];
  Storage storage = Storage();

  // Function: get list of all machine infos from localStorage
  void getInfos() {
    storage.getData('machineInfos').then((encodeData) {
      machineInfoList = [];
      List decodeData = encodeData == null ? [] : json.decode(encodeData);
      for (Map machine in decodeData) {
        machineInfoList.add(MachineInfo(
            id: machine["id"], ip: machine["ip"], name: machine["name"]));
      }
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void didPopNext() {
    getInfos();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    // routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    storage.init().then((_) {
      getInfos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundContainer(
      padding: const EdgeInsets.only(
        top: 16.0,
        left: 16.0,
        right: 16.0,
      ),
      child: machineInfoList.isEmpty
          ? noDeviceText(context)
          : SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  Row(children: [
                    Icon(
                      Icons.double_arrow_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const Text(
                      "Swipe right to delete",
                      style: TextStyle(color: Colors.white70),
                    )
                  ]),
                  Expanded(
                    child: ListView.separated(
                      itemCount: machineInfoList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return MachineInfoListItem(
                          machineInfo: machineInfoList[index],
                          removeable: true,
                          postCallback: getInfos,
                        );
                      },
                      separatorBuilder: (context, index) => const Divider(),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget noDeviceText(BuildContext context) {
    return Center(
      child: Text(
        'No device was found, please add first',
        style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
            fontSize: 20),
      ),
    );
  }
}
