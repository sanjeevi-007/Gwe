import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gwen_app/ble/ble.dart';
import 'package:gwen_app/models/models.dart';
import 'package:gwen_app/state/state.dart';

void main() {
  group('MockBleService and State Providers Tests', () {
    test('MockBleService connection lifecycle and packet stream', () async {
      final mockPuck = MockPuck();
      final service = MockBleService(mockPuck: mockPuck, autoStart: false);

      expect(service.currentConnectionState, BleConnectionState.disconnected);

      // Connect
      await service.connect('TEST-DEVICE');
      expect(service.currentConnectionState, BleConnectionState.connected);

      // Write time sync and config
      await service.writeTimeSync(1710000000);
      expect(service.lastSyncedEpoch, 1710000000);

      await service.writeConfig(2000, true);
      expect(service.lastNotifyIntervalMs, 2000);
      expect(service.lastLocationLogging, true);

      // Listen for a parsed packet
      final firstPacket = await service.parsedPackets.first;
      expect(firstPacket.isSuccess, isTrue);

      // Disconnect via scenario
      service.setScenario(MockScenario.disconnected);
      expect(service.currentConnectionState, BleConnectionState.disconnected);

      // Manual disconnect
      await service.disconnect();
      expect(service.currentConnectionState, BleConnectionState.disconnected);

      service.dispose();
    });

    test('RealBleServiceStub returns disconnected', () async {
      final stub = RealBleServiceStub();
      expect(stub.currentConnectionState, BleConnectionState.disconnected);
      expect(
        () => stub.connect('REAL-ID'),
        throwsA(isA<UnimplementedError>()),
      );
      stub.dispose();
    });

    test('Riverpod readings providers extract typed domain models', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Check default mock mode
      expect(container.read(isMockModeProvider), isTrue);

      final service = container.read(bleServiceProvider) as MockBleService;
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(service.currentConnectionState, BleConnectionState.connected);

      // Read providers and verify typed models arrive
      final pulse = await container.read(latestPulseProvider.future);
      expect(pulse, isNotNull);
      expect(pulse!.bpm, 72);
      expect(pulse.valid, isTrue);

      final motion = await container.read(latestMotionProvider.future);
      expect(motion, isNotNull);
      expect(motion!.intensity, 35);

      final gps = await container.read(latestGpsProvider.future);
      expect(gps, isNotNull);
      expect(gps!.fixState, GpsFixState.fix);

      final ai = await container.read(latestAiResultProvider.future);
      expect(ai, isNotNull);
      expect(ai!.label, AiLabel.walkingLike);

      final status = await container.read(latestStatusProvider.future);
      expect(status, isNotNull);
      expect(status!.battery, 88);
    });
  });
}
