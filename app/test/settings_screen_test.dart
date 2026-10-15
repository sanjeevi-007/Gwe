import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gwen_app/ble/ble.dart';
import 'package:gwen_app/core/permission_helper.dart';
import 'package:gwen_app/data/export_service.dart';
import 'package:gwen_app/data/repositories/repositories.dart';
import 'package:gwen_app/features/onboarding/onboarding_screen.dart';
import 'package:gwen_app/features/settings/device_picker_screen.dart';
import 'package:gwen_app/features/settings/settings_screen.dart';
import 'package:gwen_app/models/models.dart';
import 'package:gwen_app/state/ble_providers.dart';
import 'package:gwen_app/state/readings_providers.dart';
import 'package:gwen_app/state/sync_providers.dart';
import 'package:permission_handler/permission_handler.dart';

class FakeSettingsRepo implements SettingsRepository {
  final Map<String, String> _storage = {};

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<void> setSetting(String key, String value) async {
    _storage[key] = value;
  }

  @override
  Future<String?> getSetting(String key) async {
    return _storage[key];
  }

  @override
  Future<int> deleteAllSettings() async {
    final count = _storage.length;
    _storage.clear();
    return count;
  }
}

class FakePulseRepo implements PulseRepository {
  bool deleted = false;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<int> deleteAllPulse() async {
    deleted = true;
    return 1;
  }
}

class FakeMotionRepo implements MotionRepository {
  bool deleted = false;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<int> deleteAllMotion() async {
    deleted = true;
    return 1;
  }
}

class FakeGpsRepo implements GpsRepository {
  bool deleted = false;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<int> deleteAllGps() async {
    deleted = true;
    return 1;
  }

  @override
  Future<int> insertGps(GpsReading reading) async => 1;
}

class FakeAiRepo implements AiRepository {
  bool deleted = false;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<int> deleteAllAi() async {
    deleted = true;
    return 1;
  }
}

class FakeExportService extends ExportService {
  bool csvExported = false;
  bool jsonExported = false;

  FakeExportService({
    required super.pulseRepository,
    required super.motionRepository,
    required super.gpsRepository,
    required super.aiRepository,
  });

  @override
  Future<List<String>> exportCsvAndShare({dynamic targetDirectory}) async {
    csvExported = true;
    return ['dummy_pulse.csv', 'dummy_motion.csv', 'dummy_gps.csv'];
  }

  @override
  Future<String> exportJsonAndShare({dynamic targetDirectory}) async {
    jsonExported = true;
    return 'dummy_export.json';
  }
}

class FakeScannerService implements BleScannerService {
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
  Future<void> requestEnableBluetooth() async {}

  @override
  void dispose() {}
}

