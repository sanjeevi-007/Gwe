import 'package:flutter/foundation.dart';
import 'enums.dart';

@immutable
class PulseReading {
  final int? id;
  final String? deviceId;
  final DateTime tsDevice;
  final DateTime tsReceived;
  final int? bpm; // Null if invalid or 0xFFFF
  final int? spo2; // Null if off (0xFF) or unavailable
  final int quality;
  final PulseState state;
  final bool valid;

  const PulseReading({
    this.id,
    this.deviceId,
    required this.tsDevice,
    required this.tsReceived,
    this.bpm,
    this.spo2,
    required this.quality,
    required this.state,
    required this.valid,
  });

  /// Checks if reading was received within [maxAgeSeconds].
  bool isFresh(int maxAgeSeconds) {
    return DateTime.now().difference(tsReceived).inSeconds <= maxAgeSeconds;
  }

  PulseReading copyWith({
    int? id,
    String? deviceId,
    DateTime? tsDevice,
    DateTime? tsReceived,
    int? bpm,
    int? spo2,
    int? quality,
    PulseState? state,
    bool? valid,
  }) {
    return PulseReading(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      tsDevice: tsDevice ?? this.tsDevice,
      tsReceived: tsReceived ?? this.tsReceived,
      bpm: bpm ?? this.bpm,
      spo2: spo2 ?? this.spo2,
      quality: quality ?? this.quality,
      state: state ?? this.state,
      valid: valid ?? this.valid,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PulseReading &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          deviceId == other.deviceId &&
          tsDevice == other.tsDevice &&
          tsReceived == other.tsReceived &&
          bpm == other.bpm &&
          spo2 == other.spo2 &&
          quality == other.quality &&
          state == other.state &&
          valid == other.valid;

  @override
  int get hashCode => Object.hash(
        id,
        deviceId,
        tsDevice,
        tsReceived,
        bpm,
        spo2,
        quality,
        state,
        valid,
      );

  @override
  String toString() =>
      'PulseReading(id: $id, deviceId: $deviceId, bpm: $bpm, spo2: $spo2, quality: $quality, state: $state, valid: $valid, tsDevice: $tsDevice, tsReceived: $tsReceived)';
}
