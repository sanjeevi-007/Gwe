import 'dart:typed_data';

import '../models/models.dart';

class PacketHeader {
  final int version;
  final int type;
  final int seq;
  final int tMs;
  final int flags;
  final bool isValid;
  final bool isStale;
  final bool hasSensorError;

  const PacketHeader({
    required this.version,
    required this.type,
    required this.seq,
    required this.tMs,
    required this.flags,
    required this.isValid,
    required this.isStale,
    required this.hasSensorError,
  });

  @override
  String toString() =>
      'PacketHeader(ver: $version, type: 0x${type.toRadixString(16)}, seq: $seq, tMs: $tMs, valid: $isValid, stale: $isStale, err: $hasSensorError)';
}

class ParsedPacketResult {
  final PacketHeader? header;
  final Object? data;
  final String? error;

  bool get isSuccess => error == null && data != null;

  const ParsedPacketResult.success({
    required PacketHeader this.header,
    required Object this.data,
  }) : error = null;

  const ParsedPacketResult.error(this.error)
      : header = null,
        data = null;

  @override
  String toString() => isSuccess
      ? 'ParsedPacketResult.success(header: $header, data: $data)'
      : 'ParsedPacketResult.error($error)';
}

class PacketParser {
  /// Parses raw BLE notification bytes into domain models.
  /// This parser is safe and guaranteed NEVER to throw on malformed data.
  static ParsedPacketResult parsePacket(
    Uint8List bytes, {
    String? deviceId,
    DateTime? receivedAt,
  }) {
    try {
      if (bytes.length < 9) {
        return const ParsedPacketResult.error('Packet shorter than header');
      }

      final byteData = ByteData.sublistView(bytes);

      final version = byteData.getUint8(0);
      if (version != 0x01) {
        return ParsedPacketResult.error('Unsupported protocol version: $version');
      }

      final type = byteData.getUint8(1);
      final seq = byteData.getUint16(2, Endian.little);
      final tMs = byteData.getUint32(4, Endian.little);
      final flags = byteData.getUint8(8);

      final isValid = (flags & 0x01) != 0;
      final isStale = (flags & 0x02) != 0;
      final hasSensorError = (flags & 0x04) != 0;

      final header = PacketHeader(
        version: version,
        type: type,
        seq: seq,
        tMs: tMs,
        flags: flags,
        isValid: isValid,
        isStale: isStale,
        hasSensorError: hasSensorError,
      );

      final tsReceived = receivedAt ?? DateTime.now();
      // Derive device timestamp from uptime or received time
      final tsDevice = tsReceived;

      switch (type) {
        case 0x01: // Pulse
          if (bytes.length < 14) {
            return const ParsedPacketResult.error('Pulse packet shorter than 14 bytes');
          }
          final rawBpm = byteData.getUint16(9, Endian.little);
          final bpm = (rawBpm == 0xFFFF || !isValid) ? null : rawBpm;
          final quality = byteData.getUint8(12);
          final stateRaw = byteData.getUint8(13);
          final state = PulseState.fromRawValue(stateRaw);

          final pulseReading = PulseReading(
            deviceId: deviceId,
            tsDevice: tsDevice,
            tsReceived: tsReceived,
            bpm: bpm,
            quality: quality,
            state: state,
            valid: isValid,
          );

          return ParsedPacketResult.success(
            header: header,
            data: pulseReading,
          );

        case 0x02: // Motion
          if (bytes.length < 23) {
            return const ParsedPacketResult.error('Motion packet shorter than 23 bytes');
          }
          final ax = byteData.getInt16(9, Endian.little);
          final ay = byteData.getInt16(11, Endian.little);
          final az = byteData.getInt16(13, Endian.little);
          final gx = byteData.getInt16(15, Endian.little);
          final gy = byteData.getInt16(17, Endian.little);
          final gz = byteData.getInt16(19, Endian.little);
          final intensity = byteData.getUint8(21);

          final motionReading = MotionReading(
            deviceId: deviceId,
            tsDevice: tsDevice,
            tsReceived: tsReceived,
            ax: ax,
            ay: ay,
            az: az,
            gx: gx,
            gy: gy,
            gz: gz,
            intensity: intensity,
            valid: isValid,
          );

          return ParsedPacketResult.success(
            header: header,
            data: motionReading,
          );

        case 0x03: // GPS
          if (bytes.length < 25) {
            return const ParsedPacketResult.error('GPS packet shorter than 25 bytes');
          }
          final fixRaw = byteData.getUint8(9);
          final fixState = GpsFixState.fromRawValue(fixRaw);
          final sats = byteData.getUint8(10);
          final rawLat = byteData.getInt32(11, Endian.little);
          final rawLon = byteData.getInt32(15, Endian.little);
          final rawHdop = byteData.getUint16(19, Endian.little);

          final isFixValid = fixState == GpsFixState.fix || fixState == GpsFixState.weak;
          final double? lat = (isFixValid && rawLat != 0x7FFFFFFF && rawLat != 0)
              ? (rawLat / 1e7)
              : null;
          final double? lon = (isFixValid && rawLon != 0x7FFFFFFF && rawLon != 0)
              ? (rawLon / 1e7)
              : null;
          final double? hdop = (rawHdop == 0xFFFF || rawHdop == 0) ? null : (rawHdop / 10.0);

          final gpsReading = GpsReading(
            deviceId: deviceId,
            tsDevice: tsDevice,
            tsReceived: tsReceived,
            fixState: fixState,
            lat: lat,
            lon: lon,
            satellites: sats,
            hdop: hdop,
            valid: isValid,
            stale: isStale,
          );

          return ParsedPacketResult.success(
            header: header,
            data: gpsReading,
          );

        case 0x04: // AI Result
          if (bytes.length < 14) {
            return const ParsedPacketResult.error('AI Result packet shorter than 14 bytes');
          }
          final labelRaw = byteData.getUint8(9);
          final label = AiLabel.fromRawValue(labelRaw);
          final rawScore = byteData.getUint8(10);
          final score = rawScore == 255 ? null : rawScore;
          final modelVer = byteData.getUint16(11, Endian.little);
          final sourceRaw = byteData.getUint8(13);
          final source = AiSource.fromRawValue(sourceRaw);

          final aiResult = AiResult(
            deviceId: deviceId,
            tsDevice: tsDevice,
            tsReceived: tsReceived,
            label: label,
            score: score,
            modelVersion: modelVer,
            source: source,
            valid: isValid,
          );

          return ParsedPacketResult.success(
            header: header,
            data: aiResult,
          );

        case 0x05: // Device Status
          if (bytes.length < 18) {
            return const ParsedPacketResult.error('Device Status packet shorter than 18 bytes');
          }
          final fwMajor = byteData.getUint8(9);
          final fwMinor = byteData.getUint8(10);
          final fwPatch = byteData.getUint8(11);
          final sensors = byteData.getUint8(12);
          final uptimeS = byteData.getUint32(13, Endian.little);
          final rawBattery = byteData.getUint8(17);
          final battery = rawBattery == 255 ? null : rawBattery;

          final deviceStatus = DeviceStatus(
            deviceId: deviceId,
            tsDevice: tsDevice,
            tsReceived: tsReceived,
            fwMajor: fwMajor,
            fwMinor: fwMinor,
            fwPatch: fwPatch,
            sensorsBitmask: sensors,
            uptimeSeconds: uptimeS,
            battery: battery,
            valid: isValid,
          );

          return ParsedPacketResult.success(
            header: header,
            data: deviceStatus,
          );

        default:
          return ParsedPacketResult.error('Unknown packet type: 0x${type.toRadixString(16)}');
      }
    } catch (e) {
      return ParsedPacketResult.error('Exception parsing packet: $e');
    }
  }
}