void main() {
  group('SettingsScreen Widget Tests', () {
    late FakeSettingsRepo fakeSettingsRepo;
    late FakePulseRepo fakePulseRepo;
    late FakeMotionRepo fakeMotionRepo;
    late FakeGpsRepo fakeGpsRepo;
    late FakeAiRepo fakeAiRepo;
    late FakeExportService fakeExportService;

    setUp(() {
      fakeSettingsRepo = FakeSettingsRepo();
      fakePulseRepo = FakePulseRepo();
      fakeMotionRepo = FakeMotionRepo();
      fakeGpsRepo = FakeGpsRepo();
      fakeAiRepo = FakeAiRepo();
      fakeExportService = FakeExportService(
        pulseRepository: fakePulseRepo,
        motionRepository: fakeMotionRepo,
        gpsRepository: fakeGpsRepo,
        aiRepository: fakeAiRepo,
      );
    });

    Widget createTestApp({Key? scopeKey}) {
      return ProviderScope(
        key: scopeKey ?? UniqueKey(),
        overrides: [
          settingsRepositoryProvider.overrideWithValue(fakeSettingsRepo),
          pulseRepositoryProvider.overrideWithValue(fakePulseRepo),
          motionRepositoryProvider.overrideWithValue(fakeMotionRepo),
          gpsRepositoryProvider.overrideWithValue(fakeGpsRepo),
          aiRepositoryProvider.overrideWithValue(fakeAiRepo),
          exportServiceProvider.overrideWithValue(fakeExportService),
          bleScannerServiceProvider.overrideWithValue(FakeScannerService()),
          permissionHelperProvider.overrideWithValue(
            PermissionHelper(
              explicitAndroidSdkVersion: 33,
              permissionStatusChecker: (_) async => PermissionStatus.granted,
            ),
          ),
          latestStatusProvider.overrideWith((ref) => Stream.value(
                DeviceStatus(
                  id: 1,
                  deviceId: 'GWEN-PUCK-MOCK',
                  tsDevice: DateTime.now(),
                  tsReceived: DateTime.now(),
                  fwMajor: 1,
                  fwMinor: 0,
                  fwPatch: 0,
                  sensorsBitmask: 0x1F,
                  uptimeSeconds: 1530,
                  battery: 92,
                  valid: true,
                ),
              )),
        ],
        child: const MaterialApp(
          home: SettingsScreen(),
        ),
      );
    }

    testWidgets('renders all major settings sections and hardware info', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestApp(scopeKey: const Key('settings_all_sections')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('CONNECTED PUCK HARDWARE'), findsOneWidget);
      expect(find.text('SIMULATION & MOCK HARDWARE'), findsOneWidget);
      expect(find.text('DATA EXPORT & PRIVACY'), findsOneWidget);
      expect(find.text('RETENTION & STORAGE PURGE'), findsOneWidget);
      expect(find.text('ABOUT & APP NOTICE'), findsOneWidget);

      // Verify Hardware details
      expect(find.text('GWEN Puck (Simulated)'), findsOneWidget);
      expect(find.text('GWEN-PUCK-MOCK'), findsOneWidget);
      expect(find.text('v1.0.0'), findsWidgets);
      expect(find.text('92%'), findsOneWidget);

      // Verify Buttons presence
      expect(find.byKey(const Key('change_device_button')), findsOneWidget);
      expect(find.byKey(const Key('phone_gps_toggle')), findsOneWidget);
      expect(find.byKey(const Key('mock_mode_switch')), findsOneWidget);
      expect(find.byKey(const Key('export_csv_button')), findsOneWidget);
      expect(find.byKey(const Key('export_json_button')), findsOneWidget);
      expect(find.byKey(const Key('history_retention_dropdown')), findsOneWidget);
      expect(find.byKey(const Key('delete_all_history_button')), findsOneWidget);
      expect(find.byKey(const Key('health_disclaimer_button')), findsOneWidget);
      expect(find.byKey(const Key('revisit_onboarding_button')), findsOneWidget);
    });

    testWidgets('toggles phone GPS bridge switch', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      const key = Key('settings_phone_gps');
      await tester.pumpWidget(createTestApp(scopeKey: key));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final gpsSwitch = find.byKey(const Key('phone_gps_toggle'));
      expect(gpsSwitch, findsOneWidget);

      await tester.tap(gpsSwitch);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('triggers CSV and JSON exports when buttons are tapped', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      const key = Key('settings_exports');
      await tester.pumpWidget(createTestApp(scopeKey: key));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Tap CSV export
      await tester.tap(find.byKey(const Key('export_csv_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(fakeExportService.csvExported, isTrue);
      expect(find.text('CSV telemetry export ready for sharing.'), findsOneWidget);

      // Tap JSON export
      await tester.tap(find.byKey(const Key('export_json_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(fakeExportService.jsonExported, isTrue);
      expect(find.text('JSON telemetry export ready for sharing.'), findsOneWidget);
    });

    testWidgets('confirms and executes Delete All Local History purge', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      const key = Key('settings_purge');
      await tester.pumpWidget(createTestApp(scopeKey: key));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final deleteBtn = find.byKey(const Key('delete_all_history_button'));
      expect(deleteBtn, findsOneWidget);
      await tester.tap(deleteBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify confirmation dialog
      expect(find.text('Delete All Local History?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      // Tap confirm
      final confirmBtn = find.byKey(const Key('confirm_delete_history_button'));
      expect(confirmBtn, findsOneWidget);
      await tester.tap(confirmBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify repositories deleted
      expect(fakePulseRepo.deleted, isTrue);
      expect(fakeMotionRepo.deleted, isTrue);
      expect(fakeGpsRepo.deleted, isTrue);
      expect(fakeAiRepo.deleted, isTrue);

      expect(find.text('All local telemetry history erased.'), findsOneWidget);
    });

    testWidgets('shows health disclaimer notice dialog', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      const key = Key('settings_disclaimer');
      await tester.pumpWidget(createTestApp(scopeKey: key));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.byKey(const Key('health_disclaimer_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Health & Safety Notice'), findsOneWidget);
      expect(find.textContaining('GWEN is NOT a medical device'), findsOneWidget);

      await tester.tap(find.text('Understood'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Health & Safety Notice'), findsNothing);
    });

    testWidgets('navigates to DevicePickerScreen when Change Device is tapped',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      const key = Key('settings_nav_picker');
      await tester.pumpWidget(createTestApp(scopeKey: key));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.byKey(const Key('change_device_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(DevicePickerScreen), findsOneWidget);
    });

    testWidgets('navigates to OnboardingScreen when Revisit Onboarding is tapped',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      const key = Key('settings_nav_onboarding');
      await tester.pumpWidget(createTestApp(scopeKey: key));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.byKey(const Key('revisit_onboarding_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(OnboardingScreen), findsOneWidget);
    });
  });
}
