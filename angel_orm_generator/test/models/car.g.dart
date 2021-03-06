// GENERATED CODE - DO NOT MODIFY BY HAND

part of angel_orm.generator.models.car;

// **************************************************************************
// MigrationGenerator
// **************************************************************************

class CarMigration extends Migration {
  @override
  up(Schema schema) {
    schema.create('cars', (table) {
      table.serial('id')..primaryKey();
      table.varChar('make');
      table.varChar('description');
      table.boolean('family_friendly');
      table.timeStamp('recalled_at');
      table.timeStamp('created_at');
      table.timeStamp('updated_at');
    });
  }

  @override
  down(Schema schema) {
    schema.drop('cars');
  }
}

// **************************************************************************
// OrmGenerator
// **************************************************************************

class CarQuery extends Query<Car, CarQueryWhere> {
  CarQuery({Set<String> trampoline}) {
    trampoline ??= Set();
    trampoline.add(tableName);
    _where = new CarQueryWhere(this);
  }

  @override
  final CarQueryValues values = new CarQueryValues();

  CarQueryWhere _where;

  @override
  get casts {
    return {};
  }

  @override
  get tableName {
    return 'cars';
  }

  @override
  get fields {
    return const [
      'id',
      'make',
      'description',
      'family_friendly',
      'recalled_at',
      'created_at',
      'updated_at'
    ];
  }

  @override
  CarQueryWhere get where {
    return _where;
  }

  @override
  CarQueryWhere newWhereClause() {
    return new CarQueryWhere(this);
  }

  static Car parseRow(List row) {
    if (row.every((x) => x == null)) return null;
    var model = new Car(
        id: row[0].toString(),
        make: (row[1] as String),
        description: (row[2] as String),
        familyFriendly: (row[3] as bool),
        recalledAt: (row[4] as DateTime),
        createdAt: (row[5] as DateTime),
        updatedAt: (row[6] as DateTime));
    return model;
  }

  @override
  deserialize(List row) {
    return parseRow(row);
  }
}

class CarQueryWhere extends QueryWhere {
  CarQueryWhere(CarQuery query)
      : id = new NumericSqlExpressionBuilder<int>(query, 'id'),
        make = new StringSqlExpressionBuilder(query, 'make'),
        description = new StringSqlExpressionBuilder(query, 'description'),
        familyFriendly =
            new BooleanSqlExpressionBuilder(query, 'family_friendly'),
        recalledAt = new DateTimeSqlExpressionBuilder(query, 'recalled_at'),
        createdAt = new DateTimeSqlExpressionBuilder(query, 'created_at'),
        updatedAt = new DateTimeSqlExpressionBuilder(query, 'updated_at');

  final NumericSqlExpressionBuilder<int> id;

  final StringSqlExpressionBuilder make;

  final StringSqlExpressionBuilder description;

  final BooleanSqlExpressionBuilder familyFriendly;

  final DateTimeSqlExpressionBuilder recalledAt;

  final DateTimeSqlExpressionBuilder createdAt;

  final DateTimeSqlExpressionBuilder updatedAt;

  @override
  get expressionBuilders {
    return [
      id,
      make,
      description,
      familyFriendly,
      recalledAt,
      createdAt,
      updatedAt
    ];
  }
}

class CarQueryValues extends MapQueryValues {
  @override
  get casts {
    return {};
  }

  int get id {
    return (values['id'] as int);
  }

  set id(int value) => values['id'] = value;
  String get make {
    return (values['make'] as String);
  }

  set make(String value) => values['make'] = value;
  String get description {
    return (values['description'] as String);
  }

  set description(String value) => values['description'] = value;
  bool get familyFriendly {
    return (values['family_friendly'] as bool);
  }

  set familyFriendly(bool value) => values['family_friendly'] = value;
  DateTime get recalledAt {
    return (values['recalled_at'] as DateTime);
  }

  set recalledAt(DateTime value) => values['recalled_at'] = value;
  DateTime get createdAt {
    return (values['created_at'] as DateTime);
  }

  set createdAt(DateTime value) => values['created_at'] = value;
  DateTime get updatedAt {
    return (values['updated_at'] as DateTime);
  }

  set updatedAt(DateTime value) => values['updated_at'] = value;
  void copyFrom(Car model) {
    make = model.make;
    description = model.description;
    familyFriendly = model.familyFriendly;
    recalledAt = model.recalledAt;
    createdAt = model.createdAt;
    updatedAt = model.updatedAt;
  }
}

// **************************************************************************
// JsonModelGenerator
// **************************************************************************

@generatedSerializable
class Car extends _Car {
  Car(
      {this.id,
      this.make,
      this.description,
      this.familyFriendly,
      this.recalledAt,
      this.createdAt,
      this.updatedAt});

  @override
  final String id;

  @override
  final String make;

  @override
  final String description;

  @override
  final bool familyFriendly;

  @override
  final DateTime recalledAt;

  @override
  final DateTime createdAt;

  @override
  final DateTime updatedAt;

  Car copyWith(
      {String id,
      String make,
      String description,
      bool familyFriendly,
      DateTime recalledAt,
      DateTime createdAt,
      DateTime updatedAt}) {
    return new Car(
        id: id ?? this.id,
        make: make ?? this.make,
        description: description ?? this.description,
        familyFriendly: familyFriendly ?? this.familyFriendly,
        recalledAt: recalledAt ?? this.recalledAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt);
  }

  bool operator ==(other) {
    return other is _Car &&
        other.id == id &&
        other.make == make &&
        other.description == description &&
        other.familyFriendly == familyFriendly &&
        other.recalledAt == recalledAt &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return hashObjects([
      id,
      make,
      description,
      familyFriendly,
      recalledAt,
      createdAt,
      updatedAt
    ]);
  }

  Map<String, dynamic> toJson() {
    return CarSerializer.toMap(this);
  }
}

// **************************************************************************
// SerializerGenerator
// **************************************************************************

abstract class CarSerializer {
  static Car fromMap(Map map) {
    return new Car(
        id: map['id'] as String,
        make: map['make'] as String,
        description: map['description'] as String,
        familyFriendly: map['family_friendly'] as bool,
        recalledAt: map['recalled_at'] != null
            ? (map['recalled_at'] is DateTime
                ? (map['recalled_at'] as DateTime)
                : DateTime.parse(map['recalled_at'].toString()))
            : null,
        createdAt: map['created_at'] != null
            ? (map['created_at'] is DateTime
                ? (map['created_at'] as DateTime)
                : DateTime.parse(map['created_at'].toString()))
            : null,
        updatedAt: map['updated_at'] != null
            ? (map['updated_at'] is DateTime
                ? (map['updated_at'] as DateTime)
                : DateTime.parse(map['updated_at'].toString()))
            : null);
  }

  static Map<String, dynamic> toMap(_Car model) {
    if (model == null) {
      return null;
    }
    return {
      'id': model.id,
      'make': model.make,
      'description': model.description,
      'family_friendly': model.familyFriendly,
      'recalled_at': model.recalledAt?.toIso8601String(),
      'created_at': model.createdAt?.toIso8601String(),
      'updated_at': model.updatedAt?.toIso8601String()
    };
  }
}

abstract class CarFields {
  static const List<String> allFields = const <String>[
    id,
    make,
    description,
    familyFriendly,
    recalledAt,
    createdAt,
    updatedAt
  ];

  static const String id = 'id';

  static const String make = 'make';

  static const String description = 'description';

  static const String familyFriendly = 'family_friendly';

  static const String recalledAt = 'recalled_at';

  static const String createdAt = 'created_at';

  static const String updatedAt = 'updated_at';
}
