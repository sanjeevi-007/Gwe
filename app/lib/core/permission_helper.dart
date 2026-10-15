import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

/// Helper for requesting and verifying Bluetooth and Location permissions
/// needed for BLE device scanning and connection on Android.
class PermissionHelper {
  final int? explicitAndroidSdkVersion;
  final Future<PermissionStatus> Function(Permission permission)? permissionStatusChecker;
  final Future<Map<Permission, PermissionStatus>> Function(List<Permission> permissions)?
      permissionRequester;

  PermissionHelper({
    this.explicitAndroidSdkVersion,
    this.permissionStatusChecker,
    this.permissionRequester,
  });

  /// Returns active Android SDK version (e.g. 33 for Android 13, 30 for Android 11),
  /// or null if not running on Android.
  int? get androidSdkVersion {
    if (explicitAndroidSdkVersion != null) return explicitAndroidSdkVersion;
    if (kIsWeb || !Platform.isAndroid) return null;
    return parseAndroidSdkVersion(Platform.operatingSystemVersion);
  }

  /// Whether current environment is Android 12 or higher (API level >= 31).
  bool get isAndroid12OrNewer {
    final sdk = androidSdkVersion;
    if (sdk == null) return false;
    return sdk >= 31;
  }

  /// Checks whether required BLE permissions are currently granted without prompting.
  Future<bool> checkBlePermissions() async {
    // Non-Android platforms (e.g., testing on desktop) or web default to granted
    if (explicitAndroidSdkVersion == null && (kIsWeb || !Platform.isAndroid)) {
      return true;
    }

    if (isAndroid12OrNewer) {
      final scanStatus = await _checkStatus(Permission.bluetoothScan);
      final connectStatus = await _checkStatus(Permission.bluetoothConnect);
      return scanStatus.isGranted && connectStatus.isGranted;
    } else {
      final locationStatus = await _checkStatus(Permission.locationWhenInUse);
      return locationStatus.isGranted;
    }
  }

  /// Requests required BLE permissions according to the Android OS version:
  /// - On Android 12+ (SDK >= 31): Requests [bluetoothScan] and [bluetoothConnect].
  /// - On Android 11- (SDK < 31): Explains location is required by Android OS
  ///   strictly for BLE scanning (separate from Puck GPS), then requests [locationWhenInUse].
  ///
  /// Returns `true` if all required permissions are granted.
  Future<bool> requestBlePermissions({
    BuildContext? context,
    Future<bool> Function()? onShowLocationRationale,
  }) async {
    // Non-Android platforms default to granted
    if (explicitAndroidSdkVersion == null && (kIsWeb || !Platform.isAndroid)) {
      return true;
    }

    if (isAndroid12OrNewer) {
      final statuses = await _requestPermissions([
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ]);
      final scanOk = statuses[Permission.bluetoothScan]?.isGranted ?? false;
      final connectOk = statuses[Permission.bluetoothConnect]?.isGranted ?? false;
      return scanOk && connectOk;
    } else {
      // Android 11 and older: Location permission is mandated by Android OS for BLE discovery.
      // Explain this rationale so the user understands Puck GPS is separate and 100% offline.
      if (onShowLocationRationale != null) {
        final proceed = await onShowLocationRationale();
        if (!proceed) return false;
      } else if (context != null && context.mounted) {
        final proceed = await showLegacyLocationRationale(context);
        if (!proceed) return false;
      }

      final statuses = await _requestPermissions([
        Permission.locationWhenInUse,
        Permission.bluetooth,
      ]);
      return statuses[Permission.locationWhenInUse]?.isGranted ?? false;
    }
  }

  /// Displays an informational dialog explaining that Android 11 and older mandates
  /// OS Location permission for BLE scanning, separate from GWEN's offline GPS telemetry.
  static Future<bool> showLegacyLocationRationale(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('Location Permission Notice'),
            content: const Text(
              'Android 11 and older requires Location permission to discover nearby Bluetooth LE devices.\n\n'
              'GWEN only uses this because the Android OS mandates it for BLE scanning. '
              'Your GPS coordinates and sensor telemetry stay 100% offline on your device and are never sent anywhere.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Understood & Continue'),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Parses Android SDK version from an OS version string.
  static int? parseAndroidSdkVersion(String osVersion) {
    // Match "API 33" or "API: 31"
    final apiMatch = RegExp(r'API\s*[:=]?\s*(\d+)', caseSensitive: false).firstMatch(osVersion);
    if (apiMatch != null) {
      return int.tryParse(apiMatch.group(1)!);
    }
    // Match "Android 13" or "Android 11"
    final androidMatch =
        RegExp(r'Android\s+(\d+)', caseSensitive: false).firstMatch(osVersion);
    if (androidMatch != null) {
      final major = int.tryParse(androidMatch.group(1)!);
      if (major != null) {
        switch (major) {
          case 14:
            return 34;
          case 13:
            return 33;
          case 12:
            return 31;
          case 11:
            return 30;
          case 10:
            return 29;
          case 9:
            return 28;
          default:
            return major >= 12 ? 31 : 30;
        }
      }
    }
    return null;
  }

  Future<PermissionStatus> _checkStatus(Permission permission) async {
    final checker = permissionStatusChecker;
    if (checker != null) {
      return checker(permission);
    }
    return permission.status;
  }

  Future<Map<Permission, PermissionStatus>> _requestPermissions(
      List<Permission> permissions) async {
    final requester = permissionRequester;
    if (requester != null) {
      return requester(permissions);
    }
    return permissions.request();
  }
}

/// Provider for [PermissionHelper] instance.
final permissionHelperProvider = Provider<PermissionHelper>((ref) {
  return PermissionHelper();
});

/// FutureProvider checking if BLE permissions are currently granted.
final blePermissionsGrantedProvider = FutureProvider<bool>((ref) async {
  final helper = ref.watch(permissionHelperProvider);
  return helper.checkBlePermissions();
});
