import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gwen_app/ble/phone_gps_bridge.dart';
import 'package:gwen_app/data/export_service.dart';
import 'package:gwen_app/data/repositories/repositories.dart';
import 'package:gwen_app/models/models.dart';

class FakePulseRepository implements PulseRepository {
  List<PulseReading> pulseList = [];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<List<PulseReading>> getPulseHistory(DateTime start, DateTime end) async {
    return pulseList;
  }
}

class FakeMotionRepository implements MotionRepository {
  List<MotionReading> motionList = [];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<List<MotionReading>> getMotionHistory(DateTime start, DateTime end) async {
    return motionList;
  }
}

class FakeGpsRepository implements GpsRepository {
  List<GpsReading> gpsList = [];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<int> insertGps(GpsReading reading) async {
    gpsList.add(reading);
    return gpsList.length;
  }

  @override
  Future<List<GpsReading>> getGpsHistory(DateTime start, DateTime end) async {
    return gpsList;
  }
}

class FakeAiRepository implements AiRepository {
  List<AiResult> aiList = [];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<List<AiResult>> getAiHistory(DateTime start, DateTime end) async {
    return aiList;
  }
}

void main() {
  group('ExportService Formatting Tests', () {
    final now = DateTime(2026, 10, 16, 12, 0, 0);

    test('formatPulseCsv generates valid CSV string', () {
      final readings = [
        PulseReading(
          id: 1,
          deviceId: 'GWEN-PUCK-1',
          tsDevice: now,
          tsReceived: now,
          bpm: 72,
          quality: 95,
          state: PulseState.valid,
          valid: true,
        ),
      ];

      final csv = ExportService.formatPulseCsv(readings);
      final lines = csv.trim().split('\n');
      expect(lines.length, 2);
      expect(lines[0], 'id,deviceId,tsDevice,tsReceived,bpm,quality,state,valid');
      expect(lines[1], contains('1,GWEN-PUCK-1'));
      expect(lines[1], contains('72,95,valid,true'));
    });

    test('formatMotionCsv generates valid CSV string', () {
      final readings = [
        MotionReading(
          id: 2,
          deviceId: 'GWEN-PUCK-1',
          tsDevice: now,
          tsReceived: now,
          ax: 120,
          ay: -980,
          az: 50,
          gx: 12,
          gy: -5,
          gz: 1,
          intensity: 15,
          valid: true,
        ),
      ];

      final csv = ExportService.formatMotionCsv(readings);
      final lines = csv.trim().split('\n');
      expect(lines.length, 2);
      expect(lines[0], 'id,deviceId,tsDevice,tsReceived,ax,ay,az,gx,gy,gz,intensity,valid');
      expect(lines[1], contains('2,GWEN-PUCK-1'));
      expect(lines[1], contains('120,-980,50,12,-5,1,15,true'));
    });

    test('formatGpsCsv generates valid CSV string', () {
      final readings = [
        GpsReading(
          id: 3,
          deviceId: 'GWEN-PUCK-1',
          tsDevice: now,
          tsReceived: now,
          fixState: GpsFixState.fix,
          lat: 37.7749,
          lon: -122.4194,
          satellites: 8,
          hdop: 1.0,
          valid: true,
          stale: false,
        ),
      ];

      final csv = ExportService.formatGpsCsv(readings);
      final lines = csv.trim().split('\n');
      expect(lines.length, 2);
      expect(
        lines[0],
        'id,deviceId,tsDevice,tsReceived,fixState,lat,lon,satellites,hdop,valid,stale',
      );
      expect(lines[1], contains('3,GWEN-PUCK-1'));
      expect(lines[1], contains('fix,37.7749,-122.4194,8,1.0,true,false'));
    });

    test('formatJsonExport creates complete JSON payload with summary and arrays', () {
      final pulse = [
        PulseReading(
          id: 1,
          deviceId: 'GWEN-PUCK',
          tsDevice: now,
          tsReceived: now,
          bpm: 68,
          quality: 90,
          state: PulseState.valid,
          valid: true,
        ),
      ];
      final motion = [
        MotionReading(
          id: 1,
          deviceId: 'GWEN-PUCK',
          tsDevice: now,
          tsReceived: now,
          ax: 0,
          ay: 1000,
          az: 0,
          gx: 0,
          gy: 0,
          gz: 0,
          intensity: 10,
          valid: true,
        ),
      ];
      final gps = [
        GpsReading(
          id: 1,
          deviceId: 'GWEN-PUCK',
          tsDevice: now,
          tsReceived: now,
          fixState: GpsFixState.fix,
          lat: 12.34,
          lon: 56.78,
          satellites: 9,
          hdop: 0.9,
          valid: true,
          stale: false,
        ),
      ];
      final ai = [
        AiResult(
          id: 1,
          deviceId: 'GWEN-PUCK',
          tsDevice: now,
          tsReceived: now,
          label: AiLabel.stationary,
          score: 98,
          modelVersion: 1,
          source: AiSource.ruleBased,
          valid: true,
        ),
      ];

      final jsonStr = ExportService.formatJsonExport(
        pulse: pulse,
        motion: motion,
        gps: gps,
        ai: ai,
        appVersion: '0.5.0',
        exportTime: now,
      );

      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      expect(decoded['gwen_export_version'], '0.5.0');
      expect(decoded['summary']['total_pulse_records'], 1);
      expect(decoded['summary']['total_motion_records'], 1);
      expect(decoded['summary']['total_gps_records'], 1);
      expect(decoded['summary']['total_ai_records'], 1);
      expect((decoded['pulse_readings'] as List).length, 1);
      expect((decoded['motion_readings'] as List).length, 1);
      expect((decoded['gps_readings'] as List).length, 1);
      expect((decoded['ai_results'] as List).length, 1);
    });
  });

  group('ExportService File Creation and Sharing Tests', () {
    late Directory tempDir;
    late FakePulseRepository fakePulse;
    late FakeMotionRepository fakeMotion;
    late FakeGpsRepository fakeGps;
    late FakeAiRepository fakeAi;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('gwen_export_test_');
      fakePulse = FakePulseRepository();
      fakeMotion = FakeMotionRepository();
      fakeGps = FakeGpsRepository();
      fakeAi = FakeAiRepository();
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('exportCsvAndShare writes 3 CSV files and triggers shareHandler', () async {
      List<String>? sharedPaths;
      String? shareSubject;

      final service = ExportService(
        pulseRepository: fakePulse,
        motionRepository: fakeMotion,
        gpsRepository: fakeGps,
        aiRepository: fakeAi,
        shareHandler: (paths, {subject}) async {
          sharedPaths = paths;
          shareSubject = subject;
        },
      );

      final files = await service.exportCsvAndShare(targetDirectory: tempDir);
      expect(files.length, 3);
      expect(sharedPaths, equals(files));
      expect(shareSubject, contains('CSV'));

      for (final path in files) {
        expect(File(path).existsSync(), isTrue);
      }
    });

    test('exportJsonAndShare writes single JSON file and triggers shareHandler', () async {
      List<String>? sharedPaths;
      String? shareSubject;

      final service = ExportService(
        pulseRepository: fakePulse,
        motionRepository: fakeMotion,
        gpsRepository: fakeGps,
        aiRepository: fakeAi,
        shareHandler: (paths, {subject}) async {
          sharedPaths = paths;
          shareSubject = subject;
        },
      );

      final jsonPath = await service.exportJsonAndShare(targetDirectory: tempDir);
      expect(File(jsonPath).existsSync(), isTrue);
      expect(sharedPaths, contains(jsonPath));
      expect(shareSubject, contains('JSON'));
    });
  });

  group('PhoneGpsBridge Tests', () {
    test('PhoneGpsBridge generates valid fix coordinates and updates location', () async {
      final fakeGps = FakeGpsRepository();
      final bridge = PhoneGpsBridge(
        gpsRepository: fakeGps,
        currentLat: 40.7128,
        currentLon: -74.0060,
      );

      expect(bridge.isActive, isFalse);

      bridge.start(interval: const Duration(milliseconds: 50));
      expect(bridge.isActive, isTrue);

      // Verify initial reading was emitted and stored
      expect(fakeGps.gpsList.isNotEmpty, isTrue);
      final initial = fakeGps.gpsList.first;
      expect(initial.lat, 40.7128);
      expect(initial.lon, -74.0060);
      expect(initial.fixState, GpsFixState.fix);
      expect(initial.satellites, 8);
      expect(initial.hdop, 1.0);

      // Update coordinates dynamically
      final updated = bridge.updateCoordinates(lat: 34.0522, lon: -118.2437);
      expect(updated.lat, 34.0522);
      expect(updated.lon, -118.2437);

      bridge.stop();
      expect(bridge.isActive, isFalse);
      bridge.dispose();
    });
  });
}
