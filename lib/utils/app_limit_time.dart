import 'package:lnc_mach_app/utils/storage.dart';

class AppLimitTime {
  // ignore: non_constant_identifier_names
  DateTime DUE_TIME = DateTime.parse('20230912');
  Storage storage = Storage();
  String? lastTime;

  Future<void> init() async {
    await storage.init();
    await getLastTime();

    bool isTimeNull = lastTime?.isEmpty ?? true;

    if (isTimeNull || DateTime.now().isAfter(DateTime.parse(lastTime!))) {
      storage.saveStringData('lastTime', DateTime.now().toString());
    }
  }

  Future<void> getLastTime() async {
    lastTime = await storage.getData('lastTime');
  }

  Future<bool> isTimeOver() async {
    await getLastTime();
    if (DateTime.now().isBefore(DateTime.parse(lastTime!))) {
      return true;
    }
    if (DateTime.now().isAfter(DUE_TIME)) {
      return true;
    }
    return false;
  }
}
