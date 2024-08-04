import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/domain/server.dart';
import 'package:photo_manager_client/src/persistence/schemas/server.dart'
    as server;

part 'server_db.freezed.dart';

@freezed
class ServerDB with _$ServerDB {
  const ServerDB._();

  const factory ServerDB({
    required String name,
    required String uri,
  }) = _ServerDB;

  factory ServerDB.fromDomain(Server server) =>
      ServerDB(name: server.name, uri: server.uri.toString());

  factory ServerDB.fromDBMap(Map<String, dynamic> json) {
    final {
      server.nameCol: String name,
      server.uriCol: String uri,
    } = json;
    return ServerDB(name: name, uri: uri);
  }

  Map<String, dynamic> toDBMap() {
    return {
      server.nameCol: name,
      server.uriCol: uri,
    };
  }

  Option<Server> toDomain() {
    return Uri.tryParse(uri)
        .toOption()
        .map((uri) => Server(name: name, uri: uri));
  }
}
