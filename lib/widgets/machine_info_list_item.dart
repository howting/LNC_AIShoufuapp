import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:lnc_mach_app/ai/routes/app_pages.dart';
import 'package:lnc_mach_app/global.dart';
import 'package:lnc_mach_app/providers/recorn.dart';
import 'package:lnc_mach_app/utils/add_machine.dart';
import 'package:lnc_mach_app/utils/storage.dart';
import 'package:provider/provider.dart';

class MachineInfoListItem extends StatefulWidget {
  const MachineInfoListItem(
      {super.key,
      required this.machineInfo,
      this.addButton = false,
      this.removeable = false,
      this.postCallback});
  final bool addButton;
  final bool removeable;
  final MachineInfo machineInfo;
  final VoidCallback? postCallback;

  @override
  State<MachineInfoListItem> createState() => _MachineInfoListItemState();
}

class _MachineInfoListItemState extends State<MachineInfoListItem> {
  final TextEditingController _controller = TextEditingController();
  late Recorn _recorn;
  Storage storage = Storage();
  bool isConnecting = false;
  bool isAvoidClick = false;
  String connectingIp = "";
  String? errMsg;

  Future<void> wait(milliseconds) async {
    await Future.delayed(Duration(milliseconds: milliseconds), () {});
  }

  // Function: handle delete machine info
  Future<void> handleDelete() async {
    // get data
    String machineInfoList = await storage.getData('machineInfos');
    List decodeList = json.decode(machineInfoList);
    // set data
    int index = decodeList
        .indexWhere((machine) => machine["id"] == widget.machineInfo.id);
    decodeList.removeAt(index);
    String encodeInfos = json.encode(decodeList);
    if (decodeList.isEmpty) {
      storage.removeDate('machineInfos');
    } else {
      storage.saveStringData('machineInfos', encodeInfos);
    }
    // when has callback
    if (widget.postCallback == null) return;
    widget.postCallback!();

    // show toast
    if (!mounted) return;
    Fluttertoast.showToast(
        msg: "Delete Success",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Theme.of(context).colorScheme.primary,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  // Function: handle connect to device from ip
  Future<void> handleConnect(String ip, String name) async {
    if (isAvoidClick) return;
    setState(() {
      isConnecting = true;
      isAvoidClick = true;
      connectingIp = ip;
    });

    bool isConnectStateSuccess = await _recorn.testConnection(ip);
    if (!mounted) return;
    if (isConnectStateSuccess) {
      Future.delayed(const Duration(milliseconds: 100), () {
        Get.toNamed(Routes.MACHINE_CHAT,
            arguments: {'ip': ip, 'machineName': name});
        // Get.toNamed(Routes.MAH_MACHINE_MAIN,
        //     arguments: {'ip': ip, 'machineName': name});
      });
      Fluttertoast.showToast(
          msg: "Successfully Connected",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black87,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      // if fail, need to clean the isolate
      _recorn.cleanIsolate();
      Fluttertoast.showToast(
          msg: "Time out!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }

    // allow click again after a second
    await wait(1000);
    setState(() {
      isAvoidClick = false;
      isConnecting = false;
    });
  }

  // Funciton: handle add new machine to list
  Future<void> handleAddMachine(BuildContext context,
      Function(void Function()) setState, String ip) async {
    if (isAvoidClick) return;
    // add machine to storage and validate the input data
    await addMachine(
        controller: _controller,
        setErrMsg: (err) {
          setState(() {
            errMsg = err;
          });
        },
        ip: ip);

    // if no error than close the dialog and show toast
    if (!mounted || errMsg != null) return;
    // close dialog
    Navigator.of(context).pop();
    setState(() {
      errMsg = null;
      Fluttertoast.showToast(
          msg: "新增成功",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black87,
          textColor: Colors.white,
          fontSize: 16.0);
    });
  }

  @override
  void didChangeDependencies() {
    // _recorn = Provider.of<Recorn>(context, listen: false);
    _recorn = Global.recorn;
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    storage.init();
  }

  @override
  void dispose() {
    // avoid user click back button when testing connection, need to clear while loop
    _recorn.clearTestingConnection();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      enabled: widget.removeable,
      key: Key(widget.machineInfo.id),
      startActionPane: ActionPane(
        extentRatio: 0.25,
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) async {
              await handleDelete();
            },
            label: 'Delete',
            icon: Icons.delete,
            backgroundColor: Colors.red,
          )
        ],
      ),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2.0),
            color: Theme.of(context).colorScheme.primaryContainer),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Expanded(
                          flex: 1,
                          child: Text(
                            'Alias',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 239, 239, 239)),
                          )),
                      const SizedBox(width: 4.0),
                      Expanded(
                        flex: 5,
                        child: Container(
                          padding: const EdgeInsets.all(4.0),
                          color:
                              Theme.of(context).colorScheme.secondaryContainer,
                          child: Text(
                            widget.machineInfo.name,
                            style: const TextStyle(
                                color: Color.fromARGB(255, 239, 239, 239)),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Expanded(
                          flex: 1,
                          child: Text(
                            'IP',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 239, 239, 239)),
                          )),
                      const SizedBox(width: 4.0),
                      Expanded(
                        flex: 5,
                        child: Container(
                          padding: const EdgeInsets.all(4.0),
                          color:
                              Theme.of(context).colorScheme.secondaryContainer,
                          child: Text(
                            widget.machineInfo.ip,
                            style: const TextStyle(
                                color: Color.fromARGB(255, 239, 239, 239)),
                          ),
                        ),
                      )
                    ],
                  ),
                ]),
              ),
            ),
            widget.addButton
                ? SizedBox(
                    height: 80,
                    child: ElevatedButton(
                        onPressed: () async {
                          await showAddConfirmDialog(widget.machineInfo);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0)),
                            elevation: 0),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add),
                            Text('Add', style: TextStyle(fontSize: 10)),
                          ],
                        )),
                  )
                : const SizedBox(),
            SizedBox(
              height: 80,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0)),
                      elevation: 0),
                  onPressed: () {
                    // Navigator.pushNamed(context, '/machine');
                    handleConnect(
                        widget.machineInfo.ip, widget.machineInfo.name);
                  },
                  child: isConnecting && connectingIp == widget.machineInfo.ip
                      ? const _ConnectionLoadingIcon(color: Colors.white70)
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cast_connected_outlined),
                            SizedBox(height: 8.0),
                            Text(
                              'Connect',
                              style: TextStyle(fontSize: 10),
                            )
                          ],
                        )),
            )
          ],
        ),
      ),
    );
  }

  Future<bool?> showAddConfirmDialog(MachineInfo machineInfo) {
    _controller.text = machineInfo.name;
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            title: const Text("Add To List"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Please enter machine name",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                TextField(
                  style: const TextStyle(fontSize: 18),
                  controller: _controller,
                  decoration: InputDecoration(
                    errorText: errMsg ?? errMsg,
                    errorStyle: TextStyle(fontSize: 16, color: Colors.red[400]),
                  ),
                )
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text("CANCEL"),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: const Text("ADD"),
                onPressed: () async {
                  await handleAddMachine(context, setState, machineInfo.ip);
                },
              ),
            ],
          );
        });
      },
    );
  }
}

class _ConnectionLoadingIcon extends StatelessWidget {
  const _ConnectionLoadingIcon({this.color = Colors.white});
  final Color? color;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SpinKitWave(
          color: color,
          size: 20.0,
        ),
        const SizedBox(
          height: 4,
        ),
        Text(
          'Connecting',
          style: TextStyle(color: color, fontSize: 10.0),
        )
      ],
    );
  }
}

class MachineInfo {
  MachineInfo({required this.id, required this.ip, required this.name});
  String ip;
  String name;
  String id;

  Map<String, String> toMap() {
    // ignore: no_leading_underscores_for_local_identifiers
    Map<String, String> _mMap = {};
    _mMap['id'] = id;
    _mMap['name'] = name;
    _mMap['ip'] = ip;
    return _mMap;
  }
}
