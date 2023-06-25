import 'package:photo_manager_client/src/domain/server.dart';
import 'package:photo_manager_client/src/persistence/isar_provider.dart';
import 'package:photo_manager_client/src/persistence/server/models/selected_server_db.dart';
import 'package:photo_manager_client/src/persistence/server/models/server_db.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'update_current_server_provider.g.dart';

@riverpod
Future<void> updateCurrentServer(
  UpdateCurrentServerRef ref,
  Server server,
) async {
  final isar = ref.read(isarProvider);
  final (serverDb, selected) = await isar.txn(() async {
    final serverDb = await isar.serverDBs.getByName(server.name);
    final selected =
        await isar.selectedServerDBs.get(SelectedServerDB.selectedId);

    return (serverDb, selected ?? SelectedServerDB());
  });

  await isar.writeTxn(() async {
    await isar.selectedServerDBs.put(selected);
    selected.server.value = serverDb;
    await selected.server.save();
  });
}
