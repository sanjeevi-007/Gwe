import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ble/ble.dart';
import '../../core/permission_helper.dart';
import '../../core/theme.dart';
import '../../state/ble_providers.dart';

/// Screen for scanning, discovering, and connecting to GWEN Puck BLE hardware.
class DevicePickerScreen extends ConsumerStatefulWidget {
  const DevicePickerScreen({super.key});

  @override
  ConsumerState<DevicePickerScreen> createState() => _DevicePickerScreenState();
}

class _DevicePickerScreenState extends ConsumerState<DevicePickerScreen> {
  bool _isCheckingPermissions = true;
  bool _hasPermissions = true;
  String? _connectingDeviceId;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final helper = ref.read(permissionHelperProvider);
    final granted = await helper.checkBlePermissions();
    if (mounted) {
      setState(() {
        _hasPermissions = granted;
        _isCheckingPermissions = false;
      });

      // Auto start scan if permissions are granted
      if (granted) {
        _startScan();
      }
    }
  }

  Future<void> _requestPermissions() async {
    final helper = ref.read(permissionHelperProvider);
    final granted = await helper.requestBlePermissions(context: context);
    if (mounted) {
      setState(() {
        _hasPermissions = granted;
      });
      if (granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bluetooth permissions granted.'),
            backgroundColor: AppTheme.darkSuccess,
          ),
        );
        _startScan();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permissions denied. Cannot scan for BLE devices.'),
            backgroundColor: AppTheme.darkError,
          ),
        );
      }
    }
  }

  Future<void> _startScan() async {
    final scanner = ref.read(bleScannerServiceProvider);
    await scanner.startScan();
  }

  Future<void> _stopScan() async {
    final scanner = ref.read(bleScannerServiceProvider);
    await scanner.stopScan();
  }

  Future<void> _enableBluetooth() async {
    final scanner = ref.read(bleScannerServiceProvider);
    await scanner.requestEnableBluetooth();
  }

  Future<void> _connectToDevice(DiscoveredBleDevice device) async {
    setState(() {
      _connectingDeviceId = device.id;
    });

    try {
      final bleService = ref.read(bleServiceProvider);
      await bleService.connect(device.id);
      ref.read(connectedDeviceIdProvider.notifier).state = device.id;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connected to ${device.name}'),
            backgroundColor: AppTheme.darkSuccess,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to connect: $e'),
            backgroundColor: AppTheme.darkError,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _connectingDeviceId = null;
        });
      }
    }
  }

  Future<void> _disconnectDevice() async {
    final bleService = ref.read(bleServiceProvider);
    await bleService.disconnect();
    ref.read(connectedDeviceIdProvider.notifier).state = null;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Disconnected from Puck.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectionState =
        ref.watch(bleConnectionStateProvider).value ?? BleConnectionState.disconnected;
    final isScanning = ref.watch(isScanningProvider).value ?? false;
    final discoveredDevices =
        ref.watch(discoveredDevicesProvider).value ?? [];
    final adapterStatus =
        ref.watch(bleAdapterStatusProvider).value ?? BleAdapterStatus.on;
    final connectedDeviceId = ref.watch(connectedDeviceIdProvider);
    final isMockMode = ref.watch(isMockModeProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Connect GWEN Puck'),
        actions: [
          if (isMockMode)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Chip(
                label: const Text('Mock Mode', style: TextStyle(fontSize: 12)),
                backgroundColor: AppTheme.darkSurface,
                side: BorderSide(color: AppTheme.darkPrimary.withValues(alpha: 0.5)),
              ),
            ),
          IconButton(
            icon: isScanning
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.darkPrimary,
                    ),
                  )
                : const Icon(Icons.refresh_rounded),
            tooltip: 'Rescan',
            onPressed: (_hasPermissions && adapterStatus == BleAdapterStatus.on)
                ? (isScanning ? _stopScan : _startScan)
                : null,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('floating_scan_button'),
        backgroundColor: isScanning ? AppTheme.darkSurface : AppTheme.darkPrimary,
        foregroundColor: Colors.white,
        icon: isScanning
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.bluetooth_searching_rounded),
        label: Text(isScanning ? 'Scanning...' : 'Scan for Puck'),
        onPressed: () {
          if (!_hasPermissions) {
            _requestPermissions();
          } else if (adapterStatus == BleAdapterStatus.off) {
            _enableBluetooth();
          } else if (isScanning) {
            _stopScan();
          } else {
            _startScan();
          }
        },
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Banner 1: Permission Required Banner
          if (!_isCheckingPermissions && !_hasPermissions)
            _buildPermissionBanner(),

          // Banner 2: Bluetooth Disabled Banner
          if (!_isCheckingPermissions &&
              _hasPermissions &&
              adapterStatus == BleAdapterStatus.off)
            _buildBluetoothOffBanner(),

          // Active Connection Status Card
          _buildConnectionStatusCard(connectionState, connectedDeviceId),
          const SizedBox(height: 16),

          // Header for Discovered Devices
          Row(
            children: [
              Text(
                'DISCOVERED DEVICES (${discoveredDevices.length})',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: AppTheme.darkTextSecondary,
                ),
              ),
              const Spacer(),
              if (isScanning)
                const Row(
                  children: [
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: AppTheme.darkPrimary,
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Scanning nearby...',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.darkPrimary,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Devices List or Empty State
          if (discoveredDevices.isEmpty)
            _buildEmptyState(isScanning)
          else
            ...discoveredDevices.map((device) {
              final isConnected =
                  connectionState == BleConnectionState.connected &&
                      connectedDeviceId == device.id;
              final isConnecting = _connectingDeviceId == device.id ||
                  (connectionState == BleConnectionState.connecting &&
                      connectedDeviceId == device.id);

              return _buildDeviceCard(
                device: device,
                isConnected: isConnected,
                isConnecting: isConnecting,
              );
            }),

          const SizedBox(height: 80), // Padding for FAB
        ],
      ),
    );
  }

  Widget _buildPermissionBanner() {
    return Container(
      key: const Key('permission_check_banner'),
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppTheme.darkWarning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.darkWarning.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppTheme.darkWarning),
              SizedBox(width: 10),
              Text(
                'Bluetooth Permissions Needed',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkWarning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Android requires Bluetooth and Location permissions to scan for nearby Puck hardware. '
            'Your sensor data and GPS coordinates remain 100% offline on your device.',
            style: TextStyle(fontSize: 13, color: AppTheme.darkTextPrimary, height: 1.3),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            key: const Key('grant_permission_button'),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.darkWarning,
              foregroundColor: Colors.black,
            ),
            icon: const Icon(Icons.check_rounded, size: 18),
            label: const Text('Grant Permission'),
            onPressed: _requestPermissions,
          ),
        ],
      ),
    );
  }

  Widget _buildBluetoothOffBanner() {
    return Container(
      key: const Key('bluetooth_off_banner'),
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppTheme.darkError.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.darkError.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bluetooth_disabled_rounded, color: AppTheme.darkError),
              SizedBox(width: 10),
              Text(
                'Bluetooth is Turned Off',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkError,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Enable Bluetooth on your device to discover and connect to your GWEN Puck.',
            style: TextStyle(fontSize: 13, color: AppTheme.darkTextPrimary),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            key: const Key('enable_bluetooth_button'),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.darkError,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.bluetooth_rounded, size: 18),
            label: const Text('Enable Bluetooth'),
            onPressed: _enableBluetooth,
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatusCard(
    BleConnectionState state,
    String? connectedDeviceId,
  ) {
    final isConnected = state == BleConnectionState.connected;
    final isConnecting = state == BleConnectionState.connecting;

    Color stateColor = AppTheme.darkTextSecondary;
    String statusTitle = 'Disconnected';
    String statusSubtitle = 'Scan below to connect to your Puck';

    if (isConnected) {
      stateColor = AppTheme.darkSuccess;
      statusTitle = 'Connected to Puck';
      statusSubtitle = connectedDeviceId ?? 'GWEN Puck';
    } else if (isConnecting) {
      stateColor = AppTheme.darkWarning;
      statusTitle = 'Connecting...';
      statusSubtitle = 'Establishing secure BLE link';
    }

    return Card(
      color: AppTheme.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isConnected
              ? AppTheme.darkSuccess.withValues(alpha: 0.4)
              : Colors.transparent,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: stateColor,
                boxShadow: isConnected
                    ? [
                        BoxShadow(
                          color: AppTheme.darkSuccess.withValues(alpha: 0.5),
                          blurRadius: 6,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusTitle,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    statusSubtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.darkTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isConnected)
              OutlinedButton(
                key: const Key('disconnect_button'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.darkError,
                  side: BorderSide(color: AppTheme.darkError.withValues(alpha: 0.5)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onPressed: _disconnectDevice,
                child: const Text('Disconnect'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceCard({
    required DiscoveredBleDevice device,
    required bool isConnected,
    required bool isConnecting,
  }) {
    final signalIcon = _getSignalIcon(device.rssi);
    final signalColor = _getSignalColor(device.rssi);

    return Card(
      key: Key('device_card_${device.id}'),
      color: AppTheme.darkSurface,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isConnected
              ? AppTheme.darkPrimary.withValues(alpha: 0.4)
              : Colors.transparent,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          children: [
            // Signal strength indicator
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: signalColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(signalIcon, color: signalColor, size: 22),
            ),
            const SizedBox(width: 14),

            // Device Name & MAC / ID
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          device.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkTextPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (device.isMock) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.darkPrimary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Mock',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.darkPrimary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        device.id,
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          color: AppTheme.darkTextSecondary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${device.rssi} dBm',
                        style: TextStyle(
                          fontSize: 11,
                          color: signalColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Connect button or status
            if (isConnected)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.darkSuccess.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_rounded,
                        color: AppTheme.darkSuccess, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Connected',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkSuccess,
                      ),
                    ),
                  ],
                ),
              )
            else if (isConnecting)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.darkPrimary,
                ),
              )
            else
              FilledButton.tonal(
                key: Key('connect_button_${device.id}'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.darkPrimary.withValues(alpha: 0.15),
                  foregroundColor: AppTheme.darkPrimary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                onPressed: () => _connectToDevice(device),
                child: const Text('Connect'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isScanning) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isScanning
                ? Icons.bluetooth_searching_rounded
                : Icons.bluetooth_disabled_rounded,
            size: 48,
            color: AppTheme.darkTextSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            isScanning ? 'Scanning for devices...' : 'No Puck detected',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.darkTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isScanning
                ? 'Looking for nearby GWEN Puck BLE hardware. Please keep the Puck within 5 meters.'
                : 'Turn on your Puck hardware or enable Mock mode, then tap "Scan for Puck".',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.darkTextSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSignalIcon(int rssi) {
    if (rssi >= -65) {
      return Icons.signal_cellular_alt_rounded;
    } else if (rssi >= -80) {
      return Icons.signal_cellular_alt_2_bar_rounded;
    } else {
      return Icons.signal_cellular_alt_1_bar_rounded;
    }
  }

  Color _getSignalColor(int rssi) {
    if (rssi >= -65) {
      return AppTheme.darkSuccess;
    } else if (rssi >= -80) {
      return AppTheme.darkWarning;
    } else {
      return AppTheme.darkError;
    }
  }
}
