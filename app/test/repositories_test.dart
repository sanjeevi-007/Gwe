import 'dart:ffi';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:sqlite3/open.dart';

import 'package:gwen_app/data/database.dart';
import 'package:gwen_app/data/repositories/repositories.dart';
import 'package:gwen_app/models/models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows) {
    open.overrideFor(OperatingSystem.windows, () {
      final possiblePaths = [
        'sqlite3.dll',
        'app/sqlite3.dll',
        r'C:\Users\rkrsa\AppData\Local\Programs\Python\Python311\DLLs\sqlite3.dll',
      ];
      for (final path in possiblePaths) {
        if (File(path).existsSync()) {
          return DynamicLibrary.open(path);
        }
      }
      return DynamicLibrary.open('sqlite3.dll');
    });
  }

  late AppDatabase db;
  late PulseRepository pulseRepo;
  late MotionRepository motionRepo;
  late GpsRepository gpsRepo;
  late AiRepository aiRepo;
  late SettingsRepository settingsRepo;

  setUpAll(() {
    db = AppDatabase(NativeDatabase.memory());
    pulseRepo = PulseRepository(db);
    motionRepo = MotionRepository(db);
    gpsRepo = GpsRepository(db);
    aiRepo = AiRepository(db);
    settingsRepo = SettingsRepository(db);
  });

  setUp(() async {
    await pulseRepo.deleteAllPulse();
    await motionRepo.deleteAllMotion();
    await gpsRepo.deleteAllGps();
    await aiRepo.deleteAllAi();
    await settingsRepo.deleteAllSettings();
  });

  tearDownAll(() async {
    await db.close();
  });

  group('PulseRepository Tests', () {
    test('insert valid pulse reading and query latest', () async {
      final now = DateTime.now();
      final reading = PulseReading(
        deviceId: 'PUCK_01',
        tsDevice: now.subtract(const Duration(milliseconds: 100)),
        tsReceived: now,
        bpm: 72,
        quality: 95,
        state: PulseState.valid,
        valid: true,
      );

      final id = await pulseRepo.insertPulse(reading);
      expect(id, isPositive);

      final latest = await pulseRepo.getLatestPulse();
      expect(latest, isNotNull);
      expect(latest!.deviceId, 'PUCK_01');
      expect(latest.bpm, 72);
      expect(latest.quality, 95);
      expect(latest.state, PulseState.valid);
      expect(latest.valid, isTrue);
    });

    test('insert pulse reading with NULL bpm (0xFFFF case)', () async {
      final now = DateTime.now();
      final reading = PulseReading(
        deviceId: 'PUCK_01',
        tsDevice: now,
        tsReceived: now,
        bpm: null, // 0xFFFF missing/invalid
        quality: 10,
        state: PulseState.poorSignal,
        valid: false,
      );

      await pulseRepo.insertPulse(reading);

      final latest = await pulseRepo.getLatestPulse();
      expect(latest, isNotNull);
      expect(latest!.bpm, isNull);
      expect(latest.state, PulseState.poorSignal);
      expect(latest.valid, isFalse);
    });

    test('getPulseHistory returns readings within specified window', () async {
      final base = DateTime(2026, 1, 1, 12, 0, 0);

      for (int i = 0; i < 5; i++) {
        await pulseRepo.insertPulse(
          PulseReading(
            deviceId: 'PUCK_01',
            tsDevice: base.add(Duration(minutes: i)),
            tsReceived: base.add(Duration(minutes: i)),
            bpm: 60 + i,
            quality: 80,
            state: PulseState.valid,
            valid: true,
          ),
        );
      }

      final start = base.add(const Duration(minutes: 1));
      final end = base.add(const Duration(minutes: 3));

      final history = await pulseRepo.getPulseHistory(start, end);
      expect(history.length, 3);
      expect(history[0].bpm, 61);
      expect(history[1].bpm, 62);
      expect(history[2].bpm, 63);
    });

    test('deleteAllPulse clears table', () async {
      final now = DateTime.now();
      await pulseRepo.insertPulse(
        PulseReading(
          tsDevice: now,
          tsReceived: now,
          bpm: 70,
          quality: 90,
          state: PulseState.valid,
          valid: true,
        ),
      );

      final deletedCount = await pulseRepo.deleteAllPulse();
      expect(deletedCount, 1);

      final latest = await pulseRepo.getLatestPulse();
      expect(latest, isNull);
    });
  });

  group('MotionRepository Tests', () {
    test('insert valid motion reading and query latest', () async {
      final now = DateTime.now();
      final reading = MotionReading(
        deviceId: 'PUCK_01',
        tsDevice: now,
        tsReceived: now,
        ax: 100,
        ay: -250,
        az: 980,
        gx: 12,
        gy: -5,
        gz: 2,
        intensity: 45,
        valid: true,
      );

      final id = await motionRepo.insertMotion(reading);
      expect(id, isPositive);

      final latest = await motionRepo.getLatestMotion();
      expect(latest, isNotNull);
      expect(latest!.ax, 100);
      expect(latest.ay, -250);
      expect(latest.az, 980);
      expect(latest.gx, 12);
      expect(latest.gy, -5);
      expect(latest.gz, 2);
      expect(latest.intensity, 45);
      expect(latest.valid, isTrue);
    });

    test('deleteAllMotion clears table', () async {
      final now = DateTime.now();
      await motionRepo.insertMotion(
        MotionReading(
          tsDevice: now,
          tsReceived: now,
          ax: 0,
          ay: 0,
          az: 1000,
          gx: 0,
          gy: 0,
          gz: 0,
          intensity: 0,
          valid: true,
        ),
      );

      final count = await motionRepo.deleteAllMotion();
      expect(count, 1);

      final latest = await motionRepo.getLatestMotion();
      expect(latest, isNull);
    });
  });

  group('GpsRepository Tests', () {
    test('insert valid GPS reading with lat/lon and verify querying latest returns exact doubles', () async {
      final now = DateTime.now();
      const double testLat = 13.0826802;
      const double testLon = 80.2707184;

      final reading = GpsReading(
        deviceId: 'PUCK_01',
        tsDevice: now,
        tsReceived: now,
        fixState: GpsFixState.fix,
        lat: testLat,
        lon: testLon,
        satellites: 9,
        hdop: 1.2,
        valid: true,
        stale: false,
      );

      final id = await gpsRepo.insertGps(reading);
      expect(id, isPositive);

      final latest = await gpsRepo.getLatestGps();
      expect(latest, isNotNull);
      expect(latest!.fixState, GpsFixState.fix);
      expect(latest.lat, closeTo(testLat, 0.000001));
      expect(latest.lon, closeTo(testLon, 0.000001));
      expect(latest.satellites, 9);
      expect(latest.hdop, closeTo(1.2, 0.01));
      expect(latest.valid, isTrue);
      expect(latest.stale, isFalse);
    });

    test('insert GPS reading with searching fix and NULL coordinates', () async {
      final now = DateTime.now();
      final reading = GpsReading(
        deviceId: 'PUCK_01',
        tsDevice: now,
        tsReceived: now,
        fixState: GpsFixState.searching,
        lat: null, // Must never be 0 when unavailable
        lon: null,
        satellites: 2,
        hdop: null,
        valid: false,
        stale: false,
      );

      await gpsRepo.insertGps(reading);

      final latest = await gpsRepo.getLatestGps();
      expect(latest, isNotNull);
      expect(latest!.fixState, GpsFixState.searching);
      expect(latest.lat, isNull);
      expect(latest.lon, isNull);
      expect(latest.hdop, isNull);
      expect(latest.valid, isFalse);
    });

    test('deleteAllGps clears table', () async {
      final now = DateTime.now();
      await gpsRepo.insertGps(
        GpsReading(
          tsDevice: now,
          tsReceived: now,
          fixState: GpsFixState.noFix,
          satellites: 0,
          valid: false,
          stale: true,
        ),
      );

      final count = await gpsRepo.deleteAllGps();
      expect(count, 1);

      final latest = await gpsRepo.getLatestGps();
      expect(latest, isNull);
    });
  });

  group('AiRepository Tests', () {
    test('insert AI result with ruleBased source and verify honest labeling', () async {
      final now = DateTime.now();
      final result = AiResult(
        deviceId: 'PUCK_01',
        tsDevice: now,
        tsReceived: now,
        label: AiLabel.walkingLike,
        score: 85,
        modelVersion: 1,
        source: AiSource.ruleBased,
        valid: true,
      );

      final id = await aiRepo.insertAiResult(result);
      expect(id, isPositive);

      final latest = await aiRepo.getLatestAiResult();
      expect(latest, isNotNull);
      expect(latest!.isRuleBased, isTrue);
      expect(latest.isTrained, isFalse);
      expect(latest.displayLabelString, 'Motion estimate (rule-based)');
    });

    test('insert AI result with invalid/null score', () async {
      final now = DateTime.now();
      final result = AiResult(
        deviceId: 'PUCK_01',
        tsDevice: now,
        tsReceived: now,
        label: AiLabel.uncertain,
        score: null, // 255/invalid
        modelVersion: 1,
        source: AiSource.none,
        valid: false,
      );

      await aiRepo.insertAiResult(result);

      final latest = await aiRepo.getLatestAiResult();
      expect(latest, isNotNull);
      expect(latest!.score, isNull);
      expect(latest.label, AiLabel.uncertain);
      expect(latest.valid, isFalse);
    });
  });

  group('SettingsRepository Tests', () {
    test('set and get key-value pair', () async {
      await settingsRepo.setSetting('notify_interval_ms', '500');
      final val = await settingsRepo.getSetting('notify_interval_ms');
      expect(val, '500');
    });

    test('update existing key with new value', () async {
      await settingsRepo.setSetting('mode', 'mock');
      var val = await settingsRepo.getSetting('mode');
      expect(val, 'mock');

      await settingsRepo.setSetting('mode', 'real');
      val = await settingsRepo.getSetting('mode');
      expect(val, 'real');
    });

    test('deleteAllSettings clears settings', () async {
      await settingsRepo.setSetting('k1', 'v1');
      await settingsRepo.setSetting('k2', 'v2');

      final count = await settingsRepo.deleteAllSettings();
      expect(count, 2);

      final val = await settingsRepo.getSetting('k1');
      expect(val, isNull);
    });
  });
}
