import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/domain/server.dart';
import 'package:photo_manager_client/src/persistence/isar_provider.dart';
import 'package:photo_manager_client/src/persistence/server/models/selected_server_db.dart';
import 'package:photo_manager_client/src/persistence/server/models/server_db.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_server_provider.g.dart';

typedef CurrentServerState = Option<Server>;

@riverpod
class CurrentServer extends _$CurrentServer {
  @override
  FutureOr<CurrentServerState> build() async {
    final isar = ref.watch(isarProvider);
    final selectedServer =
        await isar.selectedServerDBs.get(SelectedServerDB.selectedId);
    final listener = isar.selectedServerDBs
        .watchObject(SelectedServerDB.selectedId)
        .asyncMap(
          (event) =>
              event.option.andThenAsync((value) => value.toDomainAsync()),
        )
        .listen(
      (event) {
        state = AsyncValue.data(event);
      },
    );
    ref.onDispose(listener.cancel);
    return await selectedServer.option
        .andThenAsync((value) => value.toDomainAsync());
  }

  Future<void> updateCurrent(Server server) async {
    final isar = ref.read(isarProvider);
    state = await AsyncValue.guard(
      () async {
        final (serverDb, selected) = await isar.txn(() async {
          final serverDb = await isar.serverDBs.getByName(server.name);
          final selected =
              await isar.selectedServerDBs.get(SelectedServerDB.selectedId);

          return (serverDb, selected);
        });

        await isar.writeTxn(() async {
          var innerSelected = selected;
          if (innerSelected == null) {
            innerSelected = SelectedServerDB();
            await isar.selectedServerDBs.put(innerSelected);
          }
          innerSelected.server.value = serverDb;
          await innerSelected.server.save();
        });

        return Some(server);
      },
    );
  }
}
