import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../state/state.dart';
import '../../widgets/stale_badge.dart';

class AiInsightsScreen extends ConsumerWidget {
  const AiInsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveAiAsync = ref.watch(latestAiResultProvider);
    final ai = liveAiAsync.valueOrNull;

    final historyAsync = ref.watch(aiHistoryProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('AI Motion Insights'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: _buildStaleBadge(ai),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        children: [
          _buildClassificationCard(context, ai),
          const SizedBox(height: 16),
          _buildArchitectureCard(context, ai),
          const SizedBox(height: 16),
          _buildConfidenceCard(context, ai),
          const SizedBox(height: 16),
          _buildRecentTimelineCard(context, historyAsync),
          const SizedBox(height: 16),
          _buildLimitationsCard(context),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  StaleBadge _buildStaleBadge(AiResult? ai) {
    if (ai == null || ai.label == AiLabel.unavailable) {
      return const StaleBadge(state: StaleState.unavailable);
    }
    if (ai.label == AiLabel.uncertain) {
      return const StaleBadge(state: StaleState.poorSignal);
    }
    if (!ai.isFresh(AppConstants.aiFreshnessSeconds)) {
      return const StaleBadge(state: StaleState.stale);
    }
    return const StaleBadge(state: StaleState.live);
  }

  Widget _buildClassificationCard(BuildContext context, AiResult? ai) {
    final theme = Theme.of(context);

    String labelText;
    IconData labelIcon;
    Color labelColor;

    if (ai == null || ai.label == AiLabel.unavailable) {
      labelText = 'Unavailable';
      labelIcon = Icons.help_outline_rounded;
      labelColor = AppTheme.darkOnSurface.withValues(alpha: 0.4);
    } else {
      switch (ai.label) {
        case AiLabel.stationary:
          labelText = 'Stationary';
          labelIcon = Icons.airline_seat_recline_normal_rounded;
          labelColor = const Color(0xFF64B5F6);
          break;
        case AiLabel.walkingLike:
          labelText = 'Walking-like Locomotion';
          labelIcon = Icons.directions_walk_rounded;
          labelColor = const Color(0xFF00E676);
          break;
        case AiLabel.vigorous:
          labelText = 'Vigorous Motion';
          labelIcon = Icons.directions_run_rounded;
          labelColor = const Color(0xFFFF9100);
          break;
        case AiLabel.uncertain:
          labelText = 'Uncertain Movement';
          labelIcon = Icons.question_mark_rounded;
          labelColor = const Color(0xFFFFD600);
          break;
        case AiLabel.unavailable:
          labelText = 'Unavailable';
          labelIcon = Icons.help_outline_rounded;
          labelColor = AppTheme.darkOnSurface.withValues(alpha: 0.4);
          break;
      }
    }

    // Critical Contract Rule: Until a trained model exists, label any rule-based motion result
    // "Motion estimate (rule-based)", never AI.
    String sourceBadgeText;
    Color sourceBadgeColor;
    if (ai == null || ai.source == AiSource.none) {
      sourceBadgeText = 'Model Inactive';
      sourceBadgeColor = const Color(0xFF9E9E9E);
    } else if (ai.source == AiSource.ruleBased) {
      sourceBadgeText = 'Motion estimate (rule-based)';
      sourceBadgeColor = const Color(0xFFFFB74D);
    } else {
      sourceBadgeText = 'Trained Model (TFLite Micro v${ai.modelVersion})';
      sourceBadgeColor = const Color(0xFF00E676);
    }

    final ageStr = ai != null ? _formatAge(ai.tsReceived) : '--';

    return Card(
      color: AppTheme.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: labelColor.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(labelIcon, color: labelColor, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Active Classification',
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
              labelText,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: labelColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: sourceBadgeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: sourceBadgeColor.withValues(alpha: 0.35),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    ai?.source == AiSource.trainedModel
                        ? Icons.psychology_rounded
                        : Icons.rule_rounded,
                    size: 16,
                    color: sourceBadgeColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    sourceBadgeText,
                    style: TextStyle(
                      color: sourceBadgeColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArchitectureCard(BuildContext context, AiResult? ai) {
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
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.memory_rounded,
                  color: AppTheme.darkPrimary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'On-Device Edge Architecture',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.darkOnSurface,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'GWEN operates with zero cloud inference. All sensor classification occurs locally on the ESP32 microcontroller firmware.',
              style: TextStyle(
                color: AppTheme.darkOnSurface.withValues(alpha: 0.7),
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildPipelineStep('1. MPU6050', '50 Hz IMU\nSamples')),
                const Icon(Icons.arrow_forward_rounded, size: 16, color: AppTheme.darkPrimary),
                Expanded(child: _buildPipelineStep('2. ESP32', 'On-Device\nClassifier')),
                const Icon(Icons.arrow_forward_rounded, size: 16, color: AppTheme.darkPrimary),
                Expanded(child: _buildPipelineStep('3. BLE Telemetry', 'Type 0x04\nPayload')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPipelineStep(String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.darkPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              color: AppTheme.darkOnSurface.withValues(alpha: 0.5),
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceCard(BuildContext context, AiResult? ai) {
    final score = ai?.score;
    final hasScore = score != null && score != 255;

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
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.speed_rounded,
                      color: AppTheme.darkPrimary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Confidence Metric',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.darkOnSurface,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                Text(
                  hasScore ? '$score%' : 'Rule Heuristic (N/A)',
                  style: TextStyle(
                    color: hasScore ? AppTheme.darkPrimary : AppTheme.darkOnSurface.withValues(alpha: 0.5),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: hasScore ? (score / 100.0).clamp(0.0, 1.0) : 0.0,
                minHeight: 8,
                backgroundColor: Colors.white.withValues(alpha: 0.05),
                valueColor: AlwaysStoppedAnimation<Color>(
                  hasScore && score >= 70
                      ? const Color(0xFF00E676)
                      : const Color(0xFFFF9100),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasScore
                  ? 'Gated inference: Predictions below threshold fallback honestly to Uncertain.'
                  : 'Rule-based motion classification relies on intensity thresholds rather than probabilistic softmax weights.',
              style: TextStyle(
                color: AppTheme.darkOnSurface.withValues(alpha: 0.5),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTimelineCard(
    BuildContext context,
    AsyncValue<List<AiResult>> historyAsync,
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
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.history_rounded,
                  color: AppTheme.darkPrimary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Classification Timeline',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.darkOnSurface,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            historyAsync.when(
              data: (history) {
                final recent = history.reversed.take(6).toList();
                if (recent.isEmpty) {
                  return Text(
                    'No classifications recorded yet.',
                    style: TextStyle(
                      color: AppTheme.darkOnSurface.withValues(alpha: 0.4),
                      fontSize: 12,
                    ),
                  );
                }
                return Column(
                  children: recent.map((r) {
                    final time = r.tsReceived;
                    final timeStr =
                        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            timeStr,
                            style: TextStyle(
                              color: AppTheme.darkOnSurface.withValues(alpha: 0.5),
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            r.label.name,
                            style: const TextStyle(
                              color: AppTheme.darkOnSurface,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            r.source == AiSource.trainedModel ? 'Trained' : 'Rule-based',
                            style: TextStyle(
                              color: r.source == AiSource.trainedModel
                                  ? const Color(0xFF00E676)
                                  : const Color(0xFFFFB74D),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, _) => Text(
                'Error loading timeline: $err',
                style: const TextStyle(color: Color(0xFFEF5350), fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLimitationsCard(BuildContext context) {
    return Card(
      color: AppTheme.darkSurface.withValues(alpha: 0.8),
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
                  Icons.warning_amber_rounded,
                  color: Color(0xFFFFB74D),
                  size: 22,
                ),
                SizedBox(width: 8),
                Text(
                  'Mandatory Limitations & Honest Disclosure',
                  style: TextStyle(
                    color: Color(0xFFFFB74D),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildLimitationItem(
              'Not a Medical Device',
              'GWEN provides general physical motion observation only. It is NOT capable of clinical diagnosis, medical status assessment, or physiological disorder detection.',
            ),
            _buildLimitationItem(
              'No Emergency or Fall Detection',
              'No safety guarantees, automated SOS, medical alerts, or fall event detection are supported. Never rely on GWEN for critical personal safety.',
            ),
            _buildLimitationItem(
              'Microcontroller Sensor Limitations',
              'Inference is computed from a wrist-mounted MPU6050 accelerometer and gyroscope. Hand tremors, vehicle motion, or passive arm swings may trigger ambiguous or uncertain classifications.',
            ),
            _buildLimitationItem(
              'Honest Fallback Protocol',
              'Whenever sensor readings are marginal, missing, or outside confident classification margins, GWEN honestly outputs Uncertain or Unavailable instead of displaying inaccurate predictions.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLimitationItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• $title',
            style: const TextStyle(
              color: AppTheme.darkOnSurface,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            description,
            style: TextStyle(
              color: AppTheme.darkOnSurface.withValues(alpha: 0.65),
              fontSize: 11,
              height: 1.35,
            ),
          ),
        ],
      ),
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
