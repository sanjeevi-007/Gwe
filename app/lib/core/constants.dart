class AppConstants {
  // App Title
  static const String appTitle = 'GWEN';

  // BLE Service & Characteristic UUIDs
  static const String bleServiceUuid = '6E400001-B5A3-F393-E0A9-E50E24DCCA9E';
  static const String pulseCharacteristicUuid = '6E400002-B5A3-F393-E0A9-E50E24DCCA9E';
  static const String motionCharacteristicUuid = '6E400003-B5A3-F393-E0A9-E50E24DCCA9E';
  static const String gpsCharacteristicUuid = '6E400004-B5A3-F393-E0A9-E50E24DCCA9E';
  static const String aiCharacteristicUuid = '6E400005-B5A3-F393-E0A9-E50E24DCCA9E';
  static const String statusCharacteristicUuid = '6E400006-B5A3-F393-E0A9-E50E24DCCA9E';
  static const String timeSyncCharacteristicUuid = '6E400007-B5A3-F393-E0A9-E50E24DCCA9E';
  static const String configCharacteristicUuid = '6E400008-B5A3-F393-E0A9-E50E24DCCA9E';

  // Freshness Thresholds (seconds)
  static const int pulseFreshnessSeconds = 5;
  static const int motionFreshnessSeconds = 5;
  static const int aiFreshnessSeconds = 5;
  static const int gpsFreshnessSeconds = 30;
}
