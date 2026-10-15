import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ble/ble.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../state/state.dart';
import '../../widgets/stale_badge.dart';
import '../../widgets/status_card.dart';
import '../ai_insights/ai_insights_screen.dart';
import '../location/location_screen.dart';
import '../motion/motion_screen.dart';
import '../pulse/pulse_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionStateAsync = ref.watch(bleConnectionStateProvider);
    final connectionState = connectionStateAsync.value ?? BleConnectionState.disconnected;

    final pulseAsync = ref.watch(latestPulseProvider);
    final motionAsync = ref.watch(latestMotionProvider);
    final gpsAsync = ref.watch(latestGpsProvider);
    final aiAsync = ref.watch(latestAiResultProvider);
    final statusAsync = ref.watch(latestStatusProvider);

    final pulse = pulseAsync.valueOrNull;
    final motion = motionAsync.valueOrNull;
    final gps = gpsAsync.valueOrNull;
    final ai = aiAsync.valueOrNull;
    final status = statusAsync.valueOrNull;

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('GWEN'),
        actions: [
          _buildConnectionIndicator(connectionState),
          const SizedBox(width: 8),
          IconButton(
            key: const Key('debug_scenario_button'),
            icon: const Icon(Icons.bug_report_rounded, color: AppTheme.darkPrimary),
            tooltip: 'Simulation Scenarios',
            onPressed: () => _showScenarioBottomSheet(context, ref),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        children: [
          _buildPulseCard(context, pulse),
          const SizedBox(height: 12),
          _buildMotionCard(context, motion),
          const SizedBox(height: 12),
          _buildGpsCard(context, gps),
          const SizedBox(height: 12),
          _buildAiCard(context, ai),
          const SizedBox(height: 12),
          _buildStatusCard(context, status),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildConnectionIndicator(BleConnectionState state) {
    Color color;
    String label;

    switch (state) {
      case BleConnectionState.connected:
        color = const Color(0xFF00E676);
        label = 'Connected';
        break;
      case BleConnectionState.connecting:
        color = const Color(0xFFFF9100);
        label = 'Connecting';
        break;
      case BleConnectionState.scanning:
        color = const Color(0xFF00B0FF);
        label = 'Scanning';
        break;
      case BleConnectionState.disconnected:
        color = const Color(0xFF94A3B8);
        label = 'Disconnected';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulseCard(BuildContext context, PulseReading? pulse) {
    final theme = Theme.of(context);
    StaleState staleState = StaleState.unavailable;

    if (pulse != null) {
      if (pulse.state == PulseState.poorSignal) {
        staleState = StaleState.poorSignal;
      } else if (pulse.state == PulseState.noFinger ||
          pulse.state == PulseState.sensorError ||
          !pulse.valid) {
        staleState = StaleState.unavailable;
      } else if (!pulse.isFresh(AppConstants.pulseFreshnessSeconds)) {
        staleState = StaleState.stale;
      } else {
        staleState = StaleState.live;
      }
    }

    Widget content;
    if (pulse == null) {
      content = const SizedBox.shrink();
    } else if (pulse.state == PulseState.noFinger) {
      content = Text(
        'No Finger Detected',
        style: theme.textTheme.headlineSmall?.copyWith(
          color: AppTheme.darkOnSurface.withValues(alpha: 0.6),
          fontWeight: FontWeight.w600,
        ),
      );
    } else if (pulse.state == PulseState.sensorError) {
      content = Text(
        'Sensor Error',
        style: theme.textTheme.headlineSmall?.copyWith(
          color: const Color(0xFFEF5350),
          fontWeight: FontWeight.w600,
        ),
      );
    } else {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                pulse.bpm != null ? '${pulse.bpm}' : '--',
                style: theme.textTheme.displaySmall?.copyWith(
                  color: AppTheme.darkPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'BPM',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.darkOnSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildMetricChip(
                context,
                'Quality',
                '${pulse.quality}%',
                pulse.quality > 50 ? const Color(0xFF00E676) : const Color(0xFFFF9100),
              ),
              const SizedBox(width: 8),
              _buildMetricChip(
                context,
                'State',
                pulse.state.name,
                pulse.state == PulseState.valid
                    ? const Color(0xFF00E676)
                    : const Color(0xFFFF9100),
              ),
            ],
          ),
        ],
      );
    }

    return StatusCard(
      title: 'Pulse',
      icon: Icons.favorite_rounded,
      staleState: staleState,
      timestamp: pulse?.tsReceived,
      footerText: 'MAX30102 • 5s freshness',
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PulseScreen()),
      ),
      content: content,
    );
  }

  Widget _buildMotionCard(BuildContext context, MotionReading? motion) {
    final theme = Theme.of(context);
    StaleState staleState = StaleState.unavailable;

    if (motion != null) {
      if (!motion.isFresh(AppConstants.motionFreshnessSeconds)) {
        staleState = StaleState.stale;
      } else {
        staleState = StaleState.live;
      }
    }

    Widget content = const SizedBox.shrink();
    if (motion != null) {
      final activityClass = motion.intensity < 15
          ? 'Stationary'
          : (motion.intensity < 60 ? 'Walking' : 'Vigorous');

      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${motion.intensity}',
                style: theme.textTheme.displaySmall?.copyWith(
                  color: AppTheme.darkPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Intensity',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.darkOnSurface.withValues(alpha: 0.6),
                ),
              ),
              const Spacer(),
              _buildMetricChip(context, 'Activity', activityClass, AppTheme.darkPrimary),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.darkBackground.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Accel (mg):',
                        style: TextStyle(
                            color: AppTheme.darkOnSurface.withValues(alpha: 0.6),
                            fontSize: 12)),
                    Text('X: ${motion.ax}  Y: ${motion.ay}  Z: ${motion.az}',
                        style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Gyro (dps):',
                        style: TextStyle(
                            color: AppTheme.darkOnSurface.withValues(alpha: 0.6),
                            fontSize: 12)),
                    Text('X: ${motion.gx}  Y: ${motion.gy}  Z: ${motion.gz}',
                        style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    }

    return StatusCard(
      title: 'Movement',
      icon: Icons.directions_run_rounded,
      staleState: staleState,
      timestamp: motion?.tsReceived,
      footerText: 'MPU6050 • 5s freshness',
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MotionScreen()),
      ),
      content: content,
    );
  }

  Widget _buildGpsCard(BuildContext context, GpsReading? gps) {
    final theme = Theme.of(context);
    StaleState staleState = StaleState.unavailable;

    if (gps != null) {
      if (gps.stale || !gps.isFresh(AppConstants.gpsFreshnessSeconds)) {
        staleState = StaleState.stale;
      } else if (gps.fixState == GpsFixState.searching ||
          gps.fixState == GpsFixState.weak) {
        staleState = StaleState.poorSignal;
      } else if (gps.fixState == GpsFixState.fix) {
        staleState = StaleState.live;
      } else {
        staleState = StaleState.unavailable;
      }
    }

    Widget content = const SizedBox.shrink();
    if (gps != null) {
      final hasCoords = gps.lat != null && gps.lon != null;
      final coordsText = hasCoords
          ? '${gps.lat!.toStringAsFixed(6)}°, ${gps.lon!.toStringAsFixed(6)}°'
          : 'Coordinates: Acquiring...';

      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                gps.fixState == GpsFixState.fix
                    ? 'Fixed'
                    : gps.fixState.name.toUpperCase(),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: gps.fixState == GpsFixState.fix
                      ? const Color(0xFF00E676)
                      : const Color(0xFFFF9100),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              _buildMetricChip(
                context,
                'Sats',
                '${gps.satellites}',
                gps.satellites >= 4 ? const Color(0xFF00E676) : const Color(0xFFFF9100),
              ),
              const SizedBox(width: 6),
              _buildMetricChip(
                context,
                'HDOP',
                gps.hdop != null ? gps.hdop!.toStringAsFixed(1) : '--',
                AppTheme.darkPrimary,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.darkBackground.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.my_location_rounded,
                  size: 16,
                  color: hasCoords
                      ? AppTheme.darkPrimary
                      : AppTheme.darkOnSurface.withValues(alpha: 0.4),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    coordsText,
                    style: TextStyle(
                      fontFamily: hasCoords ? 'monospace' : null,
                      fontSize: 13,
                      fontWeight: hasCoords ? FontWeight.w600 : FontWeight.normal,
                      color: hasCoords
                          ? AppTheme.darkOnSurface
                          : AppTheme.darkOnSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return StatusCard(
      title: 'GPS',
      icon: Icons.location_on_rounded,
      staleState: staleState,
      timestamp: gps?.tsReceived,
      footerText: 'NEO-6M • 30s freshness',
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LocationScreen()),
      ),
      content: content,
    );
  }

  Widget _buildAiCard(BuildContext context, AiResult? ai) {
    final theme = Theme.of(context);
    StaleState staleState = StaleState.unavailable;

    if (ai != null) {
      if (!ai.isFresh(AppConstants.aiFreshnessSeconds)) {
        staleState = StaleState.stale;
      } else if (ai.label == AiLabel.uncertain) {
        staleState = StaleState.poorSignal;
      } else {
        staleState = StaleState.live;
      }
    }

    Widget content = const SizedBox.shrink();
    if (ai != null) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ai.displayLabelString,
            style: theme.textTheme.titleLarge?.copyWith(
              color: ai.isRuleBased ? const Color(0xFFFFB74D) : AppTheme.darkPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildMetricChip(
                context,
                'Score',
                ai.score != null ? '${ai.score}%' : 'N/A',
                AppTheme.darkPrimary,
              ),
              const SizedBox(width: 8),
              _buildMetricChip(
                context,
                'Model',
                'v${ai.modelVersion}',
                AppTheme.darkOnSurface.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 8),
              _buildMetricChip(
                context,
                'Engine',
                ai.isRuleBased ? 'Rule-Based' : 'TFLite Micro',
                ai.isRuleBased ? const Color(0xFFFFB74D) : const Color(0xFF00E676),
              ),
            ],
          ),
        ],
      );
    }

    return StatusCard(
      title: 'On-Device AI',
      icon: Icons.psychology_rounded,
      staleState: staleState,
      timestamp: ai?.tsReceived,
      footerText: 'TFLite Micro on ESP32 • 5s freshness',
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AiInsightsScreen()),
      ),
      content: content,
    );
  }

  Widget _buildStatusCard(BuildContext context, DeviceStatus? status) {
    final theme = Theme.of(context);
    StaleState staleState = StaleState.unavailable;

    if (status != null) {
      if (!status.isFresh(30)) {
        staleState = StaleState.stale;
      } else {
        staleState = StaleState.live;
      }
    }

    Widget content = const SizedBox.shrink();
    if (status != null) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.battery_charging_full_rounded,
                color: status.battery != null && status.battery! < 20
                    ? const Color(0xFFEF5350)
                    : const Color(0xFF00E676),
                size: 24,
              ),
              const SizedBox(width: 6),
              Text(
                status.battery != null ? '${status.battery}%' : 'External',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: AppTheme.darkOnSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                'v${status.firmwareVersion}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.darkPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Uptime: ${status.uptimeSeconds}s (${status.uptimeSeconds ~/ 60}m)',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.darkOnSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              _buildSensorChip('MAX30102', status.isMax30102Ok),
              _buildSensorChip('MPU6050', status.isMpu6050Ok),
              _buildSensorChip('NEO-6M', status.isGpsOk),
              _buildSensorChip('TFT', status.isTftOk),
              _buildSensorChip('AI Model', status.isModelLoaded),
            ],
          ),
        ],
      );
    }

    return StatusCard(
      title: 'Device Status',
      icon: Icons.memory_rounded,
      staleState: staleState,
      timestamp: status?.tsReceived,
      footerText: 'ESP32 System Health',
      content: content,
    );
  }

  Widget _buildMetricChip(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSensorChip(String name, bool isOk) {
    final color = isOk ? const Color(0xFF00E676) : const Color(0xFFEF5350);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$name: ${isOk ? "OK" : "FAIL"}',
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showScenarioBottomSheet(BuildContext context, WidgetRef ref) {
    final currentScenario = ref.read(mockScenarioProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.75,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      children: [
                        const Icon(Icons.tune_rounded, color: AppTheme.darkPrimary),
                        const SizedBox(width: 8),
                        Text(
                          'Simulation Scenarios',
                          style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                                color: AppTheme.darkOnSurface,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      'Select a MockPuck hardware profile to test UI states',
                      style: TextStyle(
                        color: AppTheme.darkOnSurface.withValues(alpha: 0.6),
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const Divider(height: 24),
                  Expanded(
                    child: ListView(
                      children: [
                      _buildScenarioTile(
                        ctx,
                        ref,
                        scenario: MockScenario.normal,
                        title: 'Normal Operating Mode',
                        subtitle: 'Valid readings across all sensors',
                        icon: Icons.check_circle_outline_rounded,
                        isSelected: currentScenario == MockScenario.normal,
                      ),
                      _buildScenarioTile(
                        ctx,
                        ref,
                        scenario: MockScenario.poorSignal,
                        title: 'Poor Signal State',
                        subtitle: 'MAX30102 low perfusion or motion artifact',
                        icon: Icons.signal_cellular_alt_1_bar_rounded,
                        isSelected: currentScenario == MockScenario.poorSignal,
                      ),
                      _buildScenarioTile(
                        ctx,
                        ref,
                        scenario: MockScenario.noFinger,
                        title: 'No Finger Detected',
                        subtitle: 'BPM 0xFFFF, sensor uncoupled',
                        icon: Icons.touch_app_outlined,
                        isSelected: currentScenario == MockScenario.noFinger,
                      ),
                      _buildScenarioTile(
                        ctx,
                        ref,
                        scenario: MockScenario.gpsSearching,
                        title: 'GPS Searching Mode',
                        subtitle: 'No satellite lock, acquiring coordinates',
                        icon: Icons.location_searching_rounded,
                        isSelected: currentScenario == MockScenario.gpsSearching,
                      ),
                      _buildScenarioTile(
                        ctx,
                        ref,
                        scenario: MockScenario.gpsStale,
                        title: 'GPS Stale State',
                        subtitle: 'Fix age > 30s, cached position',
                        icon: Icons.history_rounded,
                        isSelected: currentScenario == MockScenario.gpsStale,
                      ),
                      _buildScenarioTile(
                        ctx,
                        ref,
                        scenario: MockScenario.aiUncertain,
                        title: 'AI Uncertain State',
                        subtitle: 'Low heuristic score, ambiguous motion',
                        icon: Icons.help_outline_rounded,
                        isSelected: currentScenario == MockScenario.aiUncertain,
                      ),
                      _buildScenarioTile(
                        ctx,
                        ref,
                        scenario: MockScenario.sensorError,
                        title: 'Sensor Hardware Error',
                        subtitle: 'I2C/UART bus fault, bitmask cleared',
                        icon: Icons.error_outline_rounded,
                        isSelected: currentScenario == MockScenario.sensorError,
                      ),
                      _buildScenarioTile(
                        ctx,
                        ref,
                        scenario: MockScenario.disconnected,
                        title: 'Disconnected Link',
                        subtitle: 'Simulates BLE link loss / timeout',
                        icon: Icons.link_off_rounded,
                        isSelected: currentScenario == MockScenario.disconnected,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ),
        );
      },
    );
  }

  Widget _buildScenarioTile(
    BuildContext context,
    WidgetRef ref, {
    required MockScenario scenario,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppTheme.darkPrimary : AppTheme.darkOnSurface.withValues(alpha: 0.6),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppTheme.darkPrimary : AppTheme.darkOnSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: AppTheme.darkOnSurface.withValues(alpha: 0.5),
          fontSize: 12,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_rounded, color: AppTheme.darkPrimary)
          : null,
      onTap: () {
        ref.read(mockScenarioProvider.notifier).state = scenario;
        Navigator.of(context).pop();
      },
    );
  }
}
