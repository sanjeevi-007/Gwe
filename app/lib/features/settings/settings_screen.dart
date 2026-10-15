import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ble/ble.dart';
import '../../core/theme.dart';
import '../../state/ble_providers.dart';
import 'device_picker_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState =
        ref.watch(bleConnectionStateProvider).value ?? BleConnectionState.disconnected;
    final connectedDeviceId = ref.watch(connectedDeviceIdProvider);
    final isMockMode = ref.watch(isMockModeProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Device Connection Tile
          Card(
            color: AppTheme.darkSurface,
            child: ListTile(
              key: const Key('settings_device_picker_tile'),
              leading: const Icon(
                Icons.bluetooth_searching_rounded,
                color: AppTheme.darkPrimary,
              ),
              title: const Text('BLE Device / Puck'),
              subtitle: Text(
                connectionState == BleConnectionState.connected
                    ? 'Connected: ${connectedDeviceId ?? 'GWEN Puck'}'
                    : 'Scan and pair with your Puck',
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const DevicePickerScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Mode Switch: Mock / Real Puck
          Card(
            color: AppTheme.darkSurface,
            child: SwitchListTile(
              secondary: const Icon(
                Icons.tune_rounded,
                color: AppTheme.darkPrimary,
              ),
              title: const Text('Mock Mode'),
              subtitle: Text(
                isMockMode
                    ? 'Using simulated Puck telemetry'
                    : 'Using physical BLE Puck hardware',
              ),
              value: isMockMode,
              onChanged: (value) {
                ref.read(isMockModeProvider.notifier).state = value;
              },
            ),
          ),
          const SizedBox(height: 8),

          // Export Data
          Card(
            color: AppTheme.darkSurface,
            child: ListTile(
              leading: const Icon(
                Icons.file_download_outlined,
                color: AppTheme.darkPrimary,
              ),
              title: const Text('Export Data (CSV / JSON)'),
              subtitle: const Text('Offline export via Android share sheet'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 8),

          // Purge All History
          Card(
            color: AppTheme.darkSurface,
            child: ListTile(
              leading: const Icon(
                Icons.delete_outline_rounded,
                color: AppTheme.darkError,
              ),
              title: const Text('Delete All Local History'),
              subtitle: const Text('Purges all local SQLite tables'),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
