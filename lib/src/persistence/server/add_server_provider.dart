import 'package:photo_manager_client/src/domain/server.dart';
import 'package:photo_manager_client/src/persistence/isar_provider.dart';
import 'package:photo_manager_client/src/persistence/server/server_db.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'add_server_provider.g.dart';

@riverpod
Future<void> addServer(AddServerRef ref, Server server) async {
  final isar = ref.watch(isarProvider);
  await isar.writeTxn(
    () => isar.serverDBs.put(ServerDB(name: server.name, uri: '${server.uri}')),
  );
}
