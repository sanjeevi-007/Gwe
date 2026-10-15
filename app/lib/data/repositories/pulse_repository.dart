import 'package:drift/drift.dart';

import '../../models/enums.dart';
import '../../models/pulse_reading.dart';
import '../database.dart';

class PulseRepository {
  final AppDatabase db;

  PulseRepository(this.db);

  PulseReading _toDomain(PulseReadingData row) {
    return PulseReading(
      id: row.id,
      deviceId: row.deviceId,
      tsDevice: row.tsDevice,
      tsReceived: row.tsReceived,
      bpm: row.bpm,
      quality: row.quality,
      state: PulseState.fromRawValue(row.state),
      valid: row.valid,
    );
  }

  Future<int> insertPulse(PulseReading reading) {
    return db.into(db.pulseReadings).insert(
          PulseReadingsCompanion.insert(
            deviceId: Value(reading.deviceId),
            tsDevice: reading.tsDevice,
            tsReceived: reading.tsReceived,
            bpm: Value(reading.bpm),
            quality: reading.quality,
            state: reading.state.rawValue,
            valid: reading.valid,
          ),
        );
  }

  Future<PulseReading?> getLatestPulse() async {
    final query = db.select(db.pulseReadings)
      ..orderBy([(t) => OrderingTerm.desc(t.tsReceived)])
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row != null ? _toDomain(row) : null;
  }

  Stream<PulseReading?> watchLatestPulse() {
    final query = db.select(db.pulseReadings)
      ..orderBy([(t) => OrderingTerm.desc(t.tsReceived)])
      ..limit(1);
    return query.watchSingleOrNull().map((row) => row != null ? _toDomain(row) : null);
  }

  Future<List<PulseReading>> getPulseHistory(DateTime start, DateTime end) async {
    final query = db.select(db.pulseReadings)
      ..where((t) =>
          t.tsReceived.isBiggerOrEqualValue(start) &
          t.tsReceived.isSmallerOrEqualValue(end))
      ..orderBy([(t) => OrderingTerm.asc(t.tsReceived)]);
    final rows = await query.get();
    return rows.map(_toDomain).toList();
  }

  Future<int> deleteAllPulse() {
    return db.delete(db.pulseReadings).go();
  }
}
