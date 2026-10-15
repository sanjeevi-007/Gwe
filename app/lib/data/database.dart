import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

// 1. Devices Table
@DataClassName('DeviceData')
class Devices extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get bleId => text()();
  TextColumn get firmwareVersion => text()();
  DateTimeColumn get firstConnectedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// 2. PulseReadings Table
@DataClassName('PulseReadingData')
class PulseReadings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get deviceId => text().nullable().references(Devices, #id)();
  DateTimeColumn get tsDevice => dateTime()();
  DateTimeColumn get tsReceived => dateTime()();
  IntColumn get bpm => integer().nullable()(); // NULL if invalid or missing, never 0
  IntColumn get quality => integer()();
  IntColumn get state => integer()();
  BoolColumn get valid => boolean()();
}

// 3. MotionReadings Table
@DataClassName('MotionReadingData')
class MotionReadings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get deviceId => text().nullable()();
  DateTimeColumn get tsDevice => dateTime()();
  DateTimeColumn get tsReceived => dateTime()();
  IntColumn get ax => integer()();
  IntColumn get ay => integer()();
  IntColumn get az => integer()();
  IntColumn get gx => integer()();
  IntColumn get gy => integer()();
  IntColumn get gz => integer()();
  IntColumn get intensity => integer()();
  BoolColumn get valid => boolean()();
}

// 4. GpsReadings Table
@DataClassName('GpsReadingData')
class GpsReadings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get deviceId => text().nullable()();
  DateTimeColumn get tsDevice => dateTime()();
  DateTimeColumn get tsReceived => dateTime()();
  IntColumn get fixState => integer()();
  RealColumn get lat => real().nullable()(); // NULL if invalid, never 0
  RealColumn get lon => real().nullable()(); // NULL if invalid, never 0
  IntColumn get satellites => integer()();
  RealColumn get hdop => real().nullable()();
  BoolColumn get valid => boolean()();
  BoolColumn get stale => boolean()();
}

// 5. AiResults Table
@DataClassName('AiResultData')
class AiResults extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get deviceId => text().nullable()();
  DateTimeColumn get tsDevice => dateTime()();
  DateTimeColumn get tsReceived => dateTime()();
  IntColumn get label => integer()();
  IntColumn get score => integer().nullable()(); // NULL if 255/invalid
  IntColumn get modelVersion => integer()();
  IntColumn get source => integer()();
  BoolColumn get valid => boolean()();
}

// 6. ConnectionEvents Table
@DataClassName('ConnectionEventData')
class ConnectionEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get deviceId => text().nullable()();
  DateTimeColumn get ts => dateTime()();
  TextColumn get event => text()();
  TextColumn get reason => text().nullable()();
}

// 7. AppSettings Table
@DataClassName('AppSettingData')
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [
  Devices,
  PulseReadings,
  MotionReadings,
  GpsReadings,
  AiResults,
  ConnectionEvents,
  AppSettings,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'gwen.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
