import 'package:flutter/material.dart';

enum StaleState {
  live,
  stale,
  poorSignal,
  unavailable,
  unknown;

  String get label {
    switch (this) {
      case StaleState.live:
        return 'Live';
      case StaleState.stale:
        return 'Stale';
      case StaleState.poorSignal:
        return 'Signal poor';
      case StaleState.unavailable:
        return 'Unavailable';
      case StaleState.unknown:
        return 'Unknown';
    }
  }

  Color get color {
    switch (this) {
      case StaleState.live:
        return const Color(0xFF00E676); // Green
      case StaleState.stale:
        return const Color(0xFFFF9100); // Amber
      case StaleState.poorSignal:
        return const Color(0xFFFFD600); // Yellow
      case StaleState.unavailable:
        return const Color(0xFF94A3B8); // Muted Slate
      case StaleState.unknown:
        return const Color(0xFF64748B); // Dark Slate
    }
  }
}

class StaleBadge extends StatelessWidget {
  final StaleState state;

  const StaleBadge({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final color = state.color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            state.label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
