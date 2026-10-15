import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../state/state.dart';
import '../../widgets/stale_badge.dart';

/// The 6 canonical GPS states for GWEN offline location monitor.
enum GpsDisplayState {
  searching,
  fix,
  weak,
  noFix,
  disconnected,
  staleOrUnavailable,
}

class LocationScreen extends ConsumerWidget {
  const LocationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveGpsAsync = ref.watch(latestGpsProvider);
    final gps = liveGpsAsync.valueOrNull;

    final historyAsync = ref.watch(gpsHistoryProvider);

    final displayState = _evaluateGpsState(gps);

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Location & GPS'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: _buildStaleBadge(gps, displayState),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        children: [
          _buildActiveStateBanner(context, displayState, gps),
          const SizedBox(height: 16),
          _buildCoordinatesCard(context, gps, displayState),
          const SizedBox(height: 16),
          _buildAccuracyAndSatsCard(context, gps, displayState),
          const SizedBox(height: 16),
          _buildSixStatesLegendCard(context, displayState),
          const SizedBox(height: 16),
          _buildRecentFixesCard(context, historyAsync),
          const SizedBox(height: 16),
          _buildPrivacyCard(context),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  GpsDisplayState _evaluateGpsState(GpsReading? gps) {
    if (gps == null) return GpsDisplayState.staleOrUnavailable;
    if (gps.fixState == GpsFixState.disconnected) {
      return GpsDisplayState.disconnected;
    }
    if (gps.stale || !gps.isFresh(AppConstants.gpsFreshnessSeconds)) {
      return GpsDisplayState.staleOrUnavailable;
    }
    switch (gps.fixState) {
      case GpsFixState.fix:
        return GpsDisplayState.fix;
      case GpsFixState.weak:
        return GpsDisplayState.weak;
      case GpsFixState.searching:
        return GpsDisplayState.searching;
      case GpsFixState.noFix:
        return GpsDisplayState.noFix;
      case GpsFixState.disconnected:
        return GpsDisplayState.disconnected;
    }
  }

  StaleBadge _buildStaleBadge(GpsReading? gps, GpsDisplayState state) {
    if (state == GpsDisplayState.disconnected ||
        state == GpsDisplayState.staleOrUnavailable && gps == null) {
      return const StaleBadge(state: StaleState.unavailable);
    }
    if (state == GpsDisplayState.staleOrUnavailable) {
      return const StaleBadge(state: StaleState.stale);
    }
    if (state == GpsDisplayState.weak) {
      return const StaleBadge(state: StaleState.poorSignal);
    }
    return const StaleBadge(state: StaleState.live);
  }

