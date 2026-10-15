import 'package:flutter/foundation.dart';
import 'enums.dart';

@immutable
class PulseReading {
  final int? id;
  final String? deviceId;
  final DateTime tsDevice;
  final DateTime tsReceived;
  final int? bpm; // Null if invalid or 0xFFFF
  final int quality;
  final PulseState state;
  final bool valid;

  const PulseReading({
    this.id,
    this.deviceId,
    required this.tsDevice,
    required this.tsReceived,
    this.bpm,
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
        quality,
        state,
        valid,
      );

  @override
  String toString() =>
      'PulseReading(id: $id, deviceId: $deviceId, bpm: $bpm, quality: $quality, state: $state, valid: $valid, tsDevice: $tsDevice, tsReceived: $tsReceived)';
}
