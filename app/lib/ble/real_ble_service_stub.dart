import 'dart:async';

import 'ble_service.dart';
import 'packet_parser.dart';

/// Real BLE service stub for Milestone 8 hardware integration.
class RealBleServiceStub implements BleService {
  final StreamController<BleConnectionState> _stateController =
      StreamController<BleConnectionState>.broadcast();
  final StreamController<ParsedPacketResult> _packetsController =
      StreamController<ParsedPacketResult>.broadcast();

  @override
  BleConnectionState get currentConnectionState => BleConnectionState.disconnected;

  @override
  String? get connectedDeviceId => null;

  @override
  Stream<BleConnectionState> get connectionState async* {
    yield BleConnectionState.disconnected;
    yield* _stateController.stream;
  }

  @override
  Stream<ParsedPacketResult> get parsedPackets => _packetsController.stream;

  @override
  Future<void> connect(String deviceId) async {
    throw UnimplementedError('Real BLE hardware integration will be implemented in Milestone 8.');
  }

  @override
  Future<void> disconnect() async {
    // No-op stub
  }

  @override
  Future<void> writeTimeSync(int epochSeconds) async {
    // No-op stub
  }

  @override
  Future<void> writeConfig(int notifyIntervalMs, bool locationLogging) async {
    // No-op stub
  }

  @override
  void dispose() {
    _stateController.close();
    _packetsController.close();
  }
}
