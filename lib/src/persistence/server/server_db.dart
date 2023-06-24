import 'package:isar/isar.dart';

part 'server_db.g.dart';

@collection
class ServerDB {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String name;
  String uri;

  ServerDB({required this.name, required this.uri});
}
