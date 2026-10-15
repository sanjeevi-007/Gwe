/// Model representing a discovered Bluetooth LE device.
class DiscoveredBleDevice {
  /// Unique identifier or MAC address of the device.
  final String id;

  /// Advertised name of the device.
  final String name;

  /// Received Signal Strength Indicator in dBm (e.g. -60 dBm).
  final int rssi;

  /// Whether this device is simulated by MockPuck.
  final bool isMock;

  const DiscoveredBleDevice({
    required this.id,
    required this.name,
    required this.rssi,
    this.isMock = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiscoveredBleDevice &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'DiscoveredBleDevice(id: $id, name: $name, rssi: $rssi, isMock: $isMock)';
}
