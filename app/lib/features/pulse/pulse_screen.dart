import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../state/state.dart';
import '../../widgets/stale_badge.dart';

class PulseScreen extends ConsumerWidget {
  const PulseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final livePulseAsync = ref.watch(latestPulseProvider);
    final pulse = livePulseAsync.valueOrNull;

    final selectedRange = ref.watch(pulseRangeProvider);
    final historyAsync = ref.watch(pulseHistoryProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Pulse Insights'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: _buildStaleBadge(pulse),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        children: [
          _buildSummaryCard(context, pulse, historyAsync.valueOrNull ?? []),
          const SizedBox(height: 16),
          _buildRangeSelector(context, ref, selectedRange),
          const SizedBox(height: 16),
          _buildChartCard(context, historyAsync, selectedRange),
          const SizedBox(height: 16),
          _buildDisclaimerCard(context),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  StaleBadge _buildStaleBadge(PulseReading? pulse) {
    if (pulse == null) {
      return const StaleBadge(state: StaleState.unavailable);
    }
    if (pulse.state == PulseState.poorSignal) {
      return const StaleBadge(state: StaleState.poorSignal);
    }
    if (pulse.state == PulseState.noFinger ||
        pulse.state == PulseState.sensorError ||
        !pulse.valid) {
      return const StaleBadge(state: StaleState.unavailable);
    }
    if (!pulse.isFresh(AppConstants.pulseFreshnessSeconds)) {
      return const StaleBadge(state: StaleState.stale);
    }
    return const StaleBadge(state: StaleState.live);
  }

  Widget _buildSummaryCard(
    BuildContext context,
    PulseReading? pulse,
    List<PulseReading> history,
  ) {
    final theme = Theme.of(context);

    // Calculate historical statistics excluding invalid readings
    final validReadings =
        history.where((r) => r.valid && r.bpm != null).toList();
    final int? avgBpm = validReadings.isNotEmpty
        ? (validReadings.map((r) => r.bpm!).reduce((a, b) => a + b) /
                validReadings.length)
            .round()
        : null;
    final int? minBpm = validReadings.isNotEmpty
        ? validReadings.map((r) => r.bpm!).reduce(math.min)
        : null;
    final int? maxBpm = validReadings.isNotEmpty
        ? validReadings.map((r) => r.bpm!).reduce(math.max)
        : null;

    String primaryBpmText;
    Color primaryColor = AppTheme.darkPrimary;

    if (pulse == null) {
      primaryBpmText = 'Unavailable';
      primaryColor = AppTheme.darkOnSurface.withValues(alpha: 0.4);
    } else if (pulse.state == PulseState.noFinger) {
      primaryBpmText = 'No Finger';
      primaryColor = const Color(0xFFFF9100);
    } else if (pulse.state == PulseState.poorSignal) {
      primaryBpmText =
          pulse.bpm != null ? '${pulse.bpm} (Signal Poor)' : 'Signal Poor';
      primaryColor = const Color(0xFFFFD600);
    } else if (pulse.state == PulseState.sensorError) {
      primaryBpmText = 'Sensor Error';
      primaryColor = const Color(0xFFEF5350);
    } else if (pulse.bpm != null) {
      primaryBpmText = '${pulse.bpm} BPM';
      primaryColor = AppTheme.darkPrimary;
    } else {
      primaryBpmText = 'Unavailable';
      primaryColor = AppTheme.darkOnSurface.withValues(alpha: 0.4);
    }

    final ageStr = pulse != null ? _formatAge(pulse.tsReceived) : '--';

    return Card(
      color: AppTheme.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppTheme.darkPrimary.withValues(alpha: 0.2),
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
                  Icons.favorite_rounded,
                  color: Color(0xFFFF5252),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Current Heart Rate',
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
              primaryBpmText,
              style: theme.textTheme.displayMedium?.copyWith(
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _buildInfoBadge(
                  label: 'Signal Quality',
                  value: pulse != null ? '${pulse.quality}%' : '--',
                  color: pulse != null && pulse.quality > 50
                      ? const Color(0xFF00E676)
                      : const Color(0xFFFF9100),
                ),
                const SizedBox(width: 8),
                _buildInfoBadge(
                  label: 'State',
                  value: pulse != null ? pulse.state.name : '--',
                  color: pulse?.state == PulseState.valid
                      ? const Color(0xFF00E676)
                      : const Color(0xFFFF9100),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn('Average', avgBpm != null ? '$avgBpm BPM' : '--'),
                _buildStatColumn('Minimum', minBpm != null ? '$minBpm BPM' : '--'),
                _buildStatColumn('Maximum', maxBpm != null ? '$maxBpm BPM' : '--'),
              ],
            ),
          ],
        ),
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
          ref.read(pulseRangeProvider.notifier).state = newSelection.first;
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

  Widget _buildChartCard(
    BuildContext context,
    AsyncValue<List<PulseReading>> historyAsync,
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
                  Icons.show_chart_rounded,
                  color: AppTheme.darkPrimary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Heart Rate Trend',
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

  Widget _buildChart(List<PulseReading> history, Duration range) {
    // Exclude invalid or missing BPM readings
    final validReadings =
        history.where((r) => r.valid && r.bpm != null).toList();

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
              'No valid pulse readings in this period',
              style: TextStyle(
                color: AppTheme.darkOnSurface.withValues(alpha: 0.5),
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    // CRITICAL GAP HANDLING RULE:
    // Split readings into separate contiguous segments if consecutive readings have > 10s gap.
    final List<List<PulseReading>> segments = [];
    List<PulseReading> currentSegment = [];

    for (int i = 0; i < validReadings.length; i++) {
      final reading = validReadings[i];
      if (currentSegment.isEmpty) {
        currentSegment.add(reading);
      } else {
        final prev = currentSegment.last;
        final gapSeconds =
            reading.tsReceived.difference(prev.tsReceived).inSeconds;
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

    final allBpms = validReadings.map((r) => r.bpm!).toList();
    final double rawMinY = allBpms.reduce(math.min).toDouble();
    final double rawMaxY = allBpms.reduce(math.max).toDouble();

    final double minY = math.max(30.0, (rawMinY - 10).clamp(40.0, 180.0));
    final double maxY = math.min(220.0, (rawMaxY + 10).clamp(60.0, 200.0));

    final lineBars = segments.map((segment) {
      final spots = segment.map((r) {
        return FlSpot(
          r.tsReceived.millisecondsSinceEpoch.toDouble(),
          r.bpm!.toDouble(),
        );
      }).toList();

      return LineChartBarData(
        spots: spots,
        isCurved: segment.length > 2,
        color: AppTheme.darkPrimary,
        barWidth: 2.5,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: segment.length == 1,
          getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
            radius: 4,
            color: AppTheme.darkPrimary,
            strokeWidth: 1.5,
            strokeColor: AppTheme.darkBackground,
          ),
        ),
        belowBarData: BarAreaData(
          show: true,
          color: AppTheme.darkPrimary.withValues(alpha: 0.12),
        ),
      );
    }).toList();

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        lineBarsData: lineBars,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 20,
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
              interval: 30,
              reservedSize: 36,
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
                  '${barSpot.y.toInt()} BPM\n$timeStr',
                  const TextStyle(
                    color: AppTheme.darkPrimary,
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
                'Not a medical device. Heart rate measurements are for general fitness monitoring and trend observation only. No diagnosis, medical analysis, or emergency warnings are provided.',
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

  Widget _buildInfoBadge({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
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
