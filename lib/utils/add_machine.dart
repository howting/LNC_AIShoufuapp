import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:lnc_mach_app/utils/storage.dart';
import 'package:uuid/uuid.dart';

Future<void> addMachine(
    {required TextEditingController controller, required Function(dynamic err) setErrMsg, required String ip}) async {
  Storage storage = Storage();
  await storage.init();
  final machineName = controller.value.text.trim();
  setErrMsg(null);
  if (machineName.isEmpty) {
    setErrMsg('Required Field');
    return;
  }
  // uuid
  const uuid = Uuid();
  final String machineID = uuid.v5(Uuid.NAMESPACE_URL, machineName);
  // get data
  var encodeInfos = await storage.getData('machineInfos');
  bool isKeyNotExist = encodeInfos?.isEmpty ?? true;
  Map<String, dynamic> newInfosMap = {'id': machineID, 'ip': ip, 'name': machineName};

  if (!isKeyNotExist) {
    List decodedInfos = json.decode(encodeInfos);
    // check Duplicate
    if (storage.hasDuplicate(machineID, decodedInfos)) {
      setErrMsg('Duplicated Name');
      return;
    }
    decodedInfos.add(newInfosMap);
    String encodesInfos = json.encode(decodedInfos);
    storage.saveStringData('machineInfos', encodesInfos);
  } else {
    String encodesInfos = json.encode([newInfosMap]);
    storage.saveStringData('machineInfos', encodesInfos);
  }
}
