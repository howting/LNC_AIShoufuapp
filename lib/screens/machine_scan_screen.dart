import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lnc_mach_app/widgets/back_button.dart';
import 'package:lnc_mach_app/widgets/machine_info_list_item.dart';
import 'package:lnc_mach_app/providers/background_container.dart';

class MachineScanScreen extends StatefulWidget {
  const MachineScanScreen({super.key});

  @override
  State<MachineScanScreen> createState() => _MachineScanScreenState();
}

class _MachineScanScreenState extends State<MachineScanScreen> {
  Timer? _timer;
  bool isDetected = false;
  bool isLoading = false;
  RawDatagramSocket? _udpSocket;
  List<MachineInfo> machineInfoList = [
    // test data
    // MachineInfo(id: '123', ip: '12321', name: 'name'),
  ];
  List<int> socketSendData = utf8.encode('?');
  // ignore: non_constant_identifier_names
  InternetAddress INADDR_BROADCAST = InternetAddress("255.255.255.255");

  // check duplicate
  bool checkIpDuplicate(ip) {
    for (MachineInfo machine in machineInfoList) {
      if (machine.ip == ip) return true;
    }
    return false;
  }

  // Function: wait some times
  Future<void> wait(milliseconds) async {
    await Future.delayed(Duration(milliseconds: milliseconds), () {});
  }

  Future<void> udpSocketInit() async {
    // ip detect use socket
    _udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 1701);
    _udpSocket!.broadcastEnabled = true;
    _udpSocket!.listen((_) {
      Datagram? dg = _udpSocket!.receive();
      if (dg != null) {
        String machineName = "";
        String machineIp = dg.address.address;
        // because of other five times sending, must exclude duplicate ip
        if (checkIpDuplicate(machineIp)) return;

        // get machine name
        try {
          machineName = const Utf8Codec().decode(dg.data);
        } catch (error) {
          machineName = "--";
        }

        // "?" means my device (who send the request), so need to exclude it
        if (machineName == "?") return;
        setState(() {
          machineInfoList.add(MachineInfo(id: '', ip: machineIp, name: machineName));
        });
      }
    });
    // must send a char '?' to get the reply, you can't get correct reply with using others char
    // port 1701 is LNC controller listening port for replying
    _udpSocket!.send(socketSendData, INADDR_BROADCAST, 1701);
  }

  // Function: handle start detect ips
  Future<void> handleStartDetectIps() async {
    // if last udp is listening than close it
    _udpSocket?.close();
    _timer?.cancel();
    // init all state
    setState(() {
      isLoading = true;
      isDetected = false;
      machineInfoList = [];
    });

    await udpSocketInit();

    // set the limit time of listening
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      _udpSocket!.send(socketSendData, INADDR_BROADCAST, 1701);
      // set loading state to false, but still detecting
      // send other 10 times to avoid nothing detect
      if (timer.tick == 10) {
        setState(() {
          isLoading = false;
          isDetected = true;
        });
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _udpSocket?.close();
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    handleStartDetectIps();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          leading: const MyBackButton(),
          title: const Text(
            'Scan',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            Container(
              child: isDetected
                  ? IconButton(
                      onPressed: handleStartDetectIps,
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.white70,
                      ))
                  : const SizedBox(),
            )
          ],
        ),
        body: Column(children: [
          Expanded(
              child: BackgroundContainer(
            padding: const EdgeInsets.only(
              top: 16.0,
              left: 16.0,
              right: 16.0,
            ),
            child: (machineInfoList.isEmpty && isDetected)
                ? noDeviceFoundText(context)
                : ListView.separated(
                    itemCount: machineInfoList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return MachineInfoListItem(
                        machineInfo: machineInfoList[index],
                        addButton: true,
                      );
                    },
                    separatorBuilder: (context, index) => const Divider(),
                  ),
          )),
          // Loading indicator
          isLoading
              ? LinearProgressIndicator(
                  color: Theme.of(context).colorScheme.secondary,
                )
              : const SizedBox(),
        ]),
      ),
    );
  }

  Widget noDeviceFoundText(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.sms_failed, color: Theme.of(context).colorScheme.onPrimaryContainer),
        Text(
          'No device was found',
          style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          'Check your internet or add manually',
          style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }
}
