// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $DevicesTable extends Devices with TableInfo<$DevicesTable, DeviceData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DevicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bleIdMeta = const VerificationMeta('bleId');
  @override
  late final GeneratedColumn<String> bleId = GeneratedColumn<String>(
      'ble_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _firmwareVersionMeta =
      const VerificationMeta('firmwareVersion');
  @override
  late final GeneratedColumn<String> firmwareVersion = GeneratedColumn<String>(
      'firmware_version', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _firstConnectedAtMeta =
      const VerificationMeta('firstConnectedAt');
  @override
  late final GeneratedColumn<DateTime> firstConnectedAt =
      GeneratedColumn<DateTime>('first_connected_at', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, bleId, firmwareVersion, firstConnectedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'devices';
  @override
  VerificationContext validateIntegrity(Insertable<DeviceData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('ble_id')) {
      context.handle(
          _bleIdMeta, bleId.isAcceptableOrUnknown(data['ble_id']!, _bleIdMeta));
    } else if (isInserting) {
      context.missing(_bleIdMeta);
    }
    if (data.containsKey('firmware_version')) {
      context.handle(
          _firmwareVersionMeta,
          firmwareVersion.isAcceptableOrUnknown(
              data['firmware_version']!, _firmwareVersionMeta));
    } else if (isInserting) {
      context.missing(_firmwareVersionMeta);
    }
    if (data.containsKey('first_connected_at')) {
      context.handle(
          _firstConnectedAtMeta,
          firstConnectedAt.isAcceptableOrUnknown(
              data['first_connected_at']!, _firstConnectedAtMeta));
    } else if (isInserting) {
      context.missing(_firstConnectedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DeviceData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeviceData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      bleId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ble_id'])!,
      firmwareVersion: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}firmware_version'])!,
      firstConnectedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}first_connected_at'])!,
    );
  }

  @override
  $DevicesTable createAlias(String alias) {
    return $DevicesTable(attachedDatabase, alias);
  }
}

