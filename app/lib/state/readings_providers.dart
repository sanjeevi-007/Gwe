import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import 'ble_providers.dart';
import 'sync_providers.dart';

/// Stream provider for the latest [PulseReading].
final latestPulseProvider = StreamProvider<PulseReading?>((ref) {
  final bleService = ref.watch(bleServiceProvider);
  return bleService.parsedPackets
      .where((pkt) => pkt.isSuccess && pkt.data is PulseReading)
      .map((pkt) => pkt.data as PulseReading);
});

/// Stream provider for the latest [MotionReading].
final latestMotionProvider = StreamProvider<MotionReading?>((ref) {
  final bleService = ref.watch(bleServiceProvider);
  return bleService.parsedPackets
      .where((pkt) => pkt.isSuccess && pkt.data is MotionReading)
      .map((pkt) => pkt.data as MotionReading);
});

/// Stream provider for the latest [GpsReading].
final latestGpsProvider = StreamProvider<GpsReading?>((ref) {
  final bleService = ref.watch(bleServiceProvider);
  return bleService.parsedPackets
      .where((pkt) => pkt.isSuccess && pkt.data is GpsReading)
      .map((pkt) => pkt.data as GpsReading);
});

/// Stream provider for the latest [AiResult].
final latestAiResultProvider = StreamProvider<AiResult?>((ref) {
  final bleService = ref.watch(bleServiceProvider);
  return bleService.parsedPackets
      .where((pkt) => pkt.isSuccess && pkt.data is AiResult)
      .map((pkt) => pkt.data as AiResult);
});

/// Stream provider for the latest [DeviceStatus].
final latestStatusProvider = StreamProvider<DeviceStatus?>((ref) {
  final bleService = ref.watch(bleServiceProvider);
  return bleService.parsedPackets
      .where((pkt) => pkt.isSuccess && pkt.data is DeviceStatus)
      .map((pkt) => pkt.data as DeviceStatus);
});

/// Selected time range for historical charts (defaults to 15 minutes).
final pulseRangeProvider = StateProvider<Duration>((ref) => const Duration(minutes: 15));

/// Future provider fetching historical pulse readings within the selected time window.
final pulseHistoryProvider = FutureProvider<List<PulseReading>>((ref) async {
  final pulseRepo = ref.watch(pulseRepositoryProvider);
  final range = ref.watch(pulseRangeProvider);

  final now = DateTime.now();
  final start = now.subtract(range);
  return pulseRepo.getPulseHistory(start, now);
});

/// Selected time range for historical motion charts.
final motionRangeProvider = StateProvider<Duration>((ref) => const Duration(minutes: 15));

/// Future provider fetching historical motion readings within the selected time window.
final motionHistoryProvider = FutureProvider<List<MotionReading>>((ref) async {
  final motionRepo = ref.watch(motionRepositoryProvider);
  final range = ref.watch(motionRangeProvider);

  final now = DateTime.now();
  final start = now.subtract(range);
  return motionRepo.getMotionHistory(start, now);
});

/// Selected time range for GPS history.
final gpsRangeProvider = StateProvider<Duration>((ref) => const Duration(hours: 1));

/// Future provider fetching historical GPS readings within the selected time window.
final gpsHistoryProvider = FutureProvider<List<GpsReading>>((ref) async {
  final gpsRepo = ref.watch(gpsRepositoryProvider);
  final range = ref.watch(gpsRangeProvider);

  final now = DateTime.now();
  final start = now.subtract(range);
  return gpsRepo.getGpsHistory(start, now);
});

/// Selected time range for AI classification history.
final aiRangeProvider = StateProvider<Duration>((ref) => const Duration(hours: 1));

/// Future provider fetching historical AI results within the selected time window.
final aiHistoryProvider = FutureProvider<List<AiResult>>((ref) async {
  final aiRepo = ref.watch(aiRepositoryProvider);
  final range = ref.watch(aiRangeProvider);

  final now = DateTime.now();
  final start = now.subtract(range);
  return aiRepo.getAiHistory(start, now);
});

/// Selected range for the comprehensive History & Insights screen.
final historyTabRangeProvider = StateProvider<Duration>((ref) => const Duration(hours: 24));

/// Domain model representing a gap in continuous telemetry stream (> 10s gap).
class MissingDataPeriod {
  final DateTime start;
  final DateTime end;
  final Duration duration;
  final String metric;
  final String reason;

  const MissingDataPeriod({
    required this.start,
    required this.end,
    required this.duration,
    required this.metric,
    required this.reason,
  });
}

/// Provider calculating missing telemetry periods and sensor dropouts in the selected history window.
final missingDataPeriodsProvider = FutureProvider<List<MissingDataPeriod>>((ref) async {
  final pulseRepo = ref.watch(pulseRepositoryProvider);
  final range = ref.watch(historyTabRangeProvider);

  final now = DateTime.now();
  final start = now.subtract(range);

  final pulseHistory = await pulseRepo.getPulseHistory(start, now);
  final List<MissingDataPeriod> periods = [];

  // Identify gaps in pulse readings > 10 seconds
  for (int i = 0; i < pulseHistory.length - 1; i++) {
    final cur = pulseHistory[i];
    final next = pulseHistory[i + 1];
    final diff = next.tsReceived.difference(cur.tsReceived);

    if (diff.inSeconds > 10) {
      String reason;
      if (cur.state == PulseState.noFinger) {
        reason = 'No finger contact on sensor';
      } else if (cur.state == PulseState.poorSignal) {
        reason = 'Poor optical signal / sensor decoupled';
      } else if (diff.inSeconds > 60) {
        reason = 'Link offline / BLE disconnected';
      } else {
        reason = 'Telemetry gap (${diff.inSeconds}s)';
      }

      periods.add(MissingDataPeriod(
        start: cur.tsReceived,
        end: next.tsReceived,
        duration: diff,
        metric: 'Pulse / Heart Rate',
        reason: reason,
      ));
    }
  }

  // Also check if data is completely missing up to `now`
  if (pulseHistory.isNotEmpty) {
    final lastTime = pulseHistory.last.tsReceived;
    final sinceLast = now.difference(lastTime);
    if (sinceLast.inSeconds > 30) {
      periods.add(MissingDataPeriod(
        start: lastTime,
        end: now,
        duration: sinceLast,
        metric: 'Puck Telemetry',
        reason: 'Current link idle / Puck offline',
      ));
    }
  }

  return periods;
});

