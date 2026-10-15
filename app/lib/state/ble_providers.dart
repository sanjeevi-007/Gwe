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
