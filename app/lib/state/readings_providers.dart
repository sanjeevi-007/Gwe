import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import 'ble_providers.dart';

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
