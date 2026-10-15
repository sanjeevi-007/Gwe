import '../database.dart';

class SettingsRepository {
  final AppDatabase db;

  SettingsRepository(this.db);

  Future<void> setSetting(String key, String value) {
    return db.into(db.appSettings).insertOnConflictUpdate(
          AppSettingsCompanion.insert(
            key: key,
            value: value,
          ),
        );
  }

  Future<String?> getSetting(String key) async {
    final query = db.select(db.appSettings)..where((t) => t.key.equals(key));
    final row = await query.getSingleOrNull();
    return row?.value;
  }

  Future<int> deleteAllSettings() {
    return db.delete(db.appSettings).go();
  }
}
