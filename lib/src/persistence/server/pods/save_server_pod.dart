import 'package:isar/isar.dart';
import 'package:photo_manager_client/src/domain/server.dart';
import 'package:photo_manager_client/src/persistence/isar_pod.dart';
import 'package:photo_manager_client/src/persistence/server/models/server_db.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'save_server_pod.g.dart';

Future<void> _saveServer(Isar isar, Server server) async {
  await isar.writeTxn(
    () async {
      await isar.serverDBs
          .put(ServerDB(name: server.name, uri: '${server.uri}'));
    },
  );
}

@riverpod
Future<void> Function(Server server) saveServer(SaveServerRef ref) {
  final isar = ref.watch(isarPod);
  return (server) => _saveServer(isar, server);
}
