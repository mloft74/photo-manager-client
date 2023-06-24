import 'package:isar/isar.dart';

part 'server.g.dart';

@collection
class Server {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String name;
  String uri;

  Server({required this.name, required this.uri});
}
