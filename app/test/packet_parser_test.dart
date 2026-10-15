import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:gwen_app/ble/ble.dart';
import 'package:gwen_app/models/models.dart';

Uint8List buildHeader({
  int ver = 0x01,
  required int type,
  int seq = 1,
  int tMs = 1000,
  int flags = 0x01, // default valid = true
}) {
  final bytes = Uint8List(9);
  final bd = ByteData.sublistView(bytes);
  bd.setUint8(0, ver);
  bd.setUint8(1, type);
  bd.setUint16(2, seq, Endian.little);
  bd.setUint32(4, tMs, Endian.little);
  bd.setUint8(8, flags);
  return bytes;
}

Uint8List buildPulsePacket({
  int ver = 0x01,
  int seq = 1,
  int tMs = 1000,
  int flags = 0x01,
  required int bpm,
  int spo2 = 0xFF,
  int quality = 90,
  int state = 1,
}) {
  final bytes = Uint8List(14);
  bytes.setRange(0, 9, buildHeader(ver: ver, type: 0x01, seq: seq, tMs: tMs, flags: flags));
  final bd = ByteData.sublistView(bytes);
  bd.setUint16(9, bpm, Endian.little);
  bd.setUint8(11, spo2);
  bd.setUint8(12, quality);
  bd.setUint8(13, state);
  return bytes;
}

Uint8List buildMotionPacket({
  int ver = 0x01,
  int seq = 1,
  int tMs = 1000,
  int flags = 0x01,
  required int ax,
  required int ay,
  required int az,
  required int gx,
  required int gy,
  required int gz,
  int intensity = 25,
  int estClass = 1,
}) {
  final bytes = Uint8List(23);
  bytes.setRange(0, 9, buildHeader(ver: ver, type: 0x02, seq: seq, tMs: tMs, flags: flags));
  final bd = ByteData.sublistView(bytes);
  bd.setInt16(9, ax, Endian.little);
  bd.setInt16(11, ay, Endian.little);
  bd.setInt16(13, az, Endian.little);
  bd.setInt16(15, gx, Endian.little);
  bd.setInt16(17, gy, Endian.little);
  bd.setInt16(19, gz, Endian.little);
  bd.setUint8(21, intensity);
  bd.setUint8(22, estClass);
  return bytes;
}

Uint8List buildGpsPacket({
  int ver = 0x01,
  int seq = 1,
  int tMs = 1000,
  int flags = 0x01,
  required int fix,
  int sats = 8,
  required int lat,
  required int lon,
  int hdop = 12,
  int utc = 1710000000,
}) {
  final bytes = Uint8List(25);
  bytes.setRange(0, 9, buildHeader(ver: ver, type: 0x03, seq: seq, tMs: tMs, flags: flags));
  final bd = ByteData.sublistView(bytes);
  bd.setUint8(9, fix);
  bd.setUint8(10, sats);
  bd.setInt32(11, lat, Endian.little);
  bd.setInt32(15, lon, Endian.little);
  bd.setUint16(19, hdop, Endian.little);
  bd.setUint32(21, utc, Endian.little);
  return bytes;
}

Uint8List buildAiPacket({
  int ver = 0x01,
  int seq = 1,
  int tMs = 1000,
  int flags = 0x01,
  required int label,
  required int score,
  int modelVer = 1,
  required int source,
}) {
  final bytes = Uint8List(14);
  bytes.setRange(0, 9, buildHeader(ver: ver, type: 0x04, seq: seq, tMs: tMs, flags: flags));
  final bd = ByteData.sublistView(bytes);
  bd.setUint8(9, label);
  bd.setUint8(10, score);
  bd.setUint16(11, modelVer, Endian.little);
  bd.setUint8(13, source);
  return bytes;
}

Uint8List buildStatusPacket({
  int ver = 0x01,
  int seq = 1,
  int tMs = 1000,
  int flags = 0x01,
  int fwMajor = 1,
  int fwMinor = 2,
  int fwPatch = 3,
  int sensors = 0x1F,
  int uptimeS = 3600,
  required int battery,
}) {
  final bytes = Uint8List(18);
  bytes.setRange(0, 9, buildHeader(ver: ver, type: 0x05, seq: seq, tMs: tMs, flags: flags));
  final bd = ByteData.sublistView(bytes);
  bd.setUint8(9, fwMajor);
  bd.setUint8(10, fwMinor);
  bd.setUint8(11, fwPatch);
  bd.setUint8(12, sensors);
  bd.setUint32(13, uptimeS, Endian.little);
  bd.setUint8(17, battery);
  return bytes;
}

