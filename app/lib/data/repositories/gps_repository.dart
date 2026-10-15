import 'package:drift/drift.dart';

import '../../models/enums.dart';
import '../../models/gps_reading.dart';
import '../database.dart';

class GpsRepository {
  final AppDatabase db;

  GpsRepository(this.db);

  GpsReading _toDomain(GpsReadingData row) {
    return GpsReading(
      id: row.id,
      deviceId: row.deviceId,
      tsDevice: row.tsDevice,
      tsReceived: row.tsReceived,
      fixState: GpsFixState.fromRawValue(row.fixState),
      lat: row.lat,
      lon: row.lon,
      satellites: row.satellites,
      hdop: row.hdop,
      valid: row.valid,
      stale: row.stale,
    );
  }

  Future<int> insertGps(GpsReading reading) {
    return db.into(db.gpsReadings).insert(
          GpsReadingsCompanion.insert(
            deviceId: Value(reading.deviceId),
            tsDevice: reading.tsDevice,
            tsReceived: reading.tsReceived,
            fixState: reading.fixState.rawValue,
            lat: Value(reading.lat),
            lon: Value(reading.lon),
            satellites: reading.satellites,
            hdop: Value(reading.hdop),
            valid: reading.valid,
            stale: reading.stale,
          ),
        );
  }

  Future<GpsReading?> getLatestGps() async {
    final query = db.select(db.gpsReadings)
      ..orderBy([(t) => OrderingTerm.desc(t.tsReceived)])
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row != null ? _toDomain(row) : null;
  }

  Stream<GpsReading?> watchLatestGps() {
    final query = db.select(db.gpsReadings)
      ..orderBy([(t) => OrderingTerm.desc(t.tsReceived)])
      ..limit(1);
    return query.watchSingleOrNull().map((row) => row != null ? _toDomain(row) : null);
  }

  Future<List<GpsReading>> getGpsHistory(DateTime start, DateTime end) async {
    final query = db.select(db.gpsReadings)
      ..where((t) =>
          t.tsReceived.isBiggerOrEqualValue(start) &
          t.tsReceived.isSmallerOrEqualValue(end))
      ..orderBy([(t) => OrderingTerm.asc(t.tsReceived)]);
    final rows = await query.get();
    return rows.map(_toDomain).toList();
  }

  Future<int> deleteAllGps() {
    return db.delete(db.gpsReadings).go();
  }
}
