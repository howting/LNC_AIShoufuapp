// ignore_for_file: non_constant_identifier_names

class RValue {
  // 保持連線 R 值，若無持續寫入，控制器會判定我們沒有在連線
  static int get KEEP_CONNECTION => 20039;

  // 機台模式 R 值
  static int get READ_MACHINE_MODE => 22000;
  static int get WRITE_MACHINE_MODE => 20000;

  // 機台狀態 R 值
  static int get READ_MACHINE_STATUS => 17003; // 17003 for production
  static int get WRITE_MACHINE_STATUS => 1;

  // 機台功能 R 值
  static int get READ_MACHINE_FN => 352;
  static int get WRITE_MACHINE_FN => 20001;

  // 進給率
  static int get READ_FEED_RATE => 82066;

  // 進給比
  static int get READ_FEED_RATIO => 17001;

  // 主軸轉速
  static int get READ_SPINDLE_ROTATION_SPEED => 83138;

  // 轉速比
  static int get READ_SPINDLE_ROTATION_SPEED_RATIO => 11370;

  // 快進比
  static int get READ_FAST_FORWARD_RATIO => 1024005;

  // OP面板
  static int get WRITE_MACHINE_OPERATION_RATIO => 20001;

  // 主軸啟動/停止
  static int get READ_SPINDLE_ROTATION_STATUS => 356;
  static int get WRITE_SPINDLE_ROTATION_STATUS => 20000;

  // F
  static int get READ_F => 3006196;

  // S
  static int get READ_S => 21001;

  // 主軸刀號
  static int get READ_SPINDLE_BLADE => 7813;

  // 待命刀號
  static int get READ_BACKUP_BLADE => 7901;

  // 機械座標
  static int get MECHANICAL_X => 11564;
  static int get MECHANICAL_Y1 => 11565;
  static int get MECHANICAL_Y2 => 11569;
  static int get MECHANICAL_Z => 11566;
  // 絕對座標
  static int get ABSOLUTE_X => 12032;
  static int get ABSOLUTE_Y1 => 12033;
  static int get ABSOLUTE_Y2 => 12037;
  static int get ABSOLUTE_Z => 12034;

  // EMC 模式
  static int get EMC_R => 20000;
  static int get EMC_BIT => 31;
  // 開始加工
  static int get START_R => 20000;
  static int get START_BIT => 10;
  // 暫停加工
  static int get STOP_R => 20000;
  static int get STOP_BIT => 11;
  // 復位
  static int get RETURN_R => 20000;
  static int get RETURN_BIT => 0;

  // X 軸增加
  static int get X_PLUS_R => 20040;
  static int get X_PLUS_BIT => 13;
  // X 軸減少
  static int get X_MINUS_R => 20040;
  static int get X_MINUS_BIT => 14;
  // Y 軸增加
  static int get Y_PLUS_R => 20040;
  static int get Y_PLUS_BIT => 15;
  // Y 軸減少
  static int get Y_MINUS_R => 20040;
  static int get Y_MINUS_BIT => 16;
  // Z 軸增加
  static int get Z_PLUS_R => 20040;
  static int get Z_PLUS_BIT => 17;
  // Z 軸減少
  static int get Z_MINUS_R => 20040;
  static int get Z_MINUS_BIT => 18;

  // 全部軸 List
  static List<int> get COORDINATE_LIST =>
      [MECHANICAL_X, MECHANICAL_Y1, MECHANICAL_Y2, MECHANICAL_Z, ABSOLUTE_X, ABSOLUTE_Y1, ABSOLUTE_Y2, ABSOLUTE_Z];
}
