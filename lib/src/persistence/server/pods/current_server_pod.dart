import 'dart:async';

import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/domain/server.dart';
import 'package:photo_manager_client/src/errors/error_trace.dart';
import 'package:photo_manager_client/src/persistence/db_pod.dart';
import 'package:photo_manager_client/src/persistence/server/models/selected_server_db.dart';
import 'package:photo_manager_client/src/persistence/server/models/server_db.dart';
import 'package:photo_manager_client/src/persistence/server/pods/current_server_pod/models/set_current_server_error.dart';
import 'package:photo_manager_client/src/state_management/async_notifier_async_rollback_update.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_server_pod.g.dart';

typedef CurrentServerState = Option<Server>;
typedef SetCurrentServerResult = Result<(), SetCurrentServerError>;
typedef _SetCurrentServerResult = Result<(), ErrorTrace<Object>>;

@riverpod
final class CurrentServer extends _$CurrentServer
    with AsyncNotifierAsyncRollbackUpdate<CurrentServerState> {
  @override
  Future<CurrentServerState> build() async {
    final db = ref.watch(dbPod);
    final res = await db.selectedServerDBs
        .get(SelectedServerDB.selectedId)
        .toFutureOption();
    return res.andThen((value) => value.toDomain());
  }

  Future<SetCurrentServerResult> setServer(Option<Server> server) async =>
      await updateWithRollbackSynchronized(
        onNoData: const NoData(),
        update: (value) async {
          state = AsyncData(server);
          final isar = ref.read(isarPod);
          return switch (server) {
            Some(:final value) => await _setCurrentServer(isar, value),
            None() => await _unsetCurrentServer(isar),
          }
              .mapErr(ErrorOccurred.new);
        },
      );
}

Future<_SetCurrentServerResult> _setCurrentServer(
  Isar isar,
  Server server,
) async {
  try {
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

    return const Ok(());
  } catch (ex, st) {
    return Err(ErrorTrace(ex, Some(st)));
  }
}

Future<_SetCurrentServerResult> _unsetCurrentServer(
  Isar isar,
) async {
  try {
    final selected =
        await isar.selectedServerDBs.get(SelectedServerDB.selectedId);

    await isar.writeTxn(() async {
      final innerSelected = selected ?? SelectedServerDB();
      await isar.selectedServerDBs.put(innerSelected);
      innerSelected.server.value = null;
      await innerSelected.server.save();
    });

    return const Ok(());
  } catch (ex, st) {
    return Err(ErrorTrace(ex, Some(st)));
  }
}
