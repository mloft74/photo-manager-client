import 'package:isar/isar.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/domain/server.dart';
import 'package:photo_manager_client/src/errors/error_trace.dart';
import 'package:photo_manager_client/src/persistence/isar_pod.dart';
import 'package:photo_manager_client/src/persistence/server/models/selected_server_db.dart';
import 'package:photo_manager_client/src/persistence/server/models/server_db.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'remove_server_pod.g.dart';

typedef RemoveServerResult = Result<(), ErrorTrace<Object>>;

Future<RemoveServerResult> _removeServer(Isar isar, Server server) async {
  try {
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

    return const Ok(());
  } catch (ex, st) {
    return Err(ErrorTrace(ex, Some(st)));
  }
}

@riverpod
Future<RemoveServerResult> Function(Server server) removeServer(
  RemoveServerRef ref,
) {
  final isar = ref.watch(isarPod);
  return (server) => _removeServer(isar, server);
}
