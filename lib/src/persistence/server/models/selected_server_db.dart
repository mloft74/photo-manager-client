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

  Future<Option<ServerDB>> toDBAsync() async {
    await server.load();
    return server.value.option;
  }

  Future<Option<Server>> toDomainAsync() async {
    return (await toDBAsync()).andThen((value) => value.toDomain());
  }
}
