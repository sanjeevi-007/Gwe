import 'dart:async';
import 'dart:typed_data';

import 'ble_service.dart';
import 'mock_puck.dart';
import 'packet_parser.dart';

/// Mock implementation of [BleService] wrapping [MockPuck].
/// Emits parsed domain model results and simulates connection states.
class MockBleService implements BleService {
  final MockPuck _mockPuck;
  String? _connectedDeviceId;
  BleConnectionState _connectionState = BleConnectionState.disconnected;
  StreamSubscription<Uint8List>? _puckSubscription;

  final StreamController<BleConnectionState> _connectionStateController =
      StreamController<BleConnectionState>.broadcast();
  final StreamController<ParsedPacketResult> _parsedPacketsController =
      StreamController<ParsedPacketResult>.broadcast();

  int? lastSyncedEpoch;
  int? lastNotifyIntervalMs;
  bool? lastLocationLogging;

  MockBleService({
    MockPuck? mockPuck,
    bool autoStart = true,
    String defaultDeviceId = 'GWEN-PUCK-MOCK',
  }) : _mockPuck = mockPuck ?? MockPuck() {
    _puckSubscription = _mockPuck.packetStream.listen(_onRawPacket);

    if (autoStart) {
      connect(defaultDeviceId);
    }
  }

  /// Underlying [MockPuck] device simulator.
  MockPuck get mockPuck => _mockPuck;

  @override
  BleConnectionState get currentConnectionState => _connectionState;

  @override
  Stream<BleConnectionState> get connectionState async* {
    yield _connectionState;
    yield* _connectionStateController.stream;
  }

  @override
  Stream<ParsedPacketResult> get parsedPackets => _parsedPacketsController.stream;

  /// Forces a simulation scenario on the underlying [MockPuck].
  /// Updates [connectionState] if scenario is [MockScenario.disconnected].
  void setScenario(MockScenario scenario) {
    _mockPuck.setScenario(scenario);
    if (scenario == MockScenario.disconnected) {
      _setConnectionState(BleConnectionState.disconnected);
    } else if (_connectedDeviceId != null &&
        _connectionState == BleConnectionState.disconnected) {
      _setConnectionState(BleConnectionState.connected);
      _mockPuck.start();
    }
  }

  @override
  Future<void> connect(String deviceId) async {
    _connectedDeviceId = deviceId;

    if (_mockPuck.scenario != MockScenario.disconnected) {
      _setConnectionState(BleConnectionState.connected);
      _mockPuck.start();
    } else {
      _setConnectionState(BleConnectionState.disconnected);
    }
  }

  @override
  Future<void> disconnect() async {
    _mockPuck.stop();
    _connectedDeviceId = null;
    _setConnectionState(BleConnectionState.disconnected);
  }

  @override
  Future<void> writeTimeSync(int epochSeconds) async {
    lastSyncedEpoch = epochSeconds;
  }

  @override
  Future<void> writeConfig(int notifyIntervalMs, bool locationLogging) async {
    lastNotifyIntervalMs = notifyIntervalMs;
    lastLocationLogging = locationLogging;
  }

  @override
  void dispose() {
    _mockPuck.stop();
    _puckSubscription?.cancel();
    _mockPuck.dispose();
    _connectionStateController.close();
    _parsedPacketsController.close();
  }

  void _onRawPacket(Uint8List bytes) {
    final parsed = PacketParser.parsePacket(
      bytes,
      deviceId: _connectedDeviceId ?? 'GWEN-PUCK-MOCK',
    );
    if (!_parsedPacketsController.isClosed) {
      _parsedPacketsController.add(parsed);
    }
  }

  void _setConnectionState(BleConnectionState state) {
    _connectionState = state;
    if (!_connectionStateController.isClosed) {
      _connectionStateController.add(state);
    }
  }
}
