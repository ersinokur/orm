library angel_orm_generator.test.models.foot;

import 'package:angel_migration/angel_migration.dart';
import 'package:angel_model/angel_model.dart';
import 'package:angel_orm/angel_orm.dart';
import 'package:angel_serialize/angel_serialize.dart';
part 'foot.g.dart';

@serializable
@Orm(tableName: 'feet')
class _Foot extends Model {
  int legId;

  double nToes;
}
