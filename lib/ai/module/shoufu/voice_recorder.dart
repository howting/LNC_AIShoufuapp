import 'dart:io';
import 'package:record/record.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class VoiceRecorder {
  final Record _record = Record();

  /// 開始錄音：iOS / Android 都用 WAV
  Future<String?> startRecord() async {
    // 麥克風權限確認（可以先用 permission_handler 要權限）
    if (!await _record.hasPermission()) return null;

    final dir = await getTemporaryDirectory();
    final ts = DateTime.now().millisecondsSinceEpoch;

    // ★ 副檔名給 .wav
    final path = p.join(dir.path, 'rec_$ts.wav');

    await _record.start(
      path: path,                 // ★ 決定實際檔案路徑 + 副檔名
      encoder: AudioEncoder.wav,  // ★ 真正錄成 WAV
      bitRate: 128000,
      samplingRate: 16000,
    );

    print("startRecord path=$path");
    return path;
  }

  /// 停止錄音並回傳檔案路徑
  Future<String?> stopRecord() async {
    final path = await _record.stop();
    print("stopRecord path=$path");
    return path;
  }

  Future<void> dispose() async {
    await _record.dispose();
  }
}