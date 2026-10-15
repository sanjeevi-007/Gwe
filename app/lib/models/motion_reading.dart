import 'package:flutter/foundation.dart';

@immutable
class MotionReading {
  final int? id;
  final String? deviceId;
  final DateTime tsDevice;
  final DateTime tsReceived;
  final int ax; // mg
  final int ay; // mg
  final int az; // mg
  final int gx; // deg/s x10
  final int gy; // deg/s x10
  final int gz; // deg/s x10
  final int intensity;
  final bool valid;

  const MotionReading({
    this.id,
    this.deviceId,
    required this.tsDevice,
    required this.tsReceived,
    required this.ax,
    required this.ay,
    required this.az,
    required this.gx,
    required this.gy,
    required this.gz,
    required this.intensity,
    required this.valid,
  });

  /// Checks if reading was received within [maxAgeSeconds].
  bool isFresh(int maxAgeSeconds) {
    return DateTime.now().difference(tsReceived).inSeconds <= maxAgeSeconds;
  }

  MotionReading copyWith({
    int? id,
    String? deviceId,
    DateTime? tsDevice,
    DateTime? tsReceived,
    int? ax,
    int? ay,
    int? az,
    int? gx,
    int? gy,
    int? gz,
    int? intensity,
    bool? valid,
  }) {
    return MotionReading(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      tsDevice: tsDevice ?? this.tsDevice,
      tsReceived: tsReceived ?? this.tsReceived,
      ax: ax ?? this.ax,
      ay: ay ?? this.ay,
      az: az ?? this.az,
      gx: gx ?? this.gx,
      gy: gy ?? this.gy,
      gz: gz ?? this.gz,
      intensity: intensity ?? this.intensity,
      valid: valid ?? this.valid,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MotionReading &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          deviceId == other.deviceId &&
          tsDevice == other.tsDevice &&
          tsReceived == other.tsReceived &&
          ax == other.ax &&
          ay == other.ay &&
          az == other.az &&
          gx == other.gx &&
          gy == other.gy &&
          gz == other.gz &&
          intensity == other.intensity &&
          valid == other.valid;

  @override
  int get hashCode => Object.hash(
        id,
        deviceId,
        tsDevice,
        tsReceived,
        ax,
        ay,
        az,
        gx,
        gy,
        gz,
        intensity,
        valid,
      );

  @override
  String toString() =>
      'MotionReading(id: $id, deviceId: $deviceId, ax: $ax, ay: $ay, az: $az, gx: $gx, gy: $gy, gz: $gz, intensity: $intensity, valid: $valid, tsDevice: $tsDevice, tsReceived: $tsReceived)';
}