void main() {
  group('PacketParser Unit Tests', () {
    test('1. Pulse Packet Parsing (Type 0x01) - Valid Packet', () {
      final packet = buildPulsePacket(
        bpm: 75,
        spo2: 0xFF,
        quality: 90,
        state: 1, // valid
        flags: 0x01,
      );

      final result = PacketParser.parsePacket(packet, deviceId: 'TEST_PUCK');
      expect(result.isSuccess, isTrue);
      expect(result.data, isA<PulseReading>());

      final pulse = result.data as PulseReading;
      expect(pulse.bpm, 75);
      expect(pulse.spo2, isNull);
      expect(pulse.quality, 90);
      expect(pulse.state, PulseState.valid);
      expect(pulse.valid, isTrue);
    });

    test('1. Pulse Packet Parsing (Type 0x01) - Invalid BPM (0xFFFF)', () {
      final packet = buildPulsePacket(
        bpm: 0xFFFF,
        quality: 20,
        state: 3, // noFinger
        flags: 0x00, // not valid
      );

      final result = PacketParser.parsePacket(packet);
      expect(result.isSuccess, isTrue);

      final pulse = result.data as PulseReading;
      expect(pulse.bpm, isNull);
      expect(pulse.state, PulseState.noFinger);
      expect(pulse.valid, isFalse);
    });

    test('2. Motion Packet Parsing (Type 0x02) - Exact Axis Values', () {
      final packet = buildMotionPacket(
        ax: 100,
        ay: -200,
        az: 980,
        gx: 5,
        gy: -10,
        gz: 0,
        intensity: 25,
      );

      final result = PacketParser.parsePacket(packet);
      expect(result.isSuccess, isTrue);
      expect(result.data, isA<MotionReading>());

      final motion = result.data as MotionReading;
      expect(motion.ax, 100);
      expect(motion.ay, -200);
      expect(motion.az, 980);
      expect(motion.gx, 5);
      expect(motion.gy, -10);
      expect(motion.gz, 0);
      expect(motion.intensity, 25);
      expect(motion.valid, isTrue);
    });

    test('3. GPS Packet Parsing (Type 0x03) - Valid Fix', () {
      final packet = buildGpsPacket(
        fix: 1, // fix
        sats: 8,
        lat: 130826802, // 13.0826802 deg
        lon: 802707184, // 80.2707184 deg
        hdop: 12, // 1.2
        utc: 1710000000,
      );

      final result = PacketParser.parsePacket(packet);
      expect(result.isSuccess, isTrue);
      expect(result.data, isA<GpsReading>());

      final gps = result.data as GpsReading;
      expect(gps.fixState, GpsFixState.fix);
      expect(gps.satellites, 8);
      expect(gps.lat, closeTo(13.0826802, 0.000001));
      expect(gps.lon, closeTo(80.2707184, 0.000001));
      expect(gps.hdop, closeTo(1.2, 0.01));
      expect(gps.valid, isTrue);
    });

    test('3. GPS Packet Parsing (Type 0x03) - Searching State (lat/lon null)', () {
      final packet = buildGpsPacket(
        fix: 0, // searching
        sats: 1,
        lat: 0,
        lon: 0,
        hdop: 0,
        flags: 0x00,
      );

      final result = PacketParser.parsePacket(packet);
      expect(result.isSuccess, isTrue);

      final gps = result.data as GpsReading;
      expect(gps.fixState, GpsFixState.searching);
      expect(gps.lat, isNull);
      expect(gps.lon, isNull);
      expect(gps.valid, isFalse);
    });

    test('4. AI Packet Parsing (Type 0x04) - Rule-Based Classification', () {
      final packet = buildAiPacket(
        label: 1, // walkingLike
        score: 80,
        source: 1, // ruleBased
      );

      final result = PacketParser.parsePacket(packet);
      expect(result.isSuccess, isTrue);
      expect(result.data, isA<AiResult>());

      final ai = result.data as AiResult;
      expect(ai.isRuleBased, isTrue);
      expect(ai.isTrained, isFalse);
      expect(ai.displayLabelString, 'Motion estimate (rule-based)');
      expect(ai.score, 80);
    });

    test('4. AI Packet Parsing (Type 0x04) - Trained Model Classification', () {
      final packet = buildAiPacket(
        label: 2, // vigorous
        score: 95,
        source: 2, // trainedModel
      );

      final result = PacketParser.parsePacket(packet);
      expect(result.isSuccess, isTrue);

      final ai = result.data as AiResult;
      expect(ai.isTrained, isTrue);
      expect(ai.isRuleBased, isFalse);
      expect(ai.displayLabelString, 'vigorous');
      expect(ai.score, 95);
    });

    test('5. Device Status Packet Parsing (Type 0x05) - Valid Status', () {
      final packet = buildStatusPacket(
        fwMajor: 1,
        fwMinor: 2,
        fwPatch: 3,
        sensors: 0x1F, // all 5 bits ok
        uptimeS: 3600,
        battery: 85,
      );

      final result = PacketParser.parsePacket(packet);
      expect(result.isSuccess, isTrue);
      expect(result.data, isA<DeviceStatus>());

      final status = result.data as DeviceStatus;
      expect(status.firmwareVersion, '1.2.3');
      expect(status.battery, 85);
      expect(status.isMax30102Ok, isTrue);
      expect(status.isMpu6050Ok, isTrue);
      expect(status.isGpsOk, isTrue);
      expect(status.isTftOk, isTrue);
      expect(status.isModelLoaded, isTrue);
      expect(status.uptimeSeconds, 3600);
    });

    test('5. Device Status Packet Parsing (Type 0x05) - Battery Unknown (255)', () {
      final packet = buildStatusPacket(
        battery: 255,
      );

      final result = PacketParser.parsePacket(packet);
      expect(result.isSuccess, isTrue);

      final status = result.data as DeviceStatus;
      expect(status.battery, isNull);
    });

    test('6. Header & Failure Edge Cases - Truncated packet (< 9 bytes)', () {
      final truncated = Uint8List.fromList([0x01, 0x01, 0x00]);
      final result = PacketParser.parsePacket(truncated);

      expect(result.isSuccess, isFalse);
      expect(result.error, contains('shorter than header'));
    });

    test('6. Header & Failure Edge Cases - Wrong Protocol Version', () {
      final invalidVer = buildHeader(ver: 0x02, type: 0x01);
      final result = PacketParser.parsePacket(invalidVer);

      expect(result.isSuccess, isFalse);
      expect(result.error, contains('Unsupported protocol version'));
    });

    test('6. Header & Failure Edge Cases - Unknown Packet Type', () {
      final unknownType = buildHeader(type: 0x99);
      final result = PacketParser.parsePacket(unknownType);

      expect(result.isSuccess, isFalse);
      expect(result.error, contains('Unknown packet type'));
    });
  });

  group('SequenceTracker Unit Tests', () {
    test('Sequential processing: seq 1, 2, 3 -> status valid', () {
      final tracker = SequenceTracker();

      final res1 = tracker.processSequence(1);
      expect(res1.status, SequenceStatus.valid);
      expect(res1.expectedSeq, 1);
      expect(res1.receivedSeq, 1);
      expect(res1.droppedCount, 0);

      final res2 = tracker.processSequence(2);
      expect(res2.status, SequenceStatus.valid);
      expect(res2.expectedSeq, 2);
      expect(res2.receivedSeq, 2);
      expect(res2.droppedCount, 0);

      final res3 = tracker.processSequence(3);
      expect(res3.status, SequenceStatus.valid);
      expect(res3.expectedSeq, 3);
      expect(res3.receivedSeq, 3);
      expect(res3.droppedCount, 0);
    });

    test('Duplicate packet: seq 3 repeated -> status duplicate', () {
      final tracker = SequenceTracker();

      tracker.processSequence(1);
      tracker.processSequence(2);
      final res3 = tracker.processSequence(3);
      expect(res3.status, SequenceStatus.valid);

      final dup = tracker.processSequence(3);
      expect(dup.status, SequenceStatus.duplicate);
      expect(dup.expectedSeq, 4);
      expect(dup.receivedSeq, 3);
      expect(dup.droppedCount, 0);
    });

    test('Dropped packets: seq 3 -> seq 6 -> status dropped, droppedCount == 2', () {
      final tracker = SequenceTracker();

      tracker.processSequence(1);
      tracker.processSequence(2);
      tracker.processSequence(3);

      final gap = tracker.processSequence(6);
      expect(gap.status, SequenceStatus.dropped);
      expect(gap.expectedSeq, 4);
      expect(gap.receivedSeq, 6);
      expect(gap.droppedCount, 2); // 4 and 5 were dropped
    });

    test('Sequence tracker reset clears state', () {
      final tracker = SequenceTracker();
      tracker.processSequence(100);
      expect(tracker.lastSeq, 100);

      tracker.reset();
      expect(tracker.lastSeq, isNull);

      final fresh = tracker.processSequence(5);
      expect(fresh.status, SequenceStatus.valid);
      expect(fresh.receivedSeq, 5);
    });
  });
}
