import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../state/state.dart';
import '../../widgets/stale_badge.dart';

enum MotionDisplayMode { friendly, raw }

final motionDisplayModeProvider =
    StateProvider<MotionDisplayMode>((ref) => MotionDisplayMode.friendly);

class MotionScreen extends ConsumerWidget {
  const MotionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveMotionAsync = ref.watch(latestMotionProvider);
    final motion = liveMotionAsync.valueOrNull;

    final displayMode = ref.watch(motionDisplayModeProvider);
    final selectedRange = ref.watch(motionRangeProvider);
    final historyAsync = ref.watch(motionHistoryProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Movement & IMU'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: _buildStaleBadge(motion),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        children: [
          _buildViewModeToggle(context, ref, displayMode),
          const SizedBox(height: 16),
          if (displayMode == MotionDisplayMode.friendly)
            _buildFriendlyCard(context, motion, historyAsync.valueOrNull ?? [])
          else
            _buildRawImuCard(context, motion),
          const SizedBox(height: 16),
          _buildRangeSelector(context, ref, selectedRange),
          const SizedBox(height: 16),
          _buildIntensityChartCard(context, historyAsync, selectedRange),
          const SizedBox(height: 16),
          _buildDisclaimerCard(context),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  StaleBadge _buildStaleBadge(MotionReading? motion) {
    if (motion == null || !motion.valid) {
      return const StaleBadge(state: StaleState.unavailable);
    }
    if (!motion.isFresh(AppConstants.motionFreshnessSeconds)) {
      return const StaleBadge(state: StaleState.stale);
    }
    return const StaleBadge(state: StaleState.live);
  }

  Widget _buildViewModeToggle(
    BuildContext context,
    WidgetRef ref,
    MotionDisplayMode mode,
  ) {
    return Center(
      child: SegmentedButton<MotionDisplayMode>(
        segments: const [
          ButtonSegment(
            value: MotionDisplayMode.friendly,
            icon: Icon(Icons.directions_run_rounded, size: 18),
            label: Text('Activity View'),
          ),
          ButtonSegment(
            value: MotionDisplayMode.raw,
            icon: Icon(Icons.sensors_rounded, size: 18),
            label: Text('Raw IMU Data'),
          ),
        ],
        selected: {mode},
        onSelectionChanged: (newSelection) {
          ref.read(motionDisplayModeProvider.notifier).state =
              newSelection.first;
        },
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppTheme.darkPrimary.withValues(alpha: 0.2);
            }
            return AppTheme.darkSurface;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppTheme.darkPrimary;
            }
            return AppTheme.darkOnSurface.withValues(alpha: 0.8);
          }),
        ),
      ),
    );
  }

  Widget _buildFriendlyCard(
    BuildContext context,
    MotionReading? motion,
    List<MotionReading> history,
  ) {
    final theme = Theme.of(context);
    final intensity = motion?.intensity ?? 0;

    String activityLabel;
    IconData activityIcon;
    Color activityColor;

    if (motion == null || !motion.valid) {
      activityLabel = 'Unavailable';
      activityIcon = Icons.help_outline_rounded;
      activityColor = AppTheme.darkOnSurface.withValues(alpha: 0.4);
    } else if (intensity < 25) {
      activityLabel = 'Stationary / Resting';
      activityIcon = Icons.airline_seat_recline_normal_rounded;
      activityColor = const Color(0xFF64B5F6);
    } else if (intensity < 90) {
      activityLabel = 'Walking-like Motion';
      activityIcon = Icons.directions_walk_rounded;
      activityColor = const Color(0xFF00E676);
    } else {
      activityLabel = 'Vigorous Activity';
      activityIcon = Icons.directions_run_rounded;
      activityColor = const Color(0xFFFF9100);
    }

    final validHistory = history.where((r) => r.valid).toList();
    final avgIntensity = validHistory.isNotEmpty
        ? (validHistory.map((r) => r.intensity).reduce((a, b) => a + b) /
                validHistory.length)
            .round()
        : null;
    final maxIntensity = validHistory.isNotEmpty
        ? validHistory.map((r) => r.intensity).reduce(math.max)
        : null;

    final ageStr = motion != null ? _formatAge(motion.tsReceived) : '--';

    return Card(
      color: AppTheme.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: activityColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(activityIcon, color: activityColor, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Motion Estimate (Rule-based)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.darkOnSurface.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  ageStr,
                  style: TextStyle(
                    color: AppTheme.darkOnSurface.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              activityLabel,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: activityColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Motion Intensity Score',
                  style: TextStyle(
                    color: AppTheme.darkOnSurface.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
                Text(
                  motion != null && motion.valid ? '$intensity / 255' : '--',
                  style: const TextStyle(
                    color: AppTheme.darkOnSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: motion != null && motion.valid
                    ? (intensity / 255.0).clamp(0.0, 1.0)
                    : 0,
                minHeight: 10,
                backgroundColor: Colors.white.withValues(alpha: 0.05),
                valueColor: AlwaysStoppedAnimation<Color>(activityColor),
              ),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn(
                    'Average Intensity',
                    avgIntensity != null ? '$avgIntensity / 255' : '--'),
                _buildStatColumn(
                    'Peak Intensity',
                    maxIntensity != null ? '$maxIntensity / 255' : '--'),
                _buildStatColumn('Samples Logged', '${validHistory.length}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRawImuCard(BuildContext context, MotionReading? motion) {
    final theme = Theme.of(context);
    final isAvailable = motion != null && motion.valid;

    final ax = isAvailable ? motion.ax : null;
    final ay = isAvailable ? motion.ay : null;
    final az = isAvailable ? motion.az : null;

    final gx = isAvailable ? (motion.gx / 10.0) : null;
    final gy = isAvailable ? (motion.gy / 10.0) : null;
    final gz = isAvailable ? (motion.gz / 10.0) : null;

    final double? accelMagnitude = isAvailable
        ? math.sqrt((ax! * ax) + (ay! * ay) + (az! * az))
        : null;

    return Card(
      color: AppTheme.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppTheme.darkPrimary.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.sensors_rounded,
                  color: AppTheme.darkPrimary,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  'MPU6050 Raw 6-DOF Sensor Channels',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.darkOnSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'ACCELEROMETER (mg)',
              style: TextStyle(
                color: AppTheme.darkPrimary.withValues(alpha: 0.8),
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildSensorChannel('X', ax != null ? '${ax > 0 ? '+' : ''}$ax' : '--', 'mg')),
                const SizedBox(width: 8),
                Expanded(child: _buildSensorChannel('Y', ay != null ? '${ay > 0 ? '+' : ''}$ay' : '--', 'mg')),
                const SizedBox(width: 8),
                Expanded(child: _buildSensorChannel('Z', az != null ? '${az > 0 ? '+' : ''}$az' : '--', 'mg')),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Accel Vector |A|',
                    style: TextStyle(color: AppTheme.darkOnSurface, fontSize: 12),
                  ),
                  Text(
                    accelMagnitude != null ? '${accelMagnitude.toStringAsFixed(1)} mg' : '--',
                    style: const TextStyle(
                      color: AppTheme.darkPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 24),
            Text(
              'GYROSCOPE (deg/s)',
              style: TextStyle(
                color: AppTheme.darkPrimary.withValues(alpha: 0.8),
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildSensorChannel('X', gx != null ? gx.toStringAsFixed(1) : '--', '°/s')),
                const SizedBox(width: 8),
                Expanded(child: _buildSensorChannel('Y', gy != null ? gy.toStringAsFixed(1) : '--', '°/s')),
                const SizedBox(width: 8),
                Expanded(child: _buildSensorChannel('Z', gz != null ? gz.toStringAsFixed(1) : '--', '°/s')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorChannel(String axis, String value, String unit) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        children: [
          Text(
            axis,
            style: TextStyle(
              color: AppTheme.darkOnSurface.withValues(alpha: 0.5),
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.darkOnSurface,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              color: AppTheme.darkOnSurface.withValues(alpha: 0.4),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRangeSelector(
    BuildContext context,
    WidgetRef ref,
    Duration currentRange,
  ) {
    return Center(
      child: SegmentedButton<Duration>(
        segments: const [
          ButtonSegment(
            value: Duration(minutes: 15),
            label: Text('15 Min'),
          ),
          ButtonSegment(
            value: Duration(hours: 1),
            label: Text('1 Hour'),
          ),
          ButtonSegment(
            value: Duration(hours: 24),
            label: Text('24 Hours'),
          ),
        ],
        selected: {currentRange},
        onSelectionChanged: (newSelection) {
          ref.read(motionRangeProvider.notifier).state = newSelection.first;
        },
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppTheme.darkPrimary.withValues(alpha: 0.2);
            }
            return AppTheme.darkSurface;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppTheme.darkPrimary;
            }
            return AppTheme.darkOnSurface.withValues(alpha: 0.8);
          }),
        ),
      ),
    );
  }

  Widget _buildIntensityChartCard(
    BuildContext context,
    AsyncValue<List<MotionReading>> historyAsync,
    Duration range,
  ) {
    return Card(
      color: AppTheme.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.trending_up_rounded,
                  color: AppTheme.darkPrimary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Motion Intensity History',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.darkOnSurface,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 240,
              child: historyAsync.when(
                data: (history) => _buildChart(history, range),
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppTheme.darkPrimary),
                ),
                error: (e, _) => Center(
                  child: Text(
                    'Error loading history: $e',
                    style: const TextStyle(color: Color(0xFFEF5350)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(List<MotionReading> history, Duration range) {
    final validReadings = history.where((r) => r.valid).toList()
      ..sort((a, b) => a.tsReceived.compareTo(b.tsReceived));

    if (validReadings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.timeline_rounded,
              size: 40,
              color: AppTheme.darkOnSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 8),
            Text(
              'No valid motion readings in this period',
              style: TextStyle(
                color: AppTheme.darkOnSurface.withValues(alpha: 0.5),
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    // Gap handling: segment data when gap > 10s
    final List<List<MotionReading>> segments = [];
    List<MotionReading> currentSegment = [];

    for (int i = 0; i < validReadings.length; i++) {
      final reading = validReadings[i];
      if (currentSegment.isEmpty) {
        currentSegment.add(reading);
      } else {
        final prev = currentSegment.last;
        final gapSeconds =
            reading.tsReceived.difference(prev.tsReceived).inSeconds.abs();
        if (gapSeconds > 10) {
          segments.add(currentSegment);
          currentSegment = [reading];
        } else {
          currentSegment.add(reading);
        }
      }
    }
    if (currentSegment.isNotEmpty) {
      segments.add(currentSegment);
    }

    final lineBars = segments.map((segment) {
      final spots = segment.map((r) {
        return FlSpot(
          r.tsReceived.millisecondsSinceEpoch.toDouble(),
          r.intensity.toDouble(),
        );
      }).toList();

      return LineChartBarData(
        spots: spots,
        isCurved: segment.length > 2,
        color: const Color(0xFF00E676),
        barWidth: 2.2,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: segment.length == 1,
          getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
            radius: 4,
            color: const Color(0xFF00E676),
            strokeWidth: 1.5,
            strokeColor: AppTheme.darkBackground,
          ),
        ),
        belowBarData: BarAreaData(
          show: true,
          color: const Color(0xFF00E676).withValues(alpha: 0.12),
        ),
      );
    }).toList();

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 255,
        lineBarsData: lineBars,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 50,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.white.withValues(alpha: 0.05),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 50,
              reservedSize: 34,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    color: AppTheme.darkOnSurface.withValues(alpha: 0.5),
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              getTitlesWidget: (value, meta) {
                final date =
                    DateTime.fromMillisecondsSinceEpoch(value.toInt());
                final timeStr =
                    '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
                return Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    timeStr,
                    style: TextStyle(
                      color: AppTheme.darkOnSurface.withValues(alpha: 0.5),
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppTheme.darkSurface,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((barSpot) {
                final date =
                    DateTime.fromMillisecondsSinceEpoch(barSpot.x.toInt());
                final timeStr =
                    '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}';
                return LineTooltipItem(
                  'Intensity: ${barSpot.y.toInt()}/255\n$timeStr',
                  const TextStyle(
                    color: Color(0xFF00E676),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDisclaimerCard(BuildContext context) {
    return Card(
      color: AppTheme.darkSurface.withValues(alpha: 0.6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: Color(0xFFFFB74D),
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Motion and intensity measurements are estimated from the ESP32 Puck IMU sensors for general activity tracking. Not intended for fall detection, medical diagnosis, or emergency monitoring.',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: AppTheme.darkOnSurface.withValues(alpha: 0.65),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppTheme.darkOnSurface.withValues(alpha: 0.5),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.darkOnSurface,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  String _formatAge(DateTime ts) {
    final diff = DateTime.now().difference(ts);
    if (diff.isNegative || diff.inSeconds < 2) return 'just now';
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }
}
