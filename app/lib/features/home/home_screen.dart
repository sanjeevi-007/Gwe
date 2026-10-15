import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../widgets/stale_badge.dart';
import '../../widgets/status_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('GWEN Dashboard'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: StaleBadge(state: StaleState.unavailable),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          StatusCard(
            title: 'Pulse',
            icon: Icons.favorite_rounded,
            staleState: StaleState.unavailable,
            content: Text(
              '-- BPM',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.darkPrimary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            footerText: 'MAX30102',
          ),
          const SizedBox(height: 12),
          StatusCard(
            title: 'Motion',
            icon: Icons.directions_run_rounded,
            staleState: StaleState.unavailable,
            content: Text(
              'Intensity: --',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.darkOnSurface,
                  ),
            ),
            footerText: 'MPU6050',
          ),
          const SizedBox(height: 12),
          StatusCard(
            title: 'Location',
            icon: Icons.location_on_rounded,
            staleState: StaleState.unavailable,
            content: Text(
              'No GPS Fix',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.darkOnSurface,
                  ),
            ),
            footerText: 'NEO-6M',
          ),
          const SizedBox(height: 12),
          StatusCard(
            title: 'AI Classification',
            icon: Icons.psychology_rounded,
            staleState: StaleState.unavailable,
            content: Text(
              'Unavailable',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.darkOnSurface,
                  ),
            ),
            footerText: 'On-device classifier',
          ),
        ],
      ),
    );
  }
}
