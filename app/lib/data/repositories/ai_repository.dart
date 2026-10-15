import 'package:drift/drift.dart';

import '../../models/ai_result.dart';
import '../../models/enums.dart';
import '../database.dart';

class AiRepository {
  final AppDatabase db;

  AiRepository(this.db);

  AiResult _toDomain(AiResultData row) {
    return AiResult(
      id: row.id,
      deviceId: row.deviceId,
      tsDevice: row.tsDevice,
      tsReceived: row.tsReceived,
      label: AiLabel.fromRawValue(row.label),
      score: row.score,
      modelVersion: row.modelVersion,
      source: AiSource.fromRawValue(row.source),
      valid: row.valid,
    );
  }

  Future<int> insertAiResult(AiResult result) {
    return db.into(db.aiResults).insert(
          AiResultsCompanion.insert(
            deviceId: Value(result.deviceId),
            tsDevice: result.tsDevice,
            tsReceived: result.tsReceived,
            label: result.label.rawValue,
            score: Value(result.score),
            modelVersion: result.modelVersion,
            source: result.source.rawValue,
            valid: result.valid,
          ),
        );
  }

  Future<AiResult?> getLatestAiResult() async {
    final query = db.select(db.aiResults)
      ..orderBy([(t) => OrderingTerm.desc(t.tsReceived)])
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row != null ? _toDomain(row) : null;
  }

  Stream<AiResult?> watchLatestAiResult() {
    final query = db.select(db.aiResults)
      ..orderBy([(t) => OrderingTerm.desc(t.tsReceived)])
      ..limit(1);
    return query.watchSingleOrNull().map((row) => row != null ? _toDomain(row) : null);
  }

  Future<List<AiResult>> getAiHistory(DateTime start, DateTime end) async {
    final query = db.select(db.aiResults)
      ..where((t) =>
          t.tsReceived.isBiggerOrEqualValue(start) &
          t.tsReceived.isSmallerOrEqualValue(end))
      ..orderBy([(t) => OrderingTerm.asc(t.tsReceived)]);
    final rows = await query.get();
    return rows.map(_toDomain).toList();
  }

  Future<int> deleteAllAi() {
    return db.delete(db.aiResults).go();
  }
}
