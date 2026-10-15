import 'package:flutter/foundation.dart';
import 'enums.dart';

@immutable
class GpsReading {
  final int? id;
  final String? deviceId;
  final DateTime tsDevice;
  final DateTime tsReceived;
  final GpsFixState fixState;
  final double? lat; // null if invalid
  final double? lon; // null if invalid
  final int satellites;
  final double? hdop; // null if invalid
  final bool valid;
  final bool stale;

  const GpsReading({
    this.id,
    this.deviceId,
    required this.tsDevice,
    required this.tsReceived,
    required this.fixState,
    this.lat,
    this.lon,
    required this.satellites,
    this.hdop,
    required this.valid,
    required this.stale,
  });

  /// Checks if reading was received within [maxAgeSeconds].
  bool isFresh(int maxAgeSeconds) {
    return DateTime.now().difference(tsReceived).inSeconds <= maxAgeSeconds;
  }

  GpsReading copyWith({
    int? id,
    String? deviceId,
    DateTime? tsDevice,
    DateTime? tsReceived,
    GpsFixState? fixState,
    double? lat,
    double? lon,
    int? satellites,
    double? hdop,
    bool? valid,
    bool? stale,
  }) {
    return GpsReading(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      tsDevice: tsDevice ?? this.tsDevice,
      tsReceived: tsReceived ?? this.tsReceived,
      fixState: fixState ?? this.fixState,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      satellites: satellites ?? this.satellites,
      hdop: hdop ?? this.hdop,
      valid: valid ?? this.valid,
      stale: stale ?? this.stale,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GpsReading &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          deviceId == other.deviceId &&
          tsDevice == other.tsDevice &&
          tsReceived == other.tsReceived &&
          fixState == other.fixState &&
          lat == other.lat &&
          lon == other.lon &&
          satellites == other.satellites &&
          hdop == other.hdop &&
          valid == other.valid &&
          stale == other.stale;

  @override
  int get hashCode => Object.hash(
        id,
        deviceId,
        tsDevice,
        tsReceived,
        fixState,
        lat,
        lon,
        satellites,
        hdop,
        valid,
        stale,
      );

  @override
  String toString() =>
      'GpsReading(id: $id, deviceId: $deviceId, fixState: $fixState, lat: $lat, lon: $lon, sats: $satellites, hdop: $hdop, valid: $valid, stale: $stale, tsDevice: $tsDevice, tsReceived: $tsReceived)';
}
