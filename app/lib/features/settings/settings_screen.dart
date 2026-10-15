import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ble/ble.dart';
import '../../core/theme.dart';
import '../../state/ble_providers.dart';
import '../../state/readings_providers.dart';
import '../../state/sync_providers.dart';
import '../onboarding/onboarding_screen.dart';
import 'device_picker_screen.dart';

/// Full Settings screen managing device pairing, simulation scenarios,
/// phone GPS bridge, local data retention, purge, and offline exports.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isExporting = false;
  bool _isPurging = false;

  @override
  void initState() {
    super.initState();
    _loadSavedRetention();
  }

  Future<void> _loadSavedRetention() async {
    final settingsRepo = ref.read(settingsRepositoryProvider);
    final saved = await settingsRepo.getSetting('history_retention');
    if (saved != null && mounted) {
      ref.read(historyRetentionProvider.notifier).state = saved;
    }
  }

  Future<void> _updateRetention(String? value) async {
    if (value == null) return;
    ref.read(historyRetentionProvider.notifier).state = value;
    final settingsRepo = ref.read(settingsRepositoryProvider);
    await settingsRepo.setSetting('history_retention', value);
  }

  Future<void> _exportCsv() async {
    setState(() => _isExporting = true);
    try {
      final exporter = ref.read(exportServiceProvider);
      await exporter.exportCsvAndShare();
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('CSV telemetry export ready for sharing.'),
            backgroundColor: AppTheme.darkSuccess,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppTheme.darkError,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _exportJson() async {
    setState(() => _isExporting = true);
    try {
      final exporter = ref.read(exportServiceProvider);
      await exporter.exportJsonAndShare();
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('JSON telemetry export ready for sharing.'),
            backgroundColor: AppTheme.darkSuccess,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppTheme.darkError,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _confirmDeleteAllHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete All Local History?'),
        content: const Text(
          'This action will permanently erase all local pulse, motion, GPS, '
          'and AI insight records stored in your device SQLite database.\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('confirm_delete_history_button'),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.darkError,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isPurging = true);
      try {
        await ref.read(pulseRepositoryProvider).deleteAllPulse();
        await ref.read(motionRepositoryProvider).deleteAllMotion();
        await ref.read(gpsRepositoryProvider).deleteAllGps();
        await ref.read(aiRepositoryProvider).deleteAllAi();

        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All local telemetry history erased.'),
              backgroundColor: AppTheme.darkSuccess,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Purge failed: $e'),
              backgroundColor: AppTheme.darkError,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isPurging = false);
        }
      }
    }
  }

  void _showHealthDisclaimerDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.health_and_safety_rounded, color: AppTheme.darkWarning),
            SizedBox(width: 10),
            Flexible(
              child: Text(
                'Health & Safety Notice',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'GWEN Non-Medical Device Disclaimer',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppTheme.darkTextPrimary,
                ),
              ),
              SizedBox(height: 10),
              Text(
                '• GWEN is NOT a medical device and is not certified by FDA, CE, or health authorities.\n'
                '• It does NOT provide medical diagnosis, treatment, fall detection, SOS, or emergency dispatch services.\n'
                '• Sensor readings may experience noise or dropouts during movement or skin decoupling.\n'
                '• Always consult qualified healthcare professionals for health concerns.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.darkTextSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final connectionState =
        ref.watch(bleConnectionStateProvider).value ?? BleConnectionState.disconnected;
    final isConnected = connectionState == BleConnectionState.connected;
    final connectedDeviceId = ref.watch(connectedDeviceIdProvider);
    final status = ref.watch(latestStatusProvider).value;
    final isMockMode = ref.watch(isMockModeProvider);
    final currentScenario = ref.watch(mockScenarioProvider);
    final isPhoneGpsActive = ref.watch(isPhoneGpsActiveProvider);
    final retention = ref.watch(historyRetentionProvider);

    // Formatted device stats
    final deviceName = isConnected
        ? (isMockMode ? 'GWEN Puck (Simulated)' : 'GWEN Puck')
        : 'Disconnected';
    final deviceIdText = connectedDeviceId ?? 'GWEN-PUCK-MOCK';
    final firmwareText = isConnected
        ? (status != null ? 'v${status.firmwareVersion}' : 'v1.0.0')
        : 'v1.0.0';
    final batteryText = isConnected
        ? (status?.battery != null ? '${status!.battery}%' : '85%')
        : '--';
    final uptimeText = isConnected
        ? (status != null
            ? '${status.uptimeSeconds ~/ 60}m ${status.uptimeSeconds % 60}s'
            : '42m 15s')
        : '--';

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // ---------------------------------------------------------------
          // SECTION 1: Connected Device Section
          // ---------------------------------------------------------------
          _buildSectionHeader('CONNECTED PUCK HARDWARE'),
          Card(
            color: AppTheme.darkSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isConnected
                    ? AppTheme.darkSuccess.withValues(alpha: 0.3)
                    : Colors.transparent,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (isConnected ? AppTheme.darkSuccess : AppTheme.darkTextSecondary)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.watch_rounded,
                          color: isConnected ? AppTheme.darkSuccess : AppTheme.darkTextSecondary,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              deviceName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.darkTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              deviceIdText,
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'monospace',
                                color: AppTheme.darkTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Chip(
                        label: Text(
                          isConnected ? 'Active' : 'Offline',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isConnected ? AppTheme.darkSuccess : AppTheme.darkTextSecondary,
                          ),
                        ),
                        backgroundColor: AppTheme.darkBackground,
                        side: BorderSide(
                          color: (isConnected ? AppTheme.darkSuccess : AppTheme.darkTextSecondary)
                              .withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppTheme.darkSurfaceVariant, height: 1),
                  const SizedBox(height: 12),

                  // Hardware metrics row: Firmware, Battery, Uptime
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMiniMetric('Firmware', firmwareText, Icons.memory_rounded),
                      _buildMiniMetric('Battery', batteryText, Icons.battery_charging_full_rounded),
                      _buildMiniMetric('Uptime', uptimeText, Icons.timer_outlined),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Change Device / Pair Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      key: const Key('change_device_button'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.darkPrimary,
                        side: BorderSide(color: AppTheme.darkPrimary.withValues(alpha: 0.5)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.bluetooth_searching_rounded, size: 18),
                      label: const Text('Change Device / Pair'),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const DevicePickerScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Phone GPS Bridge Switch
                  Material(
                    color: AppTheme.darkBackground.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                    child: SwitchListTile(
                      key: const Key('phone_gps_toggle'),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      secondary: const Icon(
                        Icons.gps_fixed_rounded,
                        color: AppTheme.darkPrimary,
                      ),
                      title: const Text(
                        'Use Phone GPS for Location',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Text(
                        'Streams phone GPS directly into Puck location engine',
                        style: TextStyle(fontSize: 12, color: AppTheme.darkTextSecondary),
                      ),
                      value: isPhoneGpsActive,
                      onChanged: (val) {
                        ref.read(isPhoneGpsActiveProvider.notifier).state = val;
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ---------------------------------------------------------------
          // SECTION 2: Simulation Control Panel (Mock Mode)
          // ---------------------------------------------------------------
          _buildSectionHeader('SIMULATION & MOCK HARDWARE'),
          Card(
            color: AppTheme.darkSurface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    key: const Key('mock_mode_switch'),
                    contentPadding: EdgeInsets.zero,
                    secondary: const Icon(Icons.tune_rounded, color: AppTheme.darkPrimary),
                    title: const Text(
                      'Mock / Real Hardware Mode',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      isMockMode
                          ? 'Using internal MockPuck simulation'
                          : 'Listening for real ESP32 BLE hardware',
                      style: const TextStyle(fontSize: 12, color: AppTheme.darkTextSecondary),
                    ),
                    value: isMockMode,
                    onChanged: (val) {
                      ref.read(isMockModeProvider.notifier).state = val;
                    },
                  ),
                  if (isMockMode) ...[
                    const SizedBox(height: 12),
                    const Divider(color: AppTheme.darkSurfaceVariant, height: 1),
                    const SizedBox(height: 14),
                    const Text(
                      'Active Simulation Scenario',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.darkBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.darkSurfaceVariant),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<MockScenario>(
                          key: const Key('mock_scenario_dropdown'),
                          isExpanded: true,
                          dropdownColor: AppTheme.darkSurface,
                          value: currentScenario,
                          items: const [
                            DropdownMenuItem(
                              value: MockScenario.normal,
                              child: Text('Normal Telemetry'),
                            ),
                            DropdownMenuItem(
                              value: MockScenario.poorSignal,
                              child: Text('Poor Optical Signal'),
                            ),
                            DropdownMenuItem(
                              value: MockScenario.noFinger,
                              child: Text('No Finger Contact'),
                            ),
                            DropdownMenuItem(
                              value: MockScenario.gpsSearching,
                              child: Text('GPS Searching Fix'),
                            ),
                            DropdownMenuItem(
                              value: MockScenario.gpsStale,
                              child: Text('GPS Stale Coordinates'),
                            ),
                            DropdownMenuItem(
                              value: MockScenario.aiUncertain,
                              child: Text('AI Uncertain Motion'),
                            ),
                            DropdownMenuItem(
                              value: MockScenario.sensorError,
                              child: Text('Sensor Error Injection'),
                            ),
                            DropdownMenuItem(
                              value: MockScenario.disconnected,
                              child: Text('Simulate Disconnection'),
                            ),
                          ],
                          onChanged: (newScenario) {
                            if (newScenario != null) {
                              ref.read(mockScenarioProvider.notifier).state = newScenario;
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ---------------------------------------------------------------
          // SECTION 3: Data Export & Privacy Section
          // ---------------------------------------------------------------
          _buildSectionHeader('DATA EXPORT & PRIVACY'),
          Card(
            color: AppTheme.darkSurface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Privacy callout
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.darkPrimary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.darkPrimary.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.shield_outlined, color: AppTheme.darkPrimary, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'GWEN stores 100% of data locally in SQLite. Coordinates and pulse history are never uploaded.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.darkTextPrimary,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Export CSV Button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonalIcon(
                      key: const Key('export_csv_button'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.darkPrimary.withValues(alpha: 0.15),
                        foregroundColor: AppTheme.darkPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: _isExporting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.table_chart_outlined, size: 20),
                      label: const Text('Export History as CSV'),
                      onPressed: _isExporting ? null : _exportCsv,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Export JSON Button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonalIcon(
                      key: const Key('export_json_button'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.darkPrimary.withValues(alpha: 0.15),
                        foregroundColor: AppTheme.darkPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: _isExporting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.code_rounded, size: 20),
                      label: const Text('Export History as JSON'),
                      onPressed: _isExporting ? null : _exportJson,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ---------------------------------------------------------------
          // SECTION 4: Data Retention & Storage Purge Section
          // ---------------------------------------------------------------
          _buildSectionHeader('RETENTION & STORAGE PURGE'),
          Card(
            color: AppTheme.darkSurface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Local History Retention',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Automatically prune telemetry history older than:',
                    style: TextStyle(fontSize: 12, color: AppTheme.darkTextSecondary),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.darkBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.darkSurfaceVariant),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        key: const Key('history_retention_dropdown'),
                        isExpanded: true,
                        dropdownColor: AppTheme.darkSurface,
                        value: retention,
                        items: const [
                          DropdownMenuItem(value: '24_hours', child: Text('24 Hours')),
                          DropdownMenuItem(value: '7_days', child: Text('7 Days')),
                          DropdownMenuItem(value: '30_days', child: Text('30 Days')),
                          DropdownMenuItem(value: 'forever', child: Text('Keep Forever')),
                        ],
                        onChanged: _updateRetention,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppTheme.darkSurfaceVariant, height: 1),
                  const SizedBox(height: 16),

                  // Delete All History Button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      key: const Key('delete_all_history_button'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.darkError.withValues(alpha: 0.15),
                        foregroundColor: AppTheme.darkError,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: AppTheme.darkError.withValues(alpha: 0.4)),
                        ),
                      ),
                      icon: _isPurging
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.darkError,
                              ),
                            )
                          : const Icon(Icons.delete_forever_rounded, size: 20),
                      label: const Text('Delete All Local History'),
                      onPressed: _isPurging ? null : _confirmDeleteAllHistory,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ---------------------------------------------------------------
          // SECTION 5: About & Onboarding Re-run
          // ---------------------------------------------------------------
          _buildSectionHeader('ABOUT & APP NOTICE'),
          Card(
            color: AppTheme.darkSurface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'GWEN: Guardian Wristband Emergency Network',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Version 0.5.0 • 100% Offline-First Telemetry Engine\n'
                    'Open-source hardware integration for ESP32 Puck',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.darkTextSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Disclaimer button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      key: const Key('health_disclaimer_button'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.darkWarning,
                        side: BorderSide(color: AppTheme.darkWarning.withValues(alpha: 0.5)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.health_and_safety_outlined, size: 18),
                      label: const Text('Important Health & Safety Notice'),
                      onPressed: _showHealthDisclaimerDialog,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Revisit Onboarding button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      key: const Key('revisit_onboarding_button'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.darkTextPrimary,
                        side: const BorderSide(color: AppTheme.darkSurfaceVariant),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.auto_stories_outlined, size: 18),
                      label: const Text('View App Intro / Onboarding'),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const OnboardingScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: AppTheme.darkTextSecondary,
        ),
      ),
    );
  }

  Widget _buildMiniMetric(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppTheme.darkTextSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppTheme.darkTextSecondary),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkTextPrimary,
          ),
        ),
      ],
    );
  }
}
