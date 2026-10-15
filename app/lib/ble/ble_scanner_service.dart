import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'discovered_ble_device.dart';

/// Bluetooth adapter power and authorization states.
enum BleAdapterStatus {
  unknown,
  on,
  off,
  unauthorized,
  unavailable,
}

/// Abstract interface for BLE device scanning.
abstract class BleScannerService {
  /// Stream of discovered BLE devices.
  Stream<List<DiscoveredBleDevice>> get discoveredDevices;

  /// Current list of discovered devices synchronously.
  List<DiscoveredBleDevice> get currentDiscoveredDevices;

  /// Stream emitting true when actively scanning.
  Stream<bool> get isScanning;

  /// Current scanning status synchronously.
  bool get currentIsScanning;

  /// Stream of Bluetooth adapter status.
  Stream<BleAdapterStatus> get adapterStatus;

  /// Current adapter status synchronously.
  BleAdapterStatus get currentAdapterStatus;

  /// Starts scanning for nearby BLE devices.
  Future<void> startScan({Duration duration = const Duration(seconds: 4)});

  /// Stops any in-progress scan.
  Future<void> stopScan();

  /// Requests the user or system to turn on Bluetooth.
  Future<void> requestEnableBluetooth();

  /// Releases resources.
  void dispose();
}

/// Mock implementation of [BleScannerService] simulating discovery of GWEN Puck.
class MockBleScannerService implements BleScannerService {
  final List<DiscoveredBleDevice> _devices = [];
  bool _isScanning = false;
  BleAdapterStatus _adapterStatus = BleAdapterStatus.on;
  Timer? _scanTimer;

  final StreamController<List<DiscoveredBleDevice>> _devicesController =
      StreamController<List<DiscoveredBleDevice>>.broadcast();
  final StreamController<bool> _isScanningController =
      StreamController<bool>.broadcast();
  final StreamController<BleAdapterStatus> _adapterStatusController =
      StreamController<BleAdapterStatus>.broadcast();

  final List<DiscoveredBleDevice> mockDiscoveredList;

  MockBleScannerService({
    List<DiscoveredBleDevice>? initialMockDevices,
    BleAdapterStatus initialStatus = BleAdapterStatus.on,
  })  : mockDiscoveredList = initialMockDevices ??
            const [
              DiscoveredBleDevice(
                id: 'GWEN-PUCK-MOCK',
                name: 'GWEN Puck (Mock)',
                rssi: -58,
                isMock: true,
              ),
            ],
        _adapterStatus = initialStatus;

  @override
  Stream<List<DiscoveredBleDevice>> get discoveredDevices async* {
    yield _devices;
    yield* _devicesController.stream;
  }

  @override
  List<DiscoveredBleDevice> get currentDiscoveredDevices =>
      List.unmodifiable(_devices);

  @override
  Stream<bool> get isScanning async* {
    yield _isScanning;
    yield* _isScanningController.stream;
  }

  @override
  bool get currentIsScanning => _isScanning;

  @override
  Stream<BleAdapterStatus> get adapterStatus async* {
    yield _adapterStatus;
    yield* _adapterStatusController.stream;
  }

  @override
  BleAdapterStatus get currentAdapterStatus => _adapterStatus;

  void setAdapterStatus(BleAdapterStatus status) {
    _adapterStatus = status;
    if (!_adapterStatusController.isClosed) {
      _adapterStatusController.add(_adapterStatus);
    }
  }

  @override
  Future<void> startScan({Duration duration = const Duration(seconds: 4)}) async {
    if (_adapterStatus != BleAdapterStatus.on) {
      return;
    }

    _isScanning = true;
    if (!_isScanningController.isClosed) {
      _isScanningController.add(true);
    }

    _devices.clear();
    if (!_devicesController.isClosed) {
      _devicesController.add(List.unmodifiable(_devices));
    }

    _scanTimer?.cancel();

    // Populate mock devices shortly after scan starts
    Timer(const Duration(milliseconds: 200), () {
      if (!_isScanning) return;
      _devices.addAll(mockDiscoveredList);
      if (!_devicesController.isClosed) {
        _devicesController.add(List.unmodifiable(_devices));
      }
    });

    _scanTimer = Timer(duration, () {
      stopScan();
    });
  }

  @override
  Future<void> stopScan() async {
    _scanTimer?.cancel();
    _isScanning = false;
    if (!_isScanningController.isClosed) {
      _isScanningController.add(false);
    }
  }

  @override
  Future<void> requestEnableBluetooth() async {
    setAdapterStatus(BleAdapterStatus.on);
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    _devicesController.close();
    _isScanningController.close();
    _adapterStatusController.close();
  }
}

