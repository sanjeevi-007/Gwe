import 'dart:async';

import 'package:drift/drift.dart';

import '../ble/ble.dart';
import '../models/models.dart';
import 'database.dart';
import 'repositories/repositories.dart';

/// Auto-persistence sync service that automatically routes and persists
/// valid parsed BLE packets into the local Drift SQLite database.
class DatabaseSyncService {
  final AppDatabase db;
  final PulseRepository pulseRepository;
  final MotionRepository motionRepository;
  final GpsRepository gpsRepository;
  final AiRepository aiRepository;
  final Stream<ParsedPacketResult> packetStream;

  StreamSubscription<ParsedPacketResult>? _subscription;

  DatabaseSyncService({
    required this.db,
    required this.pulseRepository,
    required this.motionRepository,
    required this.gpsRepository,
    required this.aiRepository,
    required this.packetStream,
    bool autoStart = true,
  }) {
    if (autoStart) {
      start();
    }
  }

  /// Whether the packet stream subscription is currently active.
  bool get isSubscribed => _subscription != null;

  /// Starts or resumes listening to the parsed BLE packet stream.
  void start() {
    _subscription?.cancel();
    _subscription = packetStream.listen(_handlePacket);
  }

  /// Handles incoming parsed packet and persists it to the appropriate repository.
  Future<void> _handlePacket(ParsedPacketResult result) async {
    if (!result.isSuccess || result.data == null) {
      return;
    }

    final data = result.data!;
    try {
      if (data is PulseReading) {
        await pulseRepository.insertPulse(data);
      } else if (data is MotionReading) {
        await motionRepository.insertMotion(data);
      } else if (data is GpsReading) {
        await gpsRepository.insertGps(data);
      } else if (data is AiResult) {
        await aiRepository.insertAiResult(data);
      } else if (data is DeviceStatus) {
        await _upsertDevice(data);
      }
    } catch (_) {
      // Safe fallback: never crash stream listener on storage write error
    }
  }

  /// Inserts or updates the device record in the Devices table.
  Future<void> _upsertDevice(DeviceStatus status) async {
    final devId = status.deviceId ?? 'GWEN-PUCK';
    final existing = await (db.select(db.devices)..where((t) => t.id.equals(devId)))
        .getSingleOrNull();

    if (existing == null) {
      await db.into(db.devices).insert(
            DevicesCompanion.insert(
              id: devId,
              name: 'GWEN Puck',
              bleId: devId,
              firmwareVersion: status.firmwareVersion,
              firstConnectedAt: status.tsReceived,
            ),
          );
    } else {
      await (db.update(db.devices)..where((t) => t.id.equals(devId))).write(
        DevicesCompanion(
          firmwareVersion: Value(status.firmwareVersion),
        ),
      );
    }
  }

  /// Cancels subscription and releases listener resources.
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
