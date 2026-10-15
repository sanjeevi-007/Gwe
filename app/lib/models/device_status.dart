import 'package:flutter/foundation.dart';

@immutable
class DeviceStatus {
  final int? id;
  final String? deviceId;
  final DateTime tsDevice;
  final DateTime tsReceived;
  final int fwMajor;
  final int fwMinor;
  final int fwPatch;
  final int sensorsBitmask;
  final int uptimeSeconds;
  final int? battery; // null if unknown or 255
  final bool valid;

  const DeviceStatus({
    this.id,
    this.deviceId,
    required this.tsDevice,
    required this.tsReceived,
    required this.fwMajor,
    required this.fwMinor,
    required this.fwPatch,
    required this.sensorsBitmask,
    required this.uptimeSeconds,
    this.battery,
    required this.valid,
  });

  // Sensors bitmask helpers:
  // bit 0: max30102, bit 1: mpu6050, bit 2: gps, bit 3: tft, bit 4: model loaded
  bool get isMax30102Ok => (sensorsBitmask & (1 << 0)) != 0;
  bool get isMpu6050Ok => (sensorsBitmask & (1 << 1)) != 0;
  bool get isGpsOk => (sensorsBitmask & (1 << 2)) != 0;
  bool get isTftOk => (sensorsBitmask & (1 << 3)) != 0;
  bool get isModelLoaded => (sensorsBitmask & (1 << 4)) != 0;

  String get firmwareVersion => '$fwMajor.$fwMinor.$fwPatch';

  /// Checks if status was received within [maxAgeSeconds].
  bool isFresh(int maxAgeSeconds) {
    return DateTime.now().difference(tsReceived).inSeconds <= maxAgeSeconds;
  }

  DeviceStatus copyWith({
    int? id,
    String? deviceId,
    DateTime? tsDevice,
    DateTime? tsReceived,
    int? fwMajor,
    int? fwMinor,
    int? fwPatch,
    int? sensorsBitmask,
    int? uptimeSeconds,
    int? battery,
    bool? valid,
  }) {
    return DeviceStatus(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      tsDevice: tsDevice ?? this.tsDevice,
      tsReceived: tsReceived ?? this.tsReceived,
      fwMajor: fwMajor ?? this.fwMajor,
      fwMinor: fwMinor ?? this.fwMinor,
      fwPatch: fwPatch ?? this.fwPatch,
      sensorsBitmask: sensorsBitmask ?? this.sensorsBitmask,
      uptimeSeconds: uptimeSeconds ?? this.uptimeSeconds,
      battery: battery ?? this.battery,
      valid: valid ?? this.valid,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceStatus &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          deviceId == other.deviceId &&
          tsDevice == other.tsDevice &&
          tsReceived == other.tsReceived &&
          fwMajor == other.fwMajor &&
          fwMinor == other.fwMinor &&
          fwPatch == other.fwPatch &&
          sensorsBitmask == other.sensorsBitmask &&
          uptimeSeconds == other.uptimeSeconds &&
          battery == other.battery &&
          valid == other.valid;

  @override
  int get hashCode => Object.hash(
        id,
        deviceId,
        tsDevice,
        tsReceived,
        fwMajor,
        fwMinor,
        fwPatch,
        sensorsBitmask,
        uptimeSeconds,
        battery,
        valid,
      );

  @override
  String toString() =>
      'DeviceStatus(id: $id, deviceId: $deviceId, fw: $firmwareVersion, sensors: $sensorsBitmask, uptime: ${uptimeSeconds}s, battery: $battery%, valid: $valid, tsDevice: $tsDevice, tsReceived: $tsReceived)';
}
