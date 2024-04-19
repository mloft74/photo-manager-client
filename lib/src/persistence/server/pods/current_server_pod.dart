import 'dart:async';

import 'package:isar/isar.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/domain/server.dart';
import 'package:photo_manager_client/src/errors/error_trace.dart';
import 'package:photo_manager_client/src/persistence/isar_pod.dart';
import 'package:photo_manager_client/src/persistence/server/models/selected_server_db.dart';
import 'package:photo_manager_client/src/persistence/server/models/server_db.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:synchronized/synchronized.dart';

part 'current_server_pod.g.dart';

typedef CurrentServerState = Option<Server>;
typedef SetCurrentServerResult = Result<(), ErrorTrace<Object>>;

@riverpod
final class CurrentServer extends _$CurrentServer {
  @override
  Future<CurrentServerState> build() async {
    final isar = ref.watch(isarPod);
    final res = await isar.selectedServerDBs
        .get(SelectedServerDB.selectedId)
        .toFutureOption();
    return res.andThen((value) => value.toDomain());
  }

  final _setServerLock = Lock();
  Future<SetCurrentServerResult> setServer(Server server) async {
    return await _setServerLock.synchronized(() async {
      final oldState = state;
      state = AsyncData(Some(server));

      final isar = ref.read(isarPod);
      final res = await _setCurrentServer(isar, server);

      if (res.isErr) {
        state = oldState;
      }

      return res;
    });
  }
}

Future<SetCurrentServerResult> _setCurrentServer(
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