class DeviceData extends DataClass implements Insertable<DeviceData> {
  final String id;
  final String name;
  final String bleId;
  final String firmwareVersion;
  final DateTime firstConnectedAt;
  const DeviceData(
      {required this.id,
      required this.name,
      required this.bleId,
      required this.firmwareVersion,
      required this.firstConnectedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['ble_id'] = Variable<String>(bleId);
    map['firmware_version'] = Variable<String>(firmwareVersion);
    map['first_connected_at'] = Variable<DateTime>(firstConnectedAt);
    return map;
  }

  DevicesCompanion toCompanion(bool nullToAbsent) {
    return DevicesCompanion(
      id: Value(id),
      name: Value(name),
      bleId: Value(bleId),
      firmwareVersion: Value(firmwareVersion),
      firstConnectedAt: Value(firstConnectedAt),
    );
  }

  factory DeviceData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeviceData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      bleId: serializer.fromJson<String>(json['bleId']),
      firmwareVersion: serializer.fromJson<String>(json['firmwareVersion']),
      firstConnectedAt: serializer.fromJson<DateTime>(json['firstConnectedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'bleId': serializer.toJson<String>(bleId),
      'firmwareVersion': serializer.toJson<String>(firmwareVersion),
      'firstConnectedAt': serializer.toJson<DateTime>(firstConnectedAt),
    };
  }

  DeviceData copyWith(
          {String? id,
          String? name,
          String? bleId,
          String? firmwareVersion,
          DateTime? firstConnectedAt}) =>
      DeviceData(
        id: id ?? this.id,
        name: name ?? this.name,
        bleId: bleId ?? this.bleId,
        firmwareVersion: firmwareVersion ?? this.firmwareVersion,
        firstConnectedAt: firstConnectedAt ?? this.firstConnectedAt,
      );
  DeviceData copyWithCompanion(DevicesCompanion data) {
    return DeviceData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      bleId: data.bleId.present ? data.bleId.value : this.bleId,
      firmwareVersion: data.firmwareVersion.present
          ? data.firmwareVersion.value
          : this.firmwareVersion,
      firstConnectedAt: data.firstConnectedAt.present
          ? data.firstConnectedAt.value
          : this.firstConnectedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeviceData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('bleId: $bleId, ')
          ..write('firmwareVersion: $firmwareVersion, ')
          ..write('firstConnectedAt: $firstConnectedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, bleId, firmwareVersion, firstConnectedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeviceData &&
          other.id == this.id &&
          other.name == this.name &&
          other.bleId == this.bleId &&
          other.firmwareVersion == this.firmwareVersion &&
          other.firstConnectedAt == this.firstConnectedAt);
}

class DevicesCompanion extends UpdateCompanion<DeviceData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> bleId;
  final Value<String> firmwareVersion;
  final Value<DateTime> firstConnectedAt;
  final Value<int> rowid;
  const DevicesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.bleId = const Value.absent(),
    this.firmwareVersion = const Value.absent(),
    this.firstConnectedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DevicesCompanion.insert({
    required String id,
    required String name,
    required String bleId,
    required String firmwareVersion,
    required DateTime firstConnectedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        bleId = Value(bleId),
        firmwareVersion = Value(firmwareVersion),
        firstConnectedAt = Value(firstConnectedAt);
  static Insertable<DeviceData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? bleId,
    Expression<String>? firmwareVersion,
    Expression<DateTime>? firstConnectedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (bleId != null) 'ble_id': bleId,
      if (firmwareVersion != null) 'firmware_version': firmwareVersion,
      if (firstConnectedAt != null) 'first_connected_at': firstConnectedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DevicesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? bleId,
      Value<String>? firmwareVersion,
      Value<DateTime>? firstConnectedAt,
      Value<int>? rowid}) {
    return DevicesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      bleId: bleId ?? this.bleId,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      firstConnectedAt: firstConnectedAt ?? this.firstConnectedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (bleId.present) {
      map['ble_id'] = Variable<String>(bleId.value);
    }
    if (firmwareVersion.present) {
      map['firmware_version'] = Variable<String>(firmwareVersion.value);
    }
    if (firstConnectedAt.present) {
      map['first_connected_at'] = Variable<DateTime>(firstConnectedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DevicesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('bleId: $bleId, ')
          ..write('firmwareVersion: $firmwareVersion, ')
          ..write('firstConnectedAt: $firstConnectedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PulseReadingsTable extends PulseReadings
    with TableInfo<$PulseReadingsTable, PulseReadingData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PulseReadingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES devices (id)'));
  static const VerificationMeta _tsDeviceMeta =
      const VerificationMeta('tsDevice');
  @override
  late final GeneratedColumn<DateTime> tsDevice = GeneratedColumn<DateTime>(
      'ts_device', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _tsReceivedMeta =
      const VerificationMeta('tsReceived');
  @override
  late final GeneratedColumn<DateTime> tsReceived = GeneratedColumn<DateTime>(
      'ts_received', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _bpmMeta = const VerificationMeta('bpm');
  @override
  late final GeneratedColumn<int> bpm = GeneratedColumn<int>(
      'bpm', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _qualityMeta =
      const VerificationMeta('quality');
  @override
  late final GeneratedColumn<int> quality = GeneratedColumn<int>(
      'quality', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<int> state = GeneratedColumn<int>(
      'state', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _validMeta = const VerificationMeta('valid');
  @override
  late final GeneratedColumn<bool> valid = GeneratedColumn<bool>(
      'valid', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("valid" IN (0, 1))'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, deviceId, tsDevice, tsReceived, bpm, quality, state, valid];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pulse_readings';
  @override
  VerificationContext validateIntegrity(Insertable<PulseReadingData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    }
    if (data.containsKey('ts_device')) {
      context.handle(_tsDeviceMeta,
          tsDevice.isAcceptableOrUnknown(data['ts_device']!, _tsDeviceMeta));
    } else if (isInserting) {
      context.missing(_tsDeviceMeta);
    }
    if (data.containsKey('ts_received')) {
      context.handle(
          _tsReceivedMeta,
          tsReceived.isAcceptableOrUnknown(
              data['ts_received']!, _tsReceivedMeta));
    } else if (isInserting) {
      context.missing(_tsReceivedMeta);
    }
    if (data.containsKey('bpm')) {
      context.handle(
          _bpmMeta, bpm.isAcceptableOrUnknown(data['bpm']!, _bpmMeta));
    }
    if (data.containsKey('quality')) {
      context.handle(_qualityMeta,
          quality.isAcceptableOrUnknown(data['quality']!, _qualityMeta));
    } else if (isInserting) {
      context.missing(_qualityMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
          _stateMeta, state.isAcceptableOrUnknown(data['state']!, _stateMeta));
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('valid')) {
      context.handle(
          _validMeta, valid.isAcceptableOrUnknown(data['valid']!, _validMeta));
    } else if (isInserting) {
      context.missing(_validMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PulseReadingData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PulseReadingData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id']),
      tsDevice: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}ts_device'])!,
      tsReceived: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}ts_received'])!,
      bpm: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}bpm']),
      quality: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quality'])!,
      state: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}state'])!,
      valid: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}valid'])!,
    );
  }

  @override
  $PulseReadingsTable createAlias(String alias) {
    return $PulseReadingsTable(attachedDatabase, alias);
  }
}

class PulseReadingData extends DataClass
    implements Insertable<PulseReadingData> {
  final int id;
  final String? deviceId;
  final DateTime tsDevice;
  final DateTime tsReceived;
  final int? bpm;
  final int quality;
  final int state;
  final bool valid;
  const PulseReadingData(
      {required this.id,
      this.deviceId,
      required this.tsDevice,
      required this.tsReceived,
      this.bpm,
      required this.quality,
      required this.state,
      required this.valid});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['ts_device'] = Variable<DateTime>(tsDevice);
    map['ts_received'] = Variable<DateTime>(tsReceived);
    if (!nullToAbsent || bpm != null) {
      map['bpm'] = Variable<int>(bpm);
    }
    map['quality'] = Variable<int>(quality);
    map['state'] = Variable<int>(state);
    map['valid'] = Variable<bool>(valid);
    return map;
  }

  PulseReadingsCompanion toCompanion(bool nullToAbsent) {
    return PulseReadingsCompanion(
      id: Value(id),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      tsDevice: Value(tsDevice),
      tsReceived: Value(tsReceived),
      bpm: bpm == null && nullToAbsent ? const Value.absent() : Value(bpm),
      quality: Value(quality),
      state: Value(state),
      valid: Value(valid),
    );
  }

  factory PulseReadingData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PulseReadingData(
      id: serializer.fromJson<int>(json['id']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      tsDevice: serializer.fromJson<DateTime>(json['tsDevice']),
      tsReceived: serializer.fromJson<DateTime>(json['tsReceived']),
      bpm: serializer.fromJson<int?>(json['bpm']),
      quality: serializer.fromJson<int>(json['quality']),
      state: serializer.fromJson<int>(json['state']),
      valid: serializer.fromJson<bool>(json['valid']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deviceId': serializer.toJson<String?>(deviceId),
      'tsDevice': serializer.toJson<DateTime>(tsDevice),
      'tsReceived': serializer.toJson<DateTime>(tsReceived),
      'bpm': serializer.toJson<int?>(bpm),
      'quality': serializer.toJson<int>(quality),
      'state': serializer.toJson<int>(state),
      'valid': serializer.toJson<bool>(valid),
    };
  }

  PulseReadingData copyWith(
          {int? id,
          Value<String?> deviceId = const Value.absent(),
          DateTime? tsDevice,
          DateTime? tsReceived,
          Value<int?> bpm = const Value.absent(),
          int? quality,
          int? state,
          bool? valid}) =>
      PulseReadingData(
        id: id ?? this.id,
        deviceId: deviceId.present ? deviceId.value : this.deviceId,
        tsDevice: tsDevice ?? this.tsDevice,
        tsReceived: tsReceived ?? this.tsReceived,
        bpm: bpm.present ? bpm.value : this.bpm,
        quality: quality ?? this.quality,
        state: state ?? this.state,
        valid: valid ?? this.valid,
      );
  PulseReadingData copyWithCompanion(PulseReadingsCompanion data) {
    return PulseReadingData(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      tsDevice: data.tsDevice.present ? data.tsDevice.value : this.tsDevice,
      tsReceived:
          data.tsReceived.present ? data.tsReceived.value : this.tsReceived,
      bpm: data.bpm.present ? data.bpm.value : this.bpm,
      quality: data.quality.present ? data.quality.value : this.quality,
      state: data.state.present ? data.state.value : this.state,
      valid: data.valid.present ? data.valid.value : this.valid,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PulseReadingData(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('tsDevice: $tsDevice, ')
          ..write('tsReceived: $tsReceived, ')
          ..write('bpm: $bpm, ')
          ..write('quality: $quality, ')
          ..write('state: $state, ')
          ..write('valid: $valid')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, deviceId, tsDevice, tsReceived, bpm, quality, state, valid);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PulseReadingData &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.tsDevice == this.tsDevice &&
          other.tsReceived == this.tsReceived &&
          other.bpm == this.bpm &&
          other.quality == this.quality &&
          other.state == this.state &&
          other.valid == this.valid);
}

class PulseReadingsCompanion extends UpdateCompanion<PulseReadingData> {
  final Value<int> id;
  final Value<String?> deviceId;
  final Value<DateTime> tsDevice;
  final Value<DateTime> tsReceived;
  final Value<int?> bpm;
  final Value<int> quality;
  final Value<int> state;
  final Value<bool> valid;
  const PulseReadingsCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.tsDevice = const Value.absent(),
    this.tsReceived = const Value.absent(),
    this.bpm = const Value.absent(),
    this.quality = const Value.absent(),
    this.state = const Value.absent(),
    this.valid = const Value.absent(),
  });
  PulseReadingsCompanion.insert({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    required DateTime tsDevice,
    required DateTime tsReceived,
    this.bpm = const Value.absent(),
    required int quality,
    required int state,
    required bool valid,
  })  : tsDevice = Value(tsDevice),
        tsReceived = Value(tsReceived),
        quality = Value(quality),
        state = Value(state),
        valid = Value(valid);
  static Insertable<PulseReadingData> custom({
    Expression<int>? id,
    Expression<String>? deviceId,
    Expression<DateTime>? tsDevice,
    Expression<DateTime>? tsReceived,
    Expression<int>? bpm,
    Expression<int>? quality,
    Expression<int>? state,
    Expression<bool>? valid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (tsDevice != null) 'ts_device': tsDevice,
      if (tsReceived != null) 'ts_received': tsReceived,
      if (bpm != null) 'bpm': bpm,
      if (quality != null) 'quality': quality,
      if (state != null) 'state': state,
      if (valid != null) 'valid': valid,
    });
  }

  PulseReadingsCompanion copyWith(
      {Value<int>? id,
      Value<String?>? deviceId,
      Value<DateTime>? tsDevice,
      Value<DateTime>? tsReceived,
      Value<int?>? bpm,
      Value<int>? quality,
      Value<int>? state,
      Value<bool>? valid}) {
    return PulseReadingsCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      tsDevice: tsDevice ?? this.tsDevice,
      tsReceived: tsReceived ?? this.tsReceived,
      bpm: bpm ?? this.bpm,
      quality: quality ?? this.quality,
      state: state ?? this.state,
      valid: valid ?? this.valid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (tsDevice.present) {
      map['ts_device'] = Variable<DateTime>(tsDevice.value);
    }
    if (tsReceived.present) {
      map['ts_received'] = Variable<DateTime>(tsReceived.value);
    }
    if (bpm.present) {
      map['bpm'] = Variable<int>(bpm.value);
    }
    if (quality.present) {
      map['quality'] = Variable<int>(quality.value);
    }
    if (state.present) {
      map['state'] = Variable<int>(state.value);
    }
    if (valid.present) {
      map['valid'] = Variable<bool>(valid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PulseReadingsCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('tsDevice: $tsDevice, ')
          ..write('tsReceived: $tsReceived, ')
          ..write('bpm: $bpm, ')
          ..write('quality: $quality, ')
          ..write('state: $state, ')
          ..write('valid: $valid')
          ..write(')'))
        .toString();
  }
}

class $MotionReadingsTable extends MotionReadings
    with TableInfo<$MotionReadingsTable, MotionReadingData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MotionReadingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _tsDeviceMeta =
      const VerificationMeta('tsDevice');
  @override
  late final GeneratedColumn<DateTime> tsDevice = GeneratedColumn<DateTime>(
      'ts_device', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _tsReceivedMeta =
      const VerificationMeta('tsReceived');
  @override
  late final GeneratedColumn<DateTime> tsReceived = GeneratedColumn<DateTime>(
      'ts_received', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _axMeta = const VerificationMeta('ax');
  @override
  late final GeneratedColumn<int> ax = GeneratedColumn<int>(
      'ax', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _ayMeta = const VerificationMeta('ay');
  @override
  late final GeneratedColumn<int> ay = GeneratedColumn<int>(
      'ay', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _azMeta = const VerificationMeta('az');
  @override
  late final GeneratedColumn<int> az = GeneratedColumn<int>(
      'az', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _gxMeta = const VerificationMeta('gx');
  @override
  late final GeneratedColumn<int> gx = GeneratedColumn<int>(
      'gx', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _gyMeta = const VerificationMeta('gy');
  @override
  late final GeneratedColumn<int> gy = GeneratedColumn<int>(
      'gy', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _gzMeta = const VerificationMeta('gz');
  @override
  late final GeneratedColumn<int> gz = GeneratedColumn<int>(
      'gz', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _intensityMeta =
      const VerificationMeta('intensity');
  @override
  late final GeneratedColumn<int> intensity = GeneratedColumn<int>(
      'intensity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _validMeta = const VerificationMeta('valid');
  @override
  late final GeneratedColumn<bool> valid = GeneratedColumn<bool>(
      'valid', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("valid" IN (0, 1))'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        deviceId,
        tsDevice,
        tsReceived,
        ax,
        ay,
        az,
        gx,
        gy,
        gz,
        intensity,
        valid
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'motion_readings';
  @override
  VerificationContext validateIntegrity(Insertable<MotionReadingData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    }
    if (data.containsKey('ts_device')) {
      context.handle(_tsDeviceMeta,
          tsDevice.isAcceptableOrUnknown(data['ts_device']!, _tsDeviceMeta));
    } else if (isInserting) {
      context.missing(_tsDeviceMeta);
    }
    if (data.containsKey('ts_received')) {
      context.handle(
          _tsReceivedMeta,
          tsReceived.isAcceptableOrUnknown(
              data['ts_received']!, _tsReceivedMeta));
    } else if (isInserting) {
      context.missing(_tsReceivedMeta);
    }
    if (data.containsKey('ax')) {
      context.handle(_axMeta, ax.isAcceptableOrUnknown(data['ax']!, _axMeta));
    } else if (isInserting) {
      context.missing(_axMeta);
    }
    if (data.containsKey('ay')) {
      context.handle(_ayMeta, ay.isAcceptableOrUnknown(data['ay']!, _ayMeta));
    } else if (isInserting) {
      context.missing(_ayMeta);
    }
    if (data.containsKey('az')) {
      context.handle(_azMeta, az.isAcceptableOrUnknown(data['az']!, _azMeta));
    } else if (isInserting) {
      context.missing(_azMeta);
    }
    if (data.containsKey('gx')) {
      context.handle(_gxMeta, gx.isAcceptableOrUnknown(data['gx']!, _gxMeta));
    } else if (isInserting) {
      context.missing(_gxMeta);
    }
    if (data.containsKey('gy')) {
      context.handle(_gyMeta, gy.isAcceptableOrUnknown(data['gy']!, _gyMeta));
    } else if (isInserting) {
      context.missing(_gyMeta);
    }
    if (data.containsKey('gz')) {
      context.handle(_gzMeta, gz.isAcceptableOrUnknown(data['gz']!, _gzMeta));
    } else if (isInserting) {
      context.missing(_gzMeta);
    }
    if (data.containsKey('intensity')) {
      context.handle(_intensityMeta,
          intensity.isAcceptableOrUnknown(data['intensity']!, _intensityMeta));
    } else if (isInserting) {
      context.missing(_intensityMeta);
    }
    if (data.containsKey('valid')) {
      context.handle(
          _validMeta, valid.isAcceptableOrUnknown(data['valid']!, _validMeta));
    } else if (isInserting) {
      context.missing(_validMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MotionReadingData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MotionReadingData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id']),
      tsDevice: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}ts_device'])!,
      tsReceived: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}ts_received'])!,
      ax: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ax'])!,
      ay: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ay'])!,
      az: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}az'])!,
      gx: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}gx'])!,
      gy: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}gy'])!,
      gz: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}gz'])!,
      intensity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}intensity'])!,
      valid: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}valid'])!,
    );
  }

  @override
  $MotionReadingsTable createAlias(String alias) {
    return $MotionReadingsTable(attachedDatabase, alias);
  }
}

class MotionReadingData extends DataClass
    implements Insertable<MotionReadingData> {
  final int id;
  final String? deviceId;
  final DateTime tsDevice;
  final DateTime tsReceived;
  final int ax;
  final int ay;
  final int az;
  final int gx;
  final int gy;
  final int gz;
  final int intensity;
  final bool valid;
  const MotionReadingData(
      {required this.id,
      this.deviceId,
      required this.tsDevice,
      required this.tsReceived,
      required this.ax,
      required this.ay,
      required this.az,
      required this.gx,
      required this.gy,
      required this.gz,
      required this.intensity,
      required this.valid});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['ts_device'] = Variable<DateTime>(tsDevice);
    map['ts_received'] = Variable<DateTime>(tsReceived);
    map['ax'] = Variable<int>(ax);
    map['ay'] = Variable<int>(ay);
    map['az'] = Variable<int>(az);
    map['gx'] = Variable<int>(gx);
    map['gy'] = Variable<int>(gy);
    map['gz'] = Variable<int>(gz);
    map['intensity'] = Variable<int>(intensity);
    map['valid'] = Variable<bool>(valid);
    return map;
  }

  MotionReadingsCompanion toCompanion(bool nullToAbsent) {
    return MotionReadingsCompanion(
      id: Value(id),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      tsDevice: Value(tsDevice),
      tsReceived: Value(tsReceived),
      ax: Value(ax),
      ay: Value(ay),
      az: Value(az),
      gx: Value(gx),
      gy: Value(gy),
      gz: Value(gz),
      intensity: Value(intensity),
      valid: Value(valid),
    );
  }

  factory MotionReadingData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MotionReadingData(
      id: serializer.fromJson<int>(json['id']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      tsDevice: serializer.fromJson<DateTime>(json['tsDevice']),
      tsReceived: serializer.fromJson<DateTime>(json['tsReceived']),
      ax: serializer.fromJson<int>(json['ax']),
      ay: serializer.fromJson<int>(json['ay']),
      az: serializer.fromJson<int>(json['az']),
      gx: serializer.fromJson<int>(json['gx']),
      gy: serializer.fromJson<int>(json['gy']),
      gz: serializer.fromJson<int>(json['gz']),
      intensity: serializer.fromJson<int>(json['intensity']),
      valid: serializer.fromJson<bool>(json['valid']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deviceId': serializer.toJson<String?>(deviceId),
      'tsDevice': serializer.toJson<DateTime>(tsDevice),
      'tsReceived': serializer.toJson<DateTime>(tsReceived),
      'ax': serializer.toJson<int>(ax),
      'ay': serializer.toJson<int>(ay),
      'az': serializer.toJson<int>(az),
      'gx': serializer.toJson<int>(gx),
      'gy': serializer.toJson<int>(gy),
      'gz': serializer.toJson<int>(gz),
      'intensity': serializer.toJson<int>(intensity),
      'valid': serializer.toJson<bool>(valid),
    };
  }

  MotionReadingData copyWith(
          {int? id,
          Value<String?> deviceId = const Value.absent(),
          DateTime? tsDevice,
          DateTime? tsReceived,
          int? ax,
          int? ay,
          int? az,
          int? gx,
          int? gy,
          int? gz,
          int? intensity,
          bool? valid}) =>
      MotionReadingData(
        id: id ?? this.id,
        deviceId: deviceId.present ? deviceId.value : this.deviceId,
        tsDevice: tsDevice ?? this.tsDevice,
        tsReceived: tsReceived ?? this.tsReceived,
        ax: ax ?? this.ax,
        ay: ay ?? this.ay,
        az: az ?? this.az,
        gx: gx ?? this.gx,
        gy: gy ?? this.gy,
        gz: gz ?? this.gz,
        intensity: intensity ?? this.intensity,
        valid: valid ?? this.valid,
      );
  MotionReadingData copyWithCompanion(MotionReadingsCompanion data) {
    return MotionReadingData(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      tsDevice: data.tsDevice.present ? data.tsDevice.value : this.tsDevice,
      tsReceived:
          data.tsReceived.present ? data.tsReceived.value : this.tsReceived,
      ax: data.ax.present ? data.ax.value : this.ax,
      ay: data.ay.present ? data.ay.value : this.ay,
      az: data.az.present ? data.az.value : this.az,
      gx: data.gx.present ? data.gx.value : this.gx,
      gy: data.gy.present ? data.gy.value : this.gy,
      gz: data.gz.present ? data.gz.value : this.gz,
      intensity: data.intensity.present ? data.intensity.value : this.intensity,
      valid: data.valid.present ? data.valid.value : this.valid,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MotionReadingData(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('tsDevice: $tsDevice, ')
          ..write('tsReceived: $tsReceived, ')
          ..write('ax: $ax, ')
          ..write('ay: $ay, ')
          ..write('az: $az, ')
          ..write('gx: $gx, ')
          ..write('gy: $gy, ')
          ..write('gz: $gz, ')
          ..write('intensity: $intensity, ')
          ..write('valid: $valid')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, deviceId, tsDevice, tsReceived, ax, ay,
      az, gx, gy, gz, intensity, valid);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MotionReadingData &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.tsDevice == this.tsDevice &&
          other.tsReceived == this.tsReceived &&
          other.ax == this.ax &&
          other.ay == this.ay &&
          other.az == this.az &&
          other.gx == this.gx &&
          other.gy == this.gy &&
          other.gz == this.gz &&
          other.intensity == this.intensity &&
          other.valid == this.valid);
}

class MotionReadingsCompanion extends UpdateCompanion<MotionReadingData> {
  final Value<int> id;
  final Value<String?> deviceId;
  final Value<DateTime> tsDevice;
  final Value<DateTime> tsReceived;
  final Value<int> ax;
  final Value<int> ay;
  final Value<int> az;
  final Value<int> gx;
  final Value<int> gy;
  final Value<int> gz;
  final Value<int> intensity;
  final Value<bool> valid;
  const MotionReadingsCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.tsDevice = const Value.absent(),
    this.tsReceived = const Value.absent(),
    this.ax = const Value.absent(),
    this.ay = const Value.absent(),
    this.az = const Value.absent(),
    this.gx = const Value.absent(),
    this.gy = const Value.absent(),
    this.gz = const Value.absent(),
    this.intensity = const Value.absent(),
    this.valid = const Value.absent(),
  });
  MotionReadingsCompanion.insert({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    required DateTime tsDevice,
    required DateTime tsReceived,
    required int ax,
    required int ay,
    required int az,
    required int gx,
    required int gy,
    required int gz,
    required int intensity,
    required bool valid,
  })  : tsDevice = Value(tsDevice),
        tsReceived = Value(tsReceived),
        ax = Value(ax),
        ay = Value(ay),
        az = Value(az),
        gx = Value(gx),
        gy = Value(gy),
        gz = Value(gz),
        intensity = Value(intensity),
        valid = Value(valid);
  static Insertable<MotionReadingData> custom({
    Expression<int>? id,
    Expression<String>? deviceId,
    Expression<DateTime>? tsDevice,
    Expression<DateTime>? tsReceived,
    Expression<int>? ax,
    Expression<int>? ay,
    Expression<int>? az,
    Expression<int>? gx,
    Expression<int>? gy,
    Expression<int>? gz,
    Expression<int>? intensity,
    Expression<bool>? valid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (tsDevice != null) 'ts_device': tsDevice,
      if (tsReceived != null) 'ts_received': tsReceived,
      if (ax != null) 'ax': ax,
      if (ay != null) 'ay': ay,
      if (az != null) 'az': az,
      if (gx != null) 'gx': gx,
      if (gy != null) 'gy': gy,
      if (gz != null) 'gz': gz,
      if (intensity != null) 'intensity': intensity,
      if (valid != null) 'valid': valid,
    });
  }

  MotionReadingsCompanion copyWith(
      {Value<int>? id,
      Value<String?>? deviceId,
      Value<DateTime>? tsDevice,
      Value<DateTime>? tsReceived,
      Value<int>? ax,
      Value<int>? ay,
      Value<int>? az,
      Value<int>? gx,
      Value<int>? gy,
      Value<int>? gz,
      Value<int>? intensity,
      Value<bool>? valid}) {
    return MotionReadingsCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      tsDevice: tsDevice ?? this.tsDevice,
      tsReceived: tsReceived ?? this.tsReceived,
      ax: ax ?? this.ax,
      ay: ay ?? this.ay,
      az: az ?? this.az,
      gx: gx ?? this.gx,
      gy: gy ?? this.gy,
      gz: gz ?? this.gz,
      intensity: intensity ?? this.intensity,
      valid: valid ?? this.valid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (tsDevice.present) {
      map['ts_device'] = Variable<DateTime>(tsDevice.value);
    }
    if (tsReceived.present) {
      map['ts_received'] = Variable<DateTime>(tsReceived.value);
    }
    if (ax.present) {
      map['ax'] = Variable<int>(ax.value);
    }
    if (ay.present) {
      map['ay'] = Variable<int>(ay.value);
    }
    if (az.present) {
      map['az'] = Variable<int>(az.value);
    }
    if (gx.present) {
      map['gx'] = Variable<int>(gx.value);
    }
    if (gy.present) {
      map['gy'] = Variable<int>(gy.value);
    }
    if (gz.present) {
      map['gz'] = Variable<int>(gz.value);
    }
    if (intensity.present) {
      map['intensity'] = Variable<int>(intensity.value);
    }
    if (valid.present) {
      map['valid'] = Variable<bool>(valid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MotionReadingsCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('tsDevice: $tsDevice, ')
          ..write('tsReceived: $tsReceived, ')
          ..write('ax: $ax, ')
          ..write('ay: $ay, ')
          ..write('az: $az, ')
          ..write('gx: $gx, ')
          ..write('gy: $gy, ')
          ..write('gz: $gz, ')
          ..write('intensity: $intensity, ')
          ..write('valid: $valid')
          ..write(')'))
        .toString();
  }
}

class $GpsReadingsTable extends GpsReadings
    with TableInfo<$GpsReadingsTable, GpsReadingData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GpsReadingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _tsDeviceMeta =
      const VerificationMeta('tsDevice');
  @override
  late final GeneratedColumn<DateTime> tsDevice = GeneratedColumn<DateTime>(
      'ts_device', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _tsReceivedMeta =
      const VerificationMeta('tsReceived');
  @override
  late final GeneratedColumn<DateTime> tsReceived = GeneratedColumn<DateTime>(
      'ts_received', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _fixStateMeta =
      const VerificationMeta('fixState');
  @override
  late final GeneratedColumn<int> fixState = GeneratedColumn<int>(
      'fix_state', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
      'lat', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _lonMeta = const VerificationMeta('lon');
  @override
  late final GeneratedColumn<double> lon = GeneratedColumn<double>(
      'lon', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _satellitesMeta =
      const VerificationMeta('satellites');
  @override
  late final GeneratedColumn<int> satellites = GeneratedColumn<int>(
      'satellites', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _hdopMeta = const VerificationMeta('hdop');
  @override
  late final GeneratedColumn<double> hdop = GeneratedColumn<double>(
      'hdop', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _validMeta = const VerificationMeta('valid');
  @override
  late final GeneratedColumn<bool> valid = GeneratedColumn<bool>(
      'valid', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("valid" IN (0, 1))'));
  static const VerificationMeta _staleMeta = const VerificationMeta('stale');
  @override
  late final GeneratedColumn<bool> stale = GeneratedColumn<bool>(
      'stale', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("stale" IN (0, 1))'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        deviceId,
        tsDevice,
        tsReceived,
        fixState,
        lat,
        lon,
        satellites,
        hdop,
        valid,
        stale
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'gps_readings';
  @override
  VerificationContext validateIntegrity(Insertable<GpsReadingData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    }
    if (data.containsKey('ts_device')) {
      context.handle(_tsDeviceMeta,
          tsDevice.isAcceptableOrUnknown(data['ts_device']!, _tsDeviceMeta));
    } else if (isInserting) {
      context.missing(_tsDeviceMeta);
    }
    if (data.containsKey('ts_received')) {
      context.handle(
          _tsReceivedMeta,
          tsReceived.isAcceptableOrUnknown(
              data['ts_received']!, _tsReceivedMeta));
    } else if (isInserting) {
      context.missing(_tsReceivedMeta);
    }
    if (data.containsKey('fix_state')) {
      context.handle(_fixStateMeta,
          fixState.isAcceptableOrUnknown(data['fix_state']!, _fixStateMeta));
    } else if (isInserting) {
      context.missing(_fixStateMeta);
    }
    if (data.containsKey('lat')) {
      context.handle(
          _latMeta, lat.isAcceptableOrUnknown(data['lat']!, _latMeta));
    }
    if (data.containsKey('lon')) {
      context.handle(
          _lonMeta, lon.isAcceptableOrUnknown(data['lon']!, _lonMeta));
    }
    if (data.containsKey('satellites')) {
      context.handle(
          _satellitesMeta,
          satellites.isAcceptableOrUnknown(
              data['satellites']!, _satellitesMeta));
    } else if (isInserting) {
      context.missing(_satellitesMeta);
    }
    if (data.containsKey('hdop')) {
      context.handle(
          _hdopMeta, hdop.isAcceptableOrUnknown(data['hdop']!, _hdopMeta));
    }
    if (data.containsKey('valid')) {
      context.handle(
          _validMeta, valid.isAcceptableOrUnknown(data['valid']!, _validMeta));
    } else if (isInserting) {
      context.missing(_validMeta);
    }
    if (data.containsKey('stale')) {
      context.handle(
          _staleMeta, stale.isAcceptableOrUnknown(data['stale']!, _staleMeta));
    } else if (isInserting) {
      context.missing(_staleMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GpsReadingData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GpsReadingData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id']),
      tsDevice: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}ts_device'])!,
      tsReceived: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}ts_received'])!,
      fixState: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}fix_state'])!,
      lat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lat']),
      lon: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lon']),
      satellites: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}satellites'])!,
      hdop: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}hdop']),
      valid: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}valid'])!,
      stale: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}stale'])!,
    );
  }

  @override
  $GpsReadingsTable createAlias(String alias) {
    return $GpsReadingsTable(attachedDatabase, alias);
  }
}

class GpsReadingData extends DataClass implements Insertable<GpsReadingData> {
  final int id;
  final String? deviceId;
  final DateTime tsDevice;
  final DateTime tsReceived;
  final int fixState;
  final double? lat;
  final double? lon;
  final int satellites;
  final double? hdop;
  final bool valid;
  final bool stale;
  const GpsReadingData(
      {required this.id,
      this.deviceId,
      required this.tsDevice,
      required this.tsReceived,
      required this.fixState,
      this.lat,
      this.lon,
      required this.satellites,
      this.hdop,
      required this.valid,
      required this.stale});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['ts_device'] = Variable<DateTime>(tsDevice);
    map['ts_received'] = Variable<DateTime>(tsReceived);
    map['fix_state'] = Variable<int>(fixState);
    if (!nullToAbsent || lat != null) {
      map['lat'] = Variable<double>(lat);
    }
    if (!nullToAbsent || lon != null) {
      map['lon'] = Variable<double>(lon);
    }
    map['satellites'] = Variable<int>(satellites);
    if (!nullToAbsent || hdop != null) {
      map['hdop'] = Variable<double>(hdop);
    }
    map['valid'] = Variable<bool>(valid);
    map['stale'] = Variable<bool>(stale);
    return map;
  }

  GpsReadingsCompanion toCompanion(bool nullToAbsent) {
    return GpsReadingsCompanion(
      id: Value(id),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      tsDevice: Value(tsDevice),
      tsReceived: Value(tsReceived),
      fixState: Value(fixState),
      lat: lat == null && nullToAbsent ? const Value.absent() : Value(lat),
      lon: lon == null && nullToAbsent ? const Value.absent() : Value(lon),
      satellites: Value(satellites),
      hdop: hdop == null && nullToAbsent ? const Value.absent() : Value(hdop),
      valid: Value(valid),
      stale: Value(stale),
    );
  }

  factory GpsReadingData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GpsReadingData(
      id: serializer.fromJson<int>(json['id']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      tsDevice: serializer.fromJson<DateTime>(json['tsDevice']),
      tsReceived: serializer.fromJson<DateTime>(json['tsReceived']),
      fixState: serializer.fromJson<int>(json['fixState']),
      lat: serializer.fromJson<double?>(json['lat']),
      lon: serializer.fromJson<double?>(json['lon']),
      satellites: serializer.fromJson<int>(json['satellites']),
      hdop: serializer.fromJson<double?>(json['hdop']),
      valid: serializer.fromJson<bool>(json['valid']),
      stale: serializer.fromJson<bool>(json['stale']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deviceId': serializer.toJson<String?>(deviceId),
      'tsDevice': serializer.toJson<DateTime>(tsDevice),
      'tsReceived': serializer.toJson<DateTime>(tsReceived),
      'fixState': serializer.toJson<int>(fixState),
      'lat': serializer.toJson<double?>(lat),
      'lon': serializer.toJson<double?>(lon),
      'satellites': serializer.toJson<int>(satellites),
      'hdop': serializer.toJson<double?>(hdop),
      'valid': serializer.toJson<bool>(valid),
      'stale': serializer.toJson<bool>(stale),
    };
  }

  GpsReadingData copyWith(
          {int? id,
          Value<String?> deviceId = const Value.absent(),
          DateTime? tsDevice,
          DateTime? tsReceived,
          int? fixState,
          Value<double?> lat = const Value.absent(),
          Value<double?> lon = const Value.absent(),
          int? satellites,
          Value<double?> hdop = const Value.absent(),
          bool? valid,
          bool? stale}) =>
      GpsReadingData(
        id: id ?? this.id,
        deviceId: deviceId.present ? deviceId.value : this.deviceId,
        tsDevice: tsDevice ?? this.tsDevice,
        tsReceived: tsReceived ?? this.tsReceived,
        fixState: fixState ?? this.fixState,
        lat: lat.present ? lat.value : this.lat,
        lon: lon.present ? lon.value : this.lon,
        satellites: satellites ?? this.satellites,
        hdop: hdop.present ? hdop.value : this.hdop,
        valid: valid ?? this.valid,
        stale: stale ?? this.stale,
      );
  GpsReadingData copyWithCompanion(GpsReadingsCompanion data) {
    return GpsReadingData(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      tsDevice: data.tsDevice.present ? data.tsDevice.value : this.tsDevice,
      tsReceived:
          data.tsReceived.present ? data.tsReceived.value : this.tsReceived,
      fixState: data.fixState.present ? data.fixState.value : this.fixState,
      lat: data.lat.present ? data.lat.value : this.lat,
      lon: data.lon.present ? data.lon.value : this.lon,
      satellites:
          data.satellites.present ? data.satellites.value : this.satellites,
      hdop: data.hdop.present ? data.hdop.value : this.hdop,
      valid: data.valid.present ? data.valid.value : this.valid,
      stale: data.stale.present ? data.stale.value : this.stale,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GpsReadingData(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('tsDevice: $tsDevice, ')
          ..write('tsReceived: $tsReceived, ')
          ..write('fixState: $fixState, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('satellites: $satellites, ')
          ..write('hdop: $hdop, ')
          ..write('valid: $valid, ')
          ..write('stale: $stale')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, deviceId, tsDevice, tsReceived, fixState,
      lat, lon, satellites, hdop, valid, stale);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GpsReadingData &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.tsDevice == this.tsDevice &&
          other.tsReceived == this.tsReceived &&
          other.fixState == this.fixState &&
          other.lat == this.lat &&
          other.lon == this.lon &&
          other.satellites == this.satellites &&
          other.hdop == this.hdop &&
          other.valid == this.valid &&
          other.stale == this.stale);
}

class GpsReadingsCompanion extends UpdateCompanion<GpsReadingData> {
  final Value<int> id;
  final Value<String?> deviceId;
  final Value<DateTime> tsDevice;
  final Value<DateTime> tsReceived;
  final Value<int> fixState;
  final Value<double?> lat;
  final Value<double?> lon;
  final Value<int> satellites;
  final Value<double?> hdop;
  final Value<bool> valid;
  final Value<bool> stale;
  const GpsReadingsCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.tsDevice = const Value.absent(),
    this.tsReceived = const Value.absent(),
    this.fixState = const Value.absent(),
    this.lat = const Value.absent(),
    this.lon = const Value.absent(),
    this.satellites = const Value.absent(),
    this.hdop = const Value.absent(),
    this.valid = const Value.absent(),
    this.stale = const Value.absent(),
  });
  GpsReadingsCompanion.insert({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    required DateTime tsDevice,
    required DateTime tsReceived,
    required int fixState,
    this.lat = const Value.absent(),
    this.lon = const Value.absent(),
    required int satellites,
    this.hdop = const Value.absent(),
    required bool valid,
    required bool stale,
  })  : tsDevice = Value(tsDevice),
        tsReceived = Value(tsReceived),
        fixState = Value(fixState),
        satellites = Value(satellites),
        valid = Value(valid),
        stale = Value(stale);
  static Insertable<GpsReadingData> custom({
    Expression<int>? id,
    Expression<String>? deviceId,
    Expression<DateTime>? tsDevice,
    Expression<DateTime>? tsReceived,
    Expression<int>? fixState,
    Expression<double>? lat,
    Expression<double>? lon,
    Expression<int>? satellites,
    Expression<double>? hdop,
    Expression<bool>? valid,
    Expression<bool>? stale,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (tsDevice != null) 'ts_device': tsDevice,
      if (tsReceived != null) 'ts_received': tsReceived,
      if (fixState != null) 'fix_state': fixState,
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon,
      if (satellites != null) 'satellites': satellites,
      if (hdop != null) 'hdop': hdop,
      if (valid != null) 'valid': valid,
      if (stale != null) 'stale': stale,
    });
  }

  GpsReadingsCompanion copyWith(
      {Value<int>? id,
      Value<String?>? deviceId,
      Value<DateTime>? tsDevice,
      Value<DateTime>? tsReceived,
      Value<int>? fixState,
      Value<double?>? lat,
      Value<double?>? lon,
      Value<int>? satellites,
      Value<double?>? hdop,
      Value<bool>? valid,
      Value<bool>? stale}) {
    return GpsReadingsCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      tsDevice: tsDevice ?? this.tsDevice,
      tsReceived: tsReceived ?? this.tsReceived,
      fixState: fixState ?? this.fixState,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      satellites: satellites ?? this.satellites,
      hdop: hdop ?? this.hdop,
      valid: valid ?? this.valid,
      stale: stale ?? this.stale,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (tsDevice.present) {
      map['ts_device'] = Variable<DateTime>(tsDevice.value);
    }
    if (tsReceived.present) {
      map['ts_received'] = Variable<DateTime>(tsReceived.value);
    }
    if (fixState.present) {
      map['fix_state'] = Variable<int>(fixState.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lon.present) {
      map['lon'] = Variable<double>(lon.value);
    }
    if (satellites.present) {
      map['satellites'] = Variable<int>(satellites.value);
    }
    if (hdop.present) {
      map['hdop'] = Variable<double>(hdop.value);
    }
    if (valid.present) {
      map['valid'] = Variable<bool>(valid.value);
    }
    if (stale.present) {
      map['stale'] = Variable<bool>(stale.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GpsReadingsCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('tsDevice: $tsDevice, ')
          ..write('tsReceived: $tsReceived, ')
          ..write('fixState: $fixState, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('satellites: $satellites, ')
          ..write('hdop: $hdop, ')
          ..write('valid: $valid, ')
          ..write('stale: $stale')
          ..write(')'))
        .toString();
  }
}

class $AiResultsTable extends AiResults
    with TableInfo<$AiResultsTable, AiResultData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AiResultsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _tsDeviceMeta =
      const VerificationMeta('tsDevice');
  @override
  late final GeneratedColumn<DateTime> tsDevice = GeneratedColumn<DateTime>(
      'ts_device', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _tsReceivedMeta =
      const VerificationMeta('tsReceived');
  @override
  late final GeneratedColumn<DateTime> tsReceived = GeneratedColumn<DateTime>(
      'ts_received', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<int> label = GeneratedColumn<int>(
      'label', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
      'score', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _modelVersionMeta =
      const VerificationMeta('modelVersion');
  @override
  late final GeneratedColumn<int> modelVersion = GeneratedColumn<int>(
      'model_version', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<int> source = GeneratedColumn<int>(
      'source', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _validMeta = const VerificationMeta('valid');
  @override
  late final GeneratedColumn<bool> valid = GeneratedColumn<bool>(
      'valid', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("valid" IN (0, 1))'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        deviceId,
        tsDevice,
        tsReceived,
        label,
        score,
        modelVersion,
        source,
        valid
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_results';
  @override
  VerificationContext validateIntegrity(Insertable<AiResultData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    }
    if (data.containsKey('ts_device')) {
      context.handle(_tsDeviceMeta,
          tsDevice.isAcceptableOrUnknown(data['ts_device']!, _tsDeviceMeta));
    } else if (isInserting) {
      context.missing(_tsDeviceMeta);
    }
    if (data.containsKey('ts_received')) {
      context.handle(
          _tsReceivedMeta,
          tsReceived.isAcceptableOrUnknown(
              data['ts_received']!, _tsReceivedMeta));
    } else if (isInserting) {
      context.missing(_tsReceivedMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
          _scoreMeta, score.isAcceptableOrUnknown(data['score']!, _scoreMeta));
    }
    if (data.containsKey('model_version')) {
      context.handle(
          _modelVersionMeta,
          modelVersion.isAcceptableOrUnknown(
              data['model_version']!, _modelVersionMeta));
    } else if (isInserting) {
      context.missing(_modelVersionMeta);
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('valid')) {
      context.handle(
          _validMeta, valid.isAcceptableOrUnknown(data['valid']!, _validMeta));
    } else if (isInserting) {
      context.missing(_validMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AiResultData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AiResultData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id']),
      tsDevice: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}ts_device'])!,
      tsReceived: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}ts_received'])!,
      label: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}label'])!,
      score: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}score']),
      modelVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}model_version'])!,
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}source'])!,
      valid: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}valid'])!,
    );
  }

  @override
  $AiResultsTable createAlias(String alias) {
    return $AiResultsTable(attachedDatabase, alias);
  }
}

class AiResultData extends DataClass implements Insertable<AiResultData> {
  final int id;
  final String? deviceId;
  final DateTime tsDevice;
  final DateTime tsReceived;
  final int label;
  final int? score;
  final int modelVersion;
  final int source;
  final bool valid;
  const AiResultData(
      {required this.id,
      this.deviceId,
      required this.tsDevice,
      required this.tsReceived,
      required this.label,
      this.score,
      required this.modelVersion,
      required this.source,
      required this.valid});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['ts_device'] = Variable<DateTime>(tsDevice);
    map['ts_received'] = Variable<DateTime>(tsReceived);
    map['label'] = Variable<int>(label);
    if (!nullToAbsent || score != null) {
      map['score'] = Variable<int>(score);
    }
    map['model_version'] = Variable<int>(modelVersion);
    map['source'] = Variable<int>(source);
    map['valid'] = Variable<bool>(valid);
    return map;
  }

  AiResultsCompanion toCompanion(bool nullToAbsent) {
    return AiResultsCompanion(
      id: Value(id),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      tsDevice: Value(tsDevice),
      tsReceived: Value(tsReceived),
      label: Value(label),
      score:
          score == null && nullToAbsent ? const Value.absent() : Value(score),
      modelVersion: Value(modelVersion),
      source: Value(source),
      valid: Value(valid),
    );
  }

  factory AiResultData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AiResultData(
      id: serializer.fromJson<int>(json['id']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      tsDevice: serializer.fromJson<DateTime>(json['tsDevice']),
      tsReceived: serializer.fromJson<DateTime>(json['tsReceived']),
      label: serializer.fromJson<int>(json['label']),
      score: serializer.fromJson<int?>(json['score']),
      modelVersion: serializer.fromJson<int>(json['modelVersion']),
      source: serializer.fromJson<int>(json['source']),
      valid: serializer.fromJson<bool>(json['valid']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deviceId': serializer.toJson<String?>(deviceId),
      'tsDevice': serializer.toJson<DateTime>(tsDevice),
      'tsReceived': serializer.toJson<DateTime>(tsReceived),
      'label': serializer.toJson<int>(label),
      'score': serializer.toJson<int?>(score),
      'modelVersion': serializer.toJson<int>(modelVersion),
      'source': serializer.toJson<int>(source),
      'valid': serializer.toJson<bool>(valid),
    };
  }

  AiResultData copyWith(
          {int? id,
          Value<String?> deviceId = const Value.absent(),
          DateTime? tsDevice,
          DateTime? tsReceived,
          int? label,
          Value<int?> score = const Value.absent(),
          int? modelVersion,
          int? source,
          bool? valid}) =>
      AiResultData(
        id: id ?? this.id,
        deviceId: deviceId.present ? deviceId.value : this.deviceId,
        tsDevice: tsDevice ?? this.tsDevice,
        tsReceived: tsReceived ?? this.tsReceived,
        label: label ?? this.label,
        score: score.present ? score.value : this.score,
        modelVersion: modelVersion ?? this.modelVersion,
        source: source ?? this.source,
        valid: valid ?? this.valid,
      );
  AiResultData copyWithCompanion(AiResultsCompanion data) {
    return AiResultData(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      tsDevice: data.tsDevice.present ? data.tsDevice.value : this.tsDevice,
      tsReceived:
          data.tsReceived.present ? data.tsReceived.value : this.tsReceived,
      label: data.label.present ? data.label.value : this.label,
      score: data.score.present ? data.score.value : this.score,
      modelVersion: data.modelVersion.present
          ? data.modelVersion.value
          : this.modelVersion,
      source: data.source.present ? data.source.value : this.source,
      valid: data.valid.present ? data.valid.value : this.valid,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AiResultData(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('tsDevice: $tsDevice, ')
          ..write('tsReceived: $tsReceived, ')
          ..write('label: $label, ')
          ..write('score: $score, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('source: $source, ')
          ..write('valid: $valid')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, deviceId, tsDevice, tsReceived, label,
      score, modelVersion, source, valid);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AiResultData &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.tsDevice == this.tsDevice &&
          other.tsReceived == this.tsReceived &&
          other.label == this.label &&
          other.score == this.score &&
          other.modelVersion == this.modelVersion &&
          other.source == this.source &&
          other.valid == this.valid);
}

class AiResultsCompanion extends UpdateCompanion<AiResultData> {
  final Value<int> id;
  final Value<String?> deviceId;
  final Value<DateTime> tsDevice;
  final Value<DateTime> tsReceived;
  final Value<int> label;
  final Value<int?> score;
  final Value<int> modelVersion;
  final Value<int> source;
  final Value<bool> valid;
  const AiResultsCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.tsDevice = const Value.absent(),
    this.tsReceived = const Value.absent(),
    this.label = const Value.absent(),
    this.score = const Value.absent(),
    this.modelVersion = const Value.absent(),
    this.source = const Value.absent(),
    this.valid = const Value.absent(),
  });
  AiResultsCompanion.insert({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    required DateTime tsDevice,
    required DateTime tsReceived,
    required int label,
    this.score = const Value.absent(),
    required int modelVersion,
    required int source,
    required bool valid,
  })  : tsDevice = Value(tsDevice),
        tsReceived = Value(tsReceived),
        label = Value(label),
        modelVersion = Value(modelVersion),
        source = Value(source),
        valid = Value(valid);
  static Insertable<AiResultData> custom({
    Expression<int>? id,
    Expression<String>? deviceId,
    Expression<DateTime>? tsDevice,
    Expression<DateTime>? tsReceived,
    Expression<int>? label,
    Expression<int>? score,
    Expression<int>? modelVersion,
    Expression<int>? source,
    Expression<bool>? valid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (tsDevice != null) 'ts_device': tsDevice,
      if (tsReceived != null) 'ts_received': tsReceived,
      if (label != null) 'label': label,
      if (score != null) 'score': score,
      if (modelVersion != null) 'model_version': modelVersion,
      if (source != null) 'source': source,
      if (valid != null) 'valid': valid,
    });
  }

  AiResultsCompanion copyWith(
      {Value<int>? id,
      Value<String?>? deviceId,
      Value<DateTime>? tsDevice,
      Value<DateTime>? tsReceived,
      Value<int>? label,
      Value<int?>? score,
      Value<int>? modelVersion,
      Value<int>? source,
      Value<bool>? valid}) {
    return AiResultsCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      tsDevice: tsDevice ?? this.tsDevice,
      tsReceived: tsReceived ?? this.tsReceived,
      label: label ?? this.label,
      score: score ?? this.score,
      modelVersion: modelVersion ?? this.modelVersion,
      source: source ?? this.source,
      valid: valid ?? this.valid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (tsDevice.present) {
      map['ts_device'] = Variable<DateTime>(tsDevice.value);
    }
    if (tsReceived.present) {
      map['ts_received'] = Variable<DateTime>(tsReceived.value);
    }
    if (label.present) {
      map['label'] = Variable<int>(label.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (modelVersion.present) {
      map['model_version'] = Variable<int>(modelVersion.value);
    }
    if (source.present) {
      map['source'] = Variable<int>(source.value);
    }
    if (valid.present) {
      map['valid'] = Variable<bool>(valid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AiResultsCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('tsDevice: $tsDevice, ')
          ..write('tsReceived: $tsReceived, ')
          ..write('label: $label, ')
          ..write('score: $score, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('source: $source, ')
          ..write('valid: $valid')
          ..write(')'))
        .toString();
  }
}

class $ConnectionEventsTable extends ConnectionEvents
    with TableInfo<$ConnectionEventsTable, ConnectionEventData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConnectionEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _tsMeta = const VerificationMeta('ts');
  @override
  late final GeneratedColumn<DateTime> ts = GeneratedColumn<DateTime>(
      'ts', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _eventMeta = const VerificationMeta('event');
  @override
  late final GeneratedColumn<String> event = GeneratedColumn<String>(
      'event', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
      'reason', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, deviceId, ts, event, reason];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'connection_events';
  @override
  VerificationContext validateIntegrity(
      Insertable<ConnectionEventData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    }
    if (data.containsKey('ts')) {
      context.handle(_tsMeta, ts.isAcceptableOrUnknown(data['ts']!, _tsMeta));
    } else if (isInserting) {
      context.missing(_tsMeta);
    }
    if (data.containsKey('event')) {
      context.handle(
          _eventMeta, event.isAcceptableOrUnknown(data['event']!, _eventMeta));
    } else if (isInserting) {
      context.missing(_eventMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(_reasonMeta,
          reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ConnectionEventData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConnectionEventData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id']),
      ts: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}ts'])!,
      event: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}event'])!,
      reason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reason']),
    );
  }

  @override
  $ConnectionEventsTable createAlias(String alias) {
    return $ConnectionEventsTable(attachedDatabase, alias);
  }
}

class ConnectionEventData extends DataClass
    implements Insertable<ConnectionEventData> {
  final int id;
  final String? deviceId;
  final DateTime ts;
  final String event;
  final String? reason;
  const ConnectionEventData(
      {required this.id,
      this.deviceId,
      required this.ts,
      required this.event,
      this.reason});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['ts'] = Variable<DateTime>(ts);
    map['event'] = Variable<String>(event);
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    return map;
  }

  ConnectionEventsCompanion toCompanion(bool nullToAbsent) {
    return ConnectionEventsCompanion(
      id: Value(id),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      ts: Value(ts),
      event: Value(event),
      reason:
          reason == null && nullToAbsent ? const Value.absent() : Value(reason),
    );
  }

  factory ConnectionEventData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConnectionEventData(
      id: serializer.fromJson<int>(json['id']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      ts: serializer.fromJson<DateTime>(json['ts']),
      event: serializer.fromJson<String>(json['event']),
      reason: serializer.fromJson<String?>(json['reason']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deviceId': serializer.toJson<String?>(deviceId),
      'ts': serializer.toJson<DateTime>(ts),
      'event': serializer.toJson<String>(event),
      'reason': serializer.toJson<String?>(reason),
    };
  }

  ConnectionEventData copyWith(
          {int? id,
          Value<String?> deviceId = const Value.absent(),
          DateTime? ts,
          String? event,
          Value<String?> reason = const Value.absent()}) =>
      ConnectionEventData(
        id: id ?? this.id,
        deviceId: deviceId.present ? deviceId.value : this.deviceId,
        ts: ts ?? this.ts,
        event: event ?? this.event,
        reason: reason.present ? reason.value : this.reason,
      );
  ConnectionEventData copyWithCompanion(ConnectionEventsCompanion data) {
    return ConnectionEventData(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      ts: data.ts.present ? data.ts.value : this.ts,
      event: data.event.present ? data.event.value : this.event,
      reason: data.reason.present ? data.reason.value : this.reason,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConnectionEventData(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('ts: $ts, ')
          ..write('event: $event, ')
          ..write('reason: $reason')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, deviceId, ts, event, reason);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConnectionEventData &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.ts == this.ts &&
          other.event == this.event &&
          other.reason == this.reason);
}

class ConnectionEventsCompanion extends UpdateCompanion<ConnectionEventData> {
  final Value<int> id;
  final Value<String?> deviceId;
  final Value<DateTime> ts;
  final Value<String> event;
  final Value<String?> reason;
  const ConnectionEventsCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.ts = const Value.absent(),
    this.event = const Value.absent(),
    this.reason = const Value.absent(),
  });
  ConnectionEventsCompanion.insert({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    required DateTime ts,
    required String event,
    this.reason = const Value.absent(),
  })  : ts = Value(ts),
        event = Value(event);
  static Insertable<ConnectionEventData> custom({
    Expression<int>? id,
    Expression<String>? deviceId,
    Expression<DateTime>? ts,
    Expression<String>? event,
    Expression<String>? reason,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (ts != null) 'ts': ts,
      if (event != null) 'event': event,
      if (reason != null) 'reason': reason,
    });
  }

  ConnectionEventsCompanion copyWith(
      {Value<int>? id,
      Value<String?>? deviceId,
      Value<DateTime>? ts,
      Value<String>? event,
      Value<String?>? reason}) {
    return ConnectionEventsCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      ts: ts ?? this.ts,
      event: event ?? this.event,
      reason: reason ?? this.reason,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (ts.present) {
      map['ts'] = Variable<DateTime>(ts.value);
    }
    if (event.present) {
      map['event'] = Variable<String>(event.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConnectionEventsCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('ts: $ts, ')
          ..write('event: $event, ')
          ..write('reason: $reason')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSettingData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(Insertable<AppSettingData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSettingData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingData(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSettingData extends DataClass implements Insertable<AppSettingData> {
  final String key;
  final String value;
  const AppSettingData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory AppSettingData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSettingData copyWith({String? key, String? value}) => AppSettingData(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  AppSettingData copyWithCompanion(AppSettingsCompanion data) {
    return AppSettingData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingData &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSettingData> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<AppSettingData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith(
      {Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DevicesTable devices = $DevicesTable(this);
  late final $PulseReadingsTable pulseReadings = $PulseReadingsTable(this);
  late final $MotionReadingsTable motionReadings = $MotionReadingsTable(this);
  late final $GpsReadingsTable gpsReadings = $GpsReadingsTable(this);
  late final $AiResultsTable aiResults = $AiResultsTable(this);
  late final $ConnectionEventsTable connectionEvents =
      $ConnectionEventsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        devices,
        pulseReadings,
        motionReadings,
        gpsReadings,
        aiResults,
        connectionEvents,
        appSettings
      ];
}

typedef $$DevicesTableCreateCompanionBuilder = DevicesCompanion Function({
  required String id,
  required String name,
  required String bleId,
  required String firmwareVersion,
  required DateTime firstConnectedAt,
  Value<int> rowid,
});
typedef $$DevicesTableUpdateCompanionBuilder = DevicesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> bleId,
  Value<String> firmwareVersion,
  Value<DateTime> firstConnectedAt,
  Value<int> rowid,
});

class $$DevicesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DevicesTable,
    DeviceData,
    $$DevicesTableFilterComposer,
    $$DevicesTableOrderingComposer,
    $$DevicesTableCreateCompanionBuilder,
    $$DevicesTableUpdateCompanionBuilder> {
  $$DevicesTableTableManager(_$AppDatabase db, $DevicesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$DevicesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$DevicesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> bleId = const Value.absent(),
            Value<String> firmwareVersion = const Value.absent(),
            Value<DateTime> firstConnectedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DevicesCompanion(
            id: id,
            name: name,
            bleId: bleId,
            firmwareVersion: firmwareVersion,
            firstConnectedAt: firstConnectedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String bleId,
            required String firmwareVersion,
            required DateTime firstConnectedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              DevicesCompanion.insert(
            id: id,
            name: name,
            bleId: bleId,
            firmwareVersion: firmwareVersion,
            firstConnectedAt: firstConnectedAt,
            rowid: rowid,
          ),
        ));
}

class $$DevicesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get bleId => $state.composableBuilder(
      column: $state.table.bleId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get firmwareVersion => $state.composableBuilder(
      column: $state.table.firmwareVersion,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get firstConnectedAt => $state.composableBuilder(
      column: $state.table.firstConnectedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter pulseReadingsRefs(
      ComposableFilter Function($$PulseReadingsTableFilterComposer f) f) {
    final $$PulseReadingsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.pulseReadings,
        getReferencedColumn: (t) => t.deviceId,
        builder: (joinBuilder, parentComposers) =>
            $$PulseReadingsTableFilterComposer(ComposerState($state.db,
                $state.db.pulseReadings, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$DevicesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get bleId => $state.composableBuilder(
      column: $state.table.bleId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get firmwareVersion => $state.composableBuilder(
      column: $state.table.firmwareVersion,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get firstConnectedAt => $state.composableBuilder(
      column: $state.table.firstConnectedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$PulseReadingsTableCreateCompanionBuilder = PulseReadingsCompanion
    Function({
  Value<int> id,
  Value<String?> deviceId,
  required DateTime tsDevice,
  required DateTime tsReceived,
  Value<int?> bpm,
  required int quality,
  required int state,
  required bool valid,
});
typedef $$PulseReadingsTableUpdateCompanionBuilder = PulseReadingsCompanion
    Function({
  Value<int> id,
  Value<String?> deviceId,
  Value<DateTime> tsDevice,
  Value<DateTime> tsReceived,
  Value<int?> bpm,
  Value<int> quality,
  Value<int> state,
  Value<bool> valid,
});

class $$PulseReadingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PulseReadingsTable,
    PulseReadingData,
    $$PulseReadingsTableFilterComposer,
    $$PulseReadingsTableOrderingComposer,
    $$PulseReadingsTableCreateCompanionBuilder,
    $$PulseReadingsTableUpdateCompanionBuilder> {
  $$PulseReadingsTableTableManager(_$AppDatabase db, $PulseReadingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$PulseReadingsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$PulseReadingsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<DateTime> tsDevice = const Value.absent(),
            Value<DateTime> tsReceived = const Value.absent(),
            Value<int?> bpm = const Value.absent(),
            Value<int> quality = const Value.absent(),
            Value<int> state = const Value.absent(),
            Value<bool> valid = const Value.absent(),
          }) =>
              PulseReadingsCompanion(
            id: id,
            deviceId: deviceId,
            tsDevice: tsDevice,
            tsReceived: tsReceived,
            bpm: bpm,
            quality: quality,
            state: state,
            valid: valid,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            required DateTime tsDevice,
            required DateTime tsReceived,
            Value<int?> bpm = const Value.absent(),
            required int quality,
            required int state,
            required bool valid,
          }) =>
              PulseReadingsCompanion.insert(
            id: id,
            deviceId: deviceId,
            tsDevice: tsDevice,
            tsReceived: tsReceived,
            bpm: bpm,
            quality: quality,
            state: state,
            valid: valid,
          ),
        ));
}

class $$PulseReadingsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $PulseReadingsTable> {
  $$PulseReadingsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get tsDevice => $state.composableBuilder(
      column: $state.table.tsDevice,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get tsReceived => $state.composableBuilder(
      column: $state.table.tsReceived,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get bpm => $state.composableBuilder(
      column: $state.table.bpm,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get quality => $state.composableBuilder(
      column: $state.table.quality,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get state => $state.composableBuilder(
      column: $state.table.state,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get valid => $state.composableBuilder(
      column: $state.table.valid,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$DevicesTableFilterComposer get deviceId {
    final $$DevicesTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.deviceId,
        referencedTable: $state.db.devices,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$DevicesTableFilterComposer(
            ComposerState(
                $state.db, $state.db.devices, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$PulseReadingsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $PulseReadingsTable> {
  $$PulseReadingsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get tsDevice => $state.composableBuilder(
      column: $state.table.tsDevice,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get tsReceived => $state.composableBuilder(
      column: $state.table.tsReceived,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get bpm => $state.composableBuilder(
      column: $state.table.bpm,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get quality => $state.composableBuilder(
      column: $state.table.quality,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get state => $state.composableBuilder(
      column: $state.table.state,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get valid => $state.composableBuilder(
      column: $state.table.valid,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$DevicesTableOrderingComposer get deviceId {
    final $$DevicesTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.deviceId,
        referencedTable: $state.db.devices,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$DevicesTableOrderingComposer(ComposerState(
                $state.db, $state.db.devices, joinBuilder, parentComposers)));
    return composer;
  }
}

typedef $$MotionReadingsTableCreateCompanionBuilder = MotionReadingsCompanion
    Function({
  Value<int> id,
  Value<String?> deviceId,
  required DateTime tsDevice,
  required DateTime tsReceived,
  required int ax,
  required int ay,
  required int az,
  required int gx,
  required int gy,
  required int gz,
  required int intensity,
  required bool valid,
});
typedef $$MotionReadingsTableUpdateCompanionBuilder = MotionReadingsCompanion
    Function({
  Value<int> id,
  Value<String?> deviceId,
  Value<DateTime> tsDevice,
  Value<DateTime> tsReceived,
  Value<int> ax,
  Value<int> ay,
  Value<int> az,
  Value<int> gx,
  Value<int> gy,
  Value<int> gz,
  Value<int> intensity,
  Value<bool> valid,
});

class $$MotionReadingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MotionReadingsTable,
    MotionReadingData,
    $$MotionReadingsTableFilterComposer,
    $$MotionReadingsTableOrderingComposer,
    $$MotionReadingsTableCreateCompanionBuilder,
    $$MotionReadingsTableUpdateCompanionBuilder> {
  $$MotionReadingsTableTableManager(
      _$AppDatabase db, $MotionReadingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$MotionReadingsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$MotionReadingsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<DateTime> tsDevice = const Value.absent(),
            Value<DateTime> tsReceived = const Value.absent(),
            Value<int> ax = const Value.absent(),
            Value<int> ay = const Value.absent(),
            Value<int> az = const Value.absent(),
            Value<int> gx = const Value.absent(),
            Value<int> gy = const Value.absent(),
            Value<int> gz = const Value.absent(),
            Value<int> intensity = const Value.absent(),
            Value<bool> valid = const Value.absent(),
          }) =>
              MotionReadingsCompanion(
            id: id,
            deviceId: deviceId,
            tsDevice: tsDevice,
            tsReceived: tsReceived,
            ax: ax,
            ay: ay,
            az: az,
            gx: gx,
            gy: gy,
            gz: gz,
            intensity: intensity,
            valid: valid,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            required DateTime tsDevice,
            required DateTime tsReceived,
            required int ax,
            required int ay,
            required int az,
            required int gx,
            required int gy,
            required int gz,
            required int intensity,
            required bool valid,
          }) =>
              MotionReadingsCompanion.insert(
            id: id,
            deviceId: deviceId,
            tsDevice: tsDevice,
            tsReceived: tsReceived,
            ax: ax,
            ay: ay,
            az: az,
            gx: gx,
            gy: gy,
            gz: gz,
            intensity: intensity,
            valid: valid,
          ),
        ));
}

class $$MotionReadingsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $MotionReadingsTable> {
  $$MotionReadingsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get deviceId => $state.composableBuilder(
      column: $state.table.deviceId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get tsDevice => $state.composableBuilder(
      column: $state.table.tsDevice,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get tsReceived => $state.composableBuilder(
      column: $state.table.tsReceived,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get ax => $state.composableBuilder(
      column: $state.table.ax,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get ay => $state.composableBuilder(
      column: $state.table.ay,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get az => $state.composableBuilder(
      column: $state.table.az,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get gx => $state.composableBuilder(
      column: $state.table.gx,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get gy => $state.composableBuilder(
      column: $state.table.gy,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get gz => $state.composableBuilder(
      column: $state.table.gz,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get intensity => $state.composableBuilder(
      column: $state.table.intensity,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get valid => $state.composableBuilder(
      column: $state.table.valid,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$MotionReadingsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $MotionReadingsTable> {
  $$MotionReadingsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get deviceId => $state.composableBuilder(
      column: $state.table.deviceId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get tsDevice => $state.composableBuilder(
      column: $state.table.tsDevice,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get tsReceived => $state.composableBuilder(
      column: $state.table.tsReceived,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get ax => $state.composableBuilder(
      column: $state.table.ax,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get ay => $state.composableBuilder(
      column: $state.table.ay,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get az => $state.composableBuilder(
      column: $state.table.az,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get gx => $state.composableBuilder(
      column: $state.table.gx,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get gy => $state.composableBuilder(
      column: $state.table.gy,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get gz => $state.composableBuilder(
      column: $state.table.gz,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get intensity => $state.composableBuilder(
      column: $state.table.intensity,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get valid => $state.composableBuilder(
      column: $state.table.valid,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$GpsReadingsTableCreateCompanionBuilder = GpsReadingsCompanion
    Function({
  Value<int> id,
  Value<String?> deviceId,
  required DateTime tsDevice,
  required DateTime tsReceived,
  required int fixState,
  Value<double?> lat,
  Value<double?> lon,
  required int satellites,
  Value<double?> hdop,
  required bool valid,
  required bool stale,
});
typedef $$GpsReadingsTableUpdateCompanionBuilder = GpsReadingsCompanion
    Function({
  Value<int> id,
  Value<String?> deviceId,
  Value<DateTime> tsDevice,
  Value<DateTime> tsReceived,
  Value<int> fixState,
  Value<double?> lat,
  Value<double?> lon,
  Value<int> satellites,
  Value<double?> hdop,
  Value<bool> valid,
  Value<bool> stale,
});

class $$GpsReadingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GpsReadingsTable,
    GpsReadingData,
    $$GpsReadingsTableFilterComposer,
    $$GpsReadingsTableOrderingComposer,
    $$GpsReadingsTableCreateCompanionBuilder,
    $$GpsReadingsTableUpdateCompanionBuilder> {
  $$GpsReadingsTableTableManager(_$AppDatabase db, $GpsReadingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$GpsReadingsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$GpsReadingsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<DateTime> tsDevice = const Value.absent(),
            Value<DateTime> tsReceived = const Value.absent(),
            Value<int> fixState = const Value.absent(),
            Value<double?> lat = const Value.absent(),
            Value<double?> lon = const Value.absent(),
            Value<int> satellites = const Value.absent(),
            Value<double?> hdop = const Value.absent(),
            Value<bool> valid = const Value.absent(),
            Value<bool> stale = const Value.absent(),
          }) =>
              GpsReadingsCompanion(
            id: id,
            deviceId: deviceId,
            tsDevice: tsDevice,
            tsReceived: tsReceived,
            fixState: fixState,
            lat: lat,
            lon: lon,
            satellites: satellites,
            hdop: hdop,
            valid: valid,
            stale: stale,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            required DateTime tsDevice,
            required DateTime tsReceived,
            required int fixState,
            Value<double?> lat = const Value.absent(),
            Value<double?> lon = const Value.absent(),
            required int satellites,
            Value<double?> hdop = const Value.absent(),
            required bool valid,
            required bool stale,
          }) =>
              GpsReadingsCompanion.insert(
            id: id,
            deviceId: deviceId,
            tsDevice: tsDevice,
            tsReceived: tsReceived,
            fixState: fixState,
            lat: lat,
            lon: lon,
            satellites: satellites,
            hdop: hdop,
            valid: valid,
            stale: stale,
          ),
        ));
}

class $$GpsReadingsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $GpsReadingsTable> {
  $$GpsReadingsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get deviceId => $state.composableBuilder(
      column: $state.table.deviceId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get tsDevice => $state.composableBuilder(
      column: $state.table.tsDevice,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get tsReceived => $state.composableBuilder(
      column: $state.table.tsReceived,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get fixState => $state.composableBuilder(
      column: $state.table.fixState,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get lat => $state.composableBuilder(
      column: $state.table.lat,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get lon => $state.composableBuilder(
      column: $state.table.lon,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get satellites => $state.composableBuilder(
      column: $state.table.satellites,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get hdop => $state.composableBuilder(
      column: $state.table.hdop,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get valid => $state.composableBuilder(
      column: $state.table.valid,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get stale => $state.composableBuilder(
      column: $state.table.stale,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$GpsReadingsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $GpsReadingsTable> {
  $$GpsReadingsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get deviceId => $state.composableBuilder(
      column: $state.table.deviceId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get tsDevice => $state.composableBuilder(
      column: $state.table.tsDevice,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get tsReceived => $state.composableBuilder(
      column: $state.table.tsReceived,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get fixState => $state.composableBuilder(
      column: $state.table.fixState,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get lat => $state.composableBuilder(
      column: $state.table.lat,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get lon => $state.composableBuilder(
      column: $state.table.lon,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get satellites => $state.composableBuilder(
      column: $state.table.satellites,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get hdop => $state.composableBuilder(
      column: $state.table.hdop,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get valid => $state.composableBuilder(
      column: $state.table.valid,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get stale => $state.composableBuilder(
      column: $state.table.stale,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$AiResultsTableCreateCompanionBuilder = AiResultsCompanion Function({
  Value<int> id,
  Value<String?> deviceId,
  required DateTime tsDevice,
  required DateTime tsReceived,
  required int label,
  Value<int?> score,
  required int modelVersion,
  required int source,
  required bool valid,
});
typedef $$AiResultsTableUpdateCompanionBuilder = AiResultsCompanion Function({
  Value<int> id,
  Value<String?> deviceId,
  Value<DateTime> tsDevice,
  Value<DateTime> tsReceived,
  Value<int> label,
  Value<int?> score,
  Value<int> modelVersion,
  Value<int> source,
  Value<bool> valid,
});

class $$AiResultsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AiResultsTable,
    AiResultData,
    $$AiResultsTableFilterComposer,
    $$AiResultsTableOrderingComposer,
    $$AiResultsTableCreateCompanionBuilder,
    $$AiResultsTableUpdateCompanionBuilder> {
  $$AiResultsTableTableManager(_$AppDatabase db, $AiResultsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$AiResultsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$AiResultsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<DateTime> tsDevice = const Value.absent(),
            Value<DateTime> tsReceived = const Value.absent(),
            Value<int> label = const Value.absent(),
            Value<int?> score = const Value.absent(),
            Value<int> modelVersion = const Value.absent(),
            Value<int> source = const Value.absent(),
            Value<bool> valid = const Value.absent(),
          }) =>
              AiResultsCompanion(
            id: id,
            deviceId: deviceId,
            tsDevice: tsDevice,
            tsReceived: tsReceived,
            label: label,
            score: score,
            modelVersion: modelVersion,
            source: source,
            valid: valid,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            required DateTime tsDevice,
            required DateTime tsReceived,
            required int label,
            Value<int?> score = const Value.absent(),
            required int modelVersion,
            required int source,
            required bool valid,
          }) =>
              AiResultsCompanion.insert(
            id: id,
            deviceId: deviceId,
            tsDevice: tsDevice,
            tsReceived: tsReceived,
            label: label,
            score: score,
            modelVersion: modelVersion,
            source: source,
            valid: valid,
          ),
        ));
}

class $$AiResultsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $AiResultsTable> {
  $$AiResultsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get deviceId => $state.composableBuilder(
      column: $state.table.deviceId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get tsDevice => $state.composableBuilder(
      column: $state.table.tsDevice,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get tsReceived => $state.composableBuilder(
      column: $state.table.tsReceived,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get label => $state.composableBuilder(
      column: $state.table.label,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get score => $state.composableBuilder(
      column: $state.table.score,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get modelVersion => $state.composableBuilder(
      column: $state.table.modelVersion,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get source => $state.composableBuilder(
      column: $state.table.source,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get valid => $state.composableBuilder(
      column: $state.table.valid,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$AiResultsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $AiResultsTable> {
  $$AiResultsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get deviceId => $state.composableBuilder(
      column: $state.table.deviceId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get tsDevice => $state.composableBuilder(
      column: $state.table.tsDevice,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get tsReceived => $state.composableBuilder(
      column: $state.table.tsReceived,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get label => $state.composableBuilder(
      column: $state.table.label,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get score => $state.composableBuilder(
      column: $state.table.score,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get modelVersion => $state.composableBuilder(
      column: $state.table.modelVersion,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get source => $state.composableBuilder(
      column: $state.table.source,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get valid => $state.composableBuilder(
      column: $state.table.valid,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$ConnectionEventsTableCreateCompanionBuilder
    = ConnectionEventsCompanion Function({
  Value<int> id,
  Value<String?> deviceId,
  required DateTime ts,
  required String event,
  Value<String?> reason,
});
typedef $$ConnectionEventsTableUpdateCompanionBuilder
    = ConnectionEventsCompanion Function({
  Value<int> id,
  Value<String?> deviceId,
  Value<DateTime> ts,
  Value<String> event,
  Value<String?> reason,
});

class $$ConnectionEventsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ConnectionEventsTable,
    ConnectionEventData,
    $$ConnectionEventsTableFilterComposer,
    $$ConnectionEventsTableOrderingComposer,
    $$ConnectionEventsTableCreateCompanionBuilder,
    $$ConnectionEventsTableUpdateCompanionBuilder> {
  $$ConnectionEventsTableTableManager(
      _$AppDatabase db, $ConnectionEventsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ConnectionEventsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$ConnectionEventsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<DateTime> ts = const Value.absent(),
            Value<String> event = const Value.absent(),
            Value<String?> reason = const Value.absent(),
          }) =>
              ConnectionEventsCompanion(
            id: id,
            deviceId: deviceId,
            ts: ts,
            event: event,
            reason: reason,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            required DateTime ts,
            required String event,
            Value<String?> reason = const Value.absent(),
          }) =>
              ConnectionEventsCompanion.insert(
            id: id,
            deviceId: deviceId,
            ts: ts,
            event: event,
            reason: reason,
          ),
        ));
}

class $$ConnectionEventsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $ConnectionEventsTable> {
  $$ConnectionEventsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get deviceId => $state.composableBuilder(
      column: $state.table.deviceId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get ts => $state.composableBuilder(
      column: $state.table.ts,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get event => $state.composableBuilder(
      column: $state.table.event,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get reason => $state.composableBuilder(
      column: $state.table.reason,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$ConnectionEventsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $ConnectionEventsTable> {
  $$ConnectionEventsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get deviceId => $state.composableBuilder(
      column: $state.table.deviceId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get ts => $state.composableBuilder(
      column: $state.table.ts,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get event => $state.composableBuilder(
      column: $state.table.event,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get reason => $state.composableBuilder(
      column: $state.table.reason,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$AppSettingsTableCreateCompanionBuilder = AppSettingsCompanion
    Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$AppSettingsTableUpdateCompanionBuilder = AppSettingsCompanion
    Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$AppSettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AppSettingsTable,
    AppSettingData,
    $$AppSettingsTableFilterComposer,
    $$AppSettingsTableOrderingComposer,
    $$AppSettingsTableCreateCompanionBuilder,
    $$AppSettingsTableUpdateCompanionBuilder> {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$AppSettingsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$AppSettingsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AppSettingsCompanion(
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) =>
              AppSettingsCompanion.insert(
            key: key,
            value: value,
            rowid: rowid,
          ),
        ));
}

class $$AppSettingsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer(super.$state);
  ColumnFilters<String> get key => $state.composableBuilder(
      column: $state.table.key,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get value => $state.composableBuilder(
      column: $state.table.value,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$AppSettingsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get key => $state.composableBuilder(
      column: $state.table.key,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get value => $state.composableBuilder(
      column: $state.table.value,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DevicesTableTableManager get devices =>
      $$DevicesTableTableManager(_db, _db.devices);
  $$PulseReadingsTableTableManager get pulseReadings =>
      $$PulseReadingsTableTableManager(_db, _db.pulseReadings);
  $$MotionReadingsTableTableManager get motionReadings =>
      $$MotionReadingsTableTableManager(_db, _db.motionReadings);
  $$GpsReadingsTableTableManager get gpsReadings =>
      $$GpsReadingsTableTableManager(_db, _db.gpsReadings);
  $$AiResultsTableTableManager get aiResults =>
      $$AiResultsTableTableManager(_db, _db.aiResults);
  $$ConnectionEventsTableTableManager get connectionEvents =>
      $$ConnectionEventsTableTableManager(_db, _db.connectionEvents);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
