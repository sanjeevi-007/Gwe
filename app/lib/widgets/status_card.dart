import 'package:flutter/material.dart';

import '../core/theme.dart';
import 'stale_badge.dart';

class StatusCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget content;
  final StaleState staleState;
  final DateTime? timestamp;
  final String? footerText;

  const StatusCard({
    super.key,
    required this.title,
    required this.icon,
    required this.content,
    required this.staleState,
    this.timestamp,
    this.footerText,
  });

  String _formatRelativeAge(DateTime? ts) {
    if (ts == null) return '--';
    final diff = DateTime.now().difference(ts);
    if (diff.isNegative || diff.inSeconds < 2) return 'just now';
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnavailable =
        staleState == StaleState.unavailable || staleState == StaleState.unknown;

    return Card(
      color: AppTheme.darkSurface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: staleState.color.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Bar: Icon + Title and StaleBadge
            Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: AppTheme.darkPrimary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.darkOnSurface,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                StaleBadge(state: staleState),
              ],
            ),
            const SizedBox(height: 14),

            // Main Content Area: Honest fallback if unavailable/unknown
            if (isUnavailable)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  staleState == StaleState.unavailable
                      ? 'Unavailable'
                      : 'Unknown',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: AppTheme.darkOnSurface.withValues(alpha: 0.38),
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              content,

            const SizedBox(height: 12),

            // Bottom metadata: relative age & optional footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 13,
                      color: AppTheme.darkOnSurface.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatRelativeAge(timestamp),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.darkOnSurface.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                if (footerText != null)
                  Text(
                    footerText!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.darkOnSurface.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
