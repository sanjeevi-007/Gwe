import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gwen_app/ble/ble.dart';
import 'package:gwen_app/core/permission_helper.dart';
import 'package:gwen_app/features/settings/device_picker_screen.dart';
import 'package:gwen_app/features/settings/settings_screen.dart';
import 'package:gwen_app/state/ble_providers.dart';
import 'package:permission_handler/permission_handler.dart';

class FakeBleScannerService implements BleScannerService {
  final List<DiscoveredBleDevice> _devices;
  bool _isScanning = false;
  BleAdapterStatus _status;

  final StreamController<List<DiscoveredBleDevice>> _devicesCtrl =
      StreamController<List<DiscoveredBleDevice>>.broadcast();
  final StreamController<bool> _scanningCtrl =
      StreamController<bool>.broadcast();
  final StreamController<BleAdapterStatus> _statusCtrl =
      StreamController<BleAdapterStatus>.broadcast();

  FakeBleScannerService({
    List<DiscoveredBleDevice>? initialDevices,
    BleAdapterStatus initialStatus = BleAdapterStatus.on,
  })  : _devices = initialDevices ??
            [
              const DiscoveredBleDevice(
                id: 'GWEN-PUCK-MOCK',
                name: 'GWEN Puck (Mock)',
                rssi: -58,
                isMock: true,
              ),
            ],
        _status = initialStatus;

  @override
  Stream<List<DiscoveredBleDevice>> get discoveredDevices async* {
    yield _devices;
    yield* _devicesCtrl.stream;
  }

  @override
  List<DiscoveredBleDevice> get currentDiscoveredDevices => _devices;

  @override
  Stream<bool> get isScanning async* {
    yield _isScanning;
    yield* _scanningCtrl.stream;
  }

  @override
  bool get currentIsScanning => _isScanning;

  @override
  Stream<BleAdapterStatus> get adapterStatus async* {
    yield _status;
    yield* _statusCtrl.stream;
  }

  @override
  BleAdapterStatus get currentAdapterStatus => _status;

  @override
  Future<void> startScan({Duration duration = const Duration(seconds: 4)}) async {
    _isScanning = true;
    _scanningCtrl.add(true);
  }

  @override
  Future<void> stopScan() async {
    _isScanning = false;
    _scanningCtrl.add(false);
  }

  @override
  Future<void> requestEnableBluetooth() async {
    _status = BleAdapterStatus.on;
    _statusCtrl.add(BleAdapterStatus.on);
  }

  @override
  void dispose() {
    _devicesCtrl.close();
    _scanningCtrl.close();
    _statusCtrl.close();
  }
}

