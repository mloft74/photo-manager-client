import 'package:photo_manager_client/src/persistence/schemas/server.dart'
    as server;
import 'package:sqflite/sqflite.dart';

void createTableServerV1(Batch batch) {
  const tableName = server.tableName;
  batch
    ..execute('DROP TABLE IF EXISTS $tableName')
    ..execute(
      'CREATE TABLE $tableName('
      '  ${server.idCol} INTEGER PRIMARY KEY AUTOINCREMENT,'
      '  ${server.nameCol} TEXT,'
      '  ${server.uriCol} TEXT'
      '  )',
    )
    ..execute(
      'CREATE UNIQUE INDEX ${server.nameIdx}'
      '  ON $tableName(${server.nameCol})',
    );
}
