import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ble/ble.dart';

/// Provider toggling between MockBleService (true) and RealBleServiceStub (false).
final isMockModeProvider = StateProvider<bool>((ref) => true);

/// Provider controlling the active simulation scenario for MockBleService.
final mockScenarioProvider = StateProvider<MockScenario>((ref) => MockScenario.normal);

/// Core BleService provider managing lifecycle of mock or real BLE service.
final bleServiceProvider = Provider<BleService>((ref) {
  final isMock = ref.watch(isMockModeProvider);

  if (isMock) {
    final mockService = MockBleService();
    final initialScenario = ref.read(mockScenarioProvider);
    mockService.setScenario(initialScenario);

    ref.listen<MockScenario>(mockScenarioProvider, (previous, next) {
      mockService.setScenario(next);
    });

    ref.onDispose(() {
      mockService.dispose();
    });
    return mockService;
  } else {
    final stubService = RealBleServiceStub();
    ref.onDispose(() {
      stubService.dispose();
    });
    return stubService;
  }
});

/// Stream provider exposing active BLE connection state.
final bleConnectionStateProvider = StreamProvider<BleConnectionState>((ref) {
  final bleService = ref.watch(bleServiceProvider);
  return bleService.connectionState;
});

/// Stream provider exposing raw parsed BLE packet results.
final rawPacketsProvider = StreamProvider<ParsedPacketResult>((ref) {
  final bleService = ref.watch(bleServiceProvider);
  return bleService.parsedPackets;
});

/// Scanner service provider for discovering nearby BLE devices.
final bleScannerServiceProvider = Provider<BleScannerService>((ref) {
  final isMock = ref.watch(isMockModeProvider);
  if (isMock) {
    final service = MockBleScannerService();
    ref.onDispose(() {
      service.dispose();
    });
    return service;
  } else {
    final service = RealBleScannerService();
    ref.onDispose(() {
      service.dispose();
    });
    return service;
  }
});

/// Stream provider exposing the list of discovered BLE devices.
final discoveredDevicesProvider =
    StreamProvider<List<DiscoveredBleDevice>>((ref) {
  final scanner = ref.watch(bleScannerServiceProvider);
  return scanner.discoveredDevices;
});

/// Stream provider indicating whether BLE scanning is currently active.
final isScanningProvider = StreamProvider<bool>((ref) {
  final scanner = ref.watch(bleScannerServiceProvider);
  return scanner.isScanning;
});

/// Stream provider exposing the Bluetooth adapter power and authorization state.
final bleAdapterStatusProvider = StreamProvider<BleAdapterStatus>((ref) {
  final scanner = ref.watch(bleScannerServiceProvider);
  return scanner.adapterStatus;
});

/// Provider storing the ID of the currently target / connected BLE device.
final connectedDeviceIdProvider = StateProvider<String?>((ref) => 'GWEN-PUCK-MOCK');
