import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gwen_app/ble/ble.dart';
import 'package:gwen_app/core/permission_helper.dart';
import 'package:gwen_app/data/export_service.dart';
import 'package:gwen_app/data/repositories/repositories.dart';
import 'package:gwen_app/features/settings/settings_screen.dart';
import 'package:gwen_app/models/models.dart';
import 'package:gwen_app/state/ble_providers.dart';
import 'package:gwen_app/state/sync_providers.dart';
import 'package:permission_handler/permission_handler.dart';

class MockPulseRepo implements PulseRepository {
  bool deleted = false;
  List<PulseReading> readings = [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<List<PulseReading>> getPulseHistory(DateTime start, DateTime end) async =>
      readings;

  @override
  Future<int> deleteAllPulse() async {
    deleted = true;
    readings.clear();
    return 1;
  }
}

class MockMotionRepo implements MotionRepository {
  bool deleted = false;
  List<MotionReading> readings = [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<List<MotionReading>> getMotionHistory(DateTime start, DateTime end) async =>
      readings;

  @override
  Future<int> deleteAllMotion() async {
    deleted = true;
    readings.clear();
    return 1;
  }
}

class MockGpsRepo implements GpsRepository {
  bool deleted = false;
  List<GpsReading> readings = [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<List<GpsReading>> getGpsHistory(DateTime start, DateTime end) async =>
      readings;

  @override
  Future<int> deleteAllGps() async {
    deleted = true;
    readings.clear();
    return 1;
  }

  @override
  Future<int> insertGps(GpsReading reading) async {
    readings.add(reading);
    return readings.length;
  }
}

class MockAiRepo implements AiRepository {
  bool deleted = false;
  List<AiResult> readings = [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<List<AiResult>> getAiHistory(DateTime start, DateTime end) async => readings;

  @override
  Future<int> deleteAllAi() async {
    deleted = true;
    readings.clear();
    return 1;
  }
}

class MockSettingsRepo implements SettingsRepository {
  final Map<String, String> _settings = {};

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<void> setSetting(String key, String value) async {
    _settings[key] = value;
  }

  @override
  Future<String?> getSetting(String key) async => _settings[key];
}

class MockScannerService implements BleScannerService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Stream<List<DiscoveredBleDevice>> get discoveredDevices async* {
    yield [];
  }

  @override
  List<DiscoveredBleDevice> get currentDiscoveredDevices => [];

  @override
  Stream<bool> get isScanning async* {
    yield false;
  }

  @override
  bool get currentIsScanning => false;

  @override
  Stream<BleAdapterStatus> get adapterStatus async* {
    yield BleAdapterStatus.on;
  }

  @override
  BleAdapterStatus get currentAdapterStatus => BleAdapterStatus.on;

  @override
  Future<void> startScan({Duration duration = const Duration(seconds: 4)}) async {}

  @override
  Future<void> stopScan() async {}

  @override
  void dispose() {}
}

class MockExportService extends ExportService {
  bool csvExported = false;
  bool jsonExported = false;

  MockExportService({
    required super.pulseRepository,
    required super.motionRepository,
    required super.gpsRepository,
    required super.aiRepository,
  });

  @override
  Future<List<String>> exportCsvAndShare({dynamic targetDirectory}) async {
    csvExported = true;
    return ['pulse_readings.csv', 'motion_readings.csv', 'gps_readings.csv'];
  }

