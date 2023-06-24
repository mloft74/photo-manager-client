import 'package:isar/isar.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/domain/server.dart';
import 'package:photo_manager_client/src/persistence/server/models/server_db.dart';

part 'selected_server_db.g.dart';

@collection
class SelectedServerDB {
  static const Id selectedId = 0;
  final Id id = selectedId;

  final server = IsarLink<ServerDB>();

  Option<ServerDB> toDB() {
    return server.value.option;
  }

  Option<Server> toDomain() {
    return toDB().andThen((value) => value.toDomain());
  }
}
