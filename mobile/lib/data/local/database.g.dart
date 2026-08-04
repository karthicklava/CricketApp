// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $TeamsTableTable extends TeamsTable
    with TableInfo<$TeamsTableTable, TeamsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TeamsTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _shortNameMeta =
      const VerificationMeta('shortName');
  @override
  late final GeneratedColumn<String> shortName = GeneratedColumn<String>(
      'short_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _logoUrlMeta =
      const VerificationMeta('logoUrl');
  @override
  late final GeneratedColumn<String> logoUrl = GeneratedColumn<String>(
      'logo_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cityMeta = const VerificationMeta('city');
  @override
  late final GeneratedColumn<String> city = GeneratedColumn<String>(
      'city', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _defaultCaptainIdMeta =
      const VerificationMeta('defaultCaptainId');
  @override
  late final GeneratedColumn<String> defaultCaptainId = GeneratedColumn<String>(
      'default_captain_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('localOnly'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        shortName,
        logoUrl,
        city,
        color,
        defaultCaptainId,
        createdAt,
        syncStatus
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'teams_table';
  @override
  VerificationContext validateIntegrity(Insertable<TeamsTableData> instance,
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
    if (data.containsKey('short_name')) {
      context.handle(_shortNameMeta,
          shortName.isAcceptableOrUnknown(data['short_name']!, _shortNameMeta));
    } else if (isInserting) {
      context.missing(_shortNameMeta);
    }
    if (data.containsKey('logo_url')) {
      context.handle(_logoUrlMeta,
          logoUrl.isAcceptableOrUnknown(data['logo_url']!, _logoUrlMeta));
    }
    if (data.containsKey('city')) {
      context.handle(
          _cityMeta, city.isAcceptableOrUnknown(data['city']!, _cityMeta));
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('default_captain_id')) {
      context.handle(
          _defaultCaptainIdMeta,
          defaultCaptainId.isAcceptableOrUnknown(
              data['default_captain_id']!, _defaultCaptainIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TeamsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TeamsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      shortName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}short_name'])!,
      logoUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}logo_url']),
      city: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}city']),
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color']),
      defaultCaptainId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}default_captain_id']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $TeamsTableTable createAlias(String alias) {
    return $TeamsTableTable(attachedDatabase, alias);
  }
}

class TeamsTableData extends DataClass implements Insertable<TeamsTableData> {
  final String id;
  final String name;
  final String shortName;
  final String? logoUrl;
  final String? city;
  final String? color;
  final String? defaultCaptainId;
  final int createdAt;
  final String syncStatus;
  const TeamsTableData(
      {required this.id,
      required this.name,
      required this.shortName,
      this.logoUrl,
      this.city,
      this.color,
      this.defaultCaptainId,
      required this.createdAt,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['short_name'] = Variable<String>(shortName);
    if (!nullToAbsent || logoUrl != null) {
      map['logo_url'] = Variable<String>(logoUrl);
    }
    if (!nullToAbsent || city != null) {
      map['city'] = Variable<String>(city);
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    if (!nullToAbsent || defaultCaptainId != null) {
      map['default_captain_id'] = Variable<String>(defaultCaptainId);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  TeamsTableCompanion toCompanion(bool nullToAbsent) {
    return TeamsTableCompanion(
      id: Value(id),
      name: Value(name),
      shortName: Value(shortName),
      logoUrl: logoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(logoUrl),
      city: city == null && nullToAbsent ? const Value.absent() : Value(city),
      color:
          color == null && nullToAbsent ? const Value.absent() : Value(color),
      defaultCaptainId: defaultCaptainId == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultCaptainId),
      createdAt: Value(createdAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory TeamsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TeamsTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      shortName: serializer.fromJson<String>(json['shortName']),
      logoUrl: serializer.fromJson<String?>(json['logoUrl']),
      city: serializer.fromJson<String?>(json['city']),
      color: serializer.fromJson<String?>(json['color']),
      defaultCaptainId: serializer.fromJson<String?>(json['defaultCaptainId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'shortName': serializer.toJson<String>(shortName),
      'logoUrl': serializer.toJson<String?>(logoUrl),
      'city': serializer.toJson<String?>(city),
      'color': serializer.toJson<String?>(color),
      'defaultCaptainId': serializer.toJson<String?>(defaultCaptainId),
      'createdAt': serializer.toJson<int>(createdAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  TeamsTableData copyWith(
          {String? id,
          String? name,
          String? shortName,
          Value<String?> logoUrl = const Value.absent(),
          Value<String?> city = const Value.absent(),
          Value<String?> color = const Value.absent(),
          Value<String?> defaultCaptainId = const Value.absent(),
          int? createdAt,
          String? syncStatus}) =>
      TeamsTableData(
        id: id ?? this.id,
        name: name ?? this.name,
        shortName: shortName ?? this.shortName,
        logoUrl: logoUrl.present ? logoUrl.value : this.logoUrl,
        city: city.present ? city.value : this.city,
        color: color.present ? color.value : this.color,
        defaultCaptainId: defaultCaptainId.present
            ? defaultCaptainId.value
            : this.defaultCaptainId,
        createdAt: createdAt ?? this.createdAt,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  TeamsTableData copyWithCompanion(TeamsTableCompanion data) {
    return TeamsTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      shortName: data.shortName.present ? data.shortName.value : this.shortName,
      logoUrl: data.logoUrl.present ? data.logoUrl.value : this.logoUrl,
      city: data.city.present ? data.city.value : this.city,
      color: data.color.present ? data.color.value : this.color,
      defaultCaptainId: data.defaultCaptainId.present
          ? data.defaultCaptainId.value
          : this.defaultCaptainId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TeamsTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('shortName: $shortName, ')
          ..write('logoUrl: $logoUrl, ')
          ..write('city: $city, ')
          ..write('color: $color, ')
          ..write('defaultCaptainId: $defaultCaptainId, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, shortName, logoUrl, city, color,
      defaultCaptainId, createdAt, syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TeamsTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.shortName == this.shortName &&
          other.logoUrl == this.logoUrl &&
          other.city == this.city &&
          other.color == this.color &&
          other.defaultCaptainId == this.defaultCaptainId &&
          other.createdAt == this.createdAt &&
          other.syncStatus == this.syncStatus);
}

class TeamsTableCompanion extends UpdateCompanion<TeamsTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> shortName;
  final Value<String?> logoUrl;
  final Value<String?> city;
  final Value<String?> color;
  final Value<String?> defaultCaptainId;
  final Value<int> createdAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const TeamsTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.shortName = const Value.absent(),
    this.logoUrl = const Value.absent(),
    this.city = const Value.absent(),
    this.color = const Value.absent(),
    this.defaultCaptainId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TeamsTableCompanion.insert({
    required String id,
    required String name,
    required String shortName,
    this.logoUrl = const Value.absent(),
    this.city = const Value.absent(),
    this.color = const Value.absent(),
    this.defaultCaptainId = const Value.absent(),
    required int createdAt,
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        shortName = Value(shortName),
        createdAt = Value(createdAt);
  static Insertable<TeamsTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? shortName,
    Expression<String>? logoUrl,
    Expression<String>? city,
    Expression<String>? color,
    Expression<String>? defaultCaptainId,
    Expression<int>? createdAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (shortName != null) 'short_name': shortName,
      if (logoUrl != null) 'logo_url': logoUrl,
      if (city != null) 'city': city,
      if (color != null) 'color': color,
      if (defaultCaptainId != null) 'default_captain_id': defaultCaptainId,
      if (createdAt != null) 'created_at': createdAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TeamsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? shortName,
      Value<String?>? logoUrl,
      Value<String?>? city,
      Value<String?>? color,
      Value<String?>? defaultCaptainId,
      Value<int>? createdAt,
      Value<String>? syncStatus,
      Value<int>? rowid}) {
    return TeamsTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      logoUrl: logoUrl ?? this.logoUrl,
      city: city ?? this.city,
      color: color ?? this.color,
      defaultCaptainId: defaultCaptainId ?? this.defaultCaptainId,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
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
    if (shortName.present) {
      map['short_name'] = Variable<String>(shortName.value);
    }
    if (logoUrl.present) {
      map['logo_url'] = Variable<String>(logoUrl.value);
    }
    if (city.present) {
      map['city'] = Variable<String>(city.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (defaultCaptainId.present) {
      map['default_captain_id'] = Variable<String>(defaultCaptainId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TeamsTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('shortName: $shortName, ')
          ..write('logoUrl: $logoUrl, ')
          ..write('city: $city, ')
          ..write('color: $color, ')
          ..write('defaultCaptainId: $defaultCaptainId, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlayersTableTable extends PlayersTable
    with TableInfo<$PlayersTableTable, PlayersTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayersTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _jerseyNumberMeta =
      const VerificationMeta('jerseyNumber');
  @override
  late final GeneratedColumn<String> jerseyNumber = GeneratedColumn<String>(
      'jersey_number', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('allRounder'));
  static const VerificationMeta _battingStyleMeta =
      const VerificationMeta('battingStyle');
  @override
  late final GeneratedColumn<String> battingStyle = GeneratedColumn<String>(
      'batting_style', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('notSet'));
  static const VerificationMeta _bowlingStyleMeta =
      const VerificationMeta('bowlingStyle');
  @override
  late final GeneratedColumn<String> bowlingStyle = GeneratedColumn<String>(
      'bowling_style', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('notSet'));
  static const VerificationMeta _isCaptainMeta =
      const VerificationMeta('isCaptain');
  @override
  late final GeneratedColumn<bool> isCaptain = GeneratedColumn<bool>(
      'is_captain', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_captain" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isWicketKeeperMeta =
      const VerificationMeta('isWicketKeeper');
  @override
  late final GeneratedColumn<bool> isWicketKeeper = GeneratedColumn<bool>(
      'is_wicket_keeper', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_wicket_keeper" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('localOnly'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        phone,
        jerseyNumber,
        role,
        battingStyle,
        bowlingStyle,
        isCaptain,
        isWicketKeeper,
        createdAt,
        syncStatus
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'players_table';
  @override
  VerificationContext validateIntegrity(Insertable<PlayersTableData> instance,
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
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('jersey_number')) {
      context.handle(
          _jerseyNumberMeta,
          jerseyNumber.isAcceptableOrUnknown(
              data['jersey_number']!, _jerseyNumberMeta));
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    }
    if (data.containsKey('batting_style')) {
      context.handle(
          _battingStyleMeta,
          battingStyle.isAcceptableOrUnknown(
              data['batting_style']!, _battingStyleMeta));
    }
    if (data.containsKey('bowling_style')) {
      context.handle(
          _bowlingStyleMeta,
          bowlingStyle.isAcceptableOrUnknown(
              data['bowling_style']!, _bowlingStyleMeta));
    }
    if (data.containsKey('is_captain')) {
      context.handle(_isCaptainMeta,
          isCaptain.isAcceptableOrUnknown(data['is_captain']!, _isCaptainMeta));
    }
    if (data.containsKey('is_wicket_keeper')) {
      context.handle(
          _isWicketKeeperMeta,
          isWicketKeeper.isAcceptableOrUnknown(
              data['is_wicket_keeper']!, _isWicketKeeperMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlayersTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlayersTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      jerseyNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}jersey_number']),
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      battingStyle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}batting_style'])!,
      bowlingStyle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}bowling_style'])!,
      isCaptain: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_captain'])!,
      isWicketKeeper: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_wicket_keeper'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $PlayersTableTable createAlias(String alias) {
    return $PlayersTableTable(attachedDatabase, alias);
  }
}

class PlayersTableData extends DataClass
    implements Insertable<PlayersTableData> {
  final String id;
  final String name;
  final String? phone;
  final String? jerseyNumber;
  final String role;
  final String battingStyle;
  final String bowlingStyle;
  final bool isCaptain;
  final bool isWicketKeeper;
  final int createdAt;
  final String syncStatus;
  const PlayersTableData(
      {required this.id,
      required this.name,
      this.phone,
      this.jerseyNumber,
      required this.role,
      required this.battingStyle,
      required this.bowlingStyle,
      required this.isCaptain,
      required this.isWicketKeeper,
      required this.createdAt,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || jerseyNumber != null) {
      map['jersey_number'] = Variable<String>(jerseyNumber);
    }
    map['role'] = Variable<String>(role);
    map['batting_style'] = Variable<String>(battingStyle);
    map['bowling_style'] = Variable<String>(bowlingStyle);
    map['is_captain'] = Variable<bool>(isCaptain);
    map['is_wicket_keeper'] = Variable<bool>(isWicketKeeper);
    map['created_at'] = Variable<int>(createdAt);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  PlayersTableCompanion toCompanion(bool nullToAbsent) {
    return PlayersTableCompanion(
      id: Value(id),
      name: Value(name),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      jerseyNumber: jerseyNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(jerseyNumber),
      role: Value(role),
      battingStyle: Value(battingStyle),
      bowlingStyle: Value(bowlingStyle),
      isCaptain: Value(isCaptain),
      isWicketKeeper: Value(isWicketKeeper),
      createdAt: Value(createdAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory PlayersTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlayersTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String?>(json['phone']),
      jerseyNumber: serializer.fromJson<String?>(json['jerseyNumber']),
      role: serializer.fromJson<String>(json['role']),
      battingStyle: serializer.fromJson<String>(json['battingStyle']),
      bowlingStyle: serializer.fromJson<String>(json['bowlingStyle']),
      isCaptain: serializer.fromJson<bool>(json['isCaptain']),
      isWicketKeeper: serializer.fromJson<bool>(json['isWicketKeeper']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String?>(phone),
      'jerseyNumber': serializer.toJson<String?>(jerseyNumber),
      'role': serializer.toJson<String>(role),
      'battingStyle': serializer.toJson<String>(battingStyle),
      'bowlingStyle': serializer.toJson<String>(bowlingStyle),
      'isCaptain': serializer.toJson<bool>(isCaptain),
      'isWicketKeeper': serializer.toJson<bool>(isWicketKeeper),
      'createdAt': serializer.toJson<int>(createdAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  PlayersTableData copyWith(
          {String? id,
          String? name,
          Value<String?> phone = const Value.absent(),
          Value<String?> jerseyNumber = const Value.absent(),
          String? role,
          String? battingStyle,
          String? bowlingStyle,
          bool? isCaptain,
          bool? isWicketKeeper,
          int? createdAt,
          String? syncStatus}) =>
      PlayersTableData(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone.present ? phone.value : this.phone,
        jerseyNumber:
            jerseyNumber.present ? jerseyNumber.value : this.jerseyNumber,
        role: role ?? this.role,
        battingStyle: battingStyle ?? this.battingStyle,
        bowlingStyle: bowlingStyle ?? this.bowlingStyle,
        isCaptain: isCaptain ?? this.isCaptain,
        isWicketKeeper: isWicketKeeper ?? this.isWicketKeeper,
        createdAt: createdAt ?? this.createdAt,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  PlayersTableData copyWithCompanion(PlayersTableCompanion data) {
    return PlayersTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      jerseyNumber: data.jerseyNumber.present
          ? data.jerseyNumber.value
          : this.jerseyNumber,
      role: data.role.present ? data.role.value : this.role,
      battingStyle: data.battingStyle.present
          ? data.battingStyle.value
          : this.battingStyle,
      bowlingStyle: data.bowlingStyle.present
          ? data.bowlingStyle.value
          : this.bowlingStyle,
      isCaptain: data.isCaptain.present ? data.isCaptain.value : this.isCaptain,
      isWicketKeeper: data.isWicketKeeper.present
          ? data.isWicketKeeper.value
          : this.isWicketKeeper,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlayersTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('jerseyNumber: $jerseyNumber, ')
          ..write('role: $role, ')
          ..write('battingStyle: $battingStyle, ')
          ..write('bowlingStyle: $bowlingStyle, ')
          ..write('isCaptain: $isCaptain, ')
          ..write('isWicketKeeper: $isWicketKeeper, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      phone,
      jerseyNumber,
      role,
      battingStyle,
      bowlingStyle,
      isCaptain,
      isWicketKeeper,
      createdAt,
      syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlayersTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.jerseyNumber == this.jerseyNumber &&
          other.role == this.role &&
          other.battingStyle == this.battingStyle &&
          other.bowlingStyle == this.bowlingStyle &&
          other.isCaptain == this.isCaptain &&
          other.isWicketKeeper == this.isWicketKeeper &&
          other.createdAt == this.createdAt &&
          other.syncStatus == this.syncStatus);
}

class PlayersTableCompanion extends UpdateCompanion<PlayersTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> phone;
  final Value<String?> jerseyNumber;
  final Value<String> role;
  final Value<String> battingStyle;
  final Value<String> bowlingStyle;
  final Value<bool> isCaptain;
  final Value<bool> isWicketKeeper;
  final Value<int> createdAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const PlayersTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.jerseyNumber = const Value.absent(),
    this.role = const Value.absent(),
    this.battingStyle = const Value.absent(),
    this.bowlingStyle = const Value.absent(),
    this.isCaptain = const Value.absent(),
    this.isWicketKeeper = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlayersTableCompanion.insert({
    required String id,
    required String name,
    this.phone = const Value.absent(),
    this.jerseyNumber = const Value.absent(),
    this.role = const Value.absent(),
    this.battingStyle = const Value.absent(),
    this.bowlingStyle = const Value.absent(),
    this.isCaptain = const Value.absent(),
    this.isWicketKeeper = const Value.absent(),
    required int createdAt,
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        createdAt = Value(createdAt);
  static Insertable<PlayersTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? jerseyNumber,
    Expression<String>? role,
    Expression<String>? battingStyle,
    Expression<String>? bowlingStyle,
    Expression<bool>? isCaptain,
    Expression<bool>? isWicketKeeper,
    Expression<int>? createdAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (jerseyNumber != null) 'jersey_number': jerseyNumber,
      if (role != null) 'role': role,
      if (battingStyle != null) 'batting_style': battingStyle,
      if (bowlingStyle != null) 'bowling_style': bowlingStyle,
      if (isCaptain != null) 'is_captain': isCaptain,
      if (isWicketKeeper != null) 'is_wicket_keeper': isWicketKeeper,
      if (createdAt != null) 'created_at': createdAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlayersTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? phone,
      Value<String?>? jerseyNumber,
      Value<String>? role,
      Value<String>? battingStyle,
      Value<String>? bowlingStyle,
      Value<bool>? isCaptain,
      Value<bool>? isWicketKeeper,
      Value<int>? createdAt,
      Value<String>? syncStatus,
      Value<int>? rowid}) {
    return PlayersTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      jerseyNumber: jerseyNumber ?? this.jerseyNumber,
      role: role ?? this.role,
      battingStyle: battingStyle ?? this.battingStyle,
      bowlingStyle: bowlingStyle ?? this.bowlingStyle,
      isCaptain: isCaptain ?? this.isCaptain,
      isWicketKeeper: isWicketKeeper ?? this.isWicketKeeper,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
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
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (jerseyNumber.present) {
      map['jersey_number'] = Variable<String>(jerseyNumber.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (battingStyle.present) {
      map['batting_style'] = Variable<String>(battingStyle.value);
    }
    if (bowlingStyle.present) {
      map['bowling_style'] = Variable<String>(bowlingStyle.value);
    }
    if (isCaptain.present) {
      map['is_captain'] = Variable<bool>(isCaptain.value);
    }
    if (isWicketKeeper.present) {
      map['is_wicket_keeper'] = Variable<bool>(isWicketKeeper.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlayersTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('jerseyNumber: $jerseyNumber, ')
          ..write('role: $role, ')
          ..write('battingStyle: $battingStyle, ')
          ..write('bowlingStyle: $bowlingStyle, ')
          ..write('isCaptain: $isCaptain, ')
          ..write('isWicketKeeper: $isWicketKeeper, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TeamMembersTableTable extends TeamMembersTable
    with TableInfo<$TeamMembersTableTable, TeamMembersTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TeamMembersTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _teamIdMeta = const VerificationMeta('teamId');
  @override
  late final GeneratedColumn<String> teamId = GeneratedColumn<String>(
      'team_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _playerIdMeta =
      const VerificationMeta('playerId');
  @override
  late final GeneratedColumn<String> playerId = GeneratedColumn<String>(
      'player_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _joinedAtMeta =
      const VerificationMeta('joinedAt');
  @override
  late final GeneratedColumn<int> joinedAt = GeneratedColumn<int>(
      'joined_at', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _removedAtMeta =
      const VerificationMeta('removedAt');
  @override
  late final GeneratedColumn<int> removedAt = GeneratedColumn<int>(
      'removed_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [teamId, playerId, isActive, joinedAt, removedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'team_members_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<TeamMembersTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('team_id')) {
      context.handle(_teamIdMeta,
          teamId.isAcceptableOrUnknown(data['team_id']!, _teamIdMeta));
    } else if (isInserting) {
      context.missing(_teamIdMeta);
    }
    if (data.containsKey('player_id')) {
      context.handle(_playerIdMeta,
          playerId.isAcceptableOrUnknown(data['player_id']!, _playerIdMeta));
    } else if (isInserting) {
      context.missing(_playerIdMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('joined_at')) {
      context.handle(_joinedAtMeta,
          joinedAt.isAcceptableOrUnknown(data['joined_at']!, _joinedAtMeta));
    }
    if (data.containsKey('removed_at')) {
      context.handle(_removedAtMeta,
          removedAt.isAcceptableOrUnknown(data['removed_at']!, _removedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {teamId, playerId};
  @override
  TeamMembersTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TeamMembersTableData(
      teamId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}team_id'])!,
      playerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}player_id'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      joinedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}joined_at'])!,
      removedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}removed_at']),
    );
  }

  @override
  $TeamMembersTableTable createAlias(String alias) {
    return $TeamMembersTableTable(attachedDatabase, alias);
  }
}

class TeamMembersTableData extends DataClass
    implements Insertable<TeamMembersTableData> {
  final String teamId;
  final String playerId;
  final bool isActive;
  final int joinedAt;
  final int? removedAt;
  const TeamMembersTableData(
      {required this.teamId,
      required this.playerId,
      required this.isActive,
      required this.joinedAt,
      this.removedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['team_id'] = Variable<String>(teamId);
    map['player_id'] = Variable<String>(playerId);
    map['is_active'] = Variable<bool>(isActive);
    map['joined_at'] = Variable<int>(joinedAt);
    if (!nullToAbsent || removedAt != null) {
      map['removed_at'] = Variable<int>(removedAt);
    }
    return map;
  }

  TeamMembersTableCompanion toCompanion(bool nullToAbsent) {
    return TeamMembersTableCompanion(
      teamId: Value(teamId),
      playerId: Value(playerId),
      isActive: Value(isActive),
      joinedAt: Value(joinedAt),
      removedAt: removedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(removedAt),
    );
  }

  factory TeamMembersTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TeamMembersTableData(
      teamId: serializer.fromJson<String>(json['teamId']),
      playerId: serializer.fromJson<String>(json['playerId']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      joinedAt: serializer.fromJson<int>(json['joinedAt']),
      removedAt: serializer.fromJson<int?>(json['removedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'teamId': serializer.toJson<String>(teamId),
      'playerId': serializer.toJson<String>(playerId),
      'isActive': serializer.toJson<bool>(isActive),
      'joinedAt': serializer.toJson<int>(joinedAt),
      'removedAt': serializer.toJson<int?>(removedAt),
    };
  }

  TeamMembersTableData copyWith(
          {String? teamId,
          String? playerId,
          bool? isActive,
          int? joinedAt,
          Value<int?> removedAt = const Value.absent()}) =>
      TeamMembersTableData(
        teamId: teamId ?? this.teamId,
        playerId: playerId ?? this.playerId,
        isActive: isActive ?? this.isActive,
        joinedAt: joinedAt ?? this.joinedAt,
        removedAt: removedAt.present ? removedAt.value : this.removedAt,
      );
  TeamMembersTableData copyWithCompanion(TeamMembersTableCompanion data) {
    return TeamMembersTableData(
      teamId: data.teamId.present ? data.teamId.value : this.teamId,
      playerId: data.playerId.present ? data.playerId.value : this.playerId,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      joinedAt: data.joinedAt.present ? data.joinedAt.value : this.joinedAt,
      removedAt: data.removedAt.present ? data.removedAt.value : this.removedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TeamMembersTableData(')
          ..write('teamId: $teamId, ')
          ..write('playerId: $playerId, ')
          ..write('isActive: $isActive, ')
          ..write('joinedAt: $joinedAt, ')
          ..write('removedAt: $removedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(teamId, playerId, isActive, joinedAt, removedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TeamMembersTableData &&
          other.teamId == this.teamId &&
          other.playerId == this.playerId &&
          other.isActive == this.isActive &&
          other.joinedAt == this.joinedAt &&
          other.removedAt == this.removedAt);
}

class TeamMembersTableCompanion extends UpdateCompanion<TeamMembersTableData> {
  final Value<String> teamId;
  final Value<String> playerId;
  final Value<bool> isActive;
  final Value<int> joinedAt;
  final Value<int?> removedAt;
  final Value<int> rowid;
  const TeamMembersTableCompanion({
    this.teamId = const Value.absent(),
    this.playerId = const Value.absent(),
    this.isActive = const Value.absent(),
    this.joinedAt = const Value.absent(),
    this.removedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TeamMembersTableCompanion.insert({
    required String teamId,
    required String playerId,
    this.isActive = const Value.absent(),
    this.joinedAt = const Value.absent(),
    this.removedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : teamId = Value(teamId),
        playerId = Value(playerId);
  static Insertable<TeamMembersTableData> custom({
    Expression<String>? teamId,
    Expression<String>? playerId,
    Expression<bool>? isActive,
    Expression<int>? joinedAt,
    Expression<int>? removedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (teamId != null) 'team_id': teamId,
      if (playerId != null) 'player_id': playerId,
      if (isActive != null) 'is_active': isActive,
      if (joinedAt != null) 'joined_at': joinedAt,
      if (removedAt != null) 'removed_at': removedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TeamMembersTableCompanion copyWith(
      {Value<String>? teamId,
      Value<String>? playerId,
      Value<bool>? isActive,
      Value<int>? joinedAt,
      Value<int?>? removedAt,
      Value<int>? rowid}) {
    return TeamMembersTableCompanion(
      teamId: teamId ?? this.teamId,
      playerId: playerId ?? this.playerId,
      isActive: isActive ?? this.isActive,
      joinedAt: joinedAt ?? this.joinedAt,
      removedAt: removedAt ?? this.removedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (teamId.present) {
      map['team_id'] = Variable<String>(teamId.value);
    }
    if (playerId.present) {
      map['player_id'] = Variable<String>(playerId.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (joinedAt.present) {
      map['joined_at'] = Variable<int>(joinedAt.value);
    }
    if (removedAt.present) {
      map['removed_at'] = Variable<int>(removedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TeamMembersTableCompanion(')
          ..write('teamId: $teamId, ')
          ..write('playerId: $playerId, ')
          ..write('isActive: $isActive, ')
          ..write('joinedAt: $joinedAt, ')
          ..write('removedAt: $removedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MatchesTableTable extends MatchesTable
    with TableInfo<$MatchesTableTable, MatchesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MatchesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _matchNameMeta =
      const VerificationMeta('matchName');
  @override
  late final GeneratedColumn<String> matchName = GeneratedColumn<String>(
      'match_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _tournamentIdMeta =
      const VerificationMeta('tournamentId');
  @override
  late final GeneratedColumn<String> tournamentId = GeneratedColumn<String>(
      'tournament_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _teamAIdMeta =
      const VerificationMeta('teamAId');
  @override
  late final GeneratedColumn<String> teamAId = GeneratedColumn<String>(
      'team_a_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _teamBIdMeta =
      const VerificationMeta('teamBId');
  @override
  late final GeneratedColumn<String> teamBId = GeneratedColumn<String>(
      'team_b_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _formatMeta = const VerificationMeta('format');
  @override
  late final GeneratedColumn<String> format = GeneratedColumn<String>(
      'format', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('t20'));
  static const VerificationMeta _totalOversMeta =
      const VerificationMeta('totalOvers');
  @override
  late final GeneratedColumn<int> totalOvers = GeneratedColumn<int>(
      'total_overs', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _ballsPerOverMeta =
      const VerificationMeta('ballsPerOver');
  @override
  late final GeneratedColumn<int> ballsPerOver = GeneratedColumn<int>(
      'balls_per_over', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _maxOversPerBowlerMeta =
      const VerificationMeta('maxOversPerBowler');
  @override
  late final GeneratedColumn<int> maxOversPerBowler = GeneratedColumn<int>(
      'max_overs_per_bowler', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _allowConsecutiveOversMeta =
      const VerificationMeta('allowConsecutiveOvers');
  @override
  late final GeneratedColumn<bool> allowConsecutiveOvers =
      GeneratedColumn<bool>('allow_consecutive_overs', aliasedName, true,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("allow_consecutive_overs" IN (0, 1))'));
  static const VerificationMeta _maxOversWasManuallyEditedMeta =
      const VerificationMeta('maxOversWasManuallyEdited');
  @override
  late final GeneratedColumn<bool> maxOversWasManuallyEdited =
      GeneratedColumn<bool>('max_overs_was_manually_edited', aliasedName, true,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("max_overs_was_manually_edited" IN (0, 1))'));
  static const VerificationMeta _venueNameMeta =
      const VerificationMeta('venueName');
  @override
  late final GeneratedColumn<String> venueName = GeneratedColumn<String>(
      'venue_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _scheduledAtMeta =
      const VerificationMeta('scheduledAt');
  @override
  late final GeneratedColumn<int> scheduledAt = GeneratedColumn<int>(
      'scheduled_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _startedAtMeta =
      const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<int> startedAt = GeneratedColumn<int>(
      'started_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _matchTimeZoneMeta =
      const VerificationMeta('matchTimeZone');
  @override
  late final GeneratedColumn<String> matchTimeZone = GeneratedColumn<String>(
      'match_time_zone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _tossWinnerTeamIdMeta =
      const VerificationMeta('tossWinnerTeamId');
  @override
  late final GeneratedColumn<String> tossWinnerTeamId = GeneratedColumn<String>(
      'toss_winner_team_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _tossDecisionMeta =
      const VerificationMeta('tossDecision');
  @override
  late final GeneratedColumn<String> tossDecision = GeneratedColumn<String>(
      'toss_decision', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _teamASquadJsonMeta =
      const VerificationMeta('teamASquadJson');
  @override
  late final GeneratedColumn<String> teamASquadJson = GeneratedColumn<String>(
      'team_a_squad_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _teamBSquadJsonMeta =
      const VerificationMeta('teamBSquadJson');
  @override
  late final GeneratedColumn<String> teamBSquadJson = GeneratedColumn<String>(
      'team_b_squad_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _teamACaptainIdMeta =
      const VerificationMeta('teamACaptainId');
  @override
  late final GeneratedColumn<String> teamACaptainId = GeneratedColumn<String>(
      'team_a_captain_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _teamBCaptainIdMeta =
      const VerificationMeta('teamBCaptainId');
  @override
  late final GeneratedColumn<String> teamBCaptainId = GeneratedColumn<String>(
      'team_b_captain_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _teamAWicketkeeperIdMeta =
      const VerificationMeta('teamAWicketkeeperId');
  @override
  late final GeneratedColumn<String> teamAWicketkeeperId =
      GeneratedColumn<String>('team_a_wicketkeeper_id', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _teamBWicketkeeperIdMeta =
      const VerificationMeta('teamBWicketkeeperId');
  @override
  late final GeneratedColumn<String> teamBWicketkeeperId =
      GeneratedColumn<String>('team_b_wicketkeeper_id', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('draft'));
  static const VerificationMeta _currentScorerDeviceIdMeta =
      const VerificationMeta('currentScorerDeviceId');
  @override
  late final GeneratedColumn<String> currentScorerDeviceId =
      GeneratedColumn<String>('current_scorer_device_id', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('localOnly'));
  static const VerificationMeta _stateJsonMeta =
      const VerificationMeta('stateJson');
  @override
  late final GeneratedColumn<String> stateJson = GeneratedColumn<String>(
      'state_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _setupDraftJsonMeta =
      const VerificationMeta('setupDraftJson');
  @override
  late final GeneratedColumn<String> setupDraftJson = GeneratedColumn<String>(
      'setup_draft_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _endReasonCodeMeta =
      const VerificationMeta('endReasonCode');
  @override
  late final GeneratedColumn<String> endReasonCode = GeneratedColumn<String>(
      'end_reason_code', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _endReasonTextMeta =
      const VerificationMeta('endReasonText');
  @override
  late final GeneratedColumn<String> endReasonText = GeneratedColumn<String>(
      'end_reason_text', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _endNoteMeta =
      const VerificationMeta('endNote');
  @override
  late final GeneratedColumn<String> endNote = GeneratedColumn<String>(
      'end_note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _endedManuallyMeta =
      const VerificationMeta('endedManually');
  @override
  late final GeneratedColumn<bool> endedManually = GeneratedColumn<bool>(
      'ended_manually', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("ended_manually" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _endedAtMeta =
      const VerificationMeta('endedAt');
  @override
  late final GeneratedColumn<int> endedAt = GeneratedColumn<int>(
      'ended_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _endedByMeta =
      const VerificationMeta('endedBy');
  @override
  late final GeneratedColumn<String> endedBy = GeneratedColumn<String>(
      'ended_by', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _winnerTeamIdMeta =
      const VerificationMeta('winnerTeamId');
  @override
  late final GeneratedColumn<String> winnerTeamId = GeneratedColumn<String>(
      'winner_team_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _loserTeamIdMeta =
      const VerificationMeta('loserTeamId');
  @override
  late final GeneratedColumn<String> loserTeamId = GeneratedColumn<String>(
      'loser_team_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _resultTypeMeta =
      const VerificationMeta('resultType');
  @override
  late final GeneratedColumn<String> resultType = GeneratedColumn<String>(
      'result_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _resultTextMeta =
      const VerificationMeta('resultText');
  @override
  late final GeneratedColumn<String> resultText = GeneratedColumn<String>(
      'result_text', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        matchName,
        tournamentId,
        teamAId,
        teamBId,
        format,
        totalOvers,
        ballsPerOver,
        maxOversPerBowler,
        allowConsecutiveOvers,
        maxOversWasManuallyEdited,
        venueName,
        scheduledAt,
        startedAt,
        matchTimeZone,
        tossWinnerTeamId,
        tossDecision,
        teamASquadJson,
        teamBSquadJson,
        teamACaptainId,
        teamBCaptainId,
        teamAWicketkeeperId,
        teamBWicketkeeperId,
        status,
        currentScorerDeviceId,
        version,
        syncStatus,
        stateJson,
        setupDraftJson,
        createdAt,
        endReasonCode,
        endReasonText,
        endNote,
        endedManually,
        endedAt,
        endedBy,
        winnerTeamId,
        loserTeamId,
        resultType,
        resultText
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'matches_table';
  @override
  VerificationContext validateIntegrity(Insertable<MatchesTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('match_name')) {
      context.handle(_matchNameMeta,
          matchName.isAcceptableOrUnknown(data['match_name']!, _matchNameMeta));
    }
    if (data.containsKey('tournament_id')) {
      context.handle(
          _tournamentIdMeta,
          tournamentId.isAcceptableOrUnknown(
              data['tournament_id']!, _tournamentIdMeta));
    }
    if (data.containsKey('team_a_id')) {
      context.handle(_teamAIdMeta,
          teamAId.isAcceptableOrUnknown(data['team_a_id']!, _teamAIdMeta));
    } else if (isInserting) {
      context.missing(_teamAIdMeta);
    }
    if (data.containsKey('team_b_id')) {
      context.handle(_teamBIdMeta,
          teamBId.isAcceptableOrUnknown(data['team_b_id']!, _teamBIdMeta));
    } else if (isInserting) {
      context.missing(_teamBIdMeta);
    }
    if (data.containsKey('format')) {
      context.handle(_formatMeta,
          format.isAcceptableOrUnknown(data['format']!, _formatMeta));
    }
    if (data.containsKey('total_overs')) {
      context.handle(
          _totalOversMeta,
          totalOvers.isAcceptableOrUnknown(
              data['total_overs']!, _totalOversMeta));
    }
    if (data.containsKey('balls_per_over')) {
      context.handle(
          _ballsPerOverMeta,
          ballsPerOver.isAcceptableOrUnknown(
              data['balls_per_over']!, _ballsPerOverMeta));
    }
    if (data.containsKey('max_overs_per_bowler')) {
      context.handle(
          _maxOversPerBowlerMeta,
          maxOversPerBowler.isAcceptableOrUnknown(
              data['max_overs_per_bowler']!, _maxOversPerBowlerMeta));
    }
    if (data.containsKey('allow_consecutive_overs')) {
      context.handle(
          _allowConsecutiveOversMeta,
          allowConsecutiveOvers.isAcceptableOrUnknown(
              data['allow_consecutive_overs']!, _allowConsecutiveOversMeta));
    }
    if (data.containsKey('max_overs_was_manually_edited')) {
      context.handle(
          _maxOversWasManuallyEditedMeta,
          maxOversWasManuallyEdited.isAcceptableOrUnknown(
              data['max_overs_was_manually_edited']!,
              _maxOversWasManuallyEditedMeta));
    }
    if (data.containsKey('venue_name')) {
      context.handle(_venueNameMeta,
          venueName.isAcceptableOrUnknown(data['venue_name']!, _venueNameMeta));
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
          _scheduledAtMeta,
          scheduledAt.isAcceptableOrUnknown(
              data['scheduled_at']!, _scheduledAtMeta));
    } else if (isInserting) {
      context.missing(_scheduledAtMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta,
          startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    }
    if (data.containsKey('match_time_zone')) {
      context.handle(
          _matchTimeZoneMeta,
          matchTimeZone.isAcceptableOrUnknown(
              data['match_time_zone']!, _matchTimeZoneMeta));
    }
    if (data.containsKey('toss_winner_team_id')) {
      context.handle(
          _tossWinnerTeamIdMeta,
          tossWinnerTeamId.isAcceptableOrUnknown(
              data['toss_winner_team_id']!, _tossWinnerTeamIdMeta));
    }
    if (data.containsKey('toss_decision')) {
      context.handle(
          _tossDecisionMeta,
          tossDecision.isAcceptableOrUnknown(
              data['toss_decision']!, _tossDecisionMeta));
    }
    if (data.containsKey('team_a_squad_json')) {
      context.handle(
          _teamASquadJsonMeta,
          teamASquadJson.isAcceptableOrUnknown(
              data['team_a_squad_json']!, _teamASquadJsonMeta));
    }
    if (data.containsKey('team_b_squad_json')) {
      context.handle(
          _teamBSquadJsonMeta,
          teamBSquadJson.isAcceptableOrUnknown(
              data['team_b_squad_json']!, _teamBSquadJsonMeta));
    }
    if (data.containsKey('team_a_captain_id')) {
      context.handle(
          _teamACaptainIdMeta,
          teamACaptainId.isAcceptableOrUnknown(
              data['team_a_captain_id']!, _teamACaptainIdMeta));
    }
    if (data.containsKey('team_b_captain_id')) {
      context.handle(
          _teamBCaptainIdMeta,
          teamBCaptainId.isAcceptableOrUnknown(
              data['team_b_captain_id']!, _teamBCaptainIdMeta));
    }
    if (data.containsKey('team_a_wicketkeeper_id')) {
      context.handle(
          _teamAWicketkeeperIdMeta,
          teamAWicketkeeperId.isAcceptableOrUnknown(
              data['team_a_wicketkeeper_id']!, _teamAWicketkeeperIdMeta));
    }
    if (data.containsKey('team_b_wicketkeeper_id')) {
      context.handle(
          _teamBWicketkeeperIdMeta,
          teamBWicketkeeperId.isAcceptableOrUnknown(
              data['team_b_wicketkeeper_id']!, _teamBWicketkeeperIdMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('current_scorer_device_id')) {
      context.handle(
          _currentScorerDeviceIdMeta,
          currentScorerDeviceId.isAcceptableOrUnknown(
              data['current_scorer_device_id']!, _currentScorerDeviceIdMeta));
    } else if (isInserting) {
      context.missing(_currentScorerDeviceIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('state_json')) {
      context.handle(_stateJsonMeta,
          stateJson.isAcceptableOrUnknown(data['state_json']!, _stateJsonMeta));
    }
    if (data.containsKey('setup_draft_json')) {
      context.handle(
          _setupDraftJsonMeta,
          setupDraftJson.isAcceptableOrUnknown(
              data['setup_draft_json']!, _setupDraftJsonMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('end_reason_code')) {
      context.handle(
          _endReasonCodeMeta,
          endReasonCode.isAcceptableOrUnknown(
              data['end_reason_code']!, _endReasonCodeMeta));
    }
    if (data.containsKey('end_reason_text')) {
      context.handle(
          _endReasonTextMeta,
          endReasonText.isAcceptableOrUnknown(
              data['end_reason_text']!, _endReasonTextMeta));
    }
    if (data.containsKey('end_note')) {
      context.handle(_endNoteMeta,
          endNote.isAcceptableOrUnknown(data['end_note']!, _endNoteMeta));
    }
    if (data.containsKey('ended_manually')) {
      context.handle(
          _endedManuallyMeta,
          endedManually.isAcceptableOrUnknown(
              data['ended_manually']!, _endedManuallyMeta));
    }
    if (data.containsKey('ended_at')) {
      context.handle(_endedAtMeta,
          endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta));
    }
    if (data.containsKey('ended_by')) {
      context.handle(_endedByMeta,
          endedBy.isAcceptableOrUnknown(data['ended_by']!, _endedByMeta));
    }
    if (data.containsKey('winner_team_id')) {
      context.handle(
          _winnerTeamIdMeta,
          winnerTeamId.isAcceptableOrUnknown(
              data['winner_team_id']!, _winnerTeamIdMeta));
    }
    if (data.containsKey('loser_team_id')) {
      context.handle(
          _loserTeamIdMeta,
          loserTeamId.isAcceptableOrUnknown(
              data['loser_team_id']!, _loserTeamIdMeta));
    }
    if (data.containsKey('result_type')) {
      context.handle(
          _resultTypeMeta,
          resultType.isAcceptableOrUnknown(
              data['result_type']!, _resultTypeMeta));
    }
    if (data.containsKey('result_text')) {
      context.handle(
          _resultTextMeta,
          resultText.isAcceptableOrUnknown(
              data['result_text']!, _resultTextMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MatchesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MatchesTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      matchName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}match_name']),
      tournamentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tournament_id']),
      teamAId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}team_a_id'])!,
      teamBId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}team_b_id'])!,
      format: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}format'])!,
      totalOvers: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_overs']),
      ballsPerOver: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}balls_per_over']),
      maxOversPerBowler: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}max_overs_per_bowler']),
      allowConsecutiveOvers: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}allow_consecutive_overs']),
      maxOversWasManuallyEdited: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}max_overs_was_manually_edited']),
      venueName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}venue_name']),
      scheduledAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}scheduled_at'])!,
      startedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}started_at']),
      matchTimeZone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}match_time_zone']),
      tossWinnerTeamId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}toss_winner_team_id']),
      tossDecision: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}toss_decision']),
      teamASquadJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}team_a_squad_json']),
      teamBSquadJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}team_b_squad_json']),
      teamACaptainId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}team_a_captain_id']),
      teamBCaptainId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}team_b_captain_id']),
      teamAWicketkeeperId: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}team_a_wicketkeeper_id']),
      teamBWicketkeeperId: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}team_b_wicketkeeper_id']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      currentScorerDeviceId: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}current_scorer_device_id'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      stateJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}state_json']),
      setupDraftJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}setup_draft_json']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      endReasonCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}end_reason_code']),
      endReasonText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}end_reason_text']),
      endNote: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}end_note']),
      endedManually: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}ended_manually'])!,
      endedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ended_at']),
      endedBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ended_by']),
      winnerTeamId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}winner_team_id']),
      loserTeamId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}loser_team_id']),
      resultType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}result_type']),
      resultText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}result_text']),
    );
  }

  @override
  $MatchesTableTable createAlias(String alias) {
    return $MatchesTableTable(attachedDatabase, alias);
  }
}

class MatchesTableData extends DataClass
    implements Insertable<MatchesTableData> {
  final String id;
  final String? matchName;
  final String? tournamentId;
  final String teamAId;
  final String teamBId;
  final String format;
  final int? totalOvers;
  final int? ballsPerOver;
  final int? maxOversPerBowler;
  final bool? allowConsecutiveOvers;
  final bool? maxOversWasManuallyEdited;
  final String? venueName;
  final int scheduledAt;
  final int? startedAt;
  final String? matchTimeZone;
  final String? tossWinnerTeamId;
  final String? tossDecision;
  final String? teamASquadJson;
  final String? teamBSquadJson;
  final String? teamACaptainId;
  final String? teamBCaptainId;
  final String? teamAWicketkeeperId;
  final String? teamBWicketkeeperId;
  final String status;
  final String currentScorerDeviceId;
  final int version;
  final String syncStatus;
  final String? stateJson;
  final String? setupDraftJson;
  final int createdAt;
  final String? endReasonCode;
  final String? endReasonText;
  final String? endNote;
  final bool endedManually;
  final int? endedAt;
  final String? endedBy;
  final String? winnerTeamId;
  final String? loserTeamId;
  final String? resultType;
  final String? resultText;
  const MatchesTableData(
      {required this.id,
      this.matchName,
      this.tournamentId,
      required this.teamAId,
      required this.teamBId,
      required this.format,
      this.totalOvers,
      this.ballsPerOver,
      this.maxOversPerBowler,
      this.allowConsecutiveOvers,
      this.maxOversWasManuallyEdited,
      this.venueName,
      required this.scheduledAt,
      this.startedAt,
      this.matchTimeZone,
      this.tossWinnerTeamId,
      this.tossDecision,
      this.teamASquadJson,
      this.teamBSquadJson,
      this.teamACaptainId,
      this.teamBCaptainId,
      this.teamAWicketkeeperId,
      this.teamBWicketkeeperId,
      required this.status,
      required this.currentScorerDeviceId,
      required this.version,
      required this.syncStatus,
      this.stateJson,
      this.setupDraftJson,
      required this.createdAt,
      this.endReasonCode,
      this.endReasonText,
      this.endNote,
      required this.endedManually,
      this.endedAt,
      this.endedBy,
      this.winnerTeamId,
      this.loserTeamId,
      this.resultType,
      this.resultText});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || matchName != null) {
      map['match_name'] = Variable<String>(matchName);
    }
    if (!nullToAbsent || tournamentId != null) {
      map['tournament_id'] = Variable<String>(tournamentId);
    }
    map['team_a_id'] = Variable<String>(teamAId);
    map['team_b_id'] = Variable<String>(teamBId);
    map['format'] = Variable<String>(format);
    if (!nullToAbsent || totalOvers != null) {
      map['total_overs'] = Variable<int>(totalOvers);
    }
    if (!nullToAbsent || ballsPerOver != null) {
      map['balls_per_over'] = Variable<int>(ballsPerOver);
    }
    if (!nullToAbsent || maxOversPerBowler != null) {
      map['max_overs_per_bowler'] = Variable<int>(maxOversPerBowler);
    }
    if (!nullToAbsent || allowConsecutiveOvers != null) {
      map['allow_consecutive_overs'] = Variable<bool>(allowConsecutiveOvers);
    }
    if (!nullToAbsent || maxOversWasManuallyEdited != null) {
      map['max_overs_was_manually_edited'] =
          Variable<bool>(maxOversWasManuallyEdited);
    }
    if (!nullToAbsent || venueName != null) {
      map['venue_name'] = Variable<String>(venueName);
    }
    map['scheduled_at'] = Variable<int>(scheduledAt);
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<int>(startedAt);
    }
    if (!nullToAbsent || matchTimeZone != null) {
      map['match_time_zone'] = Variable<String>(matchTimeZone);
    }
    if (!nullToAbsent || tossWinnerTeamId != null) {
      map['toss_winner_team_id'] = Variable<String>(tossWinnerTeamId);
    }
    if (!nullToAbsent || tossDecision != null) {
      map['toss_decision'] = Variable<String>(tossDecision);
    }
    if (!nullToAbsent || teamASquadJson != null) {
      map['team_a_squad_json'] = Variable<String>(teamASquadJson);
    }
    if (!nullToAbsent || teamBSquadJson != null) {
      map['team_b_squad_json'] = Variable<String>(teamBSquadJson);
    }
    if (!nullToAbsent || teamACaptainId != null) {
      map['team_a_captain_id'] = Variable<String>(teamACaptainId);
    }
    if (!nullToAbsent || teamBCaptainId != null) {
      map['team_b_captain_id'] = Variable<String>(teamBCaptainId);
    }
    if (!nullToAbsent || teamAWicketkeeperId != null) {
      map['team_a_wicketkeeper_id'] = Variable<String>(teamAWicketkeeperId);
    }
    if (!nullToAbsent || teamBWicketkeeperId != null) {
      map['team_b_wicketkeeper_id'] = Variable<String>(teamBWicketkeeperId);
    }
    map['status'] = Variable<String>(status);
    map['current_scorer_device_id'] = Variable<String>(currentScorerDeviceId);
    map['version'] = Variable<int>(version);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || stateJson != null) {
      map['state_json'] = Variable<String>(stateJson);
    }
    if (!nullToAbsent || setupDraftJson != null) {
      map['setup_draft_json'] = Variable<String>(setupDraftJson);
    }
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || endReasonCode != null) {
      map['end_reason_code'] = Variable<String>(endReasonCode);
    }
    if (!nullToAbsent || endReasonText != null) {
      map['end_reason_text'] = Variable<String>(endReasonText);
    }
    if (!nullToAbsent || endNote != null) {
      map['end_note'] = Variable<String>(endNote);
    }
    map['ended_manually'] = Variable<bool>(endedManually);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<int>(endedAt);
    }
    if (!nullToAbsent || endedBy != null) {
      map['ended_by'] = Variable<String>(endedBy);
    }
    if (!nullToAbsent || winnerTeamId != null) {
      map['winner_team_id'] = Variable<String>(winnerTeamId);
    }
    if (!nullToAbsent || loserTeamId != null) {
      map['loser_team_id'] = Variable<String>(loserTeamId);
    }
    if (!nullToAbsent || resultType != null) {
      map['result_type'] = Variable<String>(resultType);
    }
    if (!nullToAbsent || resultText != null) {
      map['result_text'] = Variable<String>(resultText);
    }
    return map;
  }

  MatchesTableCompanion toCompanion(bool nullToAbsent) {
    return MatchesTableCompanion(
      id: Value(id),
      matchName: matchName == null && nullToAbsent
          ? const Value.absent()
          : Value(matchName),
      tournamentId: tournamentId == null && nullToAbsent
          ? const Value.absent()
          : Value(tournamentId),
      teamAId: Value(teamAId),
      teamBId: Value(teamBId),
      format: Value(format),
      totalOvers: totalOvers == null && nullToAbsent
          ? const Value.absent()
          : Value(totalOvers),
      ballsPerOver: ballsPerOver == null && nullToAbsent
          ? const Value.absent()
          : Value(ballsPerOver),
      maxOversPerBowler: maxOversPerBowler == null && nullToAbsent
          ? const Value.absent()
          : Value(maxOversPerBowler),
      allowConsecutiveOvers: allowConsecutiveOvers == null && nullToAbsent
          ? const Value.absent()
          : Value(allowConsecutiveOvers),
      maxOversWasManuallyEdited:
          maxOversWasManuallyEdited == null && nullToAbsent
              ? const Value.absent()
              : Value(maxOversWasManuallyEdited),
      venueName: venueName == null && nullToAbsent
          ? const Value.absent()
          : Value(venueName),
      scheduledAt: Value(scheduledAt),
      startedAt: startedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAt),
      matchTimeZone: matchTimeZone == null && nullToAbsent
          ? const Value.absent()
          : Value(matchTimeZone),
      tossWinnerTeamId: tossWinnerTeamId == null && nullToAbsent
          ? const Value.absent()
          : Value(tossWinnerTeamId),
      tossDecision: tossDecision == null && nullToAbsent
          ? const Value.absent()
          : Value(tossDecision),
      teamASquadJson: teamASquadJson == null && nullToAbsent
          ? const Value.absent()
          : Value(teamASquadJson),
      teamBSquadJson: teamBSquadJson == null && nullToAbsent
          ? const Value.absent()
          : Value(teamBSquadJson),
      teamACaptainId: teamACaptainId == null && nullToAbsent
          ? const Value.absent()
          : Value(teamACaptainId),
      teamBCaptainId: teamBCaptainId == null && nullToAbsent
          ? const Value.absent()
          : Value(teamBCaptainId),
      teamAWicketkeeperId: teamAWicketkeeperId == null && nullToAbsent
          ? const Value.absent()
          : Value(teamAWicketkeeperId),
      teamBWicketkeeperId: teamBWicketkeeperId == null && nullToAbsent
          ? const Value.absent()
          : Value(teamBWicketkeeperId),
      status: Value(status),
      currentScorerDeviceId: Value(currentScorerDeviceId),
      version: Value(version),
      syncStatus: Value(syncStatus),
      stateJson: stateJson == null && nullToAbsent
          ? const Value.absent()
          : Value(stateJson),
      setupDraftJson: setupDraftJson == null && nullToAbsent
          ? const Value.absent()
          : Value(setupDraftJson),
      createdAt: Value(createdAt),
      endReasonCode: endReasonCode == null && nullToAbsent
          ? const Value.absent()
          : Value(endReasonCode),
      endReasonText: endReasonText == null && nullToAbsent
          ? const Value.absent()
          : Value(endReasonText),
      endNote: endNote == null && nullToAbsent
          ? const Value.absent()
          : Value(endNote),
      endedManually: Value(endedManually),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      endedBy: endedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(endedBy),
      winnerTeamId: winnerTeamId == null && nullToAbsent
          ? const Value.absent()
          : Value(winnerTeamId),
      loserTeamId: loserTeamId == null && nullToAbsent
          ? const Value.absent()
          : Value(loserTeamId),
      resultType: resultType == null && nullToAbsent
          ? const Value.absent()
          : Value(resultType),
      resultText: resultText == null && nullToAbsent
          ? const Value.absent()
          : Value(resultText),
    );
  }

  factory MatchesTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MatchesTableData(
      id: serializer.fromJson<String>(json['id']),
      matchName: serializer.fromJson<String?>(json['matchName']),
      tournamentId: serializer.fromJson<String?>(json['tournamentId']),
      teamAId: serializer.fromJson<String>(json['teamAId']),
      teamBId: serializer.fromJson<String>(json['teamBId']),
      format: serializer.fromJson<String>(json['format']),
      totalOvers: serializer.fromJson<int?>(json['totalOvers']),
      ballsPerOver: serializer.fromJson<int?>(json['ballsPerOver']),
      maxOversPerBowler: serializer.fromJson<int?>(json['maxOversPerBowler']),
      allowConsecutiveOvers:
          serializer.fromJson<bool?>(json['allowConsecutiveOvers']),
      maxOversWasManuallyEdited:
          serializer.fromJson<bool?>(json['maxOversWasManuallyEdited']),
      venueName: serializer.fromJson<String?>(json['venueName']),
      scheduledAt: serializer.fromJson<int>(json['scheduledAt']),
      startedAt: serializer.fromJson<int?>(json['startedAt']),
      matchTimeZone: serializer.fromJson<String?>(json['matchTimeZone']),
      tossWinnerTeamId: serializer.fromJson<String?>(json['tossWinnerTeamId']),
      tossDecision: serializer.fromJson<String?>(json['tossDecision']),
      teamASquadJson: serializer.fromJson<String?>(json['teamASquadJson']),
      teamBSquadJson: serializer.fromJson<String?>(json['teamBSquadJson']),
      teamACaptainId: serializer.fromJson<String?>(json['teamACaptainId']),
      teamBCaptainId: serializer.fromJson<String?>(json['teamBCaptainId']),
      teamAWicketkeeperId:
          serializer.fromJson<String?>(json['teamAWicketkeeperId']),
      teamBWicketkeeperId:
          serializer.fromJson<String?>(json['teamBWicketkeeperId']),
      status: serializer.fromJson<String>(json['status']),
      currentScorerDeviceId:
          serializer.fromJson<String>(json['currentScorerDeviceId']),
      version: serializer.fromJson<int>(json['version']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      stateJson: serializer.fromJson<String?>(json['stateJson']),
      setupDraftJson: serializer.fromJson<String?>(json['setupDraftJson']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      endReasonCode: serializer.fromJson<String?>(json['endReasonCode']),
      endReasonText: serializer.fromJson<String?>(json['endReasonText']),
      endNote: serializer.fromJson<String?>(json['endNote']),
      endedManually: serializer.fromJson<bool>(json['endedManually']),
      endedAt: serializer.fromJson<int?>(json['endedAt']),
      endedBy: serializer.fromJson<String?>(json['endedBy']),
      winnerTeamId: serializer.fromJson<String?>(json['winnerTeamId']),
      loserTeamId: serializer.fromJson<String?>(json['loserTeamId']),
      resultType: serializer.fromJson<String?>(json['resultType']),
      resultText: serializer.fromJson<String?>(json['resultText']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'matchName': serializer.toJson<String?>(matchName),
      'tournamentId': serializer.toJson<String?>(tournamentId),
      'teamAId': serializer.toJson<String>(teamAId),
      'teamBId': serializer.toJson<String>(teamBId),
      'format': serializer.toJson<String>(format),
      'totalOvers': serializer.toJson<int?>(totalOvers),
      'ballsPerOver': serializer.toJson<int?>(ballsPerOver),
      'maxOversPerBowler': serializer.toJson<int?>(maxOversPerBowler),
      'allowConsecutiveOvers': serializer.toJson<bool?>(allowConsecutiveOvers),
      'maxOversWasManuallyEdited':
          serializer.toJson<bool?>(maxOversWasManuallyEdited),
      'venueName': serializer.toJson<String?>(venueName),
      'scheduledAt': serializer.toJson<int>(scheduledAt),
      'startedAt': serializer.toJson<int?>(startedAt),
      'matchTimeZone': serializer.toJson<String?>(matchTimeZone),
      'tossWinnerTeamId': serializer.toJson<String?>(tossWinnerTeamId),
      'tossDecision': serializer.toJson<String?>(tossDecision),
      'teamASquadJson': serializer.toJson<String?>(teamASquadJson),
      'teamBSquadJson': serializer.toJson<String?>(teamBSquadJson),
      'teamACaptainId': serializer.toJson<String?>(teamACaptainId),
      'teamBCaptainId': serializer.toJson<String?>(teamBCaptainId),
      'teamAWicketkeeperId': serializer.toJson<String?>(teamAWicketkeeperId),
      'teamBWicketkeeperId': serializer.toJson<String?>(teamBWicketkeeperId),
      'status': serializer.toJson<String>(status),
      'currentScorerDeviceId': serializer.toJson<String>(currentScorerDeviceId),
      'version': serializer.toJson<int>(version),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'stateJson': serializer.toJson<String?>(stateJson),
      'setupDraftJson': serializer.toJson<String?>(setupDraftJson),
      'createdAt': serializer.toJson<int>(createdAt),
      'endReasonCode': serializer.toJson<String?>(endReasonCode),
      'endReasonText': serializer.toJson<String?>(endReasonText),
      'endNote': serializer.toJson<String?>(endNote),
      'endedManually': serializer.toJson<bool>(endedManually),
      'endedAt': serializer.toJson<int?>(endedAt),
      'endedBy': serializer.toJson<String?>(endedBy),
      'winnerTeamId': serializer.toJson<String?>(winnerTeamId),
      'loserTeamId': serializer.toJson<String?>(loserTeamId),
      'resultType': serializer.toJson<String?>(resultType),
      'resultText': serializer.toJson<String?>(resultText),
    };
  }

  MatchesTableData copyWith(
          {String? id,
          Value<String?> matchName = const Value.absent(),
          Value<String?> tournamentId = const Value.absent(),
          String? teamAId,
          String? teamBId,
          String? format,
          Value<int?> totalOvers = const Value.absent(),
          Value<int?> ballsPerOver = const Value.absent(),
          Value<int?> maxOversPerBowler = const Value.absent(),
          Value<bool?> allowConsecutiveOvers = const Value.absent(),
          Value<bool?> maxOversWasManuallyEdited = const Value.absent(),
          Value<String?> venueName = const Value.absent(),
          int? scheduledAt,
          Value<int?> startedAt = const Value.absent(),
          Value<String?> matchTimeZone = const Value.absent(),
          Value<String?> tossWinnerTeamId = const Value.absent(),
          Value<String?> tossDecision = const Value.absent(),
          Value<String?> teamASquadJson = const Value.absent(),
          Value<String?> teamBSquadJson = const Value.absent(),
          Value<String?> teamACaptainId = const Value.absent(),
          Value<String?> teamBCaptainId = const Value.absent(),
          Value<String?> teamAWicketkeeperId = const Value.absent(),
          Value<String?> teamBWicketkeeperId = const Value.absent(),
          String? status,
          String? currentScorerDeviceId,
          int? version,
          String? syncStatus,
          Value<String?> stateJson = const Value.absent(),
          Value<String?> setupDraftJson = const Value.absent(),
          int? createdAt,
          Value<String?> endReasonCode = const Value.absent(),
          Value<String?> endReasonText = const Value.absent(),
          Value<String?> endNote = const Value.absent(),
          bool? endedManually,
          Value<int?> endedAt = const Value.absent(),
          Value<String?> endedBy = const Value.absent(),
          Value<String?> winnerTeamId = const Value.absent(),
          Value<String?> loserTeamId = const Value.absent(),
          Value<String?> resultType = const Value.absent(),
          Value<String?> resultText = const Value.absent()}) =>
      MatchesTableData(
        id: id ?? this.id,
        matchName: matchName.present ? matchName.value : this.matchName,
        tournamentId:
            tournamentId.present ? tournamentId.value : this.tournamentId,
        teamAId: teamAId ?? this.teamAId,
        teamBId: teamBId ?? this.teamBId,
        format: format ?? this.format,
        totalOvers: totalOvers.present ? totalOvers.value : this.totalOvers,
        ballsPerOver:
            ballsPerOver.present ? ballsPerOver.value : this.ballsPerOver,
        maxOversPerBowler: maxOversPerBowler.present
            ? maxOversPerBowler.value
            : this.maxOversPerBowler,
        allowConsecutiveOvers: allowConsecutiveOvers.present
            ? allowConsecutiveOvers.value
            : this.allowConsecutiveOvers,
        maxOversWasManuallyEdited: maxOversWasManuallyEdited.present
            ? maxOversWasManuallyEdited.value
            : this.maxOversWasManuallyEdited,
        venueName: venueName.present ? venueName.value : this.venueName,
        scheduledAt: scheduledAt ?? this.scheduledAt,
        startedAt: startedAt.present ? startedAt.value : this.startedAt,
        matchTimeZone:
            matchTimeZone.present ? matchTimeZone.value : this.matchTimeZone,
        tossWinnerTeamId: tossWinnerTeamId.present
            ? tossWinnerTeamId.value
            : this.tossWinnerTeamId,
        tossDecision:
            tossDecision.present ? tossDecision.value : this.tossDecision,
        teamASquadJson:
            teamASquadJson.present ? teamASquadJson.value : this.teamASquadJson,
        teamBSquadJson:
            teamBSquadJson.present ? teamBSquadJson.value : this.teamBSquadJson,
        teamACaptainId:
            teamACaptainId.present ? teamACaptainId.value : this.teamACaptainId,
        teamBCaptainId:
            teamBCaptainId.present ? teamBCaptainId.value : this.teamBCaptainId,
        teamAWicketkeeperId: teamAWicketkeeperId.present
            ? teamAWicketkeeperId.value
            : this.teamAWicketkeeperId,
        teamBWicketkeeperId: teamBWicketkeeperId.present
            ? teamBWicketkeeperId.value
            : this.teamBWicketkeeperId,
        status: status ?? this.status,
        currentScorerDeviceId:
            currentScorerDeviceId ?? this.currentScorerDeviceId,
        version: version ?? this.version,
        syncStatus: syncStatus ?? this.syncStatus,
        stateJson: stateJson.present ? stateJson.value : this.stateJson,
        setupDraftJson:
            setupDraftJson.present ? setupDraftJson.value : this.setupDraftJson,
        createdAt: createdAt ?? this.createdAt,
        endReasonCode:
            endReasonCode.present ? endReasonCode.value : this.endReasonCode,
        endReasonText:
            endReasonText.present ? endReasonText.value : this.endReasonText,
        endNote: endNote.present ? endNote.value : this.endNote,
        endedManually: endedManually ?? this.endedManually,
        endedAt: endedAt.present ? endedAt.value : this.endedAt,
        endedBy: endedBy.present ? endedBy.value : this.endedBy,
        winnerTeamId:
            winnerTeamId.present ? winnerTeamId.value : this.winnerTeamId,
        loserTeamId: loserTeamId.present ? loserTeamId.value : this.loserTeamId,
        resultType: resultType.present ? resultType.value : this.resultType,
        resultText: resultText.present ? resultText.value : this.resultText,
      );
  MatchesTableData copyWithCompanion(MatchesTableCompanion data) {
    return MatchesTableData(
      id: data.id.present ? data.id.value : this.id,
      matchName: data.matchName.present ? data.matchName.value : this.matchName,
      tournamentId: data.tournamentId.present
          ? data.tournamentId.value
          : this.tournamentId,
      teamAId: data.teamAId.present ? data.teamAId.value : this.teamAId,
      teamBId: data.teamBId.present ? data.teamBId.value : this.teamBId,
      format: data.format.present ? data.format.value : this.format,
      totalOvers:
          data.totalOvers.present ? data.totalOvers.value : this.totalOvers,
      ballsPerOver: data.ballsPerOver.present
          ? data.ballsPerOver.value
          : this.ballsPerOver,
      maxOversPerBowler: data.maxOversPerBowler.present
          ? data.maxOversPerBowler.value
          : this.maxOversPerBowler,
      allowConsecutiveOvers: data.allowConsecutiveOvers.present
          ? data.allowConsecutiveOvers.value
          : this.allowConsecutiveOvers,
      maxOversWasManuallyEdited: data.maxOversWasManuallyEdited.present
          ? data.maxOversWasManuallyEdited.value
          : this.maxOversWasManuallyEdited,
      venueName: data.venueName.present ? data.venueName.value : this.venueName,
      scheduledAt:
          data.scheduledAt.present ? data.scheduledAt.value : this.scheduledAt,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      matchTimeZone: data.matchTimeZone.present
          ? data.matchTimeZone.value
          : this.matchTimeZone,
      tossWinnerTeamId: data.tossWinnerTeamId.present
          ? data.tossWinnerTeamId.value
          : this.tossWinnerTeamId,
      tossDecision: data.tossDecision.present
          ? data.tossDecision.value
          : this.tossDecision,
      teamASquadJson: data.teamASquadJson.present
          ? data.teamASquadJson.value
          : this.teamASquadJson,
      teamBSquadJson: data.teamBSquadJson.present
          ? data.teamBSquadJson.value
          : this.teamBSquadJson,
      teamACaptainId: data.teamACaptainId.present
          ? data.teamACaptainId.value
          : this.teamACaptainId,
      teamBCaptainId: data.teamBCaptainId.present
          ? data.teamBCaptainId.value
          : this.teamBCaptainId,
      teamAWicketkeeperId: data.teamAWicketkeeperId.present
          ? data.teamAWicketkeeperId.value
          : this.teamAWicketkeeperId,
      teamBWicketkeeperId: data.teamBWicketkeeperId.present
          ? data.teamBWicketkeeperId.value
          : this.teamBWicketkeeperId,
      status: data.status.present ? data.status.value : this.status,
      currentScorerDeviceId: data.currentScorerDeviceId.present
          ? data.currentScorerDeviceId.value
          : this.currentScorerDeviceId,
      version: data.version.present ? data.version.value : this.version,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      stateJson: data.stateJson.present ? data.stateJson.value : this.stateJson,
      setupDraftJson: data.setupDraftJson.present
          ? data.setupDraftJson.value
          : this.setupDraftJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      endReasonCode: data.endReasonCode.present
          ? data.endReasonCode.value
          : this.endReasonCode,
      endReasonText: data.endReasonText.present
          ? data.endReasonText.value
          : this.endReasonText,
      endNote: data.endNote.present ? data.endNote.value : this.endNote,
      endedManually: data.endedManually.present
          ? data.endedManually.value
          : this.endedManually,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      endedBy: data.endedBy.present ? data.endedBy.value : this.endedBy,
      winnerTeamId: data.winnerTeamId.present
          ? data.winnerTeamId.value
          : this.winnerTeamId,
      loserTeamId:
          data.loserTeamId.present ? data.loserTeamId.value : this.loserTeamId,
      resultType:
          data.resultType.present ? data.resultType.value : this.resultType,
      resultText:
          data.resultText.present ? data.resultText.value : this.resultText,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MatchesTableData(')
          ..write('id: $id, ')
          ..write('matchName: $matchName, ')
          ..write('tournamentId: $tournamentId, ')
          ..write('teamAId: $teamAId, ')
          ..write('teamBId: $teamBId, ')
          ..write('format: $format, ')
          ..write('totalOvers: $totalOvers, ')
          ..write('ballsPerOver: $ballsPerOver, ')
          ..write('maxOversPerBowler: $maxOversPerBowler, ')
          ..write('allowConsecutiveOvers: $allowConsecutiveOvers, ')
          ..write('maxOversWasManuallyEdited: $maxOversWasManuallyEdited, ')
          ..write('venueName: $venueName, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('startedAt: $startedAt, ')
          ..write('matchTimeZone: $matchTimeZone, ')
          ..write('tossWinnerTeamId: $tossWinnerTeamId, ')
          ..write('tossDecision: $tossDecision, ')
          ..write('teamASquadJson: $teamASquadJson, ')
          ..write('teamBSquadJson: $teamBSquadJson, ')
          ..write('teamACaptainId: $teamACaptainId, ')
          ..write('teamBCaptainId: $teamBCaptainId, ')
          ..write('teamAWicketkeeperId: $teamAWicketkeeperId, ')
          ..write('teamBWicketkeeperId: $teamBWicketkeeperId, ')
          ..write('status: $status, ')
          ..write('currentScorerDeviceId: $currentScorerDeviceId, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('stateJson: $stateJson, ')
          ..write('setupDraftJson: $setupDraftJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('endReasonCode: $endReasonCode, ')
          ..write('endReasonText: $endReasonText, ')
          ..write('endNote: $endNote, ')
          ..write('endedManually: $endedManually, ')
          ..write('endedAt: $endedAt, ')
          ..write('endedBy: $endedBy, ')
          ..write('winnerTeamId: $winnerTeamId, ')
          ..write('loserTeamId: $loserTeamId, ')
          ..write('resultType: $resultType, ')
          ..write('resultText: $resultText')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        matchName,
        tournamentId,
        teamAId,
        teamBId,
        format,
        totalOvers,
        ballsPerOver,
        maxOversPerBowler,
        allowConsecutiveOvers,
        maxOversWasManuallyEdited,
        venueName,
        scheduledAt,
        startedAt,
        matchTimeZone,
        tossWinnerTeamId,
        tossDecision,
        teamASquadJson,
        teamBSquadJson,
        teamACaptainId,
        teamBCaptainId,
        teamAWicketkeeperId,
        teamBWicketkeeperId,
        status,
        currentScorerDeviceId,
        version,
        syncStatus,
        stateJson,
        setupDraftJson,
        createdAt,
        endReasonCode,
        endReasonText,
        endNote,
        endedManually,
        endedAt,
        endedBy,
        winnerTeamId,
        loserTeamId,
        resultType,
        resultText
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MatchesTableData &&
          other.id == this.id &&
          other.matchName == this.matchName &&
          other.tournamentId == this.tournamentId &&
          other.teamAId == this.teamAId &&
          other.teamBId == this.teamBId &&
          other.format == this.format &&
          other.totalOvers == this.totalOvers &&
          other.ballsPerOver == this.ballsPerOver &&
          other.maxOversPerBowler == this.maxOversPerBowler &&
          other.allowConsecutiveOvers == this.allowConsecutiveOvers &&
          other.maxOversWasManuallyEdited == this.maxOversWasManuallyEdited &&
          other.venueName == this.venueName &&
          other.scheduledAt == this.scheduledAt &&
          other.startedAt == this.startedAt &&
          other.matchTimeZone == this.matchTimeZone &&
          other.tossWinnerTeamId == this.tossWinnerTeamId &&
          other.tossDecision == this.tossDecision &&
          other.teamASquadJson == this.teamASquadJson &&
          other.teamBSquadJson == this.teamBSquadJson &&
          other.teamACaptainId == this.teamACaptainId &&
          other.teamBCaptainId == this.teamBCaptainId &&
          other.teamAWicketkeeperId == this.teamAWicketkeeperId &&
          other.teamBWicketkeeperId == this.teamBWicketkeeperId &&
          other.status == this.status &&
          other.currentScorerDeviceId == this.currentScorerDeviceId &&
          other.version == this.version &&
          other.syncStatus == this.syncStatus &&
          other.stateJson == this.stateJson &&
          other.setupDraftJson == this.setupDraftJson &&
          other.createdAt == this.createdAt &&
          other.endReasonCode == this.endReasonCode &&
          other.endReasonText == this.endReasonText &&
          other.endNote == this.endNote &&
          other.endedManually == this.endedManually &&
          other.endedAt == this.endedAt &&
          other.endedBy == this.endedBy &&
          other.winnerTeamId == this.winnerTeamId &&
          other.loserTeamId == this.loserTeamId &&
          other.resultType == this.resultType &&
          other.resultText == this.resultText);
}

class MatchesTableCompanion extends UpdateCompanion<MatchesTableData> {
  final Value<String> id;
  final Value<String?> matchName;
  final Value<String?> tournamentId;
  final Value<String> teamAId;
  final Value<String> teamBId;
  final Value<String> format;
  final Value<int?> totalOvers;
  final Value<int?> ballsPerOver;
  final Value<int?> maxOversPerBowler;
  final Value<bool?> allowConsecutiveOvers;
  final Value<bool?> maxOversWasManuallyEdited;
  final Value<String?> venueName;
  final Value<int> scheduledAt;
  final Value<int?> startedAt;
  final Value<String?> matchTimeZone;
  final Value<String?> tossWinnerTeamId;
  final Value<String?> tossDecision;
  final Value<String?> teamASquadJson;
  final Value<String?> teamBSquadJson;
  final Value<String?> teamACaptainId;
  final Value<String?> teamBCaptainId;
  final Value<String?> teamAWicketkeeperId;
  final Value<String?> teamBWicketkeeperId;
  final Value<String> status;
  final Value<String> currentScorerDeviceId;
  final Value<int> version;
  final Value<String> syncStatus;
  final Value<String?> stateJson;
  final Value<String?> setupDraftJson;
  final Value<int> createdAt;
  final Value<String?> endReasonCode;
  final Value<String?> endReasonText;
  final Value<String?> endNote;
  final Value<bool> endedManually;
  final Value<int?> endedAt;
  final Value<String?> endedBy;
  final Value<String?> winnerTeamId;
  final Value<String?> loserTeamId;
  final Value<String?> resultType;
  final Value<String?> resultText;
  final Value<int> rowid;
  const MatchesTableCompanion({
    this.id = const Value.absent(),
    this.matchName = const Value.absent(),
    this.tournamentId = const Value.absent(),
    this.teamAId = const Value.absent(),
    this.teamBId = const Value.absent(),
    this.format = const Value.absent(),
    this.totalOvers = const Value.absent(),
    this.ballsPerOver = const Value.absent(),
    this.maxOversPerBowler = const Value.absent(),
    this.allowConsecutiveOvers = const Value.absent(),
    this.maxOversWasManuallyEdited = const Value.absent(),
    this.venueName = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.matchTimeZone = const Value.absent(),
    this.tossWinnerTeamId = const Value.absent(),
    this.tossDecision = const Value.absent(),
    this.teamASquadJson = const Value.absent(),
    this.teamBSquadJson = const Value.absent(),
    this.teamACaptainId = const Value.absent(),
    this.teamBCaptainId = const Value.absent(),
    this.teamAWicketkeeperId = const Value.absent(),
    this.teamBWicketkeeperId = const Value.absent(),
    this.status = const Value.absent(),
    this.currentScorerDeviceId = const Value.absent(),
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.stateJson = const Value.absent(),
    this.setupDraftJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.endReasonCode = const Value.absent(),
    this.endReasonText = const Value.absent(),
    this.endNote = const Value.absent(),
    this.endedManually = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.endedBy = const Value.absent(),
    this.winnerTeamId = const Value.absent(),
    this.loserTeamId = const Value.absent(),
    this.resultType = const Value.absent(),
    this.resultText = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MatchesTableCompanion.insert({
    required String id,
    this.matchName = const Value.absent(),
    this.tournamentId = const Value.absent(),
    required String teamAId,
    required String teamBId,
    this.format = const Value.absent(),
    this.totalOvers = const Value.absent(),
    this.ballsPerOver = const Value.absent(),
    this.maxOversPerBowler = const Value.absent(),
    this.allowConsecutiveOvers = const Value.absent(),
    this.maxOversWasManuallyEdited = const Value.absent(),
    this.venueName = const Value.absent(),
    required int scheduledAt,
    this.startedAt = const Value.absent(),
    this.matchTimeZone = const Value.absent(),
    this.tossWinnerTeamId = const Value.absent(),
    this.tossDecision = const Value.absent(),
    this.teamASquadJson = const Value.absent(),
    this.teamBSquadJson = const Value.absent(),
    this.teamACaptainId = const Value.absent(),
    this.teamBCaptainId = const Value.absent(),
    this.teamAWicketkeeperId = const Value.absent(),
    this.teamBWicketkeeperId = const Value.absent(),
    this.status = const Value.absent(),
    required String currentScorerDeviceId,
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.stateJson = const Value.absent(),
    this.setupDraftJson = const Value.absent(),
    required int createdAt,
    this.endReasonCode = const Value.absent(),
    this.endReasonText = const Value.absent(),
    this.endNote = const Value.absent(),
    this.endedManually = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.endedBy = const Value.absent(),
    this.winnerTeamId = const Value.absent(),
    this.loserTeamId = const Value.absent(),
    this.resultType = const Value.absent(),
    this.resultText = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        teamAId = Value(teamAId),
        teamBId = Value(teamBId),
        scheduledAt = Value(scheduledAt),
        currentScorerDeviceId = Value(currentScorerDeviceId),
        createdAt = Value(createdAt);
  static Insertable<MatchesTableData> custom({
    Expression<String>? id,
    Expression<String>? matchName,
    Expression<String>? tournamentId,
    Expression<String>? teamAId,
    Expression<String>? teamBId,
    Expression<String>? format,
    Expression<int>? totalOvers,
    Expression<int>? ballsPerOver,
    Expression<int>? maxOversPerBowler,
    Expression<bool>? allowConsecutiveOvers,
    Expression<bool>? maxOversWasManuallyEdited,
    Expression<String>? venueName,
    Expression<int>? scheduledAt,
    Expression<int>? startedAt,
    Expression<String>? matchTimeZone,
    Expression<String>? tossWinnerTeamId,
    Expression<String>? tossDecision,
    Expression<String>? teamASquadJson,
    Expression<String>? teamBSquadJson,
    Expression<String>? teamACaptainId,
    Expression<String>? teamBCaptainId,
    Expression<String>? teamAWicketkeeperId,
    Expression<String>? teamBWicketkeeperId,
    Expression<String>? status,
    Expression<String>? currentScorerDeviceId,
    Expression<int>? version,
    Expression<String>? syncStatus,
    Expression<String>? stateJson,
    Expression<String>? setupDraftJson,
    Expression<int>? createdAt,
    Expression<String>? endReasonCode,
    Expression<String>? endReasonText,
    Expression<String>? endNote,
    Expression<bool>? endedManually,
    Expression<int>? endedAt,
    Expression<String>? endedBy,
    Expression<String>? winnerTeamId,
    Expression<String>? loserTeamId,
    Expression<String>? resultType,
    Expression<String>? resultText,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (matchName != null) 'match_name': matchName,
      if (tournamentId != null) 'tournament_id': tournamentId,
      if (teamAId != null) 'team_a_id': teamAId,
      if (teamBId != null) 'team_b_id': teamBId,
      if (format != null) 'format': format,
      if (totalOvers != null) 'total_overs': totalOvers,
      if (ballsPerOver != null) 'balls_per_over': ballsPerOver,
      if (maxOversPerBowler != null) 'max_overs_per_bowler': maxOversPerBowler,
      if (allowConsecutiveOvers != null)
        'allow_consecutive_overs': allowConsecutiveOvers,
      if (maxOversWasManuallyEdited != null)
        'max_overs_was_manually_edited': maxOversWasManuallyEdited,
      if (venueName != null) 'venue_name': venueName,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (startedAt != null) 'started_at': startedAt,
      if (matchTimeZone != null) 'match_time_zone': matchTimeZone,
      if (tossWinnerTeamId != null) 'toss_winner_team_id': tossWinnerTeamId,
      if (tossDecision != null) 'toss_decision': tossDecision,
      if (teamASquadJson != null) 'team_a_squad_json': teamASquadJson,
      if (teamBSquadJson != null) 'team_b_squad_json': teamBSquadJson,
      if (teamACaptainId != null) 'team_a_captain_id': teamACaptainId,
      if (teamBCaptainId != null) 'team_b_captain_id': teamBCaptainId,
      if (teamAWicketkeeperId != null)
        'team_a_wicketkeeper_id': teamAWicketkeeperId,
      if (teamBWicketkeeperId != null)
        'team_b_wicketkeeper_id': teamBWicketkeeperId,
      if (status != null) 'status': status,
      if (currentScorerDeviceId != null)
        'current_scorer_device_id': currentScorerDeviceId,
      if (version != null) 'version': version,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (stateJson != null) 'state_json': stateJson,
      if (setupDraftJson != null) 'setup_draft_json': setupDraftJson,
      if (createdAt != null) 'created_at': createdAt,
      if (endReasonCode != null) 'end_reason_code': endReasonCode,
      if (endReasonText != null) 'end_reason_text': endReasonText,
      if (endNote != null) 'end_note': endNote,
      if (endedManually != null) 'ended_manually': endedManually,
      if (endedAt != null) 'ended_at': endedAt,
      if (endedBy != null) 'ended_by': endedBy,
      if (winnerTeamId != null) 'winner_team_id': winnerTeamId,
      if (loserTeamId != null) 'loser_team_id': loserTeamId,
      if (resultType != null) 'result_type': resultType,
      if (resultText != null) 'result_text': resultText,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MatchesTableCompanion copyWith(
      {Value<String>? id,
      Value<String?>? matchName,
      Value<String?>? tournamentId,
      Value<String>? teamAId,
      Value<String>? teamBId,
      Value<String>? format,
      Value<int?>? totalOvers,
      Value<int?>? ballsPerOver,
      Value<int?>? maxOversPerBowler,
      Value<bool?>? allowConsecutiveOvers,
      Value<bool?>? maxOversWasManuallyEdited,
      Value<String?>? venueName,
      Value<int>? scheduledAt,
      Value<int?>? startedAt,
      Value<String?>? matchTimeZone,
      Value<String?>? tossWinnerTeamId,
      Value<String?>? tossDecision,
      Value<String?>? teamASquadJson,
      Value<String?>? teamBSquadJson,
      Value<String?>? teamACaptainId,
      Value<String?>? teamBCaptainId,
      Value<String?>? teamAWicketkeeperId,
      Value<String?>? teamBWicketkeeperId,
      Value<String>? status,
      Value<String>? currentScorerDeviceId,
      Value<int>? version,
      Value<String>? syncStatus,
      Value<String?>? stateJson,
      Value<String?>? setupDraftJson,
      Value<int>? createdAt,
      Value<String?>? endReasonCode,
      Value<String?>? endReasonText,
      Value<String?>? endNote,
      Value<bool>? endedManually,
      Value<int?>? endedAt,
      Value<String?>? endedBy,
      Value<String?>? winnerTeamId,
      Value<String?>? loserTeamId,
      Value<String?>? resultType,
      Value<String?>? resultText,
      Value<int>? rowid}) {
    return MatchesTableCompanion(
      id: id ?? this.id,
      matchName: matchName ?? this.matchName,
      tournamentId: tournamentId ?? this.tournamentId,
      teamAId: teamAId ?? this.teamAId,
      teamBId: teamBId ?? this.teamBId,
      format: format ?? this.format,
      totalOvers: totalOvers ?? this.totalOvers,
      ballsPerOver: ballsPerOver ?? this.ballsPerOver,
      maxOversPerBowler: maxOversPerBowler ?? this.maxOversPerBowler,
      allowConsecutiveOvers:
          allowConsecutiveOvers ?? this.allowConsecutiveOvers,
      maxOversWasManuallyEdited:
          maxOversWasManuallyEdited ?? this.maxOversWasManuallyEdited,
      venueName: venueName ?? this.venueName,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      startedAt: startedAt ?? this.startedAt,
      matchTimeZone: matchTimeZone ?? this.matchTimeZone,
      tossWinnerTeamId: tossWinnerTeamId ?? this.tossWinnerTeamId,
      tossDecision: tossDecision ?? this.tossDecision,
      teamASquadJson: teamASquadJson ?? this.teamASquadJson,
      teamBSquadJson: teamBSquadJson ?? this.teamBSquadJson,
      teamACaptainId: teamACaptainId ?? this.teamACaptainId,
      teamBCaptainId: teamBCaptainId ?? this.teamBCaptainId,
      teamAWicketkeeperId: teamAWicketkeeperId ?? this.teamAWicketkeeperId,
      teamBWicketkeeperId: teamBWicketkeeperId ?? this.teamBWicketkeeperId,
      status: status ?? this.status,
      currentScorerDeviceId:
          currentScorerDeviceId ?? this.currentScorerDeviceId,
      version: version ?? this.version,
      syncStatus: syncStatus ?? this.syncStatus,
      stateJson: stateJson ?? this.stateJson,
      setupDraftJson: setupDraftJson ?? this.setupDraftJson,
      createdAt: createdAt ?? this.createdAt,
      endReasonCode: endReasonCode ?? this.endReasonCode,
      endReasonText: endReasonText ?? this.endReasonText,
      endNote: endNote ?? this.endNote,
      endedManually: endedManually ?? this.endedManually,
      endedAt: endedAt ?? this.endedAt,
      endedBy: endedBy ?? this.endedBy,
      winnerTeamId: winnerTeamId ?? this.winnerTeamId,
      loserTeamId: loserTeamId ?? this.loserTeamId,
      resultType: resultType ?? this.resultType,
      resultText: resultText ?? this.resultText,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (matchName.present) {
      map['match_name'] = Variable<String>(matchName.value);
    }
    if (tournamentId.present) {
      map['tournament_id'] = Variable<String>(tournamentId.value);
    }
    if (teamAId.present) {
      map['team_a_id'] = Variable<String>(teamAId.value);
    }
    if (teamBId.present) {
      map['team_b_id'] = Variable<String>(teamBId.value);
    }
    if (format.present) {
      map['format'] = Variable<String>(format.value);
    }
    if (totalOvers.present) {
      map['total_overs'] = Variable<int>(totalOvers.value);
    }
    if (ballsPerOver.present) {
      map['balls_per_over'] = Variable<int>(ballsPerOver.value);
    }
    if (maxOversPerBowler.present) {
      map['max_overs_per_bowler'] = Variable<int>(maxOversPerBowler.value);
    }
    if (allowConsecutiveOvers.present) {
      map['allow_consecutive_overs'] =
          Variable<bool>(allowConsecutiveOvers.value);
    }
    if (maxOversWasManuallyEdited.present) {
      map['max_overs_was_manually_edited'] =
          Variable<bool>(maxOversWasManuallyEdited.value);
    }
    if (venueName.present) {
      map['venue_name'] = Variable<String>(venueName.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<int>(scheduledAt.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<int>(startedAt.value);
    }
    if (matchTimeZone.present) {
      map['match_time_zone'] = Variable<String>(matchTimeZone.value);
    }
    if (tossWinnerTeamId.present) {
      map['toss_winner_team_id'] = Variable<String>(tossWinnerTeamId.value);
    }
    if (tossDecision.present) {
      map['toss_decision'] = Variable<String>(tossDecision.value);
    }
    if (teamASquadJson.present) {
      map['team_a_squad_json'] = Variable<String>(teamASquadJson.value);
    }
    if (teamBSquadJson.present) {
      map['team_b_squad_json'] = Variable<String>(teamBSquadJson.value);
    }
    if (teamACaptainId.present) {
      map['team_a_captain_id'] = Variable<String>(teamACaptainId.value);
    }
    if (teamBCaptainId.present) {
      map['team_b_captain_id'] = Variable<String>(teamBCaptainId.value);
    }
    if (teamAWicketkeeperId.present) {
      map['team_a_wicketkeeper_id'] =
          Variable<String>(teamAWicketkeeperId.value);
    }
    if (teamBWicketkeeperId.present) {
      map['team_b_wicketkeeper_id'] =
          Variable<String>(teamBWicketkeeperId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (currentScorerDeviceId.present) {
      map['current_scorer_device_id'] =
          Variable<String>(currentScorerDeviceId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (stateJson.present) {
      map['state_json'] = Variable<String>(stateJson.value);
    }
    if (setupDraftJson.present) {
      map['setup_draft_json'] = Variable<String>(setupDraftJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (endReasonCode.present) {
      map['end_reason_code'] = Variable<String>(endReasonCode.value);
    }
    if (endReasonText.present) {
      map['end_reason_text'] = Variable<String>(endReasonText.value);
    }
    if (endNote.present) {
      map['end_note'] = Variable<String>(endNote.value);
    }
    if (endedManually.present) {
      map['ended_manually'] = Variable<bool>(endedManually.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<int>(endedAt.value);
    }
    if (endedBy.present) {
      map['ended_by'] = Variable<String>(endedBy.value);
    }
    if (winnerTeamId.present) {
      map['winner_team_id'] = Variable<String>(winnerTeamId.value);
    }
    if (loserTeamId.present) {
      map['loser_team_id'] = Variable<String>(loserTeamId.value);
    }
    if (resultType.present) {
      map['result_type'] = Variable<String>(resultType.value);
    }
    if (resultText.present) {
      map['result_text'] = Variable<String>(resultText.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MatchesTableCompanion(')
          ..write('id: $id, ')
          ..write('matchName: $matchName, ')
          ..write('tournamentId: $tournamentId, ')
          ..write('teamAId: $teamAId, ')
          ..write('teamBId: $teamBId, ')
          ..write('format: $format, ')
          ..write('totalOvers: $totalOvers, ')
          ..write('ballsPerOver: $ballsPerOver, ')
          ..write('maxOversPerBowler: $maxOversPerBowler, ')
          ..write('allowConsecutiveOvers: $allowConsecutiveOvers, ')
          ..write('maxOversWasManuallyEdited: $maxOversWasManuallyEdited, ')
          ..write('venueName: $venueName, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('startedAt: $startedAt, ')
          ..write('matchTimeZone: $matchTimeZone, ')
          ..write('tossWinnerTeamId: $tossWinnerTeamId, ')
          ..write('tossDecision: $tossDecision, ')
          ..write('teamASquadJson: $teamASquadJson, ')
          ..write('teamBSquadJson: $teamBSquadJson, ')
          ..write('teamACaptainId: $teamACaptainId, ')
          ..write('teamBCaptainId: $teamBCaptainId, ')
          ..write('teamAWicketkeeperId: $teamAWicketkeeperId, ')
          ..write('teamBWicketkeeperId: $teamBWicketkeeperId, ')
          ..write('status: $status, ')
          ..write('currentScorerDeviceId: $currentScorerDeviceId, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('stateJson: $stateJson, ')
          ..write('setupDraftJson: $setupDraftJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('endReasonCode: $endReasonCode, ')
          ..write('endReasonText: $endReasonText, ')
          ..write('endNote: $endNote, ')
          ..write('endedManually: $endedManually, ')
          ..write('endedAt: $endedAt, ')
          ..write('endedBy: $endedBy, ')
          ..write('winnerTeamId: $winnerTeamId, ')
          ..write('loserTeamId: $loserTeamId, ')
          ..write('resultType: $resultType, ')
          ..write('resultText: $resultText, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DeliveriesTableTable extends DeliveriesTable
    with TableInfo<$DeliveriesTableTable, DeliveriesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeliveriesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _eventIdMeta =
      const VerificationMeta('eventId');
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
      'event_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _matchIdMeta =
      const VerificationMeta('matchId');
  @override
  late final GeneratedColumn<String> matchId = GeneratedColumn<String>(
      'match_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _inningsIdMeta =
      const VerificationMeta('inningsId');
  @override
  late final GeneratedColumn<String> inningsId = GeneratedColumn<String>(
      'innings_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _overNumberMeta =
      const VerificationMeta('overNumber');
  @override
  late final GeneratedColumn<int> overNumber = GeneratedColumn<int>(
      'over_number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _legalBallNumberMeta =
      const VerificationMeta('legalBallNumber');
  @override
  late final GeneratedColumn<int> legalBallNumber = GeneratedColumn<int>(
      'legal_ball_number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _eventSequenceMeta =
      const VerificationMeta('eventSequence');
  @override
  late final GeneratedColumn<int> eventSequence = GeneratedColumn<int>(
      'event_sequence', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _sequenceInOverMeta =
      const VerificationMeta('sequenceInOver');
  @override
  late final GeneratedColumn<int> sequenceInOver = GeneratedColumn<int>(
      'sequence_in_over', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _scorerDeviceIdMeta =
      const VerificationMeta('scorerDeviceId');
  @override
  late final GeneratedColumn<String> scorerDeviceId = GeneratedColumn<String>(
      'scorer_device_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _strikerIdMeta =
      const VerificationMeta('strikerId');
  @override
  late final GeneratedColumn<String> strikerId = GeneratedColumn<String>(
      'striker_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nonStrikerIdMeta =
      const VerificationMeta('nonStrikerId');
  @override
  late final GeneratedColumn<String> nonStrikerId = GeneratedColumn<String>(
      'non_striker_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bowlerIdMeta =
      const VerificationMeta('bowlerId');
  @override
  late final GeneratedColumn<String> bowlerId = GeneratedColumn<String>(
      'bowler_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _runsBatterMeta =
      const VerificationMeta('runsBatter');
  @override
  late final GeneratedColumn<int> runsBatter = GeneratedColumn<int>(
      'runs_batter', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _extrasTypeMeta =
      const VerificationMeta('extrasType');
  @override
  late final GeneratedColumn<String> extrasType = GeneratedColumn<String>(
      'extras_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('none'));
  static const VerificationMeta _extrasRunsMeta =
      const VerificationMeta('extrasRuns');
  @override
  late final GeneratedColumn<int> extrasRuns = GeneratedColumn<int>(
      'extras_runs', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _wideRunsMeta =
      const VerificationMeta('wideRuns');
  @override
  late final GeneratedColumn<int> wideRuns = GeneratedColumn<int>(
      'wide_runs', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _additionalWideRunsMeta =
      const VerificationMeta('additionalWideRuns');
  @override
  late final GeneratedColumn<int> additionalWideRuns = GeneratedColumn<int>(
      'additional_wide_runs', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _noBallRunsMeta =
      const VerificationMeta('noBallRuns');
  @override
  late final GeneratedColumn<int> noBallRuns = GeneratedColumn<int>(
      'no_ball_runs', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _byeRunsMeta =
      const VerificationMeta('byeRuns');
  @override
  late final GeneratedColumn<int> byeRuns = GeneratedColumn<int>(
      'bye_runs', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _legByeRunsMeta =
      const VerificationMeta('legByeRuns');
  @override
  late final GeneratedColumn<int> legByeRuns = GeneratedColumn<int>(
      'leg_bye_runs', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _penaltyRunsMeta =
      const VerificationMeta('penaltyRuns');
  @override
  late final GeneratedColumn<int> penaltyRuns = GeneratedColumn<int>(
      'penalty_runs', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isLegalMeta =
      const VerificationMeta('isLegal');
  @override
  late final GeneratedColumn<bool> isLegal = GeneratedColumn<bool>(
      'is_legal', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_legal" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _isBoundaryFourMeta =
      const VerificationMeta('isBoundaryFour');
  @override
  late final GeneratedColumn<bool> isBoundaryFour = GeneratedColumn<bool>(
      'is_boundary_four', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_boundary_four" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isBoundarySixMeta =
      const VerificationMeta('isBoundarySix');
  @override
  late final GeneratedColumn<bool> isBoundarySix = GeneratedColumn<bool>(
      'is_boundary_six', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_boundary_six" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _wicketTypeMeta =
      const VerificationMeta('wicketType');
  @override
  late final GeneratedColumn<String> wicketType = GeneratedColumn<String>(
      'wicket_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dismissedPlayerIdMeta =
      const VerificationMeta('dismissedPlayerId');
  @override
  late final GeneratedColumn<String> dismissedPlayerId =
      GeneratedColumn<String>('dismissed_player_id', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fielderIdMeta =
      const VerificationMeta('fielderId');
  @override
  late final GeneratedColumn<String> fielderId = GeneratedColumn<String>(
      'fielder_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isReversedMeta =
      const VerificationMeta('isReversed');
  @override
  late final GeneratedColumn<bool> isReversed = GeneratedColumn<bool>(
      'is_reversed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_reversed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _previousEventHashMeta =
      const VerificationMeta('previousEventHash');
  @override
  late final GeneratedColumn<String> previousEventHash =
      GeneratedColumn<String>('previous_event_hash', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _clientTimestampMeta =
      const VerificationMeta('clientTimestamp');
  @override
  late final GeneratedColumn<int> clientTimestamp = GeneratedColumn<int>(
      'client_timestamp', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('localOnly'));
  @override
  List<GeneratedColumn> get $columns => [
        eventId,
        matchId,
        inningsId,
        overNumber,
        legalBallNumber,
        eventSequence,
        sequenceInOver,
        scorerDeviceId,
        strikerId,
        nonStrikerId,
        bowlerId,
        runsBatter,
        extrasType,
        extrasRuns,
        wideRuns,
        additionalWideRuns,
        noBallRuns,
        byeRuns,
        legByeRuns,
        penaltyRuns,
        isLegal,
        isBoundaryFour,
        isBoundarySix,
        wicketType,
        dismissedPlayerId,
        fielderId,
        isReversed,
        previousEventHash,
        clientTimestamp,
        syncStatus
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'deliveries_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<DeliveriesTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('event_id')) {
      context.handle(_eventIdMeta,
          eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta));
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('match_id')) {
      context.handle(_matchIdMeta,
          matchId.isAcceptableOrUnknown(data['match_id']!, _matchIdMeta));
    } else if (isInserting) {
      context.missing(_matchIdMeta);
    }
    if (data.containsKey('innings_id')) {
      context.handle(_inningsIdMeta,
          inningsId.isAcceptableOrUnknown(data['innings_id']!, _inningsIdMeta));
    } else if (isInserting) {
      context.missing(_inningsIdMeta);
    }
    if (data.containsKey('over_number')) {
      context.handle(
          _overNumberMeta,
          overNumber.isAcceptableOrUnknown(
              data['over_number']!, _overNumberMeta));
    } else if (isInserting) {
      context.missing(_overNumberMeta);
    }
    if (data.containsKey('legal_ball_number')) {
      context.handle(
          _legalBallNumberMeta,
          legalBallNumber.isAcceptableOrUnknown(
              data['legal_ball_number']!, _legalBallNumberMeta));
    } else if (isInserting) {
      context.missing(_legalBallNumberMeta);
    }
    if (data.containsKey('event_sequence')) {
      context.handle(
          _eventSequenceMeta,
          eventSequence.isAcceptableOrUnknown(
              data['event_sequence']!, _eventSequenceMeta));
    } else if (isInserting) {
      context.missing(_eventSequenceMeta);
    }
    if (data.containsKey('sequence_in_over')) {
      context.handle(
          _sequenceInOverMeta,
          sequenceInOver.isAcceptableOrUnknown(
              data['sequence_in_over']!, _sequenceInOverMeta));
    }
    if (data.containsKey('scorer_device_id')) {
      context.handle(
          _scorerDeviceIdMeta,
          scorerDeviceId.isAcceptableOrUnknown(
              data['scorer_device_id']!, _scorerDeviceIdMeta));
    } else if (isInserting) {
      context.missing(_scorerDeviceIdMeta);
    }
    if (data.containsKey('striker_id')) {
      context.handle(_strikerIdMeta,
          strikerId.isAcceptableOrUnknown(data['striker_id']!, _strikerIdMeta));
    } else if (isInserting) {
      context.missing(_strikerIdMeta);
    }
    if (data.containsKey('non_striker_id')) {
      context.handle(
          _nonStrikerIdMeta,
          nonStrikerId.isAcceptableOrUnknown(
              data['non_striker_id']!, _nonStrikerIdMeta));
    } else if (isInserting) {
      context.missing(_nonStrikerIdMeta);
    }
    if (data.containsKey('bowler_id')) {
      context.handle(_bowlerIdMeta,
          bowlerId.isAcceptableOrUnknown(data['bowler_id']!, _bowlerIdMeta));
    } else if (isInserting) {
      context.missing(_bowlerIdMeta);
    }
    if (data.containsKey('runs_batter')) {
      context.handle(
          _runsBatterMeta,
          runsBatter.isAcceptableOrUnknown(
              data['runs_batter']!, _runsBatterMeta));
    }
    if (data.containsKey('extras_type')) {
      context.handle(
          _extrasTypeMeta,
          extrasType.isAcceptableOrUnknown(
              data['extras_type']!, _extrasTypeMeta));
    }
    if (data.containsKey('extras_runs')) {
      context.handle(
          _extrasRunsMeta,
          extrasRuns.isAcceptableOrUnknown(
              data['extras_runs']!, _extrasRunsMeta));
    }
    if (data.containsKey('wide_runs')) {
      context.handle(_wideRunsMeta,
          wideRuns.isAcceptableOrUnknown(data['wide_runs']!, _wideRunsMeta));
    }
    if (data.containsKey('additional_wide_runs')) {
      context.handle(
          _additionalWideRunsMeta,
          additionalWideRuns.isAcceptableOrUnknown(
              data['additional_wide_runs']!, _additionalWideRunsMeta));
    }
    if (data.containsKey('no_ball_runs')) {
      context.handle(
          _noBallRunsMeta,
          noBallRuns.isAcceptableOrUnknown(
              data['no_ball_runs']!, _noBallRunsMeta));
    }
    if (data.containsKey('bye_runs')) {
      context.handle(_byeRunsMeta,
          byeRuns.isAcceptableOrUnknown(data['bye_runs']!, _byeRunsMeta));
    }
    if (data.containsKey('leg_bye_runs')) {
      context.handle(
          _legByeRunsMeta,
          legByeRuns.isAcceptableOrUnknown(
              data['leg_bye_runs']!, _legByeRunsMeta));
    }
    if (data.containsKey('penalty_runs')) {
      context.handle(
          _penaltyRunsMeta,
          penaltyRuns.isAcceptableOrUnknown(
              data['penalty_runs']!, _penaltyRunsMeta));
    }
    if (data.containsKey('is_legal')) {
      context.handle(_isLegalMeta,
          isLegal.isAcceptableOrUnknown(data['is_legal']!, _isLegalMeta));
    }
    if (data.containsKey('is_boundary_four')) {
      context.handle(
          _isBoundaryFourMeta,
          isBoundaryFour.isAcceptableOrUnknown(
              data['is_boundary_four']!, _isBoundaryFourMeta));
    }
    if (data.containsKey('is_boundary_six')) {
      context.handle(
          _isBoundarySixMeta,
          isBoundarySix.isAcceptableOrUnknown(
              data['is_boundary_six']!, _isBoundarySixMeta));
    }
    if (data.containsKey('wicket_type')) {
      context.handle(
          _wicketTypeMeta,
          wicketType.isAcceptableOrUnknown(
              data['wicket_type']!, _wicketTypeMeta));
    }
    if (data.containsKey('dismissed_player_id')) {
      context.handle(
          _dismissedPlayerIdMeta,
          dismissedPlayerId.isAcceptableOrUnknown(
              data['dismissed_player_id']!, _dismissedPlayerIdMeta));
    }
    if (data.containsKey('fielder_id')) {
      context.handle(_fielderIdMeta,
          fielderId.isAcceptableOrUnknown(data['fielder_id']!, _fielderIdMeta));
    }
    if (data.containsKey('is_reversed')) {
      context.handle(
          _isReversedMeta,
          isReversed.isAcceptableOrUnknown(
              data['is_reversed']!, _isReversedMeta));
    }
    if (data.containsKey('previous_event_hash')) {
      context.handle(
          _previousEventHashMeta,
          previousEventHash.isAcceptableOrUnknown(
              data['previous_event_hash']!, _previousEventHashMeta));
    } else if (isInserting) {
      context.missing(_previousEventHashMeta);
    }
    if (data.containsKey('client_timestamp')) {
      context.handle(
          _clientTimestampMeta,
          clientTimestamp.isAcceptableOrUnknown(
              data['client_timestamp']!, _clientTimestampMeta));
    } else if (isInserting) {
      context.missing(_clientTimestampMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {eventId};
  @override
  DeliveriesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeliveriesTableData(
      eventId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}event_id'])!,
      matchId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}match_id'])!,
      inningsId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}innings_id'])!,
      overNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}over_number'])!,
      legalBallNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}legal_ball_number'])!,
      eventSequence: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}event_sequence'])!,
      sequenceInOver: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sequence_in_over'])!,
      scorerDeviceId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}scorer_device_id'])!,
      strikerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}striker_id'])!,
      nonStrikerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}non_striker_id'])!,
      bowlerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}bowler_id'])!,
      runsBatter: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}runs_batter'])!,
      extrasType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}extras_type'])!,
      extrasRuns: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}extras_runs'])!,
      wideRuns: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}wide_runs'])!,
      additionalWideRuns: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}additional_wide_runs'])!,
      noBallRuns: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}no_ball_runs'])!,
      byeRuns: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}bye_runs'])!,
      legByeRuns: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}leg_bye_runs'])!,
      penaltyRuns: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}penalty_runs'])!,
      isLegal: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_legal'])!,
      isBoundaryFour: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_boundary_four'])!,
      isBoundarySix: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_boundary_six'])!,
      wicketType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}wicket_type']),
      dismissedPlayerId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}dismissed_player_id']),
      fielderId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fielder_id']),
      isReversed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_reversed'])!,
      previousEventHash: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}previous_event_hash'])!,
      clientTimestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}client_timestamp'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $DeliveriesTableTable createAlias(String alias) {
    return $DeliveriesTableTable(attachedDatabase, alias);
  }
}

class DeliveriesTableData extends DataClass
    implements Insertable<DeliveriesTableData> {
  final String eventId;
  final String matchId;
  final String inningsId;
  final int overNumber;
  final int legalBallNumber;
  final int eventSequence;
  final int sequenceInOver;
  final String scorerDeviceId;
  final String strikerId;
  final String nonStrikerId;
  final String bowlerId;
  final int runsBatter;
  final String extrasType;
  final int extrasRuns;
  final int wideRuns;
  final int additionalWideRuns;
  final int noBallRuns;
  final int byeRuns;
  final int legByeRuns;
  final int penaltyRuns;
  final bool isLegal;
  final bool isBoundaryFour;
  final bool isBoundarySix;
  final String? wicketType;
  final String? dismissedPlayerId;
  final String? fielderId;
  final bool isReversed;
  final String previousEventHash;
  final int clientTimestamp;
  final String syncStatus;
  const DeliveriesTableData(
      {required this.eventId,
      required this.matchId,
      required this.inningsId,
      required this.overNumber,
      required this.legalBallNumber,
      required this.eventSequence,
      required this.sequenceInOver,
      required this.scorerDeviceId,
      required this.strikerId,
      required this.nonStrikerId,
      required this.bowlerId,
      required this.runsBatter,
      required this.extrasType,
      required this.extrasRuns,
      required this.wideRuns,
      required this.additionalWideRuns,
      required this.noBallRuns,
      required this.byeRuns,
      required this.legByeRuns,
      required this.penaltyRuns,
      required this.isLegal,
      required this.isBoundaryFour,
      required this.isBoundarySix,
      this.wicketType,
      this.dismissedPlayerId,
      this.fielderId,
      required this.isReversed,
      required this.previousEventHash,
      required this.clientTimestamp,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['event_id'] = Variable<String>(eventId);
    map['match_id'] = Variable<String>(matchId);
    map['innings_id'] = Variable<String>(inningsId);
    map['over_number'] = Variable<int>(overNumber);
    map['legal_ball_number'] = Variable<int>(legalBallNumber);
    map['event_sequence'] = Variable<int>(eventSequence);
    map['sequence_in_over'] = Variable<int>(sequenceInOver);
    map['scorer_device_id'] = Variable<String>(scorerDeviceId);
    map['striker_id'] = Variable<String>(strikerId);
    map['non_striker_id'] = Variable<String>(nonStrikerId);
    map['bowler_id'] = Variable<String>(bowlerId);
    map['runs_batter'] = Variable<int>(runsBatter);
    map['extras_type'] = Variable<String>(extrasType);
    map['extras_runs'] = Variable<int>(extrasRuns);
    map['wide_runs'] = Variable<int>(wideRuns);
    map['additional_wide_runs'] = Variable<int>(additionalWideRuns);
    map['no_ball_runs'] = Variable<int>(noBallRuns);
    map['bye_runs'] = Variable<int>(byeRuns);
    map['leg_bye_runs'] = Variable<int>(legByeRuns);
    map['penalty_runs'] = Variable<int>(penaltyRuns);
    map['is_legal'] = Variable<bool>(isLegal);
    map['is_boundary_four'] = Variable<bool>(isBoundaryFour);
    map['is_boundary_six'] = Variable<bool>(isBoundarySix);
    if (!nullToAbsent || wicketType != null) {
      map['wicket_type'] = Variable<String>(wicketType);
    }
    if (!nullToAbsent || dismissedPlayerId != null) {
      map['dismissed_player_id'] = Variable<String>(dismissedPlayerId);
    }
    if (!nullToAbsent || fielderId != null) {
      map['fielder_id'] = Variable<String>(fielderId);
    }
    map['is_reversed'] = Variable<bool>(isReversed);
    map['previous_event_hash'] = Variable<String>(previousEventHash);
    map['client_timestamp'] = Variable<int>(clientTimestamp);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  DeliveriesTableCompanion toCompanion(bool nullToAbsent) {
    return DeliveriesTableCompanion(
      eventId: Value(eventId),
      matchId: Value(matchId),
      inningsId: Value(inningsId),
      overNumber: Value(overNumber),
      legalBallNumber: Value(legalBallNumber),
      eventSequence: Value(eventSequence),
      sequenceInOver: Value(sequenceInOver),
      scorerDeviceId: Value(scorerDeviceId),
      strikerId: Value(strikerId),
      nonStrikerId: Value(nonStrikerId),
      bowlerId: Value(bowlerId),
      runsBatter: Value(runsBatter),
      extrasType: Value(extrasType),
      extrasRuns: Value(extrasRuns),
      wideRuns: Value(wideRuns),
      additionalWideRuns: Value(additionalWideRuns),
      noBallRuns: Value(noBallRuns),
      byeRuns: Value(byeRuns),
      legByeRuns: Value(legByeRuns),
      penaltyRuns: Value(penaltyRuns),
      isLegal: Value(isLegal),
      isBoundaryFour: Value(isBoundaryFour),
      isBoundarySix: Value(isBoundarySix),
      wicketType: wicketType == null && nullToAbsent
          ? const Value.absent()
          : Value(wicketType),
      dismissedPlayerId: dismissedPlayerId == null && nullToAbsent
          ? const Value.absent()
          : Value(dismissedPlayerId),
      fielderId: fielderId == null && nullToAbsent
          ? const Value.absent()
          : Value(fielderId),
      isReversed: Value(isReversed),
      previousEventHash: Value(previousEventHash),
      clientTimestamp: Value(clientTimestamp),
      syncStatus: Value(syncStatus),
    );
  }

  factory DeliveriesTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeliveriesTableData(
      eventId: serializer.fromJson<String>(json['eventId']),
      matchId: serializer.fromJson<String>(json['matchId']),
      inningsId: serializer.fromJson<String>(json['inningsId']),
      overNumber: serializer.fromJson<int>(json['overNumber']),
      legalBallNumber: serializer.fromJson<int>(json['legalBallNumber']),
      eventSequence: serializer.fromJson<int>(json['eventSequence']),
      sequenceInOver: serializer.fromJson<int>(json['sequenceInOver']),
      scorerDeviceId: serializer.fromJson<String>(json['scorerDeviceId']),
      strikerId: serializer.fromJson<String>(json['strikerId']),
      nonStrikerId: serializer.fromJson<String>(json['nonStrikerId']),
      bowlerId: serializer.fromJson<String>(json['bowlerId']),
      runsBatter: serializer.fromJson<int>(json['runsBatter']),
      extrasType: serializer.fromJson<String>(json['extrasType']),
      extrasRuns: serializer.fromJson<int>(json['extrasRuns']),
      wideRuns: serializer.fromJson<int>(json['wideRuns']),
      additionalWideRuns: serializer.fromJson<int>(json['additionalWideRuns']),
      noBallRuns: serializer.fromJson<int>(json['noBallRuns']),
      byeRuns: serializer.fromJson<int>(json['byeRuns']),
      legByeRuns: serializer.fromJson<int>(json['legByeRuns']),
      penaltyRuns: serializer.fromJson<int>(json['penaltyRuns']),
      isLegal: serializer.fromJson<bool>(json['isLegal']),
      isBoundaryFour: serializer.fromJson<bool>(json['isBoundaryFour']),
      isBoundarySix: serializer.fromJson<bool>(json['isBoundarySix']),
      wicketType: serializer.fromJson<String?>(json['wicketType']),
      dismissedPlayerId:
          serializer.fromJson<String?>(json['dismissedPlayerId']),
      fielderId: serializer.fromJson<String?>(json['fielderId']),
      isReversed: serializer.fromJson<bool>(json['isReversed']),
      previousEventHash: serializer.fromJson<String>(json['previousEventHash']),
      clientTimestamp: serializer.fromJson<int>(json['clientTimestamp']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'eventId': serializer.toJson<String>(eventId),
      'matchId': serializer.toJson<String>(matchId),
      'inningsId': serializer.toJson<String>(inningsId),
      'overNumber': serializer.toJson<int>(overNumber),
      'legalBallNumber': serializer.toJson<int>(legalBallNumber),
      'eventSequence': serializer.toJson<int>(eventSequence),
      'sequenceInOver': serializer.toJson<int>(sequenceInOver),
      'scorerDeviceId': serializer.toJson<String>(scorerDeviceId),
      'strikerId': serializer.toJson<String>(strikerId),
      'nonStrikerId': serializer.toJson<String>(nonStrikerId),
      'bowlerId': serializer.toJson<String>(bowlerId),
      'runsBatter': serializer.toJson<int>(runsBatter),
      'extrasType': serializer.toJson<String>(extrasType),
      'extrasRuns': serializer.toJson<int>(extrasRuns),
      'wideRuns': serializer.toJson<int>(wideRuns),
      'additionalWideRuns': serializer.toJson<int>(additionalWideRuns),
      'noBallRuns': serializer.toJson<int>(noBallRuns),
      'byeRuns': serializer.toJson<int>(byeRuns),
      'legByeRuns': serializer.toJson<int>(legByeRuns),
      'penaltyRuns': serializer.toJson<int>(penaltyRuns),
      'isLegal': serializer.toJson<bool>(isLegal),
      'isBoundaryFour': serializer.toJson<bool>(isBoundaryFour),
      'isBoundarySix': serializer.toJson<bool>(isBoundarySix),
      'wicketType': serializer.toJson<String?>(wicketType),
      'dismissedPlayerId': serializer.toJson<String?>(dismissedPlayerId),
      'fielderId': serializer.toJson<String?>(fielderId),
      'isReversed': serializer.toJson<bool>(isReversed),
      'previousEventHash': serializer.toJson<String>(previousEventHash),
      'clientTimestamp': serializer.toJson<int>(clientTimestamp),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  DeliveriesTableData copyWith(
          {String? eventId,
          String? matchId,
          String? inningsId,
          int? overNumber,
          int? legalBallNumber,
          int? eventSequence,
          int? sequenceInOver,
          String? scorerDeviceId,
          String? strikerId,
          String? nonStrikerId,
          String? bowlerId,
          int? runsBatter,
          String? extrasType,
          int? extrasRuns,
          int? wideRuns,
          int? additionalWideRuns,
          int? noBallRuns,
          int? byeRuns,
          int? legByeRuns,
          int? penaltyRuns,
          bool? isLegal,
          bool? isBoundaryFour,
          bool? isBoundarySix,
          Value<String?> wicketType = const Value.absent(),
          Value<String?> dismissedPlayerId = const Value.absent(),
          Value<String?> fielderId = const Value.absent(),
          bool? isReversed,
          String? previousEventHash,
          int? clientTimestamp,
          String? syncStatus}) =>
      DeliveriesTableData(
        eventId: eventId ?? this.eventId,
        matchId: matchId ?? this.matchId,
        inningsId: inningsId ?? this.inningsId,
        overNumber: overNumber ?? this.overNumber,
        legalBallNumber: legalBallNumber ?? this.legalBallNumber,
        eventSequence: eventSequence ?? this.eventSequence,
        sequenceInOver: sequenceInOver ?? this.sequenceInOver,
        scorerDeviceId: scorerDeviceId ?? this.scorerDeviceId,
        strikerId: strikerId ?? this.strikerId,
        nonStrikerId: nonStrikerId ?? this.nonStrikerId,
        bowlerId: bowlerId ?? this.bowlerId,
        runsBatter: runsBatter ?? this.runsBatter,
        extrasType: extrasType ?? this.extrasType,
        extrasRuns: extrasRuns ?? this.extrasRuns,
        wideRuns: wideRuns ?? this.wideRuns,
        additionalWideRuns: additionalWideRuns ?? this.additionalWideRuns,
        noBallRuns: noBallRuns ?? this.noBallRuns,
        byeRuns: byeRuns ?? this.byeRuns,
        legByeRuns: legByeRuns ?? this.legByeRuns,
        penaltyRuns: penaltyRuns ?? this.penaltyRuns,
        isLegal: isLegal ?? this.isLegal,
        isBoundaryFour: isBoundaryFour ?? this.isBoundaryFour,
        isBoundarySix: isBoundarySix ?? this.isBoundarySix,
        wicketType: wicketType.present ? wicketType.value : this.wicketType,
        dismissedPlayerId: dismissedPlayerId.present
            ? dismissedPlayerId.value
            : this.dismissedPlayerId,
        fielderId: fielderId.present ? fielderId.value : this.fielderId,
        isReversed: isReversed ?? this.isReversed,
        previousEventHash: previousEventHash ?? this.previousEventHash,
        clientTimestamp: clientTimestamp ?? this.clientTimestamp,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  DeliveriesTableData copyWithCompanion(DeliveriesTableCompanion data) {
    return DeliveriesTableData(
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      matchId: data.matchId.present ? data.matchId.value : this.matchId,
      inningsId: data.inningsId.present ? data.inningsId.value : this.inningsId,
      overNumber:
          data.overNumber.present ? data.overNumber.value : this.overNumber,
      legalBallNumber: data.legalBallNumber.present
          ? data.legalBallNumber.value
          : this.legalBallNumber,
      eventSequence: data.eventSequence.present
          ? data.eventSequence.value
          : this.eventSequence,
      sequenceInOver: data.sequenceInOver.present
          ? data.sequenceInOver.value
          : this.sequenceInOver,
      scorerDeviceId: data.scorerDeviceId.present
          ? data.scorerDeviceId.value
          : this.scorerDeviceId,
      strikerId: data.strikerId.present ? data.strikerId.value : this.strikerId,
      nonStrikerId: data.nonStrikerId.present
          ? data.nonStrikerId.value
          : this.nonStrikerId,
      bowlerId: data.bowlerId.present ? data.bowlerId.value : this.bowlerId,
      runsBatter:
          data.runsBatter.present ? data.runsBatter.value : this.runsBatter,
      extrasType:
          data.extrasType.present ? data.extrasType.value : this.extrasType,
      extrasRuns:
          data.extrasRuns.present ? data.extrasRuns.value : this.extrasRuns,
      wideRuns: data.wideRuns.present ? data.wideRuns.value : this.wideRuns,
      additionalWideRuns: data.additionalWideRuns.present
          ? data.additionalWideRuns.value
          : this.additionalWideRuns,
      noBallRuns:
          data.noBallRuns.present ? data.noBallRuns.value : this.noBallRuns,
      byeRuns: data.byeRuns.present ? data.byeRuns.value : this.byeRuns,
      legByeRuns:
          data.legByeRuns.present ? data.legByeRuns.value : this.legByeRuns,
      penaltyRuns:
          data.penaltyRuns.present ? data.penaltyRuns.value : this.penaltyRuns,
      isLegal: data.isLegal.present ? data.isLegal.value : this.isLegal,
      isBoundaryFour: data.isBoundaryFour.present
          ? data.isBoundaryFour.value
          : this.isBoundaryFour,
      isBoundarySix: data.isBoundarySix.present
          ? data.isBoundarySix.value
          : this.isBoundarySix,
      wicketType:
          data.wicketType.present ? data.wicketType.value : this.wicketType,
      dismissedPlayerId: data.dismissedPlayerId.present
          ? data.dismissedPlayerId.value
          : this.dismissedPlayerId,
      fielderId: data.fielderId.present ? data.fielderId.value : this.fielderId,
      isReversed:
          data.isReversed.present ? data.isReversed.value : this.isReversed,
      previousEventHash: data.previousEventHash.present
          ? data.previousEventHash.value
          : this.previousEventHash,
      clientTimestamp: data.clientTimestamp.present
          ? data.clientTimestamp.value
          : this.clientTimestamp,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeliveriesTableData(')
          ..write('eventId: $eventId, ')
          ..write('matchId: $matchId, ')
          ..write('inningsId: $inningsId, ')
          ..write('overNumber: $overNumber, ')
          ..write('legalBallNumber: $legalBallNumber, ')
          ..write('eventSequence: $eventSequence, ')
          ..write('sequenceInOver: $sequenceInOver, ')
          ..write('scorerDeviceId: $scorerDeviceId, ')
          ..write('strikerId: $strikerId, ')
          ..write('nonStrikerId: $nonStrikerId, ')
          ..write('bowlerId: $bowlerId, ')
          ..write('runsBatter: $runsBatter, ')
          ..write('extrasType: $extrasType, ')
          ..write('extrasRuns: $extrasRuns, ')
          ..write('wideRuns: $wideRuns, ')
          ..write('additionalWideRuns: $additionalWideRuns, ')
          ..write('noBallRuns: $noBallRuns, ')
          ..write('byeRuns: $byeRuns, ')
          ..write('legByeRuns: $legByeRuns, ')
          ..write('penaltyRuns: $penaltyRuns, ')
          ..write('isLegal: $isLegal, ')
          ..write('isBoundaryFour: $isBoundaryFour, ')
          ..write('isBoundarySix: $isBoundarySix, ')
          ..write('wicketType: $wicketType, ')
          ..write('dismissedPlayerId: $dismissedPlayerId, ')
          ..write('fielderId: $fielderId, ')
          ..write('isReversed: $isReversed, ')
          ..write('previousEventHash: $previousEventHash, ')
          ..write('clientTimestamp: $clientTimestamp, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        eventId,
        matchId,
        inningsId,
        overNumber,
        legalBallNumber,
        eventSequence,
        sequenceInOver,
        scorerDeviceId,
        strikerId,
        nonStrikerId,
        bowlerId,
        runsBatter,
        extrasType,
        extrasRuns,
        wideRuns,
        additionalWideRuns,
        noBallRuns,
        byeRuns,
        legByeRuns,
        penaltyRuns,
        isLegal,
        isBoundaryFour,
        isBoundarySix,
        wicketType,
        dismissedPlayerId,
        fielderId,
        isReversed,
        previousEventHash,
        clientTimestamp,
        syncStatus
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeliveriesTableData &&
          other.eventId == this.eventId &&
          other.matchId == this.matchId &&
          other.inningsId == this.inningsId &&
          other.overNumber == this.overNumber &&
          other.legalBallNumber == this.legalBallNumber &&
          other.eventSequence == this.eventSequence &&
          other.sequenceInOver == this.sequenceInOver &&
          other.scorerDeviceId == this.scorerDeviceId &&
          other.strikerId == this.strikerId &&
          other.nonStrikerId == this.nonStrikerId &&
          other.bowlerId == this.bowlerId &&
          other.runsBatter == this.runsBatter &&
          other.extrasType == this.extrasType &&
          other.extrasRuns == this.extrasRuns &&
          other.wideRuns == this.wideRuns &&
          other.additionalWideRuns == this.additionalWideRuns &&
          other.noBallRuns == this.noBallRuns &&
          other.byeRuns == this.byeRuns &&
          other.legByeRuns == this.legByeRuns &&
          other.penaltyRuns == this.penaltyRuns &&
          other.isLegal == this.isLegal &&
          other.isBoundaryFour == this.isBoundaryFour &&
          other.isBoundarySix == this.isBoundarySix &&
          other.wicketType == this.wicketType &&
          other.dismissedPlayerId == this.dismissedPlayerId &&
          other.fielderId == this.fielderId &&
          other.isReversed == this.isReversed &&
          other.previousEventHash == this.previousEventHash &&
          other.clientTimestamp == this.clientTimestamp &&
          other.syncStatus == this.syncStatus);
}

class DeliveriesTableCompanion extends UpdateCompanion<DeliveriesTableData> {
  final Value<String> eventId;
  final Value<String> matchId;
  final Value<String> inningsId;
  final Value<int> overNumber;
  final Value<int> legalBallNumber;
  final Value<int> eventSequence;
  final Value<int> sequenceInOver;
  final Value<String> scorerDeviceId;
  final Value<String> strikerId;
  final Value<String> nonStrikerId;
  final Value<String> bowlerId;
  final Value<int> runsBatter;
  final Value<String> extrasType;
  final Value<int> extrasRuns;
  final Value<int> wideRuns;
  final Value<int> additionalWideRuns;
  final Value<int> noBallRuns;
  final Value<int> byeRuns;
  final Value<int> legByeRuns;
  final Value<int> penaltyRuns;
  final Value<bool> isLegal;
  final Value<bool> isBoundaryFour;
  final Value<bool> isBoundarySix;
  final Value<String?> wicketType;
  final Value<String?> dismissedPlayerId;
  final Value<String?> fielderId;
  final Value<bool> isReversed;
  final Value<String> previousEventHash;
  final Value<int> clientTimestamp;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const DeliveriesTableCompanion({
    this.eventId = const Value.absent(),
    this.matchId = const Value.absent(),
    this.inningsId = const Value.absent(),
    this.overNumber = const Value.absent(),
    this.legalBallNumber = const Value.absent(),
    this.eventSequence = const Value.absent(),
    this.sequenceInOver = const Value.absent(),
    this.scorerDeviceId = const Value.absent(),
    this.strikerId = const Value.absent(),
    this.nonStrikerId = const Value.absent(),
    this.bowlerId = const Value.absent(),
    this.runsBatter = const Value.absent(),
    this.extrasType = const Value.absent(),
    this.extrasRuns = const Value.absent(),
    this.wideRuns = const Value.absent(),
    this.additionalWideRuns = const Value.absent(),
    this.noBallRuns = const Value.absent(),
    this.byeRuns = const Value.absent(),
    this.legByeRuns = const Value.absent(),
    this.penaltyRuns = const Value.absent(),
    this.isLegal = const Value.absent(),
    this.isBoundaryFour = const Value.absent(),
    this.isBoundarySix = const Value.absent(),
    this.wicketType = const Value.absent(),
    this.dismissedPlayerId = const Value.absent(),
    this.fielderId = const Value.absent(),
    this.isReversed = const Value.absent(),
    this.previousEventHash = const Value.absent(),
    this.clientTimestamp = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DeliveriesTableCompanion.insert({
    required String eventId,
    required String matchId,
    required String inningsId,
    required int overNumber,
    required int legalBallNumber,
    required int eventSequence,
    this.sequenceInOver = const Value.absent(),
    required String scorerDeviceId,
    required String strikerId,
    required String nonStrikerId,
    required String bowlerId,
    this.runsBatter = const Value.absent(),
    this.extrasType = const Value.absent(),
    this.extrasRuns = const Value.absent(),
    this.wideRuns = const Value.absent(),
    this.additionalWideRuns = const Value.absent(),
    this.noBallRuns = const Value.absent(),
    this.byeRuns = const Value.absent(),
    this.legByeRuns = const Value.absent(),
    this.penaltyRuns = const Value.absent(),
    this.isLegal = const Value.absent(),
    this.isBoundaryFour = const Value.absent(),
    this.isBoundarySix = const Value.absent(),
    this.wicketType = const Value.absent(),
    this.dismissedPlayerId = const Value.absent(),
    this.fielderId = const Value.absent(),
    this.isReversed = const Value.absent(),
    required String previousEventHash,
    required int clientTimestamp,
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : eventId = Value(eventId),
        matchId = Value(matchId),
        inningsId = Value(inningsId),
        overNumber = Value(overNumber),
        legalBallNumber = Value(legalBallNumber),
        eventSequence = Value(eventSequence),
        scorerDeviceId = Value(scorerDeviceId),
        strikerId = Value(strikerId),
        nonStrikerId = Value(nonStrikerId),
        bowlerId = Value(bowlerId),
        previousEventHash = Value(previousEventHash),
        clientTimestamp = Value(clientTimestamp);
  static Insertable<DeliveriesTableData> custom({
    Expression<String>? eventId,
    Expression<String>? matchId,
    Expression<String>? inningsId,
    Expression<int>? overNumber,
    Expression<int>? legalBallNumber,
    Expression<int>? eventSequence,
    Expression<int>? sequenceInOver,
    Expression<String>? scorerDeviceId,
    Expression<String>? strikerId,
    Expression<String>? nonStrikerId,
    Expression<String>? bowlerId,
    Expression<int>? runsBatter,
    Expression<String>? extrasType,
    Expression<int>? extrasRuns,
    Expression<int>? wideRuns,
    Expression<int>? additionalWideRuns,
    Expression<int>? noBallRuns,
    Expression<int>? byeRuns,
    Expression<int>? legByeRuns,
    Expression<int>? penaltyRuns,
    Expression<bool>? isLegal,
    Expression<bool>? isBoundaryFour,
    Expression<bool>? isBoundarySix,
    Expression<String>? wicketType,
    Expression<String>? dismissedPlayerId,
    Expression<String>? fielderId,
    Expression<bool>? isReversed,
    Expression<String>? previousEventHash,
    Expression<int>? clientTimestamp,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (eventId != null) 'event_id': eventId,
      if (matchId != null) 'match_id': matchId,
      if (inningsId != null) 'innings_id': inningsId,
      if (overNumber != null) 'over_number': overNumber,
      if (legalBallNumber != null) 'legal_ball_number': legalBallNumber,
      if (eventSequence != null) 'event_sequence': eventSequence,
      if (sequenceInOver != null) 'sequence_in_over': sequenceInOver,
      if (scorerDeviceId != null) 'scorer_device_id': scorerDeviceId,
      if (strikerId != null) 'striker_id': strikerId,
      if (nonStrikerId != null) 'non_striker_id': nonStrikerId,
      if (bowlerId != null) 'bowler_id': bowlerId,
      if (runsBatter != null) 'runs_batter': runsBatter,
      if (extrasType != null) 'extras_type': extrasType,
      if (extrasRuns != null) 'extras_runs': extrasRuns,
      if (wideRuns != null) 'wide_runs': wideRuns,
      if (additionalWideRuns != null)
        'additional_wide_runs': additionalWideRuns,
      if (noBallRuns != null) 'no_ball_runs': noBallRuns,
      if (byeRuns != null) 'bye_runs': byeRuns,
      if (legByeRuns != null) 'leg_bye_runs': legByeRuns,
      if (penaltyRuns != null) 'penalty_runs': penaltyRuns,
      if (isLegal != null) 'is_legal': isLegal,
      if (isBoundaryFour != null) 'is_boundary_four': isBoundaryFour,
      if (isBoundarySix != null) 'is_boundary_six': isBoundarySix,
      if (wicketType != null) 'wicket_type': wicketType,
      if (dismissedPlayerId != null) 'dismissed_player_id': dismissedPlayerId,
      if (fielderId != null) 'fielder_id': fielderId,
      if (isReversed != null) 'is_reversed': isReversed,
      if (previousEventHash != null) 'previous_event_hash': previousEventHash,
      if (clientTimestamp != null) 'client_timestamp': clientTimestamp,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DeliveriesTableCompanion copyWith(
      {Value<String>? eventId,
      Value<String>? matchId,
      Value<String>? inningsId,
      Value<int>? overNumber,
      Value<int>? legalBallNumber,
      Value<int>? eventSequence,
      Value<int>? sequenceInOver,
      Value<String>? scorerDeviceId,
      Value<String>? strikerId,
      Value<String>? nonStrikerId,
      Value<String>? bowlerId,
      Value<int>? runsBatter,
      Value<String>? extrasType,
      Value<int>? extrasRuns,
      Value<int>? wideRuns,
      Value<int>? additionalWideRuns,
      Value<int>? noBallRuns,
      Value<int>? byeRuns,
      Value<int>? legByeRuns,
      Value<int>? penaltyRuns,
      Value<bool>? isLegal,
      Value<bool>? isBoundaryFour,
      Value<bool>? isBoundarySix,
      Value<String?>? wicketType,
      Value<String?>? dismissedPlayerId,
      Value<String?>? fielderId,
      Value<bool>? isReversed,
      Value<String>? previousEventHash,
      Value<int>? clientTimestamp,
      Value<String>? syncStatus,
      Value<int>? rowid}) {
    return DeliveriesTableCompanion(
      eventId: eventId ?? this.eventId,
      matchId: matchId ?? this.matchId,
      inningsId: inningsId ?? this.inningsId,
      overNumber: overNumber ?? this.overNumber,
      legalBallNumber: legalBallNumber ?? this.legalBallNumber,
      eventSequence: eventSequence ?? this.eventSequence,
      sequenceInOver: sequenceInOver ?? this.sequenceInOver,
      scorerDeviceId: scorerDeviceId ?? this.scorerDeviceId,
      strikerId: strikerId ?? this.strikerId,
      nonStrikerId: nonStrikerId ?? this.nonStrikerId,
      bowlerId: bowlerId ?? this.bowlerId,
      runsBatter: runsBatter ?? this.runsBatter,
      extrasType: extrasType ?? this.extrasType,
      extrasRuns: extrasRuns ?? this.extrasRuns,
      wideRuns: wideRuns ?? this.wideRuns,
      additionalWideRuns: additionalWideRuns ?? this.additionalWideRuns,
      noBallRuns: noBallRuns ?? this.noBallRuns,
      byeRuns: byeRuns ?? this.byeRuns,
      legByeRuns: legByeRuns ?? this.legByeRuns,
      penaltyRuns: penaltyRuns ?? this.penaltyRuns,
      isLegal: isLegal ?? this.isLegal,
      isBoundaryFour: isBoundaryFour ?? this.isBoundaryFour,
      isBoundarySix: isBoundarySix ?? this.isBoundarySix,
      wicketType: wicketType ?? this.wicketType,
      dismissedPlayerId: dismissedPlayerId ?? this.dismissedPlayerId,
      fielderId: fielderId ?? this.fielderId,
      isReversed: isReversed ?? this.isReversed,
      previousEventHash: previousEventHash ?? this.previousEventHash,
      clientTimestamp: clientTimestamp ?? this.clientTimestamp,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (matchId.present) {
      map['match_id'] = Variable<String>(matchId.value);
    }
    if (inningsId.present) {
      map['innings_id'] = Variable<String>(inningsId.value);
    }
    if (overNumber.present) {
      map['over_number'] = Variable<int>(overNumber.value);
    }
    if (legalBallNumber.present) {
      map['legal_ball_number'] = Variable<int>(legalBallNumber.value);
    }
    if (eventSequence.present) {
      map['event_sequence'] = Variable<int>(eventSequence.value);
    }
    if (sequenceInOver.present) {
      map['sequence_in_over'] = Variable<int>(sequenceInOver.value);
    }
    if (scorerDeviceId.present) {
      map['scorer_device_id'] = Variable<String>(scorerDeviceId.value);
    }
    if (strikerId.present) {
      map['striker_id'] = Variable<String>(strikerId.value);
    }
    if (nonStrikerId.present) {
      map['non_striker_id'] = Variable<String>(nonStrikerId.value);
    }
    if (bowlerId.present) {
      map['bowler_id'] = Variable<String>(bowlerId.value);
    }
    if (runsBatter.present) {
      map['runs_batter'] = Variable<int>(runsBatter.value);
    }
    if (extrasType.present) {
      map['extras_type'] = Variable<String>(extrasType.value);
    }
    if (extrasRuns.present) {
      map['extras_runs'] = Variable<int>(extrasRuns.value);
    }
    if (wideRuns.present) {
      map['wide_runs'] = Variable<int>(wideRuns.value);
    }
    if (additionalWideRuns.present) {
      map['additional_wide_runs'] = Variable<int>(additionalWideRuns.value);
    }
    if (noBallRuns.present) {
      map['no_ball_runs'] = Variable<int>(noBallRuns.value);
    }
    if (byeRuns.present) {
      map['bye_runs'] = Variable<int>(byeRuns.value);
    }
    if (legByeRuns.present) {
      map['leg_bye_runs'] = Variable<int>(legByeRuns.value);
    }
    if (penaltyRuns.present) {
      map['penalty_runs'] = Variable<int>(penaltyRuns.value);
    }
    if (isLegal.present) {
      map['is_legal'] = Variable<bool>(isLegal.value);
    }
    if (isBoundaryFour.present) {
      map['is_boundary_four'] = Variable<bool>(isBoundaryFour.value);
    }
    if (isBoundarySix.present) {
      map['is_boundary_six'] = Variable<bool>(isBoundarySix.value);
    }
    if (wicketType.present) {
      map['wicket_type'] = Variable<String>(wicketType.value);
    }
    if (dismissedPlayerId.present) {
      map['dismissed_player_id'] = Variable<String>(dismissedPlayerId.value);
    }
    if (fielderId.present) {
      map['fielder_id'] = Variable<String>(fielderId.value);
    }
    if (isReversed.present) {
      map['is_reversed'] = Variable<bool>(isReversed.value);
    }
    if (previousEventHash.present) {
      map['previous_event_hash'] = Variable<String>(previousEventHash.value);
    }
    if (clientTimestamp.present) {
      map['client_timestamp'] = Variable<int>(clientTimestamp.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeliveriesTableCompanion(')
          ..write('eventId: $eventId, ')
          ..write('matchId: $matchId, ')
          ..write('inningsId: $inningsId, ')
          ..write('overNumber: $overNumber, ')
          ..write('legalBallNumber: $legalBallNumber, ')
          ..write('eventSequence: $eventSequence, ')
          ..write('sequenceInOver: $sequenceInOver, ')
          ..write('scorerDeviceId: $scorerDeviceId, ')
          ..write('strikerId: $strikerId, ')
          ..write('nonStrikerId: $nonStrikerId, ')
          ..write('bowlerId: $bowlerId, ')
          ..write('runsBatter: $runsBatter, ')
          ..write('extrasType: $extrasType, ')
          ..write('extrasRuns: $extrasRuns, ')
          ..write('wideRuns: $wideRuns, ')
          ..write('additionalWideRuns: $additionalWideRuns, ')
          ..write('noBallRuns: $noBallRuns, ')
          ..write('byeRuns: $byeRuns, ')
          ..write('legByeRuns: $legByeRuns, ')
          ..write('penaltyRuns: $penaltyRuns, ')
          ..write('isLegal: $isLegal, ')
          ..write('isBoundaryFour: $isBoundaryFour, ')
          ..write('isBoundarySix: $isBoundarySix, ')
          ..write('wicketType: $wicketType, ')
          ..write('dismissedPlayerId: $dismissedPlayerId, ')
          ..write('fielderId: $fielderId, ')
          ..write('isReversed: $isReversed, ')
          ..write('previousEventHash: $previousEventHash, ')
          ..write('clientTimestamp: $clientTimestamp, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTableTable extends SyncQueueTable
    with TableInfo<$SyncQueueTableTable, SyncQueueTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _eventIdMeta =
      const VerificationMeta('eventId');
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
      'event_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _matchIdMeta =
      const VerificationMeta('matchId');
  @override
  late final GeneratedColumn<String> matchId = GeneratedColumn<String>(
      'match_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _attemptsMeta =
      const VerificationMeta('attempts');
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
      'attempts', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _errorMessageMeta =
      const VerificationMeta('errorMessage');
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
      'error_message', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, eventId, matchId, payloadJson, attempts, status, errorMessage];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue_table';
  @override
  VerificationContext validateIntegrity(Insertable<SyncQueueTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('event_id')) {
      context.handle(_eventIdMeta,
          eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta));
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('match_id')) {
      context.handle(_matchIdMeta,
          matchId.isAcceptableOrUnknown(data['match_id']!, _matchIdMeta));
    } else if (isInserting) {
      context.missing(_matchIdMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(_attemptsMeta,
          attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('error_message')) {
      context.handle(
          _errorMessageMeta,
          errorMessage.isAcceptableOrUnknown(
              data['error_message']!, _errorMessageMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      eventId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}event_id'])!,
      matchId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}match_id'])!,
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
      attempts: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}attempts'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      errorMessage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}error_message']),
    );
  }

  @override
  $SyncQueueTableTable createAlias(String alias) {
    return $SyncQueueTableTable(attachedDatabase, alias);
  }
}

class SyncQueueTableData extends DataClass
    implements Insertable<SyncQueueTableData> {
  final int id;
  final String eventId;
  final String matchId;
  final String payloadJson;
  final int attempts;
  final String status;
  final String? errorMessage;
  const SyncQueueTableData(
      {required this.id,
      required this.eventId,
      required this.matchId,
      required this.payloadJson,
      required this.attempts,
      required this.status,
      this.errorMessage});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['event_id'] = Variable<String>(eventId);
    map['match_id'] = Variable<String>(matchId);
    map['payload_json'] = Variable<String>(payloadJson);
    map['attempts'] = Variable<int>(attempts);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    return map;
  }

  SyncQueueTableCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueTableCompanion(
      id: Value(id),
      eventId: Value(eventId),
      matchId: Value(matchId),
      payloadJson: Value(payloadJson),
      attempts: Value(attempts),
      status: Value(status),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
    );
  }

  factory SyncQueueTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueTableData(
      id: serializer.fromJson<int>(json['id']),
      eventId: serializer.fromJson<String>(json['eventId']),
      matchId: serializer.fromJson<String>(json['matchId']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      attempts: serializer.fromJson<int>(json['attempts']),
      status: serializer.fromJson<String>(json['status']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'eventId': serializer.toJson<String>(eventId),
      'matchId': serializer.toJson<String>(matchId),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'attempts': serializer.toJson<int>(attempts),
      'status': serializer.toJson<String>(status),
      'errorMessage': serializer.toJson<String?>(errorMessage),
    };
  }

  SyncQueueTableData copyWith(
          {int? id,
          String? eventId,
          String? matchId,
          String? payloadJson,
          int? attempts,
          String? status,
          Value<String?> errorMessage = const Value.absent()}) =>
      SyncQueueTableData(
        id: id ?? this.id,
        eventId: eventId ?? this.eventId,
        matchId: matchId ?? this.matchId,
        payloadJson: payloadJson ?? this.payloadJson,
        attempts: attempts ?? this.attempts,
        status: status ?? this.status,
        errorMessage:
            errorMessage.present ? errorMessage.value : this.errorMessage,
      );
  SyncQueueTableData copyWithCompanion(SyncQueueTableCompanion data) {
    return SyncQueueTableData(
      id: data.id.present ? data.id.value : this.id,
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      matchId: data.matchId.present ? data.matchId.value : this.matchId,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      status: data.status.present ? data.status.value : this.status,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueTableData(')
          ..write('id: $id, ')
          ..write('eventId: $eventId, ')
          ..write('matchId: $matchId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('attempts: $attempts, ')
          ..write('status: $status, ')
          ..write('errorMessage: $errorMessage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, eventId, matchId, payloadJson, attempts, status, errorMessage);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueTableData &&
          other.id == this.id &&
          other.eventId == this.eventId &&
          other.matchId == this.matchId &&
          other.payloadJson == this.payloadJson &&
          other.attempts == this.attempts &&
          other.status == this.status &&
          other.errorMessage == this.errorMessage);
}

class SyncQueueTableCompanion extends UpdateCompanion<SyncQueueTableData> {
  final Value<int> id;
  final Value<String> eventId;
  final Value<String> matchId;
  final Value<String> payloadJson;
  final Value<int> attempts;
  final Value<String> status;
  final Value<String?> errorMessage;
  const SyncQueueTableCompanion({
    this.id = const Value.absent(),
    this.eventId = const Value.absent(),
    this.matchId = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.attempts = const Value.absent(),
    this.status = const Value.absent(),
    this.errorMessage = const Value.absent(),
  });
  SyncQueueTableCompanion.insert({
    this.id = const Value.absent(),
    required String eventId,
    required String matchId,
    required String payloadJson,
    this.attempts = const Value.absent(),
    this.status = const Value.absent(),
    this.errorMessage = const Value.absent(),
  })  : eventId = Value(eventId),
        matchId = Value(matchId),
        payloadJson = Value(payloadJson);
  static Insertable<SyncQueueTableData> custom({
    Expression<int>? id,
    Expression<String>? eventId,
    Expression<String>? matchId,
    Expression<String>? payloadJson,
    Expression<int>? attempts,
    Expression<String>? status,
    Expression<String>? errorMessage,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (eventId != null) 'event_id': eventId,
      if (matchId != null) 'match_id': matchId,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (attempts != null) 'attempts': attempts,
      if (status != null) 'status': status,
      if (errorMessage != null) 'error_message': errorMessage,
    });
  }

  SyncQueueTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? eventId,
      Value<String>? matchId,
      Value<String>? payloadJson,
      Value<int>? attempts,
      Value<String>? status,
      Value<String?>? errorMessage}) {
    return SyncQueueTableCompanion(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      matchId: matchId ?? this.matchId,
      payloadJson: payloadJson ?? this.payloadJson,
      attempts: attempts ?? this.attempts,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (matchId.present) {
      map['match_id'] = Variable<String>(matchId.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueTableCompanion(')
          ..write('id: $id, ')
          ..write('eventId: $eventId, ')
          ..write('matchId: $matchId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('attempts: $attempts, ')
          ..write('status: $status, ')
          ..write('errorMessage: $errorMessage')
          ..write(')'))
        .toString();
  }
}

class $ScoringAuditTableTable extends ScoringAuditTable
    with TableInfo<$ScoringAuditTableTable, ScoringAuditTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScoringAuditTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _matchIdMeta =
      const VerificationMeta('matchId');
  @override
  late final GeneratedColumn<String> matchId = GeneratedColumn<String>(
      'match_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _inningsIdMeta =
      const VerificationMeta('inningsId');
  @override
  late final GeneratedColumn<String> inningsId = GeneratedColumn<String>(
      'innings_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
      'action', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, matchId, inningsId, action, payloadJson, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scoring_audit_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<ScoringAuditTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('match_id')) {
      context.handle(_matchIdMeta,
          matchId.isAcceptableOrUnknown(data['match_id']!, _matchIdMeta));
    } else if (isInserting) {
      context.missing(_matchIdMeta);
    }
    if (data.containsKey('innings_id')) {
      context.handle(_inningsIdMeta,
          inningsId.isAcceptableOrUnknown(data['innings_id']!, _inningsIdMeta));
    } else if (isInserting) {
      context.missing(_inningsIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(_actionMeta,
          action.isAcceptableOrUnknown(data['action']!, _actionMeta));
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScoringAuditTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScoringAuditTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      matchId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}match_id'])!,
      inningsId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}innings_id'])!,
      action: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action'])!,
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ScoringAuditTableTable createAlias(String alias) {
    return $ScoringAuditTableTable(attachedDatabase, alias);
  }
}

class ScoringAuditTableData extends DataClass
    implements Insertable<ScoringAuditTableData> {
  final String id;
  final String matchId;
  final String inningsId;
  final String action;
  final String payloadJson;
  final int createdAt;
  const ScoringAuditTableData(
      {required this.id,
      required this.matchId,
      required this.inningsId,
      required this.action,
      required this.payloadJson,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['match_id'] = Variable<String>(matchId);
    map['innings_id'] = Variable<String>(inningsId);
    map['action'] = Variable<String>(action);
    map['payload_json'] = Variable<String>(payloadJson);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  ScoringAuditTableCompanion toCompanion(bool nullToAbsent) {
    return ScoringAuditTableCompanion(
      id: Value(id),
      matchId: Value(matchId),
      inningsId: Value(inningsId),
      action: Value(action),
      payloadJson: Value(payloadJson),
      createdAt: Value(createdAt),
    );
  }

  factory ScoringAuditTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScoringAuditTableData(
      id: serializer.fromJson<String>(json['id']),
      matchId: serializer.fromJson<String>(json['matchId']),
      inningsId: serializer.fromJson<String>(json['inningsId']),
      action: serializer.fromJson<String>(json['action']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'matchId': serializer.toJson<String>(matchId),
      'inningsId': serializer.toJson<String>(inningsId),
      'action': serializer.toJson<String>(action),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  ScoringAuditTableData copyWith(
          {String? id,
          String? matchId,
          String? inningsId,
          String? action,
          String? payloadJson,
          int? createdAt}) =>
      ScoringAuditTableData(
        id: id ?? this.id,
        matchId: matchId ?? this.matchId,
        inningsId: inningsId ?? this.inningsId,
        action: action ?? this.action,
        payloadJson: payloadJson ?? this.payloadJson,
        createdAt: createdAt ?? this.createdAt,
      );
  ScoringAuditTableData copyWithCompanion(ScoringAuditTableCompanion data) {
    return ScoringAuditTableData(
      id: data.id.present ? data.id.value : this.id,
      matchId: data.matchId.present ? data.matchId.value : this.matchId,
      inningsId: data.inningsId.present ? data.inningsId.value : this.inningsId,
      action: data.action.present ? data.action.value : this.action,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScoringAuditTableData(')
          ..write('id: $id, ')
          ..write('matchId: $matchId, ')
          ..write('inningsId: $inningsId, ')
          ..write('action: $action, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, matchId, inningsId, action, payloadJson, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScoringAuditTableData &&
          other.id == this.id &&
          other.matchId == this.matchId &&
          other.inningsId == this.inningsId &&
          other.action == this.action &&
          other.payloadJson == this.payloadJson &&
          other.createdAt == this.createdAt);
}

class ScoringAuditTableCompanion
    extends UpdateCompanion<ScoringAuditTableData> {
  final Value<String> id;
  final Value<String> matchId;
  final Value<String> inningsId;
  final Value<String> action;
  final Value<String> payloadJson;
  final Value<int> createdAt;
  final Value<int> rowid;
  const ScoringAuditTableCompanion({
    this.id = const Value.absent(),
    this.matchId = const Value.absent(),
    this.inningsId = const Value.absent(),
    this.action = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScoringAuditTableCompanion.insert({
    required String id,
    required String matchId,
    required String inningsId,
    required String action,
    required String payloadJson,
    required int createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        matchId = Value(matchId),
        inningsId = Value(inningsId),
        action = Value(action),
        payloadJson = Value(payloadJson),
        createdAt = Value(createdAt);
  static Insertable<ScoringAuditTableData> custom({
    Expression<String>? id,
    Expression<String>? matchId,
    Expression<String>? inningsId,
    Expression<String>? action,
    Expression<String>? payloadJson,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (matchId != null) 'match_id': matchId,
      if (inningsId != null) 'innings_id': inningsId,
      if (action != null) 'action': action,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScoringAuditTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? matchId,
      Value<String>? inningsId,
      Value<String>? action,
      Value<String>? payloadJson,
      Value<int>? createdAt,
      Value<int>? rowid}) {
    return ScoringAuditTableCompanion(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      inningsId: inningsId ?? this.inningsId,
      action: action ?? this.action,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (matchId.present) {
      map['match_id'] = Variable<String>(matchId.value);
    }
    if (inningsId.present) {
      map['innings_id'] = Variable<String>(inningsId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScoringAuditTableCompanion(')
          ..write('id: $id, ')
          ..write('matchId: $matchId, ')
          ..write('inningsId: $inningsId, ')
          ..write('action: $action, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MatchSquadMembersTableTable extends MatchSquadMembersTable
    with TableInfo<$MatchSquadMembersTableTable, MatchSquadMembersTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MatchSquadMembersTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _matchIdMeta =
      const VerificationMeta('matchId');
  @override
  late final GeneratedColumn<String> matchId = GeneratedColumn<String>(
      'match_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _teamIdMeta = const VerificationMeta('teamId');
  @override
  late final GeneratedColumn<String> teamId = GeneratedColumn<String>(
      'team_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _playerIdMeta =
      const VerificationMeta('playerId');
  @override
  late final GeneratedColumn<String> playerId = GeneratedColumn<String>(
      'player_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _playerNameSnapshotMeta =
      const VerificationMeta('playerNameSnapshot');
  @override
  late final GeneratedColumn<String> playerNameSnapshot =
      GeneratedColumn<String>('player_name_snapshot', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _addedAfterMatchStartMeta =
      const VerificationMeta('addedAfterMatchStart');
  @override
  late final GeneratedColumn<bool> addedAfterMatchStart = GeneratedColumn<bool>(
      'added_after_match_start', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("added_after_match_start" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _joinedAtMeta =
      const VerificationMeta('joinedAt');
  @override
  late final GeneratedColumn<int> joinedAt = GeneratedColumn<int>(
      'joined_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _joinedInningsIdMeta =
      const VerificationMeta('joinedInningsId');
  @override
  late final GeneratedColumn<String> joinedInningsId = GeneratedColumn<String>(
      'joined_innings_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _joinedOverNumberMeta =
      const VerificationMeta('joinedOverNumber');
  @override
  late final GeneratedColumn<int> joinedOverNumber = GeneratedColumn<int>(
      'joined_over_number', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _joinedDeliverySequenceMeta =
      const VerificationMeta('joinedDeliverySequence');
  @override
  late final GeneratedColumn<int> joinedDeliverySequence = GeneratedColumn<int>(
      'joined_delivery_sequence', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _isEligibleBowlerMeta =
      const VerificationMeta('isEligibleBowler');
  @override
  late final GeneratedColumn<bool> isEligibleBowler = GeneratedColumn<bool>(
      'is_eligible_bowler', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_eligible_bowler" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _isAvailableMeta =
      const VerificationMeta('isAvailable');
  @override
  late final GeneratedColumn<bool> isAvailable = GeneratedColumn<bool>(
      'is_available', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_available" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _addedToPermanentTeamMeta =
      const VerificationMeta('addedToPermanentTeam');
  @override
  late final GeneratedColumn<bool> addedToPermanentTeam = GeneratedColumn<bool>(
      'added_to_permanent_team', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("added_to_permanent_team" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _removedAtMeta =
      const VerificationMeta('removedAt');
  @override
  late final GeneratedColumn<int> removedAt = GeneratedColumn<int>(
      'removed_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        matchId,
        teamId,
        playerId,
        playerNameSnapshot,
        addedAfterMatchStart,
        joinedAt,
        joinedInningsId,
        joinedOverNumber,
        joinedDeliverySequence,
        isEligibleBowler,
        isAvailable,
        addedToPermanentTeam,
        isActive,
        removedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'match_squad_members_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<MatchSquadMembersTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('match_id')) {
      context.handle(_matchIdMeta,
          matchId.isAcceptableOrUnknown(data['match_id']!, _matchIdMeta));
    } else if (isInserting) {
      context.missing(_matchIdMeta);
    }
    if (data.containsKey('team_id')) {
      context.handle(_teamIdMeta,
          teamId.isAcceptableOrUnknown(data['team_id']!, _teamIdMeta));
    } else if (isInserting) {
      context.missing(_teamIdMeta);
    }
    if (data.containsKey('player_id')) {
      context.handle(_playerIdMeta,
          playerId.isAcceptableOrUnknown(data['player_id']!, _playerIdMeta));
    } else if (isInserting) {
      context.missing(_playerIdMeta);
    }
    if (data.containsKey('player_name_snapshot')) {
      context.handle(
          _playerNameSnapshotMeta,
          playerNameSnapshot.isAcceptableOrUnknown(
              data['player_name_snapshot']!, _playerNameSnapshotMeta));
    } else if (isInserting) {
      context.missing(_playerNameSnapshotMeta);
    }
    if (data.containsKey('added_after_match_start')) {
      context.handle(
          _addedAfterMatchStartMeta,
          addedAfterMatchStart.isAcceptableOrUnknown(
              data['added_after_match_start']!, _addedAfterMatchStartMeta));
    }
    if (data.containsKey('joined_at')) {
      context.handle(_joinedAtMeta,
          joinedAt.isAcceptableOrUnknown(data['joined_at']!, _joinedAtMeta));
    } else if (isInserting) {
      context.missing(_joinedAtMeta);
    }
    if (data.containsKey('joined_innings_id')) {
      context.handle(
          _joinedInningsIdMeta,
          joinedInningsId.isAcceptableOrUnknown(
              data['joined_innings_id']!, _joinedInningsIdMeta));
    }
    if (data.containsKey('joined_over_number')) {
      context.handle(
          _joinedOverNumberMeta,
          joinedOverNumber.isAcceptableOrUnknown(
              data['joined_over_number']!, _joinedOverNumberMeta));
    }
    if (data.containsKey('joined_delivery_sequence')) {
      context.handle(
          _joinedDeliverySequenceMeta,
          joinedDeliverySequence.isAcceptableOrUnknown(
              data['joined_delivery_sequence']!, _joinedDeliverySequenceMeta));
    }
    if (data.containsKey('is_eligible_bowler')) {
      context.handle(
          _isEligibleBowlerMeta,
          isEligibleBowler.isAcceptableOrUnknown(
              data['is_eligible_bowler']!, _isEligibleBowlerMeta));
    }
    if (data.containsKey('is_available')) {
      context.handle(
          _isAvailableMeta,
          isAvailable.isAcceptableOrUnknown(
              data['is_available']!, _isAvailableMeta));
    }
    if (data.containsKey('added_to_permanent_team')) {
      context.handle(
          _addedToPermanentTeamMeta,
          addedToPermanentTeam.isAcceptableOrUnknown(
              data['added_to_permanent_team']!, _addedToPermanentTeamMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('removed_at')) {
      context.handle(_removedAtMeta,
          removedAt.isAcceptableOrUnknown(data['removed_at']!, _removedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {matchId, playerId};
  @override
  MatchSquadMembersTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MatchSquadMembersTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      matchId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}match_id'])!,
      teamId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}team_id'])!,
      playerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}player_id'])!,
      playerNameSnapshot: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}player_name_snapshot'])!,
      addedAfterMatchStart: attachedDatabase.typeMapping.read(DriftSqlType.bool,
          data['${effectivePrefix}added_after_match_start'])!,
      joinedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}joined_at'])!,
      joinedInningsId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}joined_innings_id']),
      joinedOverNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}joined_over_number']),
      joinedDeliverySequence: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}joined_delivery_sequence']),
      isEligibleBowler: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}is_eligible_bowler'])!,
      isAvailable: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_available'])!,
      addedToPermanentTeam: attachedDatabase.typeMapping.read(DriftSqlType.bool,
          data['${effectivePrefix}added_to_permanent_team'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      removedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}removed_at']),
    );
  }

  @override
  $MatchSquadMembersTableTable createAlias(String alias) {
    return $MatchSquadMembersTableTable(attachedDatabase, alias);
  }
}

class MatchSquadMembersTableData extends DataClass
    implements Insertable<MatchSquadMembersTableData> {
  final String id;
  final String matchId;
  final String teamId;
  final String playerId;
  final String playerNameSnapshot;
  final bool addedAfterMatchStart;
  final int joinedAt;
  final String? joinedInningsId;
  final int? joinedOverNumber;
  final int? joinedDeliverySequence;
  final bool isEligibleBowler;
  final bool isAvailable;
  final bool addedToPermanentTeam;
  final bool isActive;
  final int? removedAt;
  const MatchSquadMembersTableData(
      {required this.id,
      required this.matchId,
      required this.teamId,
      required this.playerId,
      required this.playerNameSnapshot,
      required this.addedAfterMatchStart,
      required this.joinedAt,
      this.joinedInningsId,
      this.joinedOverNumber,
      this.joinedDeliverySequence,
      required this.isEligibleBowler,
      required this.isAvailable,
      required this.addedToPermanentTeam,
      required this.isActive,
      this.removedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['match_id'] = Variable<String>(matchId);
    map['team_id'] = Variable<String>(teamId);
    map['player_id'] = Variable<String>(playerId);
    map['player_name_snapshot'] = Variable<String>(playerNameSnapshot);
    map['added_after_match_start'] = Variable<bool>(addedAfterMatchStart);
    map['joined_at'] = Variable<int>(joinedAt);
    if (!nullToAbsent || joinedInningsId != null) {
      map['joined_innings_id'] = Variable<String>(joinedInningsId);
    }
    if (!nullToAbsent || joinedOverNumber != null) {
      map['joined_over_number'] = Variable<int>(joinedOverNumber);
    }
    if (!nullToAbsent || joinedDeliverySequence != null) {
      map['joined_delivery_sequence'] = Variable<int>(joinedDeliverySequence);
    }
    map['is_eligible_bowler'] = Variable<bool>(isEligibleBowler);
    map['is_available'] = Variable<bool>(isAvailable);
    map['added_to_permanent_team'] = Variable<bool>(addedToPermanentTeam);
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || removedAt != null) {
      map['removed_at'] = Variable<int>(removedAt);
    }
    return map;
  }

  MatchSquadMembersTableCompanion toCompanion(bool nullToAbsent) {
    return MatchSquadMembersTableCompanion(
      id: Value(id),
      matchId: Value(matchId),
      teamId: Value(teamId),
      playerId: Value(playerId),
      playerNameSnapshot: Value(playerNameSnapshot),
      addedAfterMatchStart: Value(addedAfterMatchStart),
      joinedAt: Value(joinedAt),
      joinedInningsId: joinedInningsId == null && nullToAbsent
          ? const Value.absent()
          : Value(joinedInningsId),
      joinedOverNumber: joinedOverNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(joinedOverNumber),
      joinedDeliverySequence: joinedDeliverySequence == null && nullToAbsent
          ? const Value.absent()
          : Value(joinedDeliverySequence),
      isEligibleBowler: Value(isEligibleBowler),
      isAvailable: Value(isAvailable),
      addedToPermanentTeam: Value(addedToPermanentTeam),
      isActive: Value(isActive),
      removedAt: removedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(removedAt),
    );
  }

  factory MatchSquadMembersTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MatchSquadMembersTableData(
      id: serializer.fromJson<String>(json['id']),
      matchId: serializer.fromJson<String>(json['matchId']),
      teamId: serializer.fromJson<String>(json['teamId']),
      playerId: serializer.fromJson<String>(json['playerId']),
      playerNameSnapshot:
          serializer.fromJson<String>(json['playerNameSnapshot']),
      addedAfterMatchStart:
          serializer.fromJson<bool>(json['addedAfterMatchStart']),
      joinedAt: serializer.fromJson<int>(json['joinedAt']),
      joinedInningsId: serializer.fromJson<String?>(json['joinedInningsId']),
      joinedOverNumber: serializer.fromJson<int?>(json['joinedOverNumber']),
      joinedDeliverySequence:
          serializer.fromJson<int?>(json['joinedDeliverySequence']),
      isEligibleBowler: serializer.fromJson<bool>(json['isEligibleBowler']),
      isAvailable: serializer.fromJson<bool>(json['isAvailable']),
      addedToPermanentTeam:
          serializer.fromJson<bool>(json['addedToPermanentTeam']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      removedAt: serializer.fromJson<int?>(json['removedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'matchId': serializer.toJson<String>(matchId),
      'teamId': serializer.toJson<String>(teamId),
      'playerId': serializer.toJson<String>(playerId),
      'playerNameSnapshot': serializer.toJson<String>(playerNameSnapshot),
      'addedAfterMatchStart': serializer.toJson<bool>(addedAfterMatchStart),
      'joinedAt': serializer.toJson<int>(joinedAt),
      'joinedInningsId': serializer.toJson<String?>(joinedInningsId),
      'joinedOverNumber': serializer.toJson<int?>(joinedOverNumber),
      'joinedDeliverySequence': serializer.toJson<int?>(joinedDeliverySequence),
      'isEligibleBowler': serializer.toJson<bool>(isEligibleBowler),
      'isAvailable': serializer.toJson<bool>(isAvailable),
      'addedToPermanentTeam': serializer.toJson<bool>(addedToPermanentTeam),
      'isActive': serializer.toJson<bool>(isActive),
      'removedAt': serializer.toJson<int?>(removedAt),
    };
  }

  MatchSquadMembersTableData copyWith(
          {String? id,
          String? matchId,
          String? teamId,
          String? playerId,
          String? playerNameSnapshot,
          bool? addedAfterMatchStart,
          int? joinedAt,
          Value<String?> joinedInningsId = const Value.absent(),
          Value<int?> joinedOverNumber = const Value.absent(),
          Value<int?> joinedDeliverySequence = const Value.absent(),
          bool? isEligibleBowler,
          bool? isAvailable,
          bool? addedToPermanentTeam,
          bool? isActive,
          Value<int?> removedAt = const Value.absent()}) =>
      MatchSquadMembersTableData(
        id: id ?? this.id,
        matchId: matchId ?? this.matchId,
        teamId: teamId ?? this.teamId,
        playerId: playerId ?? this.playerId,
        playerNameSnapshot: playerNameSnapshot ?? this.playerNameSnapshot,
        addedAfterMatchStart: addedAfterMatchStart ?? this.addedAfterMatchStart,
        joinedAt: joinedAt ?? this.joinedAt,
        joinedInningsId: joinedInningsId.present
            ? joinedInningsId.value
            : this.joinedInningsId,
        joinedOverNumber: joinedOverNumber.present
            ? joinedOverNumber.value
            : this.joinedOverNumber,
        joinedDeliverySequence: joinedDeliverySequence.present
            ? joinedDeliverySequence.value
            : this.joinedDeliverySequence,
        isEligibleBowler: isEligibleBowler ?? this.isEligibleBowler,
        isAvailable: isAvailable ?? this.isAvailable,
        addedToPermanentTeam: addedToPermanentTeam ?? this.addedToPermanentTeam,
        isActive: isActive ?? this.isActive,
        removedAt: removedAt.present ? removedAt.value : this.removedAt,
      );
  MatchSquadMembersTableData copyWithCompanion(
      MatchSquadMembersTableCompanion data) {
    return MatchSquadMembersTableData(
      id: data.id.present ? data.id.value : this.id,
      matchId: data.matchId.present ? data.matchId.value : this.matchId,
      teamId: data.teamId.present ? data.teamId.value : this.teamId,
      playerId: data.playerId.present ? data.playerId.value : this.playerId,
      playerNameSnapshot: data.playerNameSnapshot.present
          ? data.playerNameSnapshot.value
          : this.playerNameSnapshot,
      addedAfterMatchStart: data.addedAfterMatchStart.present
          ? data.addedAfterMatchStart.value
          : this.addedAfterMatchStart,
      joinedAt: data.joinedAt.present ? data.joinedAt.value : this.joinedAt,
      joinedInningsId: data.joinedInningsId.present
          ? data.joinedInningsId.value
          : this.joinedInningsId,
      joinedOverNumber: data.joinedOverNumber.present
          ? data.joinedOverNumber.value
          : this.joinedOverNumber,
      joinedDeliverySequence: data.joinedDeliverySequence.present
          ? data.joinedDeliverySequence.value
          : this.joinedDeliverySequence,
      isEligibleBowler: data.isEligibleBowler.present
          ? data.isEligibleBowler.value
          : this.isEligibleBowler,
      isAvailable:
          data.isAvailable.present ? data.isAvailable.value : this.isAvailable,
      addedToPermanentTeam: data.addedToPermanentTeam.present
          ? data.addedToPermanentTeam.value
          : this.addedToPermanentTeam,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      removedAt: data.removedAt.present ? data.removedAt.value : this.removedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MatchSquadMembersTableData(')
          ..write('id: $id, ')
          ..write('matchId: $matchId, ')
          ..write('teamId: $teamId, ')
          ..write('playerId: $playerId, ')
          ..write('playerNameSnapshot: $playerNameSnapshot, ')
          ..write('addedAfterMatchStart: $addedAfterMatchStart, ')
          ..write('joinedAt: $joinedAt, ')
          ..write('joinedInningsId: $joinedInningsId, ')
          ..write('joinedOverNumber: $joinedOverNumber, ')
          ..write('joinedDeliverySequence: $joinedDeliverySequence, ')
          ..write('isEligibleBowler: $isEligibleBowler, ')
          ..write('isAvailable: $isAvailable, ')
          ..write('addedToPermanentTeam: $addedToPermanentTeam, ')
          ..write('isActive: $isActive, ')
          ..write('removedAt: $removedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      matchId,
      teamId,
      playerId,
      playerNameSnapshot,
      addedAfterMatchStart,
      joinedAt,
      joinedInningsId,
      joinedOverNumber,
      joinedDeliverySequence,
      isEligibleBowler,
      isAvailable,
      addedToPermanentTeam,
      isActive,
      removedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MatchSquadMembersTableData &&
          other.id == this.id &&
          other.matchId == this.matchId &&
          other.teamId == this.teamId &&
          other.playerId == this.playerId &&
          other.playerNameSnapshot == this.playerNameSnapshot &&
          other.addedAfterMatchStart == this.addedAfterMatchStart &&
          other.joinedAt == this.joinedAt &&
          other.joinedInningsId == this.joinedInningsId &&
          other.joinedOverNumber == this.joinedOverNumber &&
          other.joinedDeliverySequence == this.joinedDeliverySequence &&
          other.isEligibleBowler == this.isEligibleBowler &&
          other.isAvailable == this.isAvailable &&
          other.addedToPermanentTeam == this.addedToPermanentTeam &&
          other.isActive == this.isActive &&
          other.removedAt == this.removedAt);
}

class MatchSquadMembersTableCompanion
    extends UpdateCompanion<MatchSquadMembersTableData> {
  final Value<String> id;
  final Value<String> matchId;
  final Value<String> teamId;
  final Value<String> playerId;
  final Value<String> playerNameSnapshot;
  final Value<bool> addedAfterMatchStart;
  final Value<int> joinedAt;
  final Value<String?> joinedInningsId;
  final Value<int?> joinedOverNumber;
  final Value<int?> joinedDeliverySequence;
  final Value<bool> isEligibleBowler;
  final Value<bool> isAvailable;
  final Value<bool> addedToPermanentTeam;
  final Value<bool> isActive;
  final Value<int?> removedAt;
  final Value<int> rowid;
  const MatchSquadMembersTableCompanion({
    this.id = const Value.absent(),
    this.matchId = const Value.absent(),
    this.teamId = const Value.absent(),
    this.playerId = const Value.absent(),
    this.playerNameSnapshot = const Value.absent(),
    this.addedAfterMatchStart = const Value.absent(),
    this.joinedAt = const Value.absent(),
    this.joinedInningsId = const Value.absent(),
    this.joinedOverNumber = const Value.absent(),
    this.joinedDeliverySequence = const Value.absent(),
    this.isEligibleBowler = const Value.absent(),
    this.isAvailable = const Value.absent(),
    this.addedToPermanentTeam = const Value.absent(),
    this.isActive = const Value.absent(),
    this.removedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MatchSquadMembersTableCompanion.insert({
    required String id,
    required String matchId,
    required String teamId,
    required String playerId,
    required String playerNameSnapshot,
    this.addedAfterMatchStart = const Value.absent(),
    required int joinedAt,
    this.joinedInningsId = const Value.absent(),
    this.joinedOverNumber = const Value.absent(),
    this.joinedDeliverySequence = const Value.absent(),
    this.isEligibleBowler = const Value.absent(),
    this.isAvailable = const Value.absent(),
    this.addedToPermanentTeam = const Value.absent(),
    this.isActive = const Value.absent(),
    this.removedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        matchId = Value(matchId),
        teamId = Value(teamId),
        playerId = Value(playerId),
        playerNameSnapshot = Value(playerNameSnapshot),
        joinedAt = Value(joinedAt);
  static Insertable<MatchSquadMembersTableData> custom({
    Expression<String>? id,
    Expression<String>? matchId,
    Expression<String>? teamId,
    Expression<String>? playerId,
    Expression<String>? playerNameSnapshot,
    Expression<bool>? addedAfterMatchStart,
    Expression<int>? joinedAt,
    Expression<String>? joinedInningsId,
    Expression<int>? joinedOverNumber,
    Expression<int>? joinedDeliverySequence,
    Expression<bool>? isEligibleBowler,
    Expression<bool>? isAvailable,
    Expression<bool>? addedToPermanentTeam,
    Expression<bool>? isActive,
    Expression<int>? removedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (matchId != null) 'match_id': matchId,
      if (teamId != null) 'team_id': teamId,
      if (playerId != null) 'player_id': playerId,
      if (playerNameSnapshot != null)
        'player_name_snapshot': playerNameSnapshot,
      if (addedAfterMatchStart != null)
        'added_after_match_start': addedAfterMatchStart,
      if (joinedAt != null) 'joined_at': joinedAt,
      if (joinedInningsId != null) 'joined_innings_id': joinedInningsId,
      if (joinedOverNumber != null) 'joined_over_number': joinedOverNumber,
      if (joinedDeliverySequence != null)
        'joined_delivery_sequence': joinedDeliverySequence,
      if (isEligibleBowler != null) 'is_eligible_bowler': isEligibleBowler,
      if (isAvailable != null) 'is_available': isAvailable,
      if (addedToPermanentTeam != null)
        'added_to_permanent_team': addedToPermanentTeam,
      if (isActive != null) 'is_active': isActive,
      if (removedAt != null) 'removed_at': removedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MatchSquadMembersTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? matchId,
      Value<String>? teamId,
      Value<String>? playerId,
      Value<String>? playerNameSnapshot,
      Value<bool>? addedAfterMatchStart,
      Value<int>? joinedAt,
      Value<String?>? joinedInningsId,
      Value<int?>? joinedOverNumber,
      Value<int?>? joinedDeliverySequence,
      Value<bool>? isEligibleBowler,
      Value<bool>? isAvailable,
      Value<bool>? addedToPermanentTeam,
      Value<bool>? isActive,
      Value<int?>? removedAt,
      Value<int>? rowid}) {
    return MatchSquadMembersTableCompanion(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      teamId: teamId ?? this.teamId,
      playerId: playerId ?? this.playerId,
      playerNameSnapshot: playerNameSnapshot ?? this.playerNameSnapshot,
      addedAfterMatchStart: addedAfterMatchStart ?? this.addedAfterMatchStart,
      joinedAt: joinedAt ?? this.joinedAt,
      joinedInningsId: joinedInningsId ?? this.joinedInningsId,
      joinedOverNumber: joinedOverNumber ?? this.joinedOverNumber,
      joinedDeliverySequence:
          joinedDeliverySequence ?? this.joinedDeliverySequence,
      isEligibleBowler: isEligibleBowler ?? this.isEligibleBowler,
      isAvailable: isAvailable ?? this.isAvailable,
      addedToPermanentTeam: addedToPermanentTeam ?? this.addedToPermanentTeam,
      isActive: isActive ?? this.isActive,
      removedAt: removedAt ?? this.removedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (matchId.present) {
      map['match_id'] = Variable<String>(matchId.value);
    }
    if (teamId.present) {
      map['team_id'] = Variable<String>(teamId.value);
    }
    if (playerId.present) {
      map['player_id'] = Variable<String>(playerId.value);
    }
    if (playerNameSnapshot.present) {
      map['player_name_snapshot'] = Variable<String>(playerNameSnapshot.value);
    }
    if (addedAfterMatchStart.present) {
      map['added_after_match_start'] =
          Variable<bool>(addedAfterMatchStart.value);
    }
    if (joinedAt.present) {
      map['joined_at'] = Variable<int>(joinedAt.value);
    }
    if (joinedInningsId.present) {
      map['joined_innings_id'] = Variable<String>(joinedInningsId.value);
    }
    if (joinedOverNumber.present) {
      map['joined_over_number'] = Variable<int>(joinedOverNumber.value);
    }
    if (joinedDeliverySequence.present) {
      map['joined_delivery_sequence'] =
          Variable<int>(joinedDeliverySequence.value);
    }
    if (isEligibleBowler.present) {
      map['is_eligible_bowler'] = Variable<bool>(isEligibleBowler.value);
    }
    if (isAvailable.present) {
      map['is_available'] = Variable<bool>(isAvailable.value);
    }
    if (addedToPermanentTeam.present) {
      map['added_to_permanent_team'] =
          Variable<bool>(addedToPermanentTeam.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (removedAt.present) {
      map['removed_at'] = Variable<int>(removedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MatchSquadMembersTableCompanion(')
          ..write('id: $id, ')
          ..write('matchId: $matchId, ')
          ..write('teamId: $teamId, ')
          ..write('playerId: $playerId, ')
          ..write('playerNameSnapshot: $playerNameSnapshot, ')
          ..write('addedAfterMatchStart: $addedAfterMatchStart, ')
          ..write('joinedAt: $joinedAt, ')
          ..write('joinedInningsId: $joinedInningsId, ')
          ..write('joinedOverNumber: $joinedOverNumber, ')
          ..write('joinedDeliverySequence: $joinedDeliverySequence, ')
          ..write('isEligibleBowler: $isEligibleBowler, ')
          ..write('isAvailable: $isAvailable, ')
          ..write('addedToPermanentTeam: $addedToPermanentTeam, ')
          ..write('isActive: $isActive, ')
          ..write('removedAt: $removedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MatchAwardsTableTable extends MatchAwardsTable
    with TableInfo<$MatchAwardsTableTable, MatchAwardsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MatchAwardsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _matchIdMeta =
      const VerificationMeta('matchId');
  @override
  late final GeneratedColumn<String> matchId = GeneratedColumn<String>(
      'match_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _playerIdMeta =
      const VerificationMeta('playerId');
  @override
  late final GeneratedColumn<String> playerId = GeneratedColumn<String>(
      'player_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _teamIdMeta = const VerificationMeta('teamId');
  @override
  late final GeneratedColumn<String> teamId = GeneratedColumn<String>(
      'team_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _playerNameSnapshotMeta =
      const VerificationMeta('playerNameSnapshot');
  @override
  late final GeneratedColumn<String> playerNameSnapshot =
      GeneratedColumn<String>('player_name_snapshot', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _teamNameSnapshotMeta =
      const VerificationMeta('teamNameSnapshot');
  @override
  late final GeneratedColumn<String> teamNameSnapshot = GeneratedColumn<String>(
      'team_name_snapshot', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _summaryMeta =
      const VerificationMeta('summary');
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
      'summary', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _secondarySummaryMeta =
      const VerificationMeta('secondarySummary');
  @override
  late final GeneratedColumn<String> secondarySummary = GeneratedColumn<String>(
      'secondary_summary', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _rankingScoreMeta =
      const VerificationMeta('rankingScore');
  @override
  late final GeneratedColumn<double> rankingScore = GeneratedColumn<double>(
      'ranking_score', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isManualOverrideMeta =
      const VerificationMeta('isManualOverride');
  @override
  late final GeneratedColumn<bool> isManualOverride = GeneratedColumn<bool>(
      'is_manual_override', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_manual_override" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _overrideReasonMeta =
      const VerificationMeta('overrideReason');
  @override
  late final GeneratedColumn<String> overrideReason = GeneratedColumn<String>(
      'override_reason', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        matchId,
        type,
        playerId,
        teamId,
        playerNameSnapshot,
        teamNameSnapshot,
        summary,
        secondarySummary,
        rankingScore,
        createdAt,
        isManualOverride,
        overrideReason
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'match_awards_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<MatchAwardsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('match_id')) {
      context.handle(_matchIdMeta,
          matchId.isAcceptableOrUnknown(data['match_id']!, _matchIdMeta));
    } else if (isInserting) {
      context.missing(_matchIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('player_id')) {
      context.handle(_playerIdMeta,
          playerId.isAcceptableOrUnknown(data['player_id']!, _playerIdMeta));
    } else if (isInserting) {
      context.missing(_playerIdMeta);
    }
    if (data.containsKey('team_id')) {
      context.handle(_teamIdMeta,
          teamId.isAcceptableOrUnknown(data['team_id']!, _teamIdMeta));
    } else if (isInserting) {
      context.missing(_teamIdMeta);
    }
    if (data.containsKey('player_name_snapshot')) {
      context.handle(
          _playerNameSnapshotMeta,
          playerNameSnapshot.isAcceptableOrUnknown(
              data['player_name_snapshot']!, _playerNameSnapshotMeta));
    } else if (isInserting) {
      context.missing(_playerNameSnapshotMeta);
    }
    if (data.containsKey('team_name_snapshot')) {
      context.handle(
          _teamNameSnapshotMeta,
          teamNameSnapshot.isAcceptableOrUnknown(
              data['team_name_snapshot']!, _teamNameSnapshotMeta));
    } else if (isInserting) {
      context.missing(_teamNameSnapshotMeta);
    }
    if (data.containsKey('summary')) {
      context.handle(_summaryMeta,
          summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta));
    } else if (isInserting) {
      context.missing(_summaryMeta);
    }
    if (data.containsKey('secondary_summary')) {
      context.handle(
          _secondarySummaryMeta,
          secondarySummary.isAcceptableOrUnknown(
              data['secondary_summary']!, _secondarySummaryMeta));
    }
    if (data.containsKey('ranking_score')) {
      context.handle(
          _rankingScoreMeta,
          rankingScore.isAcceptableOrUnknown(
              data['ranking_score']!, _rankingScoreMeta));
    } else if (isInserting) {
      context.missing(_rankingScoreMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('is_manual_override')) {
      context.handle(
          _isManualOverrideMeta,
          isManualOverride.isAcceptableOrUnknown(
              data['is_manual_override']!, _isManualOverrideMeta));
    }
    if (data.containsKey('override_reason')) {
      context.handle(
          _overrideReasonMeta,
          overrideReason.isAcceptableOrUnknown(
              data['override_reason']!, _overrideReasonMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {matchId, type},
      ];
  @override
  MatchAwardsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MatchAwardsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      matchId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}match_id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      playerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}player_id'])!,
      teamId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}team_id'])!,
      playerNameSnapshot: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}player_name_snapshot'])!,
      teamNameSnapshot: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}team_name_snapshot'])!,
      summary: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}summary'])!,
      secondarySummary: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}secondary_summary'])!,
      rankingScore: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}ranking_score'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      isManualOverride: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}is_manual_override'])!,
      overrideReason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}override_reason']),
    );
  }

  @override
  $MatchAwardsTableTable createAlias(String alias) {
    return $MatchAwardsTableTable(attachedDatabase, alias);
  }
}

class MatchAwardsTableData extends DataClass
    implements Insertable<MatchAwardsTableData> {
  final String id;
  final String matchId;
  final String type;
  final String playerId;
  final String teamId;
  final String playerNameSnapshot;
  final String teamNameSnapshot;
  final String summary;
  final String secondarySummary;
  final double rankingScore;
  final int createdAt;
  final bool isManualOverride;
  final String? overrideReason;
  const MatchAwardsTableData(
      {required this.id,
      required this.matchId,
      required this.type,
      required this.playerId,
      required this.teamId,
      required this.playerNameSnapshot,
      required this.teamNameSnapshot,
      required this.summary,
      required this.secondarySummary,
      required this.rankingScore,
      required this.createdAt,
      required this.isManualOverride,
      this.overrideReason});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['match_id'] = Variable<String>(matchId);
    map['type'] = Variable<String>(type);
    map['player_id'] = Variable<String>(playerId);
    map['team_id'] = Variable<String>(teamId);
    map['player_name_snapshot'] = Variable<String>(playerNameSnapshot);
    map['team_name_snapshot'] = Variable<String>(teamNameSnapshot);
    map['summary'] = Variable<String>(summary);
    map['secondary_summary'] = Variable<String>(secondarySummary);
    map['ranking_score'] = Variable<double>(rankingScore);
    map['created_at'] = Variable<int>(createdAt);
    map['is_manual_override'] = Variable<bool>(isManualOverride);
    if (!nullToAbsent || overrideReason != null) {
      map['override_reason'] = Variable<String>(overrideReason);
    }
    return map;
  }

  MatchAwardsTableCompanion toCompanion(bool nullToAbsent) {
    return MatchAwardsTableCompanion(
      id: Value(id),
      matchId: Value(matchId),
      type: Value(type),
      playerId: Value(playerId),
      teamId: Value(teamId),
      playerNameSnapshot: Value(playerNameSnapshot),
      teamNameSnapshot: Value(teamNameSnapshot),
      summary: Value(summary),
      secondarySummary: Value(secondarySummary),
      rankingScore: Value(rankingScore),
      createdAt: Value(createdAt),
      isManualOverride: Value(isManualOverride),
      overrideReason: overrideReason == null && nullToAbsent
          ? const Value.absent()
          : Value(overrideReason),
    );
  }

  factory MatchAwardsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MatchAwardsTableData(
      id: serializer.fromJson<String>(json['id']),
      matchId: serializer.fromJson<String>(json['matchId']),
      type: serializer.fromJson<String>(json['type']),
      playerId: serializer.fromJson<String>(json['playerId']),
      teamId: serializer.fromJson<String>(json['teamId']),
      playerNameSnapshot:
          serializer.fromJson<String>(json['playerNameSnapshot']),
      teamNameSnapshot: serializer.fromJson<String>(json['teamNameSnapshot']),
      summary: serializer.fromJson<String>(json['summary']),
      secondarySummary: serializer.fromJson<String>(json['secondarySummary']),
      rankingScore: serializer.fromJson<double>(json['rankingScore']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      isManualOverride: serializer.fromJson<bool>(json['isManualOverride']),
      overrideReason: serializer.fromJson<String?>(json['overrideReason']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'matchId': serializer.toJson<String>(matchId),
      'type': serializer.toJson<String>(type),
      'playerId': serializer.toJson<String>(playerId),
      'teamId': serializer.toJson<String>(teamId),
      'playerNameSnapshot': serializer.toJson<String>(playerNameSnapshot),
      'teamNameSnapshot': serializer.toJson<String>(teamNameSnapshot),
      'summary': serializer.toJson<String>(summary),
      'secondarySummary': serializer.toJson<String>(secondarySummary),
      'rankingScore': serializer.toJson<double>(rankingScore),
      'createdAt': serializer.toJson<int>(createdAt),
      'isManualOverride': serializer.toJson<bool>(isManualOverride),
      'overrideReason': serializer.toJson<String?>(overrideReason),
    };
  }

  MatchAwardsTableData copyWith(
          {String? id,
          String? matchId,
          String? type,
          String? playerId,
          String? teamId,
          String? playerNameSnapshot,
          String? teamNameSnapshot,
          String? summary,
          String? secondarySummary,
          double? rankingScore,
          int? createdAt,
          bool? isManualOverride,
          Value<String?> overrideReason = const Value.absent()}) =>
      MatchAwardsTableData(
        id: id ?? this.id,
        matchId: matchId ?? this.matchId,
        type: type ?? this.type,
        playerId: playerId ?? this.playerId,
        teamId: teamId ?? this.teamId,
        playerNameSnapshot: playerNameSnapshot ?? this.playerNameSnapshot,
        teamNameSnapshot: teamNameSnapshot ?? this.teamNameSnapshot,
        summary: summary ?? this.summary,
        secondarySummary: secondarySummary ?? this.secondarySummary,
        rankingScore: rankingScore ?? this.rankingScore,
        createdAt: createdAt ?? this.createdAt,
        isManualOverride: isManualOverride ?? this.isManualOverride,
        overrideReason:
            overrideReason.present ? overrideReason.value : this.overrideReason,
      );
  MatchAwardsTableData copyWithCompanion(MatchAwardsTableCompanion data) {
    return MatchAwardsTableData(
      id: data.id.present ? data.id.value : this.id,
      matchId: data.matchId.present ? data.matchId.value : this.matchId,
      type: data.type.present ? data.type.value : this.type,
      playerId: data.playerId.present ? data.playerId.value : this.playerId,
      teamId: data.teamId.present ? data.teamId.value : this.teamId,
      playerNameSnapshot: data.playerNameSnapshot.present
          ? data.playerNameSnapshot.value
          : this.playerNameSnapshot,
      teamNameSnapshot: data.teamNameSnapshot.present
          ? data.teamNameSnapshot.value
          : this.teamNameSnapshot,
      summary: data.summary.present ? data.summary.value : this.summary,
      secondarySummary: data.secondarySummary.present
          ? data.secondarySummary.value
          : this.secondarySummary,
      rankingScore: data.rankingScore.present
          ? data.rankingScore.value
          : this.rankingScore,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isManualOverride: data.isManualOverride.present
          ? data.isManualOverride.value
          : this.isManualOverride,
      overrideReason: data.overrideReason.present
          ? data.overrideReason.value
          : this.overrideReason,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MatchAwardsTableData(')
          ..write('id: $id, ')
          ..write('matchId: $matchId, ')
          ..write('type: $type, ')
          ..write('playerId: $playerId, ')
          ..write('teamId: $teamId, ')
          ..write('playerNameSnapshot: $playerNameSnapshot, ')
          ..write('teamNameSnapshot: $teamNameSnapshot, ')
          ..write('summary: $summary, ')
          ..write('secondarySummary: $secondarySummary, ')
          ..write('rankingScore: $rankingScore, ')
          ..write('createdAt: $createdAt, ')
          ..write('isManualOverride: $isManualOverride, ')
          ..write('overrideReason: $overrideReason')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      matchId,
      type,
      playerId,
      teamId,
      playerNameSnapshot,
      teamNameSnapshot,
      summary,
      secondarySummary,
      rankingScore,
      createdAt,
      isManualOverride,
      overrideReason);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MatchAwardsTableData &&
          other.id == this.id &&
          other.matchId == this.matchId &&
          other.type == this.type &&
          other.playerId == this.playerId &&
          other.teamId == this.teamId &&
          other.playerNameSnapshot == this.playerNameSnapshot &&
          other.teamNameSnapshot == this.teamNameSnapshot &&
          other.summary == this.summary &&
          other.secondarySummary == this.secondarySummary &&
          other.rankingScore == this.rankingScore &&
          other.createdAt == this.createdAt &&
          other.isManualOverride == this.isManualOverride &&
          other.overrideReason == this.overrideReason);
}

class MatchAwardsTableCompanion extends UpdateCompanion<MatchAwardsTableData> {
  final Value<String> id;
  final Value<String> matchId;
  final Value<String> type;
  final Value<String> playerId;
  final Value<String> teamId;
  final Value<String> playerNameSnapshot;
  final Value<String> teamNameSnapshot;
  final Value<String> summary;
  final Value<String> secondarySummary;
  final Value<double> rankingScore;
  final Value<int> createdAt;
  final Value<bool> isManualOverride;
  final Value<String?> overrideReason;
  final Value<int> rowid;
  const MatchAwardsTableCompanion({
    this.id = const Value.absent(),
    this.matchId = const Value.absent(),
    this.type = const Value.absent(),
    this.playerId = const Value.absent(),
    this.teamId = const Value.absent(),
    this.playerNameSnapshot = const Value.absent(),
    this.teamNameSnapshot = const Value.absent(),
    this.summary = const Value.absent(),
    this.secondarySummary = const Value.absent(),
    this.rankingScore = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isManualOverride = const Value.absent(),
    this.overrideReason = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MatchAwardsTableCompanion.insert({
    required String id,
    required String matchId,
    required String type,
    required String playerId,
    required String teamId,
    required String playerNameSnapshot,
    required String teamNameSnapshot,
    required String summary,
    this.secondarySummary = const Value.absent(),
    required double rankingScore,
    required int createdAt,
    this.isManualOverride = const Value.absent(),
    this.overrideReason = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        matchId = Value(matchId),
        type = Value(type),
        playerId = Value(playerId),
        teamId = Value(teamId),
        playerNameSnapshot = Value(playerNameSnapshot),
        teamNameSnapshot = Value(teamNameSnapshot),
        summary = Value(summary),
        rankingScore = Value(rankingScore),
        createdAt = Value(createdAt);
  static Insertable<MatchAwardsTableData> custom({
    Expression<String>? id,
    Expression<String>? matchId,
    Expression<String>? type,
    Expression<String>? playerId,
    Expression<String>? teamId,
    Expression<String>? playerNameSnapshot,
    Expression<String>? teamNameSnapshot,
    Expression<String>? summary,
    Expression<String>? secondarySummary,
    Expression<double>? rankingScore,
    Expression<int>? createdAt,
    Expression<bool>? isManualOverride,
    Expression<String>? overrideReason,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (matchId != null) 'match_id': matchId,
      if (type != null) 'type': type,
      if (playerId != null) 'player_id': playerId,
      if (teamId != null) 'team_id': teamId,
      if (playerNameSnapshot != null)
        'player_name_snapshot': playerNameSnapshot,
      if (teamNameSnapshot != null) 'team_name_snapshot': teamNameSnapshot,
      if (summary != null) 'summary': summary,
      if (secondarySummary != null) 'secondary_summary': secondarySummary,
      if (rankingScore != null) 'ranking_score': rankingScore,
      if (createdAt != null) 'created_at': createdAt,
      if (isManualOverride != null) 'is_manual_override': isManualOverride,
      if (overrideReason != null) 'override_reason': overrideReason,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MatchAwardsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? matchId,
      Value<String>? type,
      Value<String>? playerId,
      Value<String>? teamId,
      Value<String>? playerNameSnapshot,
      Value<String>? teamNameSnapshot,
      Value<String>? summary,
      Value<String>? secondarySummary,
      Value<double>? rankingScore,
      Value<int>? createdAt,
      Value<bool>? isManualOverride,
      Value<String?>? overrideReason,
      Value<int>? rowid}) {
    return MatchAwardsTableCompanion(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      type: type ?? this.type,
      playerId: playerId ?? this.playerId,
      teamId: teamId ?? this.teamId,
      playerNameSnapshot: playerNameSnapshot ?? this.playerNameSnapshot,
      teamNameSnapshot: teamNameSnapshot ?? this.teamNameSnapshot,
      summary: summary ?? this.summary,
      secondarySummary: secondarySummary ?? this.secondarySummary,
      rankingScore: rankingScore ?? this.rankingScore,
      createdAt: createdAt ?? this.createdAt,
      isManualOverride: isManualOverride ?? this.isManualOverride,
      overrideReason: overrideReason ?? this.overrideReason,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (matchId.present) {
      map['match_id'] = Variable<String>(matchId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (playerId.present) {
      map['player_id'] = Variable<String>(playerId.value);
    }
    if (teamId.present) {
      map['team_id'] = Variable<String>(teamId.value);
    }
    if (playerNameSnapshot.present) {
      map['player_name_snapshot'] = Variable<String>(playerNameSnapshot.value);
    }
    if (teamNameSnapshot.present) {
      map['team_name_snapshot'] = Variable<String>(teamNameSnapshot.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (secondarySummary.present) {
      map['secondary_summary'] = Variable<String>(secondarySummary.value);
    }
    if (rankingScore.present) {
      map['ranking_score'] = Variable<double>(rankingScore.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (isManualOverride.present) {
      map['is_manual_override'] = Variable<bool>(isManualOverride.value);
    }
    if (overrideReason.present) {
      map['override_reason'] = Variable<String>(overrideReason.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MatchAwardsTableCompanion(')
          ..write('id: $id, ')
          ..write('matchId: $matchId, ')
          ..write('type: $type, ')
          ..write('playerId: $playerId, ')
          ..write('teamId: $teamId, ')
          ..write('playerNameSnapshot: $playerNameSnapshot, ')
          ..write('teamNameSnapshot: $teamNameSnapshot, ')
          ..write('summary: $summary, ')
          ..write('secondarySummary: $secondarySummary, ')
          ..write('rankingScore: $rankingScore, ')
          ..write('createdAt: $createdAt, ')
          ..write('isManualOverride: $isManualOverride, ')
          ..write('overrideReason: $overrideReason, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TeamsTableTable teamsTable = $TeamsTableTable(this);
  late final $PlayersTableTable playersTable = $PlayersTableTable(this);
  late final $TeamMembersTableTable teamMembersTable =
      $TeamMembersTableTable(this);
  late final $MatchesTableTable matchesTable = $MatchesTableTable(this);
  late final $DeliveriesTableTable deliveriesTable =
      $DeliveriesTableTable(this);
  late final $SyncQueueTableTable syncQueueTable = $SyncQueueTableTable(this);
  late final $ScoringAuditTableTable scoringAuditTable =
      $ScoringAuditTableTable(this);
  late final $MatchSquadMembersTableTable matchSquadMembersTable =
      $MatchSquadMembersTableTable(this);
  late final $MatchAwardsTableTable matchAwardsTable =
      $MatchAwardsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        teamsTable,
        playersTable,
        teamMembersTable,
        matchesTable,
        deliveriesTable,
        syncQueueTable,
        scoringAuditTable,
        matchSquadMembersTable,
        matchAwardsTable
      ];
}

typedef $$TeamsTableTableCreateCompanionBuilder = TeamsTableCompanion Function({
  required String id,
  required String name,
  required String shortName,
  Value<String?> logoUrl,
  Value<String?> city,
  Value<String?> color,
  Value<String?> defaultCaptainId,
  required int createdAt,
  Value<String> syncStatus,
  Value<int> rowid,
});
typedef $$TeamsTableTableUpdateCompanionBuilder = TeamsTableCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> shortName,
  Value<String?> logoUrl,
  Value<String?> city,
  Value<String?> color,
  Value<String?> defaultCaptainId,
  Value<int> createdAt,
  Value<String> syncStatus,
  Value<int> rowid,
});

class $$TeamsTableTableFilterComposer
    extends Composer<_$AppDatabase, $TeamsTableTable> {
  $$TeamsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get shortName => $composableBuilder(
      column: $table.shortName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get logoUrl => $composableBuilder(
      column: $table.logoUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get city => $composableBuilder(
      column: $table.city, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get defaultCaptainId => $composableBuilder(
      column: $table.defaultCaptainId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));
}

class $$TeamsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TeamsTableTable> {
  $$TeamsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get shortName => $composableBuilder(
      column: $table.shortName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get logoUrl => $composableBuilder(
      column: $table.logoUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get city => $composableBuilder(
      column: $table.city, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get defaultCaptainId => $composableBuilder(
      column: $table.defaultCaptainId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));
}

class $$TeamsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TeamsTableTable> {
  $$TeamsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get shortName =>
      $composableBuilder(column: $table.shortName, builder: (column) => column);

  GeneratedColumn<String> get logoUrl =>
      $composableBuilder(column: $table.logoUrl, builder: (column) => column);

  GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get defaultCaptainId => $composableBuilder(
      column: $table.defaultCaptainId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);
}

class $$TeamsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TeamsTableTable,
    TeamsTableData,
    $$TeamsTableTableFilterComposer,
    $$TeamsTableTableOrderingComposer,
    $$TeamsTableTableAnnotationComposer,
    $$TeamsTableTableCreateCompanionBuilder,
    $$TeamsTableTableUpdateCompanionBuilder,
    (
      TeamsTableData,
      BaseReferences<_$AppDatabase, $TeamsTableTable, TeamsTableData>
    ),
    TeamsTableData,
    PrefetchHooks Function()> {
  $$TeamsTableTableTableManager(_$AppDatabase db, $TeamsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TeamsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TeamsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TeamsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> shortName = const Value.absent(),
            Value<String?> logoUrl = const Value.absent(),
            Value<String?> city = const Value.absent(),
            Value<String?> color = const Value.absent(),
            Value<String?> defaultCaptainId = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TeamsTableCompanion(
            id: id,
            name: name,
            shortName: shortName,
            logoUrl: logoUrl,
            city: city,
            color: color,
            defaultCaptainId: defaultCaptainId,
            createdAt: createdAt,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String shortName,
            Value<String?> logoUrl = const Value.absent(),
            Value<String?> city = const Value.absent(),
            Value<String?> color = const Value.absent(),
            Value<String?> defaultCaptainId = const Value.absent(),
            required int createdAt,
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TeamsTableCompanion.insert(
            id: id,
            name: name,
            shortName: shortName,
            logoUrl: logoUrl,
            city: city,
            color: color,
            defaultCaptainId: defaultCaptainId,
            createdAt: createdAt,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TeamsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TeamsTableTable,
    TeamsTableData,
    $$TeamsTableTableFilterComposer,
    $$TeamsTableTableOrderingComposer,
    $$TeamsTableTableAnnotationComposer,
    $$TeamsTableTableCreateCompanionBuilder,
    $$TeamsTableTableUpdateCompanionBuilder,
    (
      TeamsTableData,
      BaseReferences<_$AppDatabase, $TeamsTableTable, TeamsTableData>
    ),
    TeamsTableData,
    PrefetchHooks Function()>;
typedef $$PlayersTableTableCreateCompanionBuilder = PlayersTableCompanion
    Function({
  required String id,
  required String name,
  Value<String?> phone,
  Value<String?> jerseyNumber,
  Value<String> role,
  Value<String> battingStyle,
  Value<String> bowlingStyle,
  Value<bool> isCaptain,
  Value<bool> isWicketKeeper,
  required int createdAt,
  Value<String> syncStatus,
  Value<int> rowid,
});
typedef $$PlayersTableTableUpdateCompanionBuilder = PlayersTableCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String?> phone,
  Value<String?> jerseyNumber,
  Value<String> role,
  Value<String> battingStyle,
  Value<String> bowlingStyle,
  Value<bool> isCaptain,
  Value<bool> isWicketKeeper,
  Value<int> createdAt,
  Value<String> syncStatus,
  Value<int> rowid,
});

class $$PlayersTableTableFilterComposer
    extends Composer<_$AppDatabase, $PlayersTableTable> {
  $$PlayersTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get jerseyNumber => $composableBuilder(
      column: $table.jerseyNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get battingStyle => $composableBuilder(
      column: $table.battingStyle, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bowlingStyle => $composableBuilder(
      column: $table.bowlingStyle, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCaptain => $composableBuilder(
      column: $table.isCaptain, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isWicketKeeper => $composableBuilder(
      column: $table.isWicketKeeper,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));
}

class $$PlayersTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PlayersTableTable> {
  $$PlayersTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get jerseyNumber => $composableBuilder(
      column: $table.jerseyNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get battingStyle => $composableBuilder(
      column: $table.battingStyle,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bowlingStyle => $composableBuilder(
      column: $table.bowlingStyle,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCaptain => $composableBuilder(
      column: $table.isCaptain, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isWicketKeeper => $composableBuilder(
      column: $table.isWicketKeeper,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));
}

class $$PlayersTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlayersTableTable> {
  $$PlayersTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get jerseyNumber => $composableBuilder(
      column: $table.jerseyNumber, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get battingStyle => $composableBuilder(
      column: $table.battingStyle, builder: (column) => column);

  GeneratedColumn<String> get bowlingStyle => $composableBuilder(
      column: $table.bowlingStyle, builder: (column) => column);

  GeneratedColumn<bool> get isCaptain =>
      $composableBuilder(column: $table.isCaptain, builder: (column) => column);

  GeneratedColumn<bool> get isWicketKeeper => $composableBuilder(
      column: $table.isWicketKeeper, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);
}

class $$PlayersTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PlayersTableTable,
    PlayersTableData,
    $$PlayersTableTableFilterComposer,
    $$PlayersTableTableOrderingComposer,
    $$PlayersTableTableAnnotationComposer,
    $$PlayersTableTableCreateCompanionBuilder,
    $$PlayersTableTableUpdateCompanionBuilder,
    (
      PlayersTableData,
      BaseReferences<_$AppDatabase, $PlayersTableTable, PlayersTableData>
    ),
    PlayersTableData,
    PrefetchHooks Function()> {
  $$PlayersTableTableTableManager(_$AppDatabase db, $PlayersTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlayersTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlayersTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlayersTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String?> jerseyNumber = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<String> battingStyle = const Value.absent(),
            Value<String> bowlingStyle = const Value.absent(),
            Value<bool> isCaptain = const Value.absent(),
            Value<bool> isWicketKeeper = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PlayersTableCompanion(
            id: id,
            name: name,
            phone: phone,
            jerseyNumber: jerseyNumber,
            role: role,
            battingStyle: battingStyle,
            bowlingStyle: bowlingStyle,
            isCaptain: isCaptain,
            isWicketKeeper: isWicketKeeper,
            createdAt: createdAt,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> phone = const Value.absent(),
            Value<String?> jerseyNumber = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<String> battingStyle = const Value.absent(),
            Value<String> bowlingStyle = const Value.absent(),
            Value<bool> isCaptain = const Value.absent(),
            Value<bool> isWicketKeeper = const Value.absent(),
            required int createdAt,
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PlayersTableCompanion.insert(
            id: id,
            name: name,
            phone: phone,
            jerseyNumber: jerseyNumber,
            role: role,
            battingStyle: battingStyle,
            bowlingStyle: bowlingStyle,
            isCaptain: isCaptain,
            isWicketKeeper: isWicketKeeper,
            createdAt: createdAt,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PlayersTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PlayersTableTable,
    PlayersTableData,
    $$PlayersTableTableFilterComposer,
    $$PlayersTableTableOrderingComposer,
    $$PlayersTableTableAnnotationComposer,
    $$PlayersTableTableCreateCompanionBuilder,
    $$PlayersTableTableUpdateCompanionBuilder,
    (
      PlayersTableData,
      BaseReferences<_$AppDatabase, $PlayersTableTable, PlayersTableData>
    ),
    PlayersTableData,
    PrefetchHooks Function()>;
typedef $$TeamMembersTableTableCreateCompanionBuilder
    = TeamMembersTableCompanion Function({
  required String teamId,
  required String playerId,
  Value<bool> isActive,
  Value<int> joinedAt,
  Value<int?> removedAt,
  Value<int> rowid,
});
typedef $$TeamMembersTableTableUpdateCompanionBuilder
    = TeamMembersTableCompanion Function({
  Value<String> teamId,
  Value<String> playerId,
  Value<bool> isActive,
  Value<int> joinedAt,
  Value<int?> removedAt,
  Value<int> rowid,
});

class $$TeamMembersTableTableFilterComposer
    extends Composer<_$AppDatabase, $TeamMembersTableTable> {
  $$TeamMembersTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get teamId => $composableBuilder(
      column: $table.teamId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get playerId => $composableBuilder(
      column: $table.playerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get joinedAt => $composableBuilder(
      column: $table.joinedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get removedAt => $composableBuilder(
      column: $table.removedAt, builder: (column) => ColumnFilters(column));
}

class $$TeamMembersTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TeamMembersTableTable> {
  $$TeamMembersTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get teamId => $composableBuilder(
      column: $table.teamId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get playerId => $composableBuilder(
      column: $table.playerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get joinedAt => $composableBuilder(
      column: $table.joinedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get removedAt => $composableBuilder(
      column: $table.removedAt, builder: (column) => ColumnOrderings(column));
}

class $$TeamMembersTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TeamMembersTableTable> {
  $$TeamMembersTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get teamId =>
      $composableBuilder(column: $table.teamId, builder: (column) => column);

  GeneratedColumn<String> get playerId =>
      $composableBuilder(column: $table.playerId, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get joinedAt =>
      $composableBuilder(column: $table.joinedAt, builder: (column) => column);

  GeneratedColumn<int> get removedAt =>
      $composableBuilder(column: $table.removedAt, builder: (column) => column);
}

class $$TeamMembersTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TeamMembersTableTable,
    TeamMembersTableData,
    $$TeamMembersTableTableFilterComposer,
    $$TeamMembersTableTableOrderingComposer,
    $$TeamMembersTableTableAnnotationComposer,
    $$TeamMembersTableTableCreateCompanionBuilder,
    $$TeamMembersTableTableUpdateCompanionBuilder,
    (
      TeamMembersTableData,
      BaseReferences<_$AppDatabase, $TeamMembersTableTable,
          TeamMembersTableData>
    ),
    TeamMembersTableData,
    PrefetchHooks Function()> {
  $$TeamMembersTableTableTableManager(
      _$AppDatabase db, $TeamMembersTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TeamMembersTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TeamMembersTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TeamMembersTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> teamId = const Value.absent(),
            Value<String> playerId = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> joinedAt = const Value.absent(),
            Value<int?> removedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TeamMembersTableCompanion(
            teamId: teamId,
            playerId: playerId,
            isActive: isActive,
            joinedAt: joinedAt,
            removedAt: removedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String teamId,
            required String playerId,
            Value<bool> isActive = const Value.absent(),
            Value<int> joinedAt = const Value.absent(),
            Value<int?> removedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TeamMembersTableCompanion.insert(
            teamId: teamId,
            playerId: playerId,
            isActive: isActive,
            joinedAt: joinedAt,
            removedAt: removedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TeamMembersTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TeamMembersTableTable,
    TeamMembersTableData,
    $$TeamMembersTableTableFilterComposer,
    $$TeamMembersTableTableOrderingComposer,
    $$TeamMembersTableTableAnnotationComposer,
    $$TeamMembersTableTableCreateCompanionBuilder,
    $$TeamMembersTableTableUpdateCompanionBuilder,
    (
      TeamMembersTableData,
      BaseReferences<_$AppDatabase, $TeamMembersTableTable,
          TeamMembersTableData>
    ),
    TeamMembersTableData,
    PrefetchHooks Function()>;
typedef $$MatchesTableTableCreateCompanionBuilder = MatchesTableCompanion
    Function({
  required String id,
  Value<String?> matchName,
  Value<String?> tournamentId,
  required String teamAId,
  required String teamBId,
  Value<String> format,
  Value<int?> totalOvers,
  Value<int?> ballsPerOver,
  Value<int?> maxOversPerBowler,
  Value<bool?> allowConsecutiveOvers,
  Value<bool?> maxOversWasManuallyEdited,
  Value<String?> venueName,
  required int scheduledAt,
  Value<int?> startedAt,
  Value<String?> matchTimeZone,
  Value<String?> tossWinnerTeamId,
  Value<String?> tossDecision,
  Value<String?> teamASquadJson,
  Value<String?> teamBSquadJson,
  Value<String?> teamACaptainId,
  Value<String?> teamBCaptainId,
  Value<String?> teamAWicketkeeperId,
  Value<String?> teamBWicketkeeperId,
  Value<String> status,
  required String currentScorerDeviceId,
  Value<int> version,
  Value<String> syncStatus,
  Value<String?> stateJson,
  Value<String?> setupDraftJson,
  required int createdAt,
  Value<String?> endReasonCode,
  Value<String?> endReasonText,
  Value<String?> endNote,
  Value<bool> endedManually,
  Value<int?> endedAt,
  Value<String?> endedBy,
  Value<String?> winnerTeamId,
  Value<String?> loserTeamId,
  Value<String?> resultType,
  Value<String?> resultText,
  Value<int> rowid,
});
typedef $$MatchesTableTableUpdateCompanionBuilder = MatchesTableCompanion
    Function({
  Value<String> id,
  Value<String?> matchName,
  Value<String?> tournamentId,
  Value<String> teamAId,
  Value<String> teamBId,
  Value<String> format,
  Value<int?> totalOvers,
  Value<int?> ballsPerOver,
  Value<int?> maxOversPerBowler,
  Value<bool?> allowConsecutiveOvers,
  Value<bool?> maxOversWasManuallyEdited,
  Value<String?> venueName,
  Value<int> scheduledAt,
  Value<int?> startedAt,
  Value<String?> matchTimeZone,
  Value<String?> tossWinnerTeamId,
  Value<String?> tossDecision,
  Value<String?> teamASquadJson,
  Value<String?> teamBSquadJson,
  Value<String?> teamACaptainId,
  Value<String?> teamBCaptainId,
  Value<String?> teamAWicketkeeperId,
  Value<String?> teamBWicketkeeperId,
  Value<String> status,
  Value<String> currentScorerDeviceId,
  Value<int> version,
  Value<String> syncStatus,
  Value<String?> stateJson,
  Value<String?> setupDraftJson,
  Value<int> createdAt,
  Value<String?> endReasonCode,
  Value<String?> endReasonText,
  Value<String?> endNote,
  Value<bool> endedManually,
  Value<int?> endedAt,
  Value<String?> endedBy,
  Value<String?> winnerTeamId,
  Value<String?> loserTeamId,
  Value<String?> resultType,
  Value<String?> resultText,
  Value<int> rowid,
});

class $$MatchesTableTableFilterComposer
    extends Composer<_$AppDatabase, $MatchesTableTable> {
  $$MatchesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get matchName => $composableBuilder(
      column: $table.matchName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tournamentId => $composableBuilder(
      column: $table.tournamentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get teamAId => $composableBuilder(
      column: $table.teamAId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get teamBId => $composableBuilder(
      column: $table.teamBId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get format => $composableBuilder(
      column: $table.format, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalOvers => $composableBuilder(
      column: $table.totalOvers, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get ballsPerOver => $composableBuilder(
      column: $table.ballsPerOver, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get maxOversPerBowler => $composableBuilder(
      column: $table.maxOversPerBowler,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get allowConsecutiveOvers => $composableBuilder(
      column: $table.allowConsecutiveOvers,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get maxOversWasManuallyEdited => $composableBuilder(
      column: $table.maxOversWasManuallyEdited,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get venueName => $composableBuilder(
      column: $table.venueName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get matchTimeZone => $composableBuilder(
      column: $table.matchTimeZone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tossWinnerTeamId => $composableBuilder(
      column: $table.tossWinnerTeamId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tossDecision => $composableBuilder(
      column: $table.tossDecision, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get teamASquadJson => $composableBuilder(
      column: $table.teamASquadJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get teamBSquadJson => $composableBuilder(
      column: $table.teamBSquadJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get teamACaptainId => $composableBuilder(
      column: $table.teamACaptainId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get teamBCaptainId => $composableBuilder(
      column: $table.teamBCaptainId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get teamAWicketkeeperId => $composableBuilder(
      column: $table.teamAWicketkeeperId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get teamBWicketkeeperId => $composableBuilder(
      column: $table.teamBWicketkeeperId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currentScorerDeviceId => $composableBuilder(
      column: $table.currentScorerDeviceId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get stateJson => $composableBuilder(
      column: $table.stateJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get setupDraftJson => $composableBuilder(
      column: $table.setupDraftJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get endReasonCode => $composableBuilder(
      column: $table.endReasonCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get endReasonText => $composableBuilder(
      column: $table.endReasonText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get endNote => $composableBuilder(
      column: $table.endNote, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get endedManually => $composableBuilder(
      column: $table.endedManually, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get endedAt => $composableBuilder(
      column: $table.endedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get endedBy => $composableBuilder(
      column: $table.endedBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get winnerTeamId => $composableBuilder(
      column: $table.winnerTeamId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get loserTeamId => $composableBuilder(
      column: $table.loserTeamId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get resultType => $composableBuilder(
      column: $table.resultType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get resultText => $composableBuilder(
      column: $table.resultText, builder: (column) => ColumnFilters(column));
}

class $$MatchesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $MatchesTableTable> {
  $$MatchesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get matchName => $composableBuilder(
      column: $table.matchName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tournamentId => $composableBuilder(
      column: $table.tournamentId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get teamAId => $composableBuilder(
      column: $table.teamAId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get teamBId => $composableBuilder(
      column: $table.teamBId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get format => $composableBuilder(
      column: $table.format, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalOvers => $composableBuilder(
      column: $table.totalOvers, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get ballsPerOver => $composableBuilder(
      column: $table.ballsPerOver,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get maxOversPerBowler => $composableBuilder(
      column: $table.maxOversPerBowler,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get allowConsecutiveOvers => $composableBuilder(
      column: $table.allowConsecutiveOvers,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get maxOversWasManuallyEdited => $composableBuilder(
      column: $table.maxOversWasManuallyEdited,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get venueName => $composableBuilder(
      column: $table.venueName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get matchTimeZone => $composableBuilder(
      column: $table.matchTimeZone,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tossWinnerTeamId => $composableBuilder(
      column: $table.tossWinnerTeamId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tossDecision => $composableBuilder(
      column: $table.tossDecision,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get teamASquadJson => $composableBuilder(
      column: $table.teamASquadJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get teamBSquadJson => $composableBuilder(
      column: $table.teamBSquadJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get teamACaptainId => $composableBuilder(
      column: $table.teamACaptainId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get teamBCaptainId => $composableBuilder(
      column: $table.teamBCaptainId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get teamAWicketkeeperId => $composableBuilder(
      column: $table.teamAWicketkeeperId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get teamBWicketkeeperId => $composableBuilder(
      column: $table.teamBWicketkeeperId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currentScorerDeviceId => $composableBuilder(
      column: $table.currentScorerDeviceId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get stateJson => $composableBuilder(
      column: $table.stateJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get setupDraftJson => $composableBuilder(
      column: $table.setupDraftJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get endReasonCode => $composableBuilder(
      column: $table.endReasonCode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get endReasonText => $composableBuilder(
      column: $table.endReasonText,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get endNote => $composableBuilder(
      column: $table.endNote, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get endedManually => $composableBuilder(
      column: $table.endedManually,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get endedAt => $composableBuilder(
      column: $table.endedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get endedBy => $composableBuilder(
      column: $table.endedBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get winnerTeamId => $composableBuilder(
      column: $table.winnerTeamId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get loserTeamId => $composableBuilder(
      column: $table.loserTeamId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get resultType => $composableBuilder(
      column: $table.resultType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get resultText => $composableBuilder(
      column: $table.resultText, builder: (column) => ColumnOrderings(column));
}

class $$MatchesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $MatchesTableTable> {
  $$MatchesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get matchName =>
      $composableBuilder(column: $table.matchName, builder: (column) => column);

  GeneratedColumn<String> get tournamentId => $composableBuilder(
      column: $table.tournamentId, builder: (column) => column);

  GeneratedColumn<String> get teamAId =>
      $composableBuilder(column: $table.teamAId, builder: (column) => column);

  GeneratedColumn<String> get teamBId =>
      $composableBuilder(column: $table.teamBId, builder: (column) => column);

  GeneratedColumn<String> get format =>
      $composableBuilder(column: $table.format, builder: (column) => column);

  GeneratedColumn<int> get totalOvers => $composableBuilder(
      column: $table.totalOvers, builder: (column) => column);

  GeneratedColumn<int> get ballsPerOver => $composableBuilder(
      column: $table.ballsPerOver, builder: (column) => column);

  GeneratedColumn<int> get maxOversPerBowler => $composableBuilder(
      column: $table.maxOversPerBowler, builder: (column) => column);

  GeneratedColumn<bool> get allowConsecutiveOvers => $composableBuilder(
      column: $table.allowConsecutiveOvers, builder: (column) => column);

  GeneratedColumn<bool> get maxOversWasManuallyEdited => $composableBuilder(
      column: $table.maxOversWasManuallyEdited, builder: (column) => column);

  GeneratedColumn<String> get venueName =>
      $composableBuilder(column: $table.venueName, builder: (column) => column);

  GeneratedColumn<int> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => column);

  GeneratedColumn<int> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<String> get matchTimeZone => $composableBuilder(
      column: $table.matchTimeZone, builder: (column) => column);

  GeneratedColumn<String> get tossWinnerTeamId => $composableBuilder(
      column: $table.tossWinnerTeamId, builder: (column) => column);

  GeneratedColumn<String> get tossDecision => $composableBuilder(
      column: $table.tossDecision, builder: (column) => column);

  GeneratedColumn<String> get teamASquadJson => $composableBuilder(
      column: $table.teamASquadJson, builder: (column) => column);

  GeneratedColumn<String> get teamBSquadJson => $composableBuilder(
      column: $table.teamBSquadJson, builder: (column) => column);

  GeneratedColumn<String> get teamACaptainId => $composableBuilder(
      column: $table.teamACaptainId, builder: (column) => column);

  GeneratedColumn<String> get teamBCaptainId => $composableBuilder(
      column: $table.teamBCaptainId, builder: (column) => column);

  GeneratedColumn<String> get teamAWicketkeeperId => $composableBuilder(
      column: $table.teamAWicketkeeperId, builder: (column) => column);

  GeneratedColumn<String> get teamBWicketkeeperId => $composableBuilder(
      column: $table.teamBWicketkeeperId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get currentScorerDeviceId => $composableBuilder(
      column: $table.currentScorerDeviceId, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<String> get stateJson =>
      $composableBuilder(column: $table.stateJson, builder: (column) => column);

  GeneratedColumn<String> get setupDraftJson => $composableBuilder(
      column: $table.setupDraftJson, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get endReasonCode => $composableBuilder(
      column: $table.endReasonCode, builder: (column) => column);

  GeneratedColumn<String> get endReasonText => $composableBuilder(
      column: $table.endReasonText, builder: (column) => column);

  GeneratedColumn<String> get endNote =>
      $composableBuilder(column: $table.endNote, builder: (column) => column);

  GeneratedColumn<bool> get endedManually => $composableBuilder(
      column: $table.endedManually, builder: (column) => column);

  GeneratedColumn<int> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<String> get endedBy =>
      $composableBuilder(column: $table.endedBy, builder: (column) => column);

  GeneratedColumn<String> get winnerTeamId => $composableBuilder(
      column: $table.winnerTeamId, builder: (column) => column);

  GeneratedColumn<String> get loserTeamId => $composableBuilder(
      column: $table.loserTeamId, builder: (column) => column);

  GeneratedColumn<String> get resultType => $composableBuilder(
      column: $table.resultType, builder: (column) => column);

  GeneratedColumn<String> get resultText => $composableBuilder(
      column: $table.resultText, builder: (column) => column);
}

class $$MatchesTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MatchesTableTable,
    MatchesTableData,
    $$MatchesTableTableFilterComposer,
    $$MatchesTableTableOrderingComposer,
    $$MatchesTableTableAnnotationComposer,
    $$MatchesTableTableCreateCompanionBuilder,
    $$MatchesTableTableUpdateCompanionBuilder,
    (
      MatchesTableData,
      BaseReferences<_$AppDatabase, $MatchesTableTable, MatchesTableData>
    ),
    MatchesTableData,
    PrefetchHooks Function()> {
  $$MatchesTableTableTableManager(_$AppDatabase db, $MatchesTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MatchesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MatchesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MatchesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> matchName = const Value.absent(),
            Value<String?> tournamentId = const Value.absent(),
            Value<String> teamAId = const Value.absent(),
            Value<String> teamBId = const Value.absent(),
            Value<String> format = const Value.absent(),
            Value<int?> totalOvers = const Value.absent(),
            Value<int?> ballsPerOver = const Value.absent(),
            Value<int?> maxOversPerBowler = const Value.absent(),
            Value<bool?> allowConsecutiveOvers = const Value.absent(),
            Value<bool?> maxOversWasManuallyEdited = const Value.absent(),
            Value<String?> venueName = const Value.absent(),
            Value<int> scheduledAt = const Value.absent(),
            Value<int?> startedAt = const Value.absent(),
            Value<String?> matchTimeZone = const Value.absent(),
            Value<String?> tossWinnerTeamId = const Value.absent(),
            Value<String?> tossDecision = const Value.absent(),
            Value<String?> teamASquadJson = const Value.absent(),
            Value<String?> teamBSquadJson = const Value.absent(),
            Value<String?> teamACaptainId = const Value.absent(),
            Value<String?> teamBCaptainId = const Value.absent(),
            Value<String?> teamAWicketkeeperId = const Value.absent(),
            Value<String?> teamBWicketkeeperId = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> currentScorerDeviceId = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<String?> stateJson = const Value.absent(),
            Value<String?> setupDraftJson = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<String?> endReasonCode = const Value.absent(),
            Value<String?> endReasonText = const Value.absent(),
            Value<String?> endNote = const Value.absent(),
            Value<bool> endedManually = const Value.absent(),
            Value<int?> endedAt = const Value.absent(),
            Value<String?> endedBy = const Value.absent(),
            Value<String?> winnerTeamId = const Value.absent(),
            Value<String?> loserTeamId = const Value.absent(),
            Value<String?> resultType = const Value.absent(),
            Value<String?> resultText = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MatchesTableCompanion(
            id: id,
            matchName: matchName,
            tournamentId: tournamentId,
            teamAId: teamAId,
            teamBId: teamBId,
            format: format,
            totalOvers: totalOvers,
            ballsPerOver: ballsPerOver,
            maxOversPerBowler: maxOversPerBowler,
            allowConsecutiveOvers: allowConsecutiveOvers,
            maxOversWasManuallyEdited: maxOversWasManuallyEdited,
            venueName: venueName,
            scheduledAt: scheduledAt,
            startedAt: startedAt,
            matchTimeZone: matchTimeZone,
            tossWinnerTeamId: tossWinnerTeamId,
            tossDecision: tossDecision,
            teamASquadJson: teamASquadJson,
            teamBSquadJson: teamBSquadJson,
            teamACaptainId: teamACaptainId,
            teamBCaptainId: teamBCaptainId,
            teamAWicketkeeperId: teamAWicketkeeperId,
            teamBWicketkeeperId: teamBWicketkeeperId,
            status: status,
            currentScorerDeviceId: currentScorerDeviceId,
            version: version,
            syncStatus: syncStatus,
            stateJson: stateJson,
            setupDraftJson: setupDraftJson,
            createdAt: createdAt,
            endReasonCode: endReasonCode,
            endReasonText: endReasonText,
            endNote: endNote,
            endedManually: endedManually,
            endedAt: endedAt,
            endedBy: endedBy,
            winnerTeamId: winnerTeamId,
            loserTeamId: loserTeamId,
            resultType: resultType,
            resultText: resultText,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> matchName = const Value.absent(),
            Value<String?> tournamentId = const Value.absent(),
            required String teamAId,
            required String teamBId,
            Value<String> format = const Value.absent(),
            Value<int?> totalOvers = const Value.absent(),
            Value<int?> ballsPerOver = const Value.absent(),
            Value<int?> maxOversPerBowler = const Value.absent(),
            Value<bool?> allowConsecutiveOvers = const Value.absent(),
            Value<bool?> maxOversWasManuallyEdited = const Value.absent(),
            Value<String?> venueName = const Value.absent(),
            required int scheduledAt,
            Value<int?> startedAt = const Value.absent(),
            Value<String?> matchTimeZone = const Value.absent(),
            Value<String?> tossWinnerTeamId = const Value.absent(),
            Value<String?> tossDecision = const Value.absent(),
            Value<String?> teamASquadJson = const Value.absent(),
            Value<String?> teamBSquadJson = const Value.absent(),
            Value<String?> teamACaptainId = const Value.absent(),
            Value<String?> teamBCaptainId = const Value.absent(),
            Value<String?> teamAWicketkeeperId = const Value.absent(),
            Value<String?> teamBWicketkeeperId = const Value.absent(),
            Value<String> status = const Value.absent(),
            required String currentScorerDeviceId,
            Value<int> version = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<String?> stateJson = const Value.absent(),
            Value<String?> setupDraftJson = const Value.absent(),
            required int createdAt,
            Value<String?> endReasonCode = const Value.absent(),
            Value<String?> endReasonText = const Value.absent(),
            Value<String?> endNote = const Value.absent(),
            Value<bool> endedManually = const Value.absent(),
            Value<int?> endedAt = const Value.absent(),
            Value<String?> endedBy = const Value.absent(),
            Value<String?> winnerTeamId = const Value.absent(),
            Value<String?> loserTeamId = const Value.absent(),
            Value<String?> resultType = const Value.absent(),
            Value<String?> resultText = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MatchesTableCompanion.insert(
            id: id,
            matchName: matchName,
            tournamentId: tournamentId,
            teamAId: teamAId,
            teamBId: teamBId,
            format: format,
            totalOvers: totalOvers,
            ballsPerOver: ballsPerOver,
            maxOversPerBowler: maxOversPerBowler,
            allowConsecutiveOvers: allowConsecutiveOvers,
            maxOversWasManuallyEdited: maxOversWasManuallyEdited,
            venueName: venueName,
            scheduledAt: scheduledAt,
            startedAt: startedAt,
            matchTimeZone: matchTimeZone,
            tossWinnerTeamId: tossWinnerTeamId,
            tossDecision: tossDecision,
            teamASquadJson: teamASquadJson,
            teamBSquadJson: teamBSquadJson,
            teamACaptainId: teamACaptainId,
            teamBCaptainId: teamBCaptainId,
            teamAWicketkeeperId: teamAWicketkeeperId,
            teamBWicketkeeperId: teamBWicketkeeperId,
            status: status,
            currentScorerDeviceId: currentScorerDeviceId,
            version: version,
            syncStatus: syncStatus,
            stateJson: stateJson,
            setupDraftJson: setupDraftJson,
            createdAt: createdAt,
            endReasonCode: endReasonCode,
            endReasonText: endReasonText,
            endNote: endNote,
            endedManually: endedManually,
            endedAt: endedAt,
            endedBy: endedBy,
            winnerTeamId: winnerTeamId,
            loserTeamId: loserTeamId,
            resultType: resultType,
            resultText: resultText,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MatchesTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MatchesTableTable,
    MatchesTableData,
    $$MatchesTableTableFilterComposer,
    $$MatchesTableTableOrderingComposer,
    $$MatchesTableTableAnnotationComposer,
    $$MatchesTableTableCreateCompanionBuilder,
    $$MatchesTableTableUpdateCompanionBuilder,
    (
      MatchesTableData,
      BaseReferences<_$AppDatabase, $MatchesTableTable, MatchesTableData>
    ),
    MatchesTableData,
    PrefetchHooks Function()>;
typedef $$DeliveriesTableTableCreateCompanionBuilder = DeliveriesTableCompanion
    Function({
  required String eventId,
  required String matchId,
  required String inningsId,
  required int overNumber,
  required int legalBallNumber,
  required int eventSequence,
  Value<int> sequenceInOver,
  required String scorerDeviceId,
  required String strikerId,
  required String nonStrikerId,
  required String bowlerId,
  Value<int> runsBatter,
  Value<String> extrasType,
  Value<int> extrasRuns,
  Value<int> wideRuns,
  Value<int> additionalWideRuns,
  Value<int> noBallRuns,
  Value<int> byeRuns,
  Value<int> legByeRuns,
  Value<int> penaltyRuns,
  Value<bool> isLegal,
  Value<bool> isBoundaryFour,
  Value<bool> isBoundarySix,
  Value<String?> wicketType,
  Value<String?> dismissedPlayerId,
  Value<String?> fielderId,
  Value<bool> isReversed,
  required String previousEventHash,
  required int clientTimestamp,
  Value<String> syncStatus,
  Value<int> rowid,
});
typedef $$DeliveriesTableTableUpdateCompanionBuilder = DeliveriesTableCompanion
    Function({
  Value<String> eventId,
  Value<String> matchId,
  Value<String> inningsId,
  Value<int> overNumber,
  Value<int> legalBallNumber,
  Value<int> eventSequence,
  Value<int> sequenceInOver,
  Value<String> scorerDeviceId,
  Value<String> strikerId,
  Value<String> nonStrikerId,
  Value<String> bowlerId,
  Value<int> runsBatter,
  Value<String> extrasType,
  Value<int> extrasRuns,
  Value<int> wideRuns,
  Value<int> additionalWideRuns,
  Value<int> noBallRuns,
  Value<int> byeRuns,
  Value<int> legByeRuns,
  Value<int> penaltyRuns,
  Value<bool> isLegal,
  Value<bool> isBoundaryFour,
  Value<bool> isBoundarySix,
  Value<String?> wicketType,
  Value<String?> dismissedPlayerId,
  Value<String?> fielderId,
  Value<bool> isReversed,
  Value<String> previousEventHash,
  Value<int> clientTimestamp,
  Value<String> syncStatus,
  Value<int> rowid,
});

class $$DeliveriesTableTableFilterComposer
    extends Composer<_$AppDatabase, $DeliveriesTableTable> {
  $$DeliveriesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get eventId => $composableBuilder(
      column: $table.eventId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get matchId => $composableBuilder(
      column: $table.matchId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get inningsId => $composableBuilder(
      column: $table.inningsId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get overNumber => $composableBuilder(
      column: $table.overNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get legalBallNumber => $composableBuilder(
      column: $table.legalBallNumber,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get eventSequence => $composableBuilder(
      column: $table.eventSequence, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sequenceInOver => $composableBuilder(
      column: $table.sequenceInOver,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get scorerDeviceId => $composableBuilder(
      column: $table.scorerDeviceId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get strikerId => $composableBuilder(
      column: $table.strikerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nonStrikerId => $composableBuilder(
      column: $table.nonStrikerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bowlerId => $composableBuilder(
      column: $table.bowlerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get runsBatter => $composableBuilder(
      column: $table.runsBatter, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get extrasType => $composableBuilder(
      column: $table.extrasType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get extrasRuns => $composableBuilder(
      column: $table.extrasRuns, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get wideRuns => $composableBuilder(
      column: $table.wideRuns, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get additionalWideRuns => $composableBuilder(
      column: $table.additionalWideRuns,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get noBallRuns => $composableBuilder(
      column: $table.noBallRuns, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get byeRuns => $composableBuilder(
      column: $table.byeRuns, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get legByeRuns => $composableBuilder(
      column: $table.legByeRuns, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get penaltyRuns => $composableBuilder(
      column: $table.penaltyRuns, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isLegal => $composableBuilder(
      column: $table.isLegal, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isBoundaryFour => $composableBuilder(
      column: $table.isBoundaryFour,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isBoundarySix => $composableBuilder(
      column: $table.isBoundarySix, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get wicketType => $composableBuilder(
      column: $table.wicketType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dismissedPlayerId => $composableBuilder(
      column: $table.dismissedPlayerId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fielderId => $composableBuilder(
      column: $table.fielderId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isReversed => $composableBuilder(
      column: $table.isReversed, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get previousEventHash => $composableBuilder(
      column: $table.previousEventHash,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get clientTimestamp => $composableBuilder(
      column: $table.clientTimestamp,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));
}

class $$DeliveriesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DeliveriesTableTable> {
  $$DeliveriesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get eventId => $composableBuilder(
      column: $table.eventId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get matchId => $composableBuilder(
      column: $table.matchId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get inningsId => $composableBuilder(
      column: $table.inningsId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get overNumber => $composableBuilder(
      column: $table.overNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get legalBallNumber => $composableBuilder(
      column: $table.legalBallNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get eventSequence => $composableBuilder(
      column: $table.eventSequence,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sequenceInOver => $composableBuilder(
      column: $table.sequenceInOver,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get scorerDeviceId => $composableBuilder(
      column: $table.scorerDeviceId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get strikerId => $composableBuilder(
      column: $table.strikerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nonStrikerId => $composableBuilder(
      column: $table.nonStrikerId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bowlerId => $composableBuilder(
      column: $table.bowlerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get runsBatter => $composableBuilder(
      column: $table.runsBatter, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get extrasType => $composableBuilder(
      column: $table.extrasType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get extrasRuns => $composableBuilder(
      column: $table.extrasRuns, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get wideRuns => $composableBuilder(
      column: $table.wideRuns, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get additionalWideRuns => $composableBuilder(
      column: $table.additionalWideRuns,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get noBallRuns => $composableBuilder(
      column: $table.noBallRuns, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get byeRuns => $composableBuilder(
      column: $table.byeRuns, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get legByeRuns => $composableBuilder(
      column: $table.legByeRuns, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get penaltyRuns => $composableBuilder(
      column: $table.penaltyRuns, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isLegal => $composableBuilder(
      column: $table.isLegal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isBoundaryFour => $composableBuilder(
      column: $table.isBoundaryFour,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isBoundarySix => $composableBuilder(
      column: $table.isBoundarySix,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get wicketType => $composableBuilder(
      column: $table.wicketType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dismissedPlayerId => $composableBuilder(
      column: $table.dismissedPlayerId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fielderId => $composableBuilder(
      column: $table.fielderId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isReversed => $composableBuilder(
      column: $table.isReversed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get previousEventHash => $composableBuilder(
      column: $table.previousEventHash,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get clientTimestamp => $composableBuilder(
      column: $table.clientTimestamp,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));
}

class $$DeliveriesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DeliveriesTableTable> {
  $$DeliveriesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

  GeneratedColumn<String> get matchId =>
      $composableBuilder(column: $table.matchId, builder: (column) => column);

  GeneratedColumn<String> get inningsId =>
      $composableBuilder(column: $table.inningsId, builder: (column) => column);

  GeneratedColumn<int> get overNumber => $composableBuilder(
      column: $table.overNumber, builder: (column) => column);

  GeneratedColumn<int> get legalBallNumber => $composableBuilder(
      column: $table.legalBallNumber, builder: (column) => column);

  GeneratedColumn<int> get eventSequence => $composableBuilder(
      column: $table.eventSequence, builder: (column) => column);

  GeneratedColumn<int> get sequenceInOver => $composableBuilder(
      column: $table.sequenceInOver, builder: (column) => column);

  GeneratedColumn<String> get scorerDeviceId => $composableBuilder(
      column: $table.scorerDeviceId, builder: (column) => column);

  GeneratedColumn<String> get strikerId =>
      $composableBuilder(column: $table.strikerId, builder: (column) => column);

  GeneratedColumn<String> get nonStrikerId => $composableBuilder(
      column: $table.nonStrikerId, builder: (column) => column);

  GeneratedColumn<String> get bowlerId =>
      $composableBuilder(column: $table.bowlerId, builder: (column) => column);

  GeneratedColumn<int> get runsBatter => $composableBuilder(
      column: $table.runsBatter, builder: (column) => column);

  GeneratedColumn<String> get extrasType => $composableBuilder(
      column: $table.extrasType, builder: (column) => column);

  GeneratedColumn<int> get extrasRuns => $composableBuilder(
      column: $table.extrasRuns, builder: (column) => column);

  GeneratedColumn<int> get wideRuns =>
      $composableBuilder(column: $table.wideRuns, builder: (column) => column);

  GeneratedColumn<int> get additionalWideRuns => $composableBuilder(
      column: $table.additionalWideRuns, builder: (column) => column);

  GeneratedColumn<int> get noBallRuns => $composableBuilder(
      column: $table.noBallRuns, builder: (column) => column);

  GeneratedColumn<int> get byeRuns =>
      $composableBuilder(column: $table.byeRuns, builder: (column) => column);

  GeneratedColumn<int> get legByeRuns => $composableBuilder(
      column: $table.legByeRuns, builder: (column) => column);

  GeneratedColumn<int> get penaltyRuns => $composableBuilder(
      column: $table.penaltyRuns, builder: (column) => column);

  GeneratedColumn<bool> get isLegal =>
      $composableBuilder(column: $table.isLegal, builder: (column) => column);

  GeneratedColumn<bool> get isBoundaryFour => $composableBuilder(
      column: $table.isBoundaryFour, builder: (column) => column);

  GeneratedColumn<bool> get isBoundarySix => $composableBuilder(
      column: $table.isBoundarySix, builder: (column) => column);

  GeneratedColumn<String> get wicketType => $composableBuilder(
      column: $table.wicketType, builder: (column) => column);

  GeneratedColumn<String> get dismissedPlayerId => $composableBuilder(
      column: $table.dismissedPlayerId, builder: (column) => column);

  GeneratedColumn<String> get fielderId =>
      $composableBuilder(column: $table.fielderId, builder: (column) => column);

  GeneratedColumn<bool> get isReversed => $composableBuilder(
      column: $table.isReversed, builder: (column) => column);

  GeneratedColumn<String> get previousEventHash => $composableBuilder(
      column: $table.previousEventHash, builder: (column) => column);

  GeneratedColumn<int> get clientTimestamp => $composableBuilder(
      column: $table.clientTimestamp, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);
}

class $$DeliveriesTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DeliveriesTableTable,
    DeliveriesTableData,
    $$DeliveriesTableTableFilterComposer,
    $$DeliveriesTableTableOrderingComposer,
    $$DeliveriesTableTableAnnotationComposer,
    $$DeliveriesTableTableCreateCompanionBuilder,
    $$DeliveriesTableTableUpdateCompanionBuilder,
    (
      DeliveriesTableData,
      BaseReferences<_$AppDatabase, $DeliveriesTableTable, DeliveriesTableData>
    ),
    DeliveriesTableData,
    PrefetchHooks Function()> {
  $$DeliveriesTableTableTableManager(
      _$AppDatabase db, $DeliveriesTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeliveriesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeliveriesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DeliveriesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> eventId = const Value.absent(),
            Value<String> matchId = const Value.absent(),
            Value<String> inningsId = const Value.absent(),
            Value<int> overNumber = const Value.absent(),
            Value<int> legalBallNumber = const Value.absent(),
            Value<int> eventSequence = const Value.absent(),
            Value<int> sequenceInOver = const Value.absent(),
            Value<String> scorerDeviceId = const Value.absent(),
            Value<String> strikerId = const Value.absent(),
            Value<String> nonStrikerId = const Value.absent(),
            Value<String> bowlerId = const Value.absent(),
            Value<int> runsBatter = const Value.absent(),
            Value<String> extrasType = const Value.absent(),
            Value<int> extrasRuns = const Value.absent(),
            Value<int> wideRuns = const Value.absent(),
            Value<int> additionalWideRuns = const Value.absent(),
            Value<int> noBallRuns = const Value.absent(),
            Value<int> byeRuns = const Value.absent(),
            Value<int> legByeRuns = const Value.absent(),
            Value<int> penaltyRuns = const Value.absent(),
            Value<bool> isLegal = const Value.absent(),
            Value<bool> isBoundaryFour = const Value.absent(),
            Value<bool> isBoundarySix = const Value.absent(),
            Value<String?> wicketType = const Value.absent(),
            Value<String?> dismissedPlayerId = const Value.absent(),
            Value<String?> fielderId = const Value.absent(),
            Value<bool> isReversed = const Value.absent(),
            Value<String> previousEventHash = const Value.absent(),
            Value<int> clientTimestamp = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DeliveriesTableCompanion(
            eventId: eventId,
            matchId: matchId,
            inningsId: inningsId,
            overNumber: overNumber,
            legalBallNumber: legalBallNumber,
            eventSequence: eventSequence,
            sequenceInOver: sequenceInOver,
            scorerDeviceId: scorerDeviceId,
            strikerId: strikerId,
            nonStrikerId: nonStrikerId,
            bowlerId: bowlerId,
            runsBatter: runsBatter,
            extrasType: extrasType,
            extrasRuns: extrasRuns,
            wideRuns: wideRuns,
            additionalWideRuns: additionalWideRuns,
            noBallRuns: noBallRuns,
            byeRuns: byeRuns,
            legByeRuns: legByeRuns,
            penaltyRuns: penaltyRuns,
            isLegal: isLegal,
            isBoundaryFour: isBoundaryFour,
            isBoundarySix: isBoundarySix,
            wicketType: wicketType,
            dismissedPlayerId: dismissedPlayerId,
            fielderId: fielderId,
            isReversed: isReversed,
            previousEventHash: previousEventHash,
            clientTimestamp: clientTimestamp,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String eventId,
            required String matchId,
            required String inningsId,
            required int overNumber,
            required int legalBallNumber,
            required int eventSequence,
            Value<int> sequenceInOver = const Value.absent(),
            required String scorerDeviceId,
            required String strikerId,
            required String nonStrikerId,
            required String bowlerId,
            Value<int> runsBatter = const Value.absent(),
            Value<String> extrasType = const Value.absent(),
            Value<int> extrasRuns = const Value.absent(),
            Value<int> wideRuns = const Value.absent(),
            Value<int> additionalWideRuns = const Value.absent(),
            Value<int> noBallRuns = const Value.absent(),
            Value<int> byeRuns = const Value.absent(),
            Value<int> legByeRuns = const Value.absent(),
            Value<int> penaltyRuns = const Value.absent(),
            Value<bool> isLegal = const Value.absent(),
            Value<bool> isBoundaryFour = const Value.absent(),
            Value<bool> isBoundarySix = const Value.absent(),
            Value<String?> wicketType = const Value.absent(),
            Value<String?> dismissedPlayerId = const Value.absent(),
            Value<String?> fielderId = const Value.absent(),
            Value<bool> isReversed = const Value.absent(),
            required String previousEventHash,
            required int clientTimestamp,
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DeliveriesTableCompanion.insert(
            eventId: eventId,
            matchId: matchId,
            inningsId: inningsId,
            overNumber: overNumber,
            legalBallNumber: legalBallNumber,
            eventSequence: eventSequence,
            sequenceInOver: sequenceInOver,
            scorerDeviceId: scorerDeviceId,
            strikerId: strikerId,
            nonStrikerId: nonStrikerId,
            bowlerId: bowlerId,
            runsBatter: runsBatter,
            extrasType: extrasType,
            extrasRuns: extrasRuns,
            wideRuns: wideRuns,
            additionalWideRuns: additionalWideRuns,
            noBallRuns: noBallRuns,
            byeRuns: byeRuns,
            legByeRuns: legByeRuns,
            penaltyRuns: penaltyRuns,
            isLegal: isLegal,
            isBoundaryFour: isBoundaryFour,
            isBoundarySix: isBoundarySix,
            wicketType: wicketType,
            dismissedPlayerId: dismissedPlayerId,
            fielderId: fielderId,
            isReversed: isReversed,
            previousEventHash: previousEventHash,
            clientTimestamp: clientTimestamp,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DeliveriesTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DeliveriesTableTable,
    DeliveriesTableData,
    $$DeliveriesTableTableFilterComposer,
    $$DeliveriesTableTableOrderingComposer,
    $$DeliveriesTableTableAnnotationComposer,
    $$DeliveriesTableTableCreateCompanionBuilder,
    $$DeliveriesTableTableUpdateCompanionBuilder,
    (
      DeliveriesTableData,
      BaseReferences<_$AppDatabase, $DeliveriesTableTable, DeliveriesTableData>
    ),
    DeliveriesTableData,
    PrefetchHooks Function()>;
typedef $$SyncQueueTableTableCreateCompanionBuilder = SyncQueueTableCompanion
    Function({
  Value<int> id,
  required String eventId,
  required String matchId,
  required String payloadJson,
  Value<int> attempts,
  Value<String> status,
  Value<String?> errorMessage,
});
typedef $$SyncQueueTableTableUpdateCompanionBuilder = SyncQueueTableCompanion
    Function({
  Value<int> id,
  Value<String> eventId,
  Value<String> matchId,
  Value<String> payloadJson,
  Value<int> attempts,
  Value<String> status,
  Value<String?> errorMessage,
});

class $$SyncQueueTableTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTableTable> {
  $$SyncQueueTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get eventId => $composableBuilder(
      column: $table.eventId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get matchId => $composableBuilder(
      column: $table.matchId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get attempts => $composableBuilder(
      column: $table.attempts, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage, builder: (column) => ColumnFilters(column));
}

class $$SyncQueueTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTableTable> {
  $$SyncQueueTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get eventId => $composableBuilder(
      column: $table.eventId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get matchId => $composableBuilder(
      column: $table.matchId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get attempts => $composableBuilder(
      column: $table.attempts, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage,
      builder: (column) => ColumnOrderings(column));
}

class $$SyncQueueTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTableTable> {
  $$SyncQueueTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

  GeneratedColumn<String> get matchId =>
      $composableBuilder(column: $table.matchId, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage, builder: (column) => column);
}

class $$SyncQueueTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncQueueTableTable,
    SyncQueueTableData,
    $$SyncQueueTableTableFilterComposer,
    $$SyncQueueTableTableOrderingComposer,
    $$SyncQueueTableTableAnnotationComposer,
    $$SyncQueueTableTableCreateCompanionBuilder,
    $$SyncQueueTableTableUpdateCompanionBuilder,
    (
      SyncQueueTableData,
      BaseReferences<_$AppDatabase, $SyncQueueTableTable, SyncQueueTableData>
    ),
    SyncQueueTableData,
    PrefetchHooks Function()> {
  $$SyncQueueTableTableTableManager(
      _$AppDatabase db, $SyncQueueTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> eventId = const Value.absent(),
            Value<String> matchId = const Value.absent(),
            Value<String> payloadJson = const Value.absent(),
            Value<int> attempts = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> errorMessage = const Value.absent(),
          }) =>
              SyncQueueTableCompanion(
            id: id,
            eventId: eventId,
            matchId: matchId,
            payloadJson: payloadJson,
            attempts: attempts,
            status: status,
            errorMessage: errorMessage,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String eventId,
            required String matchId,
            required String payloadJson,
            Value<int> attempts = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> errorMessage = const Value.absent(),
          }) =>
              SyncQueueTableCompanion.insert(
            id: id,
            eventId: eventId,
            matchId: matchId,
            payloadJson: payloadJson,
            attempts: attempts,
            status: status,
            errorMessage: errorMessage,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncQueueTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncQueueTableTable,
    SyncQueueTableData,
    $$SyncQueueTableTableFilterComposer,
    $$SyncQueueTableTableOrderingComposer,
    $$SyncQueueTableTableAnnotationComposer,
    $$SyncQueueTableTableCreateCompanionBuilder,
    $$SyncQueueTableTableUpdateCompanionBuilder,
    (
      SyncQueueTableData,
      BaseReferences<_$AppDatabase, $SyncQueueTableTable, SyncQueueTableData>
    ),
    SyncQueueTableData,
    PrefetchHooks Function()>;
typedef $$ScoringAuditTableTableCreateCompanionBuilder
    = ScoringAuditTableCompanion Function({
  required String id,
  required String matchId,
  required String inningsId,
  required String action,
  required String payloadJson,
  required int createdAt,
  Value<int> rowid,
});
typedef $$ScoringAuditTableTableUpdateCompanionBuilder
    = ScoringAuditTableCompanion Function({
  Value<String> id,
  Value<String> matchId,
  Value<String> inningsId,
  Value<String> action,
  Value<String> payloadJson,
  Value<int> createdAt,
  Value<int> rowid,
});

class $$ScoringAuditTableTableFilterComposer
    extends Composer<_$AppDatabase, $ScoringAuditTableTable> {
  $$ScoringAuditTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get matchId => $composableBuilder(
      column: $table.matchId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get inningsId => $composableBuilder(
      column: $table.inningsId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$ScoringAuditTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ScoringAuditTableTable> {
  $$ScoringAuditTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get matchId => $composableBuilder(
      column: $table.matchId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get inningsId => $composableBuilder(
      column: $table.inningsId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$ScoringAuditTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScoringAuditTableTable> {
  $$ScoringAuditTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get matchId =>
      $composableBuilder(column: $table.matchId, builder: (column) => column);

  GeneratedColumn<String> get inningsId =>
      $composableBuilder(column: $table.inningsId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ScoringAuditTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ScoringAuditTableTable,
    ScoringAuditTableData,
    $$ScoringAuditTableTableFilterComposer,
    $$ScoringAuditTableTableOrderingComposer,
    $$ScoringAuditTableTableAnnotationComposer,
    $$ScoringAuditTableTableCreateCompanionBuilder,
    $$ScoringAuditTableTableUpdateCompanionBuilder,
    (
      ScoringAuditTableData,
      BaseReferences<_$AppDatabase, $ScoringAuditTableTable,
          ScoringAuditTableData>
    ),
    ScoringAuditTableData,
    PrefetchHooks Function()> {
  $$ScoringAuditTableTableTableManager(
      _$AppDatabase db, $ScoringAuditTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScoringAuditTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScoringAuditTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScoringAuditTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> matchId = const Value.absent(),
            Value<String> inningsId = const Value.absent(),
            Value<String> action = const Value.absent(),
            Value<String> payloadJson = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ScoringAuditTableCompanion(
            id: id,
            matchId: matchId,
            inningsId: inningsId,
            action: action,
            payloadJson: payloadJson,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String matchId,
            required String inningsId,
            required String action,
            required String payloadJson,
            required int createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ScoringAuditTableCompanion.insert(
            id: id,
            matchId: matchId,
            inningsId: inningsId,
            action: action,
            payloadJson: payloadJson,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ScoringAuditTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ScoringAuditTableTable,
    ScoringAuditTableData,
    $$ScoringAuditTableTableFilterComposer,
    $$ScoringAuditTableTableOrderingComposer,
    $$ScoringAuditTableTableAnnotationComposer,
    $$ScoringAuditTableTableCreateCompanionBuilder,
    $$ScoringAuditTableTableUpdateCompanionBuilder,
    (
      ScoringAuditTableData,
      BaseReferences<_$AppDatabase, $ScoringAuditTableTable,
          ScoringAuditTableData>
    ),
    ScoringAuditTableData,
    PrefetchHooks Function()>;
typedef $$MatchSquadMembersTableTableCreateCompanionBuilder
    = MatchSquadMembersTableCompanion Function({
  required String id,
  required String matchId,
  required String teamId,
  required String playerId,
  required String playerNameSnapshot,
  Value<bool> addedAfterMatchStart,
  required int joinedAt,
  Value<String?> joinedInningsId,
  Value<int?> joinedOverNumber,
  Value<int?> joinedDeliverySequence,
  Value<bool> isEligibleBowler,
  Value<bool> isAvailable,
  Value<bool> addedToPermanentTeam,
  Value<bool> isActive,
  Value<int?> removedAt,
  Value<int> rowid,
});
typedef $$MatchSquadMembersTableTableUpdateCompanionBuilder
    = MatchSquadMembersTableCompanion Function({
  Value<String> id,
  Value<String> matchId,
  Value<String> teamId,
  Value<String> playerId,
  Value<String> playerNameSnapshot,
  Value<bool> addedAfterMatchStart,
  Value<int> joinedAt,
  Value<String?> joinedInningsId,
  Value<int?> joinedOverNumber,
  Value<int?> joinedDeliverySequence,
  Value<bool> isEligibleBowler,
  Value<bool> isAvailable,
  Value<bool> addedToPermanentTeam,
  Value<bool> isActive,
  Value<int?> removedAt,
  Value<int> rowid,
});

class $$MatchSquadMembersTableTableFilterComposer
    extends Composer<_$AppDatabase, $MatchSquadMembersTableTable> {
  $$MatchSquadMembersTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get matchId => $composableBuilder(
      column: $table.matchId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get teamId => $composableBuilder(
      column: $table.teamId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get playerId => $composableBuilder(
      column: $table.playerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get playerNameSnapshot => $composableBuilder(
      column: $table.playerNameSnapshot,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get addedAfterMatchStart => $composableBuilder(
      column: $table.addedAfterMatchStart,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get joinedAt => $composableBuilder(
      column: $table.joinedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get joinedInningsId => $composableBuilder(
      column: $table.joinedInningsId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get joinedOverNumber => $composableBuilder(
      column: $table.joinedOverNumber,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get joinedDeliverySequence => $composableBuilder(
      column: $table.joinedDeliverySequence,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isEligibleBowler => $composableBuilder(
      column: $table.isEligibleBowler,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isAvailable => $composableBuilder(
      column: $table.isAvailable, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get addedToPermanentTeam => $composableBuilder(
      column: $table.addedToPermanentTeam,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get removedAt => $composableBuilder(
      column: $table.removedAt, builder: (column) => ColumnFilters(column));
}

class $$MatchSquadMembersTableTableOrderingComposer
    extends Composer<_$AppDatabase, $MatchSquadMembersTableTable> {
  $$MatchSquadMembersTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get matchId => $composableBuilder(
      column: $table.matchId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get teamId => $composableBuilder(
      column: $table.teamId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get playerId => $composableBuilder(
      column: $table.playerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get playerNameSnapshot => $composableBuilder(
      column: $table.playerNameSnapshot,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get addedAfterMatchStart => $composableBuilder(
      column: $table.addedAfterMatchStart,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get joinedAt => $composableBuilder(
      column: $table.joinedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get joinedInningsId => $composableBuilder(
      column: $table.joinedInningsId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get joinedOverNumber => $composableBuilder(
      column: $table.joinedOverNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get joinedDeliverySequence => $composableBuilder(
      column: $table.joinedDeliverySequence,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isEligibleBowler => $composableBuilder(
      column: $table.isEligibleBowler,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isAvailable => $composableBuilder(
      column: $table.isAvailable, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get addedToPermanentTeam => $composableBuilder(
      column: $table.addedToPermanentTeam,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get removedAt => $composableBuilder(
      column: $table.removedAt, builder: (column) => ColumnOrderings(column));
}

class $$MatchSquadMembersTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $MatchSquadMembersTableTable> {
  $$MatchSquadMembersTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get matchId =>
      $composableBuilder(column: $table.matchId, builder: (column) => column);

  GeneratedColumn<String> get teamId =>
      $composableBuilder(column: $table.teamId, builder: (column) => column);

  GeneratedColumn<String> get playerId =>
      $composableBuilder(column: $table.playerId, builder: (column) => column);

  GeneratedColumn<String> get playerNameSnapshot => $composableBuilder(
      column: $table.playerNameSnapshot, builder: (column) => column);

  GeneratedColumn<bool> get addedAfterMatchStart => $composableBuilder(
      column: $table.addedAfterMatchStart, builder: (column) => column);

  GeneratedColumn<int> get joinedAt =>
      $composableBuilder(column: $table.joinedAt, builder: (column) => column);

  GeneratedColumn<String> get joinedInningsId => $composableBuilder(
      column: $table.joinedInningsId, builder: (column) => column);

  GeneratedColumn<int> get joinedOverNumber => $composableBuilder(
      column: $table.joinedOverNumber, builder: (column) => column);

  GeneratedColumn<int> get joinedDeliverySequence => $composableBuilder(
      column: $table.joinedDeliverySequence, builder: (column) => column);

  GeneratedColumn<bool> get isEligibleBowler => $composableBuilder(
      column: $table.isEligibleBowler, builder: (column) => column);

  GeneratedColumn<bool> get isAvailable => $composableBuilder(
      column: $table.isAvailable, builder: (column) => column);

  GeneratedColumn<bool> get addedToPermanentTeam => $composableBuilder(
      column: $table.addedToPermanentTeam, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get removedAt =>
      $composableBuilder(column: $table.removedAt, builder: (column) => column);
}

class $$MatchSquadMembersTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MatchSquadMembersTableTable,
    MatchSquadMembersTableData,
    $$MatchSquadMembersTableTableFilterComposer,
    $$MatchSquadMembersTableTableOrderingComposer,
    $$MatchSquadMembersTableTableAnnotationComposer,
    $$MatchSquadMembersTableTableCreateCompanionBuilder,
    $$MatchSquadMembersTableTableUpdateCompanionBuilder,
    (
      MatchSquadMembersTableData,
      BaseReferences<_$AppDatabase, $MatchSquadMembersTableTable,
          MatchSquadMembersTableData>
    ),
    MatchSquadMembersTableData,
    PrefetchHooks Function()> {
  $$MatchSquadMembersTableTableTableManager(
      _$AppDatabase db, $MatchSquadMembersTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MatchSquadMembersTableTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$MatchSquadMembersTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MatchSquadMembersTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> matchId = const Value.absent(),
            Value<String> teamId = const Value.absent(),
            Value<String> playerId = const Value.absent(),
            Value<String> playerNameSnapshot = const Value.absent(),
            Value<bool> addedAfterMatchStart = const Value.absent(),
            Value<int> joinedAt = const Value.absent(),
            Value<String?> joinedInningsId = const Value.absent(),
            Value<int?> joinedOverNumber = const Value.absent(),
            Value<int?> joinedDeliverySequence = const Value.absent(),
            Value<bool> isEligibleBowler = const Value.absent(),
            Value<bool> isAvailable = const Value.absent(),
            Value<bool> addedToPermanentTeam = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int?> removedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MatchSquadMembersTableCompanion(
            id: id,
            matchId: matchId,
            teamId: teamId,
            playerId: playerId,
            playerNameSnapshot: playerNameSnapshot,
            addedAfterMatchStart: addedAfterMatchStart,
            joinedAt: joinedAt,
            joinedInningsId: joinedInningsId,
            joinedOverNumber: joinedOverNumber,
            joinedDeliverySequence: joinedDeliverySequence,
            isEligibleBowler: isEligibleBowler,
            isAvailable: isAvailable,
            addedToPermanentTeam: addedToPermanentTeam,
            isActive: isActive,
            removedAt: removedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String matchId,
            required String teamId,
            required String playerId,
            required String playerNameSnapshot,
            Value<bool> addedAfterMatchStart = const Value.absent(),
            required int joinedAt,
            Value<String?> joinedInningsId = const Value.absent(),
            Value<int?> joinedOverNumber = const Value.absent(),
            Value<int?> joinedDeliverySequence = const Value.absent(),
            Value<bool> isEligibleBowler = const Value.absent(),
            Value<bool> isAvailable = const Value.absent(),
            Value<bool> addedToPermanentTeam = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int?> removedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MatchSquadMembersTableCompanion.insert(
            id: id,
            matchId: matchId,
            teamId: teamId,
            playerId: playerId,
            playerNameSnapshot: playerNameSnapshot,
            addedAfterMatchStart: addedAfterMatchStart,
            joinedAt: joinedAt,
            joinedInningsId: joinedInningsId,
            joinedOverNumber: joinedOverNumber,
            joinedDeliverySequence: joinedDeliverySequence,
            isEligibleBowler: isEligibleBowler,
            isAvailable: isAvailable,
            addedToPermanentTeam: addedToPermanentTeam,
            isActive: isActive,
            removedAt: removedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MatchSquadMembersTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $MatchSquadMembersTableTable,
        MatchSquadMembersTableData,
        $$MatchSquadMembersTableTableFilterComposer,
        $$MatchSquadMembersTableTableOrderingComposer,
        $$MatchSquadMembersTableTableAnnotationComposer,
        $$MatchSquadMembersTableTableCreateCompanionBuilder,
        $$MatchSquadMembersTableTableUpdateCompanionBuilder,
        (
          MatchSquadMembersTableData,
          BaseReferences<_$AppDatabase, $MatchSquadMembersTableTable,
              MatchSquadMembersTableData>
        ),
        MatchSquadMembersTableData,
        PrefetchHooks Function()>;
typedef $$MatchAwardsTableTableCreateCompanionBuilder
    = MatchAwardsTableCompanion Function({
  required String id,
  required String matchId,
  required String type,
  required String playerId,
  required String teamId,
  required String playerNameSnapshot,
  required String teamNameSnapshot,
  required String summary,
  Value<String> secondarySummary,
  required double rankingScore,
  required int createdAt,
  Value<bool> isManualOverride,
  Value<String?> overrideReason,
  Value<int> rowid,
});
typedef $$MatchAwardsTableTableUpdateCompanionBuilder
    = MatchAwardsTableCompanion Function({
  Value<String> id,
  Value<String> matchId,
  Value<String> type,
  Value<String> playerId,
  Value<String> teamId,
  Value<String> playerNameSnapshot,
  Value<String> teamNameSnapshot,
  Value<String> summary,
  Value<String> secondarySummary,
  Value<double> rankingScore,
  Value<int> createdAt,
  Value<bool> isManualOverride,
  Value<String?> overrideReason,
  Value<int> rowid,
});

class $$MatchAwardsTableTableFilterComposer
    extends Composer<_$AppDatabase, $MatchAwardsTableTable> {
  $$MatchAwardsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get matchId => $composableBuilder(
      column: $table.matchId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get playerId => $composableBuilder(
      column: $table.playerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get teamId => $composableBuilder(
      column: $table.teamId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get playerNameSnapshot => $composableBuilder(
      column: $table.playerNameSnapshot,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get teamNameSnapshot => $composableBuilder(
      column: $table.teamNameSnapshot,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get summary => $composableBuilder(
      column: $table.summary, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get secondarySummary => $composableBuilder(
      column: $table.secondarySummary,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get rankingScore => $composableBuilder(
      column: $table.rankingScore, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isManualOverride => $composableBuilder(
      column: $table.isManualOverride,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get overrideReason => $composableBuilder(
      column: $table.overrideReason,
      builder: (column) => ColumnFilters(column));
}

class $$MatchAwardsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $MatchAwardsTableTable> {
  $$MatchAwardsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get matchId => $composableBuilder(
      column: $table.matchId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get playerId => $composableBuilder(
      column: $table.playerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get teamId => $composableBuilder(
      column: $table.teamId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get playerNameSnapshot => $composableBuilder(
      column: $table.playerNameSnapshot,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get teamNameSnapshot => $composableBuilder(
      column: $table.teamNameSnapshot,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get summary => $composableBuilder(
      column: $table.summary, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get secondarySummary => $composableBuilder(
      column: $table.secondarySummary,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get rankingScore => $composableBuilder(
      column: $table.rankingScore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isManualOverride => $composableBuilder(
      column: $table.isManualOverride,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get overrideReason => $composableBuilder(
      column: $table.overrideReason,
      builder: (column) => ColumnOrderings(column));
}

class $$MatchAwardsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $MatchAwardsTableTable> {
  $$MatchAwardsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get matchId =>
      $composableBuilder(column: $table.matchId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get playerId =>
      $composableBuilder(column: $table.playerId, builder: (column) => column);

  GeneratedColumn<String> get teamId =>
      $composableBuilder(column: $table.teamId, builder: (column) => column);

  GeneratedColumn<String> get playerNameSnapshot => $composableBuilder(
      column: $table.playerNameSnapshot, builder: (column) => column);

  GeneratedColumn<String> get teamNameSnapshot => $composableBuilder(
      column: $table.teamNameSnapshot, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<String> get secondarySummary => $composableBuilder(
      column: $table.secondarySummary, builder: (column) => column);

  GeneratedColumn<double> get rankingScore => $composableBuilder(
      column: $table.rankingScore, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isManualOverride => $composableBuilder(
      column: $table.isManualOverride, builder: (column) => column);

  GeneratedColumn<String> get overrideReason => $composableBuilder(
      column: $table.overrideReason, builder: (column) => column);
}

class $$MatchAwardsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MatchAwardsTableTable,
    MatchAwardsTableData,
    $$MatchAwardsTableTableFilterComposer,
    $$MatchAwardsTableTableOrderingComposer,
    $$MatchAwardsTableTableAnnotationComposer,
    $$MatchAwardsTableTableCreateCompanionBuilder,
    $$MatchAwardsTableTableUpdateCompanionBuilder,
    (
      MatchAwardsTableData,
      BaseReferences<_$AppDatabase, $MatchAwardsTableTable,
          MatchAwardsTableData>
    ),
    MatchAwardsTableData,
    PrefetchHooks Function()> {
  $$MatchAwardsTableTableTableManager(
      _$AppDatabase db, $MatchAwardsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MatchAwardsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MatchAwardsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MatchAwardsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> matchId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> playerId = const Value.absent(),
            Value<String> teamId = const Value.absent(),
            Value<String> playerNameSnapshot = const Value.absent(),
            Value<String> teamNameSnapshot = const Value.absent(),
            Value<String> summary = const Value.absent(),
            Value<String> secondarySummary = const Value.absent(),
            Value<double> rankingScore = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<bool> isManualOverride = const Value.absent(),
            Value<String?> overrideReason = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MatchAwardsTableCompanion(
            id: id,
            matchId: matchId,
            type: type,
            playerId: playerId,
            teamId: teamId,
            playerNameSnapshot: playerNameSnapshot,
            teamNameSnapshot: teamNameSnapshot,
            summary: summary,
            secondarySummary: secondarySummary,
            rankingScore: rankingScore,
            createdAt: createdAt,
            isManualOverride: isManualOverride,
            overrideReason: overrideReason,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String matchId,
            required String type,
            required String playerId,
            required String teamId,
            required String playerNameSnapshot,
            required String teamNameSnapshot,
            required String summary,
            Value<String> secondarySummary = const Value.absent(),
            required double rankingScore,
            required int createdAt,
            Value<bool> isManualOverride = const Value.absent(),
            Value<String?> overrideReason = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MatchAwardsTableCompanion.insert(
            id: id,
            matchId: matchId,
            type: type,
            playerId: playerId,
            teamId: teamId,
            playerNameSnapshot: playerNameSnapshot,
            teamNameSnapshot: teamNameSnapshot,
            summary: summary,
            secondarySummary: secondarySummary,
            rankingScore: rankingScore,
            createdAt: createdAt,
            isManualOverride: isManualOverride,
            overrideReason: overrideReason,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MatchAwardsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MatchAwardsTableTable,
    MatchAwardsTableData,
    $$MatchAwardsTableTableFilterComposer,
    $$MatchAwardsTableTableOrderingComposer,
    $$MatchAwardsTableTableAnnotationComposer,
    $$MatchAwardsTableTableCreateCompanionBuilder,
    $$MatchAwardsTableTableUpdateCompanionBuilder,
    (
      MatchAwardsTableData,
      BaseReferences<_$AppDatabase, $MatchAwardsTableTable,
          MatchAwardsTableData>
    ),
    MatchAwardsTableData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TeamsTableTableTableManager get teamsTable =>
      $$TeamsTableTableTableManager(_db, _db.teamsTable);
  $$PlayersTableTableTableManager get playersTable =>
      $$PlayersTableTableTableManager(_db, _db.playersTable);
  $$TeamMembersTableTableTableManager get teamMembersTable =>
      $$TeamMembersTableTableTableManager(_db, _db.teamMembersTable);
  $$MatchesTableTableTableManager get matchesTable =>
      $$MatchesTableTableTableManager(_db, _db.matchesTable);
  $$DeliveriesTableTableTableManager get deliveriesTable =>
      $$DeliveriesTableTableTableManager(_db, _db.deliveriesTable);
  $$SyncQueueTableTableTableManager get syncQueueTable =>
      $$SyncQueueTableTableTableManager(_db, _db.syncQueueTable);
  $$ScoringAuditTableTableTableManager get scoringAuditTable =>
      $$ScoringAuditTableTableTableManager(_db, _db.scoringAuditTable);
  $$MatchSquadMembersTableTableTableManager get matchSquadMembersTable =>
      $$MatchSquadMembersTableTableTableManager(
          _db, _db.matchSquadMembersTable);
  $$MatchAwardsTableTableTableManager get matchAwardsTable =>
      $$MatchAwardsTableTableTableManager(_db, _db.matchAwardsTable);
}