  @override
  Future<String> exportJsonAndShare({dynamic targetDirectory}) async {
    jsonExported = true;
    return 'gwen_export.json';
  }
}

void main() {
  group('Export Logic Unit Tests', () {
    final testDate = DateTime(2026, 10, 16, 12, 0, 0);

    test('CSV formatting outputs proper headers and rows for all readings', () {
      final pulse = [
        PulseReading(
          id: 1,
          deviceId: 'P1',
          tsDevice: testDate,
          tsReceived: testDate,
          bpm: 75,
          quality: 92,
          state: PulseState.valid,
          valid: true,
        ),
      ];
      final motion = [
        MotionReading(
          id: 1,
          deviceId: 'P1',
          tsDevice: testDate,
          tsReceived: testDate,
          ax: 10,
          ay: 20,
          az: 30,
          gx: 1,
          gy: 2,
          gz: 3,
          intensity: 12,
          valid: true,
        ),
      ];
      final gps = [
        GpsReading(
          id: 1,
          deviceId: 'P1',
          tsDevice: testDate,
          tsReceived: testDate,
          fixState: GpsFixState.fix,
          lat: 37.77,
          lon: -122.41,
          satellites: 8,
          hdop: 1.0,
          valid: true,
          stale: false,
        ),
      ];

      final pulseCsv = ExportService.formatPulseCsv(pulse);
      expect(pulseCsv.startsWith('id,deviceId,tsDevice,tsReceived,bpm,quality,state,valid'), isTrue);
      expect(pulseCsv.contains('1,P1,'), isTrue);

      final motionCsv = ExportService.formatMotionCsv(motion);
      expect(motionCsv.startsWith('id,deviceId,tsDevice,tsReceived,ax,ay,az,gx,gy,gz,intensity,valid'), isTrue);
      expect(motionCsv.contains('10,20,30,1,2,3,12,true'), isTrue);

      final gpsCsv = ExportService.formatGpsCsv(gps);
      expect(gpsCsv.startsWith('id,deviceId,tsDevice,tsReceived,fixState,lat,lon,satellites,hdop,valid,stale'), isTrue);
      expect(gpsCsv.contains('fix,37.77,-122.41,8,1.0,true,false'), isTrue);
    });

    test('JSON formatting outputs complete metadata, summary, and lists', () {
      final pulse = [
        PulseReading(
          id: 10,
          deviceId: 'P1',
          tsDevice: testDate,
          tsReceived: testDate,
          bpm: 80,
          quality: 99,
          state: PulseState.valid,
          valid: true,
        ),
      ];
      final ai = [
        AiResult(
          id: 5,
          deviceId: 'P1',
          tsDevice: testDate,
          tsReceived: testDate,
          label: AiLabel.walkingLike,
          score: 95,
          modelVersion: 1,
          source: AiSource.ruleBased,
          valid: true,
        ),
      ];

      final jsonStr = ExportService.formatJsonExport(
        pulse: pulse,
        motion: [],
        gps: [],
        ai: ai,
        appVersion: '0.5.0',
        exportTime: testDate,
      );

      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      expect(decoded['gwen_export_version'], '0.5.0');
      expect(decoded['summary']['total_pulse_records'], 1);
      expect(decoded['summary']['total_ai_records'], 1);
      expect(decoded['summary']['total_motion_records'], 0);
      expect(decoded['summary']['total_gps_records'], 0);
      expect((decoded['pulse_readings'] as List).first['bpm'], 80);
      expect((decoded['ai_results'] as List).first['label'], 'walkingLike');
    });

    test('exportCsvAndShare and exportJsonAndShare write files to directory', () async {
      final tempDir = await Directory.systemTemp.createTemp('gwen_export_test_');
      final pulseRepo = MockPulseRepo();
      final motionRepo = MockMotionRepo();
      final gpsRepo = MockGpsRepo();
      final aiRepo = MockAiRepo();

      List<String>? sharedPaths;
      final exporter = ExportService(
        pulseRepository: pulseRepo,
        motionRepository: motionRepo,
        gpsRepository: gpsRepo,
        aiRepository: aiRepo,
        shareHandler: (paths, {subject}) async {
          sharedPaths = paths;
        },
      );

      final csvPaths = await exporter.exportCsvAndShare(targetDirectory: tempDir);
      expect(csvPaths.length, 3);
      expect(sharedPaths, equals(csvPaths));
      expect(File(csvPaths[0]).existsSync(), isTrue);

      final jsonPath = await exporter.exportJsonAndShare(targetDirectory: tempDir);
      expect(File(jsonPath).existsSync(), isTrue);
      expect(sharedPaths, contains(jsonPath));

      await tempDir.delete(recursive: true);
    });
  });

  group('SettingsScreen Delete All History & Export Widget Tests', () {
    late MockPulseRepo pulseRepo;
    late MockMotionRepo motionRepo;
    late MockGpsRepo gpsRepo;
    late MockAiRepo aiRepo;
    late MockSettingsRepo settingsRepo;
    late MockExportService mockExportService;

    setUp(() {
      pulseRepo = MockPulseRepo();
      motionRepo = MockMotionRepo();
      gpsRepo = MockGpsRepo();
      aiRepo = MockAiRepo();
      settingsRepo = MockSettingsRepo();
      mockExportService = MockExportService(
        pulseRepository: pulseRepo,
        motionRepository: motionRepo,
        gpsRepository: gpsRepo,
        aiRepository: aiRepo,
      );
    });

    Widget createTestApp() {
      return ProviderScope(
        key: UniqueKey(),
        overrides: [
          pulseRepositoryProvider.overrideWithValue(pulseRepo),
          motionRepositoryProvider.overrideWithValue(motionRepo),
          gpsRepositoryProvider.overrideWithValue(gpsRepo),
          aiRepositoryProvider.overrideWithValue(aiRepo),
          settingsRepositoryProvider.overrideWithValue(settingsRepo),
          bleScannerServiceProvider.overrideWithValue(MockScannerService()),
          permissionHelperProvider.overrideWithValue(
            PermissionHelper(
              explicitAndroidSdkVersion: 33,
              permissionStatusChecker: (_) async => PermissionStatus.granted,
            ),
          ),
          exportServiceProvider.overrideWithValue(mockExportService),
        ],
        child: const MaterialApp(
          home: SettingsScreen(),
        ),
      );
    }

    testWidgets('prompts confirmation dialog and purges all database tables on confirm',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final deleteButton = find.byKey(const Key('delete_all_history_button'));
      expect(deleteButton, findsOneWidget);
      expect(find.text('Delete All History'), findsOneWidget);

      // Tap Delete All History
      await tester.tap(deleteButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify confirmation dialog appears
      expect(find.text('Delete All Local History?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete Everything'), findsOneWidget);

      // Test Cancel first
      await tester.tap(find.text('Cancel'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(pulseRepo.deleted, isFalse);
      expect(motionRepo.deleted, isFalse);
      expect(gpsRepo.deleted, isFalse);
      expect(aiRepo.deleted, isFalse);

      // Now tap Delete All History again and confirm
      await tester.tap(deleteButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.byKey(const Key('confirm_delete_history_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify purge executed on all repositories
      expect(pulseRepo.deleted, isTrue);
      expect(motionRepo.deleted, isTrue);
      expect(gpsRepo.deleted, isTrue);
      expect(aiRepo.deleted, isTrue);
      expect(find.text('All local telemetry history erased.'), findsOneWidget);
    });

    testWidgets('triggers CSV and JSON exports and displays feedback', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Export History (CSV)'), findsOneWidget);
      expect(find.text('Export History (JSON)'), findsOneWidget);
      expect(find.text('100% Offline & Private. Data stays on your device.'), findsOneWidget);

      await tester.tap(find.byKey(const Key('export_csv_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(mockExportService.csvExported, isTrue);
      expect(find.text('CSV telemetry export ready for sharing.'), findsOneWidget);

      await tester.tap(find.byKey(const Key('export_json_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(mockExportService.jsonExported, isTrue);
      expect(find.text('JSON telemetry export ready for sharing.'), findsOneWidget);
    });
  });
}
