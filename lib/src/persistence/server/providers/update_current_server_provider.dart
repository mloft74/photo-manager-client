import 'package:isar/isar.dart';
import 'package:photo_manager_client/src/domain/server.dart';
import 'package:photo_manager_client/src/persistence/isar_provider.dart';
import 'package:photo_manager_client/src/persistence/server/models/selected_server_db.dart';
import 'package:photo_manager_client/src/persistence/server/models/server_db.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'update_current_server_provider.g.dart';

Future<void> _updateCurrentServer(Isar isar, Server server) async {
  final (serverDb, selected) = await isar.txn(() async {
    final serverDb = await isar.serverDBs.getByName(server.name);
    final selected =
        await isar.selectedServerDBs.get(SelectedServerDB.selectedId);

    return (serverDb, selected);
  });

  await isar.writeTxn(() async {
    final innerSelected = selected ?? SelectedServerDB();
    await isar.selectedServerDBs.put(innerSelected);
    innerSelected.server.value = serverDb;
    await innerSelected.server.save();
  });
}

@riverpod
Future<void> Function(Server server) updateCurrentServer(
  UpdateCurrentServerRef ref,
) {
  final isar = ref.watch(isarProvider);

  return (server) => _updateCurrentServer(isar, server);
}
