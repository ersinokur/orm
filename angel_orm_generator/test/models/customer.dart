library angel_orm_generator.test.models.customer;

import 'package:angel_migration/angel_migration.dart';
import 'package:angel_model/angel_model.dart';
import 'package:angel_orm/angel_orm.dart';
import 'package:angel_serialize/angel_serialize.dart';
part 'customer.g.dart';

@orm
@serializable
class _Customer extends Model {}
