import 'dart:async';
import 'package:analyzer/dart/element/element.dart';
import 'package:angel_model/angel_model.dart';
import 'package:angel_orm/angel_orm.dart';
import 'package:angel_serialize_generator/angel_serialize_generator.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:source_gen/source_gen.dart' hide LibraryBuilder;
import 'orm_build_context.dart';

Builder migrationBuilder(BuilderOptions options) {
  return new SharedPartBuilder([
    new MigrationGenerator(
        autoSnakeCaseNames: options.config['auto_snake_case_names'] != false)
  ], 'angel_migration');
}

class MigrationGenerator extends GeneratorForAnnotation<Orm> {
  static final Parameter _schemaParam = new Parameter((b) => b
    ..name = 'schema'
    ..type = refer('Schema'));
  static final Reference _schema = refer('schema');

  /// If `true` (default), then field names will automatically be (de)serialized as snake_case.
  final bool autoSnakeCaseNames;

  const MigrationGenerator({this.autoSnakeCaseNames: true});

  @override
  Future<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) async {
    if (element is! ClassElement)
      throw 'Only classes can be annotated with @ORM().';

    var generateMigrations =
        annotation.peek('generateMigrations')?.boolValue ?? true;

    if (!generateMigrations) {
      return null;
    }

    var resolver = await buildStep.resolver;
    var ctx = await buildOrmContext(element as ClassElement, annotation,
        buildStep, resolver, autoSnakeCaseNames != false);
    var lib = generateMigrationLibrary(
        ctx, element as ClassElement, resolver, buildStep);
    if (lib == null) return null;
    return new DartFormatter().format(lib.accept(new DartEmitter()).toString());
  }

  Library generateMigrationLibrary(OrmBuildContext ctx, ClassElement element,
      Resolver resolver, BuildStep buildStep) {
    return new Library((lib) {
      lib.body.add(new Class((clazz) {
        clazz
          ..name = '${ctx.buildContext.modelClassName}Migration'
          ..extend = refer('Migration')
          ..methods
              .addAll([buildUpMigration(ctx, lib), buildDownMigration(ctx)]);
      }));
    });
  }

  Method buildUpMigration(OrmBuildContext ctx, LibraryBuilder lib) {
    return new Method((meth) {
      var autoIdAndDateFields = const TypeChecker.fromRuntime(Model)
          .isAssignableFromType(ctx.buildContext.clazz.type);
      meth
        ..name = 'up'
        ..annotations.add(refer('override'))
        ..requiredParameters.add(_schemaParam);

      //var closure = new Method.closure()..addPositional(parameter('table'));
      var closure = new Method((closure) {
        closure
          ..requiredParameters.add(new Parameter((b) => b..name = 'table'))
          ..body = new Block((closureBody) {
            var table = refer('table');

            List<String> dup = [];
            ctx.columns.forEach((name, col) {
              var key = ctx.buildContext.resolveFieldName(name);

              if (dup.contains(key))
                return;
              else {
                if (key != 'id' || autoIdAndDateFields == false) {
                  // Check for relationships that might duplicate
                  for (var rName in ctx.relations.keys) {
                    var relationship = ctx.relations[rName];
                    if (relationship.localKey == key) return;
                  }
                }

                dup.add(key);
              }

              String methodName;
              List<Expression> positional = [literal(key)];
              Map<String, Expression> named = {};

              if (autoIdAndDateFields != false && name == 'id')
                methodName = 'serial';

              if (methodName == null) {
                switch (col.type) {
                  case ColumnType.varChar:
                    methodName = 'varChar';
                    if (col.length != null)
                      named['length'] = literal(col.length);
                    break;
                  case ColumnType.serial:
                    methodName = 'serial';
                    break;
                  case ColumnType.int:
                    methodName = 'integer';
                    break;
                  case ColumnType.float:
                    methodName = 'float';
                    break;
                  case ColumnType.numeric:
                    methodName = 'numeric';
                    break;
                  case ColumnType.boolean:
                    methodName = 'boolean';
                    break;
                  case ColumnType.date:
                    methodName = 'date';
                    break;
                  case ColumnType.dateTime:
                    methodName = 'dateTime';
                    break;
                  case ColumnType.timeStamp:
                    methodName = 'timeStamp';
                    break;
                  default:
                    Expression provColumn;
                    var colType = refer('Column');
                    var columnTypeType = refer('ColumnType');

                    if (col.length == null) {
                      methodName = 'declare';
                      provColumn = columnTypeType.newInstance([
                        literal(col.type.name),
                      ]);
                    } else {
                      methodName = 'declareColumn';
                      provColumn = colType.newInstance([], {
                        'type': columnTypeType.newInstance([
                          literal(col.type.name),
                        ]),
                        'length': literal(col.length),
                      });
                    }

                    positional.add(provColumn);
                    break;
                }
              }

              var field = table.property(methodName).call(positional, named);
              var cascade = <Expression>[];

              var defaultValue = ctx.buildContext.defaults[name];

              if (defaultValue != null) {
                cascade.add(refer('defaultsTo').call([
                  new CodeExpression(
                    new Code(dartObjectToString(defaultValue)),
                  ),
                ]));
              }

              if (col.indexType == IndexType.primaryKey ||
                  (autoIdAndDateFields != false && name == 'id')) {
                cascade.add(refer('primaryKey').call([]));
              } else if (col.indexType == IndexType.unique) {
                cascade.add(refer('unique').call([]));
              }

              if (col.isNullable != true)
                cascade.add(refer('notNull').call([]));

              if (cascade.isNotEmpty) {
                var b = new StringBuffer()
                  ..writeln(field.accept(new DartEmitter()));

                for (var ex in cascade) {
                  b
                    ..write('..')
                    ..writeln(ex.accept(new DartEmitter()));
                }

                field = new CodeExpression(new Code(b.toString()));
              }

              closureBody.addExpression(field);
            });

            ctx.relations.forEach((name, r) {
              var relationship = r;

              if (relationship.type == RelationshipType.belongsTo) {
                var key = relationship.localKey;

                var field = table.property('integer').call([literal(key)]);
                // .references('user', 'id').onDeleteCascade()
                var ref = field.property('references').call([
                  literal(relationship.foreignTable),
                  literal(relationship.foreignKey),
                ]);

                if (relationship.cascadeOnDelete != false &&
                    const [RelationshipType.hasOne, RelationshipType.belongsTo]
                        .contains(relationship.type))
                  ref = ref.property('onDeleteCascade').call([]);
                closureBody.addExpression(ref);
              }
            });
          });
      });

      meth.body = new Block((b) {
        b.addExpression(_schema.property('create').call([
          literal(ctx.tableName),
          closure.closure,
        ]));
      });
    });
  }

  Method buildDownMigration(OrmBuildContext ctx) {
    return new Method((b) {
      b
        ..name = 'down'
        ..annotations.add(refer('override'))
        ..requiredParameters.add(_schemaParam)
        ..body = new Block((b) {
          b.addExpression(
              _schema.property('drop').call([literalString(ctx.tableName)]));
        });
    });
  }
}
