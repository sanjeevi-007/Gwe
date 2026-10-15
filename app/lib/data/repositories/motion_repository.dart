import 'package:drift/drift.dart';

import '../../models/motion_reading.dart';
import '../database.dart';

class MotionRepository {
  final AppDatabase db;

  MotionRepository(this.db);

  MotionReading _toDomain(MotionReadingData row) {
    return MotionReading(
      id: row.id,
      deviceId: row.deviceId,
      tsDevice: row.tsDevice,
      tsReceived: row.tsReceived,
      ax: row.ax,
      ay: row.ay,
      az: row.az,
      gx: row.gx,
      gy: row.gy,
      gz: row.gz,
      intensity: row.intensity,
      valid: row.valid,
    );
  }

  Future<int> insertMotion(MotionReading reading) {
    return db.into(db.motionReadings).insert(
          MotionReadingsCompanion.insert(
            deviceId: Value(reading.deviceId),
            tsDevice: reading.tsDevice,
            tsReceived: reading.tsReceived,
            ax: reading.ax,
            ay: reading.ay,
            az: reading.az,
            gx: reading.gx,
            gy: reading.gy,
            gz: reading.gz,
            intensity: reading.intensity,
            valid: reading.valid,
          ),
        );
  }

  Future<MotionReading?> getLatestMotion() async {
    final query = db.select(db.motionReadings)
      ..orderBy([(t) => OrderingTerm.desc(t.tsReceived)])
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row != null ? _toDomain(row) : null;
  }

  Stream<MotionReading?> watchLatestMotion() {
    final query = db.select(db.motionReadings)
      ..orderBy([(t) => OrderingTerm.desc(t.tsReceived)])
      ..limit(1);
    return query.watchSingleOrNull().map((row) => row != null ? _toDomain(row) : null);
  }

  Future<List<MotionReading>> getMotionHistory(DateTime start, DateTime end) async {
    final query = db.select(db.motionReadings)
      ..where((t) =>
          t.tsReceived.isBiggerOrEqualValue(start) &
          t.tsReceived.isSmallerOrEqualValue(end))
      ..orderBy([(t) => OrderingTerm.asc(t.tsReceived)]);
    final rows = await query.get();
    return rows.map(_toDomain).toList();
  }

  Future<int> deleteAllMotion() {
    return db.delete(db.motionReadings).go();
  }
}
