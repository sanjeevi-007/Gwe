import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../data/database_sync_service.dart';
import '../data/repositories/repositories.dart';
import 'ble_providers.dart';

/// Database singleton provider.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() {
    db.close();
  });
  return db;
});

/// PulseRepository provider.
final pulseRepositoryProvider = Provider<PulseRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return PulseRepository(db);
});

/// MotionRepository provider.
final motionRepositoryProvider = Provider<MotionRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return MotionRepository(db);
});

/// GpsRepository provider.
final gpsRepositoryProvider = Provider<GpsRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return GpsRepository(db);
});

/// AiRepository provider.
final aiRepositoryProvider = Provider<AiRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return AiRepository(db);
});

/// SettingsRepository provider.
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return SettingsRepository(db);
});

/// DatabaseSyncService provider that listens to incoming parsed packets and auto-persists them.
final databaseSyncServiceProvider = Provider<DatabaseSyncService>((ref) {
  final db = ref.watch(databaseProvider);
  final pulseRepo = ref.watch(pulseRepositoryProvider);
  final motionRepo = ref.watch(motionRepositoryProvider);
  final gpsRepo = ref.watch(gpsRepositoryProvider);
  final aiRepo = ref.watch(aiRepositoryProvider);
  final bleService = ref.watch(bleServiceProvider);

  final syncService = DatabaseSyncService(
    db: db,
    pulseRepository: pulseRepo,
    motionRepository: motionRepo,
    gpsRepository: gpsRepo,
    aiRepository: aiRepo,
    packetStream: bleService.parsedPackets,
  );

  ref.onDispose(() {
    syncService.dispose();
  });

  return syncService;
});
