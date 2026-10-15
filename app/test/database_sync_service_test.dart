import 'dart:ffi';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:sqlite3/open.dart';

import 'package:gwen_app/ble/ble.dart';
import 'package:gwen_app/data/database.dart';
import 'package:gwen_app/data/database_sync_service.dart';
import 'package:gwen_app/data/repositories/repositories.dart';
import 'package:gwen_app/state/state.dart';

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

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    pulseRepo = PulseRepository(db);
    motionRepo = MotionRepository(db);
    gpsRepo = GpsRepository(db);
    aiRepo = AiRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('DatabaseSyncService Tests', () {
    test('auto-persists packets from MockBleService into Drift database', () async {
      final mockPuck = MockPuck();
      final mockBleService = MockBleService(mockPuck: mockPuck, autoStart: false);

      final syncService = DatabaseSyncService(
        db: db,
        pulseRepository: pulseRepo,
        motionRepository: motionRepo,
        gpsRepository: gpsRepo,
        aiRepository: aiRepo,
        packetStream: mockBleService.parsedPackets,
      );

      expect(syncService.isSubscribed, isTrue);

      // Connect to start packet flow
      await mockBleService.connect('TEST_DEVICE');

      // Wait for burst packets to be parsed and written to DB
      await Future<void>.delayed(const Duration(milliseconds: 150));

      final latestPulse = await pulseRepo.getLatestPulse();
      expect(latestPulse, isNotNull);
      expect(latestPulse!.bpm, 72);

      final latestMotion = await motionRepo.getLatestMotion();
      expect(latestMotion, isNotNull);
      expect(latestMotion!.intensity, 35);

      final latestGps = await gpsRepo.getLatestGps();
      expect(latestGps, isNotNull);
      expect(latestGps!.satellites, 8);

      final latestAi = await aiRepo.getLatestAiResult();
      expect(latestAi, isNotNull);

      final devices = await db.select(db.devices).get();
      expect(devices, isNotEmpty);
      expect(devices.first.id, 'TEST_DEVICE');
      expect(devices.first.firmwareVersion, '1.0.0');

      syncService.dispose();
      expect(syncService.isSubscribed, isFalse);
      mockBleService.dispose();
    });

    test('Riverpod sync_providers wiring works with container', () async {
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
      );
      addTearDown(container.dispose);

      // Read sync service provider
      final sync = container.read(databaseSyncServiceProvider);
      expect(sync.isSubscribed, isTrue);

      // Wait for mock packets to arrive and persist
      await Future<void>.delayed(const Duration(milliseconds: 150));

      final pulse = await container.read(pulseRepositoryProvider).getLatestPulse();
      expect(pulse, isNotNull);
    });
  });
}
