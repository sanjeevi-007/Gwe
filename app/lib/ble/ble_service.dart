import 'dart:async';

import 'packet_parser.dart';

/// BLE link connection state.
enum BleConnectionState {
  disconnected,
  scanning,
  connecting,
  connected,
}

/// Abstract contract for BLE communication services.
abstract class BleService {
  /// Stream of connection state transitions.
  Stream<BleConnectionState> get connectionState;

  /// Current synchronous connection state.
  BleConnectionState get currentConnectionState;

  /// Stream of parsed packets from incoming BLE notifications.
  Stream<ParsedPacketResult> get parsedPackets;

  /// Connects to a target BLE device by identifier or address.
  Future<void> connect(String deviceId);

  /// Disconnects from the current BLE device.
  Future<void> disconnect();

  /// Writes current Unix UTC epoch to Time Sync characteristic (0x0007).
  Future<void> writeTimeSync(int epochSeconds);

  /// Writes notification interval and location logging settings to Config characteristic (0x0008).
  Future<void> writeConfig(int notifyIntervalMs, bool locationLogging);

  /// Releases service and stream resources.
  void dispose();
}
