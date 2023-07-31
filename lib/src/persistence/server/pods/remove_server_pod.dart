import 'package:isar/isar.dart';
import 'package:photo_manager_client/src/domain/server.dart';
import 'package:photo_manager_client/src/persistence/isar_pod.dart';
import 'package:photo_manager_client/src/persistence/server/models/selected_server_db.dart';
import 'package:photo_manager_client/src/persistence/server/models/server_db.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'remove_server_pod.g.dart';

Future<()> _removeServer(Isar isar, Server server) async {
  final selected =
      await isar.selectedServerDBs.get(SelectedServerDB.selectedId);
  // This load needs to be performed outside of the transaction,
  // because Isar does not support nested transactions.
  await selected?.server.load();
  await isar.writeTxn(() async {
    final innerSelected = selected ?? SelectedServerDB();
    if (innerSelected.server.value?.name == server.name) {
      await isar.selectedServerDBs.put(innerSelected);
      innerSelected.server.value = null;
      await innerSelected.server.save();
    }
    await isar.serverDBs.deleteByName(server.name);
  });

  return ();
}

@riverpod
Future<()> Function(Server server) removeServer(RemoveServerRef ref) {
  final isar = ref.watch(isarPod);
  return (server) => _removeServer(isar, server);
}