/// Real BLE scanner utilizing [FlutterBluePlus].
class RealBleScannerService implements BleScannerService {
  final List<DiscoveredBleDevice> _devices = [];
  bool _isScanning = false;
  BleAdapterStatus _adapterStatus = BleAdapterStatus.unknown;

  StreamSubscription<List<ScanResult>>? _scanSub;
  StreamSubscription<bool>? _isScanningSub;
  StreamSubscription<BluetoothAdapterState>? _adapterSub;

  final StreamController<List<DiscoveredBleDevice>> _devicesController =
      StreamController<List<DiscoveredBleDevice>>.broadcast();
  final StreamController<bool> _isScanningController =
      StreamController<bool>.broadcast();
  final StreamController<BleAdapterStatus> _adapterStatusController =
      StreamController<BleAdapterStatus>.broadcast();

  RealBleScannerService() {
    _initFlutterBlue();
  }

  void _initFlutterBlue() {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      _adapterStatus = BleAdapterStatus.on;
      return;
    }

    try {
      _adapterSub = FlutterBluePlus.adapterState.listen((state) {
        final mapped = _mapAdapterState(state);
        _adapterStatus = mapped;
        if (!_adapterStatusController.isClosed) {
          _adapterStatusController.add(mapped);
        }
      });

      _isScanningSub = FlutterBluePlus.isScanning.listen((scanning) {
        _isScanning = scanning;
        if (!_isScanningController.isClosed) {
          _isScanningController.add(scanning);
        }
      });

      _scanSub = FlutterBluePlus.scanResults.listen((results) {
        _devices.clear();
        for (final r in results) {
          final name = r.device.platformName.isNotEmpty
              ? r.device.platformName
              : (r.advertisementData.advName.isNotEmpty
                  ? r.advertisementData.advName
                  : 'Unknown Device');
          _devices.add(DiscoveredBleDevice(
            id: r.device.remoteId.str,
            name: name,
            rssi: r.rssi,
            isMock: false,
          ));
        }
        if (!_devicesController.isClosed) {
          _devicesController.add(List.unmodifiable(_devices));
        }
      });
    } catch (_) {
      // Graceful fallback on non-supported platforms
      _adapterStatus = BleAdapterStatus.on;
    }
  }

  BleAdapterStatus _mapAdapterState(BluetoothAdapterState state) {
    switch (state) {
      case BluetoothAdapterState.on:
        return BleAdapterStatus.on;
      case BluetoothAdapterState.off:
        return BleAdapterStatus.off;
      case BluetoothAdapterState.unauthorized:
        return BleAdapterStatus.unauthorized;
      case BluetoothAdapterState.unavailable:
        return BleAdapterStatus.unavailable;
      default:
        return BleAdapterStatus.unknown;
    }
  }

  @override
  Stream<List<DiscoveredBleDevice>> get discoveredDevices async* {
    yield _devices;
    yield* _devicesController.stream;
  }

  @override
  List<DiscoveredBleDevice> get currentDiscoveredDevices =>
      List.unmodifiable(_devices);

  @override
  Stream<bool> get isScanning async* {
    yield _isScanning;
    yield* _isScanningController.stream;
  }

  @override
  bool get currentIsScanning => _isScanning;

  @override
  Stream<BleAdapterStatus> get adapterStatus async* {
    yield _adapterStatus;
    yield* _adapterStatusController.stream;
  }

  @override
  BleAdapterStatus get currentAdapterStatus => _adapterStatus;

  @override
  Future<void> startScan({Duration duration = const Duration(seconds: 4)}) async {
    try {
      _devices.clear();
      if (!_devicesController.isClosed) {
        _devicesController.add(List.unmodifiable(_devices));
      }
      await FlutterBluePlus.startScan(
        timeout: duration,
        androidUsesFineLocation: false,
      );
    } catch (_) {
      // Fallback if platform scan fails
      _isScanning = false;
      if (!_isScanningController.isClosed) {
        _isScanningController.add(false);
      }
    }
  }

  @override
  Future<void> stopScan() async {
    try {
      await FlutterBluePlus.stopScan();
    } catch (_) {
      // Ignore
    }
  }

  @override
  Future<void> requestEnableBluetooth() async {
    try {
      if (Platform.isAndroid) {
        await FlutterBluePlus.turnOn();
      }
    } catch (_) {
      // Ignore
    }
  }

  @override
  void dispose() {
    _scanSub?.cancel();
    _isScanningSub?.cancel();
    _adapterSub?.cancel();
    _devicesController.close();
    _isScanningController.close();
    _adapterStatusController.close();
  }
}
