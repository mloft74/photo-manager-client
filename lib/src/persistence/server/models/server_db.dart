import 'package:isar/isar.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/domain/server.dart';

part 'server_db.g.dart';

@collection
class ServerDB {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String name;
  String uri;

  ServerDB({required this.name, required this.uri});

  ServerDB.fromDomain(Server server)
      : this(name: server.name, uri: server.uri.toString());

  Option<Server> toDomain() {
    return Uri.tryParse(uri)
        .toOption()
        .map((uri) => Server(name: name, uri: uri));
  }
}
