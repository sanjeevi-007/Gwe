import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../models/models.dart';
import '../../state/state.dart';
import '../ai_insights/ai_insights_screen.dart';
import '../location/location_screen.dart';
import '../motion/motion_screen.dart';
import '../pulse/pulse_screen.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRange = ref.watch(historyTabRangeProvider);

    final pulseHistoryAsync = ref.watch(pulseHistoryProvider);
    final motionHistoryAsync = ref.watch(motionHistoryProvider);
    final gpsHistoryAsync = ref.watch(gpsHistoryProvider);
    final missingPeriodsAsync = ref.watch(missingDataPeriodsProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('History & Telemetry Log'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        children: [
          _buildRangeSelector(context, ref, selectedRange),
          const SizedBox(height: 16),
          _buildQuickNavigationRow(context),
          const SizedBox(height: 16),
          _buildPulseAveragesCard(context, pulseHistoryAsync),
          const SizedBox(height: 16),
          _buildMotionAveragesCard(context, motionHistoryAsync),
          const SizedBox(height: 16),
          _buildGpsAveragesCard(context, gpsHistoryAsync),
          const SizedBox(height: 16),
          _buildMissingDataPeriodsCard(context, missingPeriodsAsync, selectedRange),
          const SizedBox(height: 24),
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
            value: Duration(hours: 1),
            label: Text('1 Hour'),
          ),
          ButtonSegment(
            value: Duration(hours: 24),
            label: Text('24 Hours'),
          ),
          ButtonSegment(
            value: Duration(days: 7),
            label: Text('7 Days'),
          ),
        ],
        selected: {currentRange},
        onSelectionChanged: (newSelection) {
          ref.read(historyTabRangeProvider.notifier).state = newSelection.first;
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

  Widget _buildQuickNavigationRow(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildNavChip(
            context,
            'Pulse Insights',
            Icons.favorite_rounded,
            AppTheme.darkPrimary,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PulseScreen()),
            ),
          ),
          const SizedBox(width: 8),
          _buildNavChip(
            context,
            'Motion & IMU',
            Icons.directions_run_rounded,
            const Color(0xFF00E676),
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MotionScreen()),
            ),
          ),
          const SizedBox(width: 8),
          _buildNavChip(
            context,
            'GPS Location',
            Icons.place_rounded,
            const Color(0xFF00B0FF),
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LocationScreen()),
            ),
          ),
          const SizedBox(width: 8),
          _buildNavChip(
            context,
            'AI Insights',
            Icons.psychology_rounded,
            const Color(0xFFFFB74D),
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AiInsightsScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavChip(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_forward_ios_rounded, size: 10, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildPulseAveragesCard(
    BuildContext context,
    AsyncValue<List<PulseReading>> historyAsync,
  ) {
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.favorite_rounded,
                      color: Color(0xFFFF5252),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Heart Rate Historical Averages',
                      style: TextStyle(
                        color: AppTheme.darkOnSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PulseScreen()),
                  ),
                  child: const Text('Chart >', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            historyAsync.when(
              data: (history) {
                final validReadings =
                    history.where((r) => r.valid && r.bpm != null).toList();
                if (validReadings.isEmpty) {
                  return _buildNoDataPlaceholder('No valid heart rate readings in this period');
                }

                final bpms = validReadings.map((r) => r.bpm!).toList();
                final avgBpm = (bpms.reduce((a, b) => a + b) / bpms.length).round();
                final minBpm = bpms.reduce(math.min);
                final maxBpm = bpms.reduce(math.max);

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCol('Average', '$avgBpm BPM', AppTheme.darkPrimary),
                    _buildStatCol('Minimum', '$minBpm BPM', const Color(0xFF64B5F6)),
                    _buildStatCol('Maximum', '$maxBpm BPM', const Color(0xFFFF9100)),
                    _buildStatCol('Valid Samples', '${validReadings.length}', AppTheme.darkOnSurface),
                  ],
                );
              },
              loading: () => const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator())),
              error: (e, _) => Text('Error: $e', style: const TextStyle(color: Color(0xFFEF5350))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMotionAveragesCard(
    BuildContext context,
    AsyncValue<List<MotionReading>> historyAsync,
  ) {
    return Card(
      color: AppTheme.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: const Color(0xFF00E676).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.directions_run_rounded,
                      color: Color(0xFF00E676),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Motion & Movement Summary',
                      style: TextStyle(
                        color: AppTheme.darkOnSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MotionScreen()),
                  ),
                  child: const Text('IMU >', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            historyAsync.when(
              data: (history) {
                final valid = history.where((r) => r.valid).toList();
                if (valid.isEmpty) {
                  return _buildNoDataPlaceholder('No motion samples logged in this period');
                }

                final intensities = valid.map((r) => r.intensity).toList();
                final avgIntensity = (intensities.reduce((a, b) => a + b) / intensities.length).round();
                final maxIntensity = intensities.reduce(math.max);

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCol('Avg Intensity', '$avgIntensity / 255', const Color(0xFF00E676)),
                    _buildStatCol('Peak Intensity', '$maxIntensity / 255', const Color(0xFFFF9100)),
                    _buildStatCol('Total Samples', '${valid.length}', AppTheme.darkOnSurface),
                  ],
                );
              },
              loading: () => const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator())),
              error: (e, _) => Text('Error: $e', style: const TextStyle(color: Color(0xFFEF5350))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGpsAveragesCard(
    BuildContext context,
    AsyncValue<List<GpsReading>> historyAsync,
  ) {
    return Card(
      color: AppTheme.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: const Color(0xFF00B0FF).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.place_rounded,
                      color: Color(0xFF00B0FF),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'GPS Availability & Lock Stats',
                      style: TextStyle(
                        color: AppTheme.darkOnSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LocationScreen()),
                  ),
                  child: const Text('GPS >', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            historyAsync.when(
              data: (history) {
                if (history.isEmpty) {
                  return _buildNoDataPlaceholder('No GPS fixes logged in this period');
                }

                final fixCount = history.where((r) => r.valid && r.fixState == GpsFixState.fix).length;
                final fixPct = ((fixCount / history.length) * 100).round();

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCol('Fix Ratio', '$fixPct%', const Color(0xFF00E676)),
                    _buildStatCol('Fixed Samples', '$fixCount', const Color(0xFF00B0FF)),
                    _buildStatCol('Total Pings', '${history.length}', AppTheme.darkOnSurface),
                  ],
                );
              },
              loading: () => const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator())),
              error: (e, _) => Text('Error: $e', style: const TextStyle(color: Color(0xFFEF5350))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissingDataPeriodsCard(
    BuildContext context,
    AsyncValue<List<MissingDataPeriod>> periodsAsync,
    Duration range,
  ) {
    return Card(
      color: AppTheme.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: Color(0xFFFFB74D),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.timelapse_rounded,
                  color: Color(0xFFFFB74D),
                  size: 22,
                ),
                SizedBox(width: 8),
                Text(
                  'Missing-Data & Dropouts Breakdown',
                  style: TextStyle(
                    color: Color(0xFFFFB74D),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Per GWEN contracts: Gaps are strictly tracked as missing data and never interpolated as zeros or fake readings.',
              style: TextStyle(
                color: AppTheme.darkOnSurface.withValues(alpha: 0.65),
                fontSize: 12,
              ),
            ),
            const Divider(height: 24),
            periodsAsync.when(
              data: (periods) {
                if (periods.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E676).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle_outline_rounded, color: Color(0xFF00E676), size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Continuous stream: Zero telemetry dropouts or gaps exceeding 10 seconds detected in this time window.',
                            style: TextStyle(color: Color(0xFF00E676), fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final totalGapSeconds = periods.map((p) => p.duration.inSeconds).reduce((a, b) => a + b);
                final totalGapDuration = Duration(seconds: totalGapSeconds);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Gap Periods: ${periods.length}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          Text(
                            'Missing Time: ${_formatDuration(totalGapDuration)}',
                            style: const TextStyle(color: Color(0xFFFFB74D), fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...periods.take(8).map((p) => _buildGapRow(p)),
                    if (periods.length > 8)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          '+ ${periods.length - 8} more gap events recorded',
                          style: TextStyle(color: AppTheme.darkOnSurface.withValues(alpha: 0.5), fontSize: 11),
                        ),
                      ),
                  ],
                );
              },
              loading: () => const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator())),
              error: (e, _) => Text('Error: $e', style: const TextStyle(color: Color(0xFFEF5350))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGapRow(MissingDataPeriod period) {
    final startStr =
        '${period.start.hour.toString().padLeft(2, '0')}:${period.start.minute.toString().padLeft(2, '0')}:${period.start.second.toString().padLeft(2, '0')}';
    final endStr =
        '${period.end.hour.toString().padLeft(2, '0')}:${period.end.minute.toString().padLeft(2, '0')}:${period.end.second.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 6.0),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          const Icon(Icons.link_off_rounded, size: 16, color: Color(0xFFFFB74D)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$startStr - $endStr (${_formatDuration(period.duration)})',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: AppTheme.darkOnSurface,
                  ),
                ),
                Text(
                  period.reason,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.darkOnSurface.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFFFB74D).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              period.metric,
              style: const TextStyle(
                color: Color(0xFFFFB74D),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCol(String label, String value, Color color) {
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
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildNoDataPlaceholder(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            color: AppTheme.darkOnSurface.withValues(alpha: 0.45),
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    if (d.inSeconds < 60) return '${d.inSeconds}s';
    if (d.inMinutes < 60) return '${d.inMinutes}m ${d.inSeconds % 60}s';
    return '${d.inHours}h ${d.inMinutes % 60}m';
  }
}