void main() {
  group('DevicePickerScreen Widget Tests', () {
    testWidgets('renders screen with discovered mock device and handles connect',
        (tester) async {
      final fakeScanner = FakeBleScannerService();
      final mockBleService = MockBleService(autoStart: false);
      final permissionHelper = PermissionHelper(
        explicitAndroidSdkVersion: 33,
        permissionStatusChecker: (_) async => PermissionStatus.granted,
      );

      await tester.pumpWidget(
        ProviderScope(
          key: const Key('device_picker_scope_1'),
          overrides: [
            bleScannerServiceProvider.overrideWithValue(fakeScanner),
            bleServiceProvider.overrideWithValue(mockBleService),
            permissionHelperProvider.overrideWithValue(permissionHelper),
          ],
          child: const MaterialApp(
            home: DevicePickerScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify app bar and mock mode badge
      expect(find.text('Connect GWEN Puck'), findsOneWidget);
      expect(find.text('Mock Mode'), findsOneWidget);

      // Verify discovered device info
      expect(find.text('GWEN Puck (Mock)'), findsOneWidget);
      expect(find.text('GWEN-PUCK-MOCK'), findsOneWidget);
      expect(find.text('-58 dBm'), findsOneWidget);

      // Tap Connect
      final connectButton = find.byKey(const Key('connect_button_GWEN-PUCK-MOCK'));
      expect(connectButton, findsOneWidget);
      await tester.tap(connectButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify connection state updated
      expect(find.text('Connected'), findsWidgets);
      expect(find.byKey(const Key('disconnect_button')), findsOneWidget);

      // Disconnect
      await tester.tap(find.byKey(const Key('disconnect_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(mockBleService.currentConnectionState, BleConnectionState.disconnected);
    });

    testWidgets('displays permission banner when permissions are missing',
        (tester) async {
      var requestInvoked = false;
      var hasGranted = false;

      final permissionHelper = PermissionHelper(
        explicitAndroidSdkVersion: 33,
        permissionStatusChecker: (_) async =>
            hasGranted ? PermissionStatus.granted : PermissionStatus.denied,
        permissionRequester: (_) async {
          requestInvoked = true;
          hasGranted = true;
          return {
            Permission.bluetoothScan: PermissionStatus.granted,
            Permission.bluetoothConnect: PermissionStatus.granted,
          };
        },
      );

      await tester.pumpWidget(
        ProviderScope(
          key: const Key('device_picker_scope_perm'),
          overrides: [
            permissionHelperProvider.overrideWithValue(permissionHelper),
            bleScannerServiceProvider.overrideWithValue(FakeBleScannerService()),
          ],
          child: const MaterialApp(
            home: DevicePickerScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify permission banner is displayed
      expect(find.byKey(const Key('permission_check_banner')), findsOneWidget);
      expect(find.text('Bluetooth Permissions Needed'), findsOneWidget);

      // Tap Grant Permission
      await tester.tap(find.byKey(const Key('grant_permission_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(requestInvoked, isTrue);
      // Banner disappears after grant
      expect(find.byKey(const Key('permission_check_banner')), findsNothing);
    });

    testWidgets('displays bluetooth off banner when adapter is disabled',
        (tester) async {
      final fakeScanner = FakeBleScannerService(initialStatus: BleAdapterStatus.off);
      final permissionHelper = PermissionHelper(
        explicitAndroidSdkVersion: 33,
        permissionStatusChecker: (_) async => PermissionStatus.granted,
      );

      await tester.pumpWidget(
        ProviderScope(
          key: const Key('device_picker_scope_bt_off'),
          overrides: [
            bleScannerServiceProvider.overrideWithValue(fakeScanner),
            permissionHelperProvider.overrideWithValue(permissionHelper),
          ],
          child: const MaterialApp(
            home: DevicePickerScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byKey(const Key('bluetooth_off_banner')), findsOneWidget);
      expect(find.text('Bluetooth is Turned Off'), findsOneWidget);

      // Tap Enable Bluetooth
      await tester.tap(find.byKey(const Key('enable_bluetooth_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(fakeScanner.currentAdapterStatus, BleAdapterStatus.on);
    });

    testWidgets('floating scan button toggles scan in fake scanner', (tester) async {
      final fakeScanner = FakeBleScannerService();
      final permissionHelper = PermissionHelper(
        explicitAndroidSdkVersion: 33,
        permissionStatusChecker: (_) async => PermissionStatus.granted,
      );

      await tester.pumpWidget(
        ProviderScope(
          key: const Key('device_picker_scope_scan'),
          overrides: [
            bleScannerServiceProvider.overrideWithValue(fakeScanner),
            permissionHelperProvider.overrideWithValue(permissionHelper),
          ],
          child: const MaterialApp(
            home: DevicePickerScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final fab = find.byKey(const Key('floating_scan_button'));
      expect(fab, findsOneWidget);
      await tester.tap(fab);
      await tester.pump();

      expect(fakeScanner.currentIsScanning, isTrue);
    });

    testWidgets('SettingsScreen navigates to DevicePickerScreen on tile tap',
        (tester) async {
      final fakeScanner = FakeBleScannerService();
      final permissionHelper = PermissionHelper(
        explicitAndroidSdkVersion: 33,
        permissionStatusChecker: (_) async => PermissionStatus.granted,
      );

      await tester.pumpWidget(
        ProviderScope(
          key: const Key('settings_nav_scope'),
          overrides: [
            bleScannerServiceProvider.overrideWithValue(fakeScanner),
            permissionHelperProvider.overrideWithValue(permissionHelper),
          ],
          child: const MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final tile = find.byKey(const Key('change_device_button'));
      expect(tile, findsOneWidget);
      await tester.tap(tile);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(DevicePickerScreen), findsOneWidget);
      expect(find.text('Connect GWEN Puck'), findsOneWidget);
    });
  });
}