  Widget _buildActiveStateBanner(
    BuildContext context,
    GpsDisplayState state,
    GpsReading? gps,
  ) {
    final theme = Theme.of(context);

    Color stateColor;
    IconData stateIcon;
    String stateTitle;
    String stateSubtitle;

    switch (state) {
      case GpsDisplayState.fix:
        stateColor = const Color(0xFF00E676);
        stateIcon = Icons.gps_fixed_rounded;
        stateTitle = 'State 2/6: 3D GPS Fix Active';
        stateSubtitle = 'Acquired valid satellite lock with precise coordinates.';
        break;
      case GpsDisplayState.weak:
        stateColor = const Color(0xFFFFD600);
        stateIcon = Icons.gps_not_fixed_rounded;
        stateTitle = 'State 3/6: Weak GPS Fix';
        stateSubtitle = 'Degraded satellite geometry or marginal signal accuracy.';
        break;
      case GpsDisplayState.searching:
        stateColor = const Color(0xFF00B0FF);
        stateIcon = Icons.radar_rounded;
        stateTitle = 'State 1/6: Searching for Satellites';
        stateSubtitle = 'Acquiring orbital ephemeris data. Maintain open sky view.';
        break;
      case GpsDisplayState.noFix:
        stateColor = const Color(0xFFFF9100);
        stateIcon = Icons.location_searching_rounded;
        stateTitle = 'State 4/6: No Satellite Lock';
        stateSubtitle = 'Signal obstructed by buildings, dense canopy, or indoor roof.';
        break;
      case GpsDisplayState.disconnected:
        stateColor = const Color(0xFFEF5350);
        stateIcon = Icons.gps_off_rounded;
        stateTitle = 'State 5/6: GPS Receiver Disconnected';
        stateSubtitle = 'NEO-6M hardware communication failure or module offline.';
        break;
      case GpsDisplayState.staleOrUnavailable:
        stateColor = const Color(0xFF9E9E9E);
        stateIcon = Icons.timer_outlined;
        stateTitle = 'State 6/6: Stale / Unavailable';
        stateSubtitle = gps != null
            ? 'Fix timestamp is older than 30s freshness threshold.'
            : 'No GPS telemetry packet received yet from Puck.';
        break;
    }

    final ageStr = gps != null ? _formatAge(gps.tsReceived) : '--';

    return Card(
      color: AppTheme.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: stateColor.withValues(alpha: 0.35),
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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: stateColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(stateIcon, color: stateColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stateTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: stateColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        stateSubtitle,
                        style: TextStyle(
                          color: AppTheme.darkOnSurface.withValues(alpha: 0.65),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  ageStr,
                  style: TextStyle(
                    color: AppTheme.darkOnSurface.withValues(alpha: 0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoordinatesCard(
    BuildContext context,
    GpsReading? gps,
    GpsDisplayState state,
  ) {
    final theme = Theme.of(context);
    final hasCoords =
        gps != null && gps.valid && gps.lat != null && gps.lon != null;

    final latStr = hasCoords ? '${gps.lat!.toStringAsFixed(6)}°' : '--';
    final lonStr = hasCoords ? '${gps.lon!.toStringAsFixed(6)}°' : '--';

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
                  Icons.place_rounded,
                  color: AppTheme.darkPrimary,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  'Local Geographic Position',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.darkOnSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildCoordinateBox(
                    label: 'LATITUDE',
                    value: latStr,
                    isAvailable: hasCoords,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildCoordinateBox(
                    label: 'LONGITUDE',
                    value: lonStr,
                    isAvailable: hasCoords,
                  ),
                ),
              ],
            ),
            if (!hasCoords)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                  state == GpsDisplayState.searching
                      ? 'Waiting for satellite triangulation...'
                      : 'Honest state: Coordinates withheld while GPS lock is unavailable.',
                  style: TextStyle(
                    color: AppTheme.darkOnSurface.withValues(alpha: 0.45),
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoordinateBox({
    required String label,
    required String value,
    required bool isAvailable,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppTheme.darkPrimary.withValues(alpha: 0.8),
              fontWeight: FontWeight.bold,
              fontSize: 10,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: isAvailable
                  ? AppTheme.darkOnSurface
                  : AppTheme.darkOnSurface.withValues(alpha: 0.35),
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccuracyAndSatsCard(
    BuildContext context,
    GpsReading? gps,
    GpsDisplayState state,
  ) {
    final sats = gps?.satellites ?? 0;
    final hdop = gps?.hdop;

    String hdopRating;
    Color hdopColor;
    if (hdop == null) {
      hdopRating = 'N/A';
      hdopColor = AppTheme.darkOnSurface.withValues(alpha: 0.4);
    } else if (hdop < 1.0) {
      hdopRating = 'Ideal (<1.0)';
      hdopColor = const Color(0xFF00E676);
    } else if (hdop <= 2.0) {
      hdopRating = 'Excellent (1-2)';
      hdopColor = const Color(0xFF00E676);
    } else if (hdop <= 5.0) {
      hdopRating = 'Good (2-5)';
      hdopColor = const Color(0xFF64B5F6);
    } else if (hdop <= 10.0) {
      hdopRating = 'Moderate (5-10)';
      hdopColor = const Color(0xFFFF9100);
    } else {
      hdopRating = 'Poor (>10)';
      hdopColor = const Color(0xFFEF5350);
    }

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
                  Icons.satellite_alt_rounded,
                  color: AppTheme.darkPrimary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Signal Quality & Geometry',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.darkOnSurface,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Satellites Tracked',
                        style: TextStyle(
                          color: AppTheme.darkOnSurface.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '$sats',
                            style: const TextStyle(
                              color: AppTheme.darkOnSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            sats >= 4 ? '(Lock capable)' : '(Need >= 4)',
                            style: TextStyle(
                              color: sats >= 4
                                  ? const Color(0xFF00E676)
                                  : const Color(0xFFFF9100),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HDOP Accuracy',
                        style: TextStyle(
                          color: AppTheme.darkOnSurface.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hdop != null ? hdop.toStringAsFixed(1) : '--',
                        style: TextStyle(
                          color: hdopColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      Text(
                        hdopRating,
                        style: TextStyle(
                          color: hdopColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSixStatesLegendCard(
    BuildContext context,
    GpsDisplayState currentState,
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
                  Icons.list_alt_rounded,
                  color: AppTheme.darkPrimary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '6-State GPS Protocol Specification',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.darkOnSurface,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStateRow('1. Searching', 'Sats < 4, acquiring ephemeris', const Color(0xFF00B0FF),
                currentState == GpsDisplayState.searching),
            _buildStateRow('2. Fix (3D/2D)', 'Sats >= 4, valid coordinates', const Color(0xFF00E676),
                currentState == GpsDisplayState.fix),
            _buildStateRow('3. Weak', 'Marginal geometry / high HDOP', const Color(0xFFFFD600),
                currentState == GpsDisplayState.weak),
            _buildStateRow('4. No Fix', 'Sky obscured or indoor', const Color(0xFFFF9100),
                currentState == GpsDisplayState.noFix),
            _buildStateRow('5. Disconnected', 'NEO-6M hardware bus error', const Color(0xFFEF5350),
                currentState == GpsDisplayState.disconnected),
            _buildStateRow('6. Stale / Unavailable', 'Data > 30s old or disconnected', const Color(0xFF9E9E9E),
                currentState == GpsDisplayState.staleOrUnavailable),
          ],
        ),
      ),
    );
  }

  Widget _buildStateRow(
      String title, String desc, Color color, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isActive
            ? color.withValues(alpha: 0.12)
            : Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive ? color.withValues(alpha: 0.4) : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isActive ? color : AppTheme.darkOnSurface,
                    fontWeight:
                        isActive ? FontWeight.bold : FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                Text(
                  desc,
                  style: TextStyle(
                    color: AppTheme.darkOnSurface.withValues(alpha: 0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'CURRENT',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 9,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecentFixesCard(
    BuildContext context,
    AsyncValue<List<GpsReading>> historyAsync,
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
                  'Recent Location Fixes',
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
                final validPoints = history.where((r) => r.valid && r.lat != null).toList().reversed.take(5).toList();
                if (validPoints.isEmpty) {
                  return Text(
                    'No valid fixes logged in current window.',
                    style: TextStyle(
                      color: AppTheme.darkOnSurface.withValues(alpha: 0.4),
                      fontSize: 12,
                    ),
                  );
                }
                return Column(
                  children: validPoints.map((pt) {
                    final time = pt.tsReceived;
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
                            '${pt.lat!.toStringAsFixed(5)}, ${pt.lon!.toStringAsFixed(5)}',
                            style: const TextStyle(
                              color: AppTheme.darkOnSurface,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${pt.satellites} sats',
                            style: const TextStyle(
                              color: Color(0xFF00E676),
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
                'Error loading fixes: $err',
                style: const TextStyle(color: Color(0xFFEF5350), fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyCard(BuildContext context) {
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
              Icons.shield_outlined,
              color: Color(0xFF00E676),
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Offline Privacy Guarantee: All GPS coordinates remain strictly stored in local device SQLite memory. Coordinates are never transmitted over the internet or uploaded to any remote server.',
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

  String _formatAge(DateTime ts) {
    final diff = DateTime.now().difference(ts);
    if (diff.isNegative || diff.inSeconds < 2) return 'just now';
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }
}
