import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:isar/isar.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/domain/server.dart';
import 'package:photo_manager_client/src/errors/error_trace.dart';
import 'package:photo_manager_client/src/persistence/isar_pod.dart';
import 'package:photo_manager_client/src/persistence/server/models/selected_server_db.dart';
import 'package:photo_manager_client/src/persistence/server/models/server_db.dart';
import 'package:photo_manager_client/src/persistence/server/pods/current_server_pod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:synchronized/synchronized.dart';

part 'servers_pod.freezed.dart';
part 'servers_pod.g.dart';

typedef SaveServerResult = Result<(), SaveServerError>;
typedef _SaveServerResult = Result<_AffectedSelected, ErrorTrace<Object>>;
typedef RemoveServerResult = Result<(), ErrorTrace<Object>>;
typedef _RemoveServerResult = Result<_AffectedSelected, ErrorTrace<Object>>;

@riverpod
final class Servers extends _$Servers {
  @override
  Future<IList<Server>> build() async {
    final isar = ref.watch(isarPod);
    final dbs = await isar.serverDBs.where().findAll();
    return dbs.map((element) => element.toDomain()).whereSome().toIList();
  }

  final _saveServerLock = Lock();
  Future<SaveServerResult> saveServer(Server server) async {
    return await _saveServerLock.synchronized(() async {
      final oldState = state;
      final lifted = Ok<Server, SaveServerError>(server);
      final x = await lifted
          .andThen(
        (server) => state.value
            .toOption()
            .map((servers) => (server, servers))
            .okOr(const NoData()),
      )
          .andThenAsync((env) async {
        state = AsyncData(env.$2.add(env.$1));
        final isar = ref.read(isarPod);
        final res = await _saveServer(isar, env.$1);
        return res
            .map((affected) => (env.$1, env.$2, affected))
            .mapErr(ErrorSaving.new);
      });
      final y = await x.andThenAsync((env) async {
        switch (env.$3) {
          case _AffectedSelected.selectedNotAffected:
            return const Ok(());
          case _AffectedSelected.selectedAffected:
            final res = await ref
                .read(currentServerPod.notifier)
                .setServer(Some(env.$1));
            return res.mapErr(ErrorSettingServer.new);
        }
      });
      if (y.isErr) {
        state = oldState;
      }
      return y;
    });
  }

  final _removeServerLock = Lock();
  // TODO(mloft74): reset state on failure
  Future<RemoveServerResult> removeServer(Server server) async {
    return await _removeServerLock.synchronized(() async {
      final isar = ref.read(isarPod);
      final res = await _removeServer(isar, server);
      switch (res) {
        case Ok(:final value):
          switch (value) {
            case _AffectedSelected.selectedNotAffected:
              return const Ok(());
            case _AffectedSelected.selectedAffected:
              final res = await ref
                  .read(currentServerPod.notifier)
                  .setServer(const None());
              // TODO(mloft74): make dedicated error type for removing
              return res;
          }
        case Err(:final error):
          // TODO(mloft74): make dedicated error type for removing
          return Err(error);
      }
    });
  }
}

Future<_SaveServerResult> _saveServer(
  Isar isar,
  Server server,
) async {
  try {
    final currentServer =
        await isar.selectedServerDBs.get(SelectedServerDB.selectedId);
    await currentServer?.server.load();
    final affected = await isar.writeTxn(
      () async {
        final serverDb = ServerDB.fromDomain(server);
        await isar.serverDBs.put(serverDb);
        if (currentServer != null &&
            currentServer.server.value?.name == server.name) {
          await isar.selectedServerDBs.put(currentServer);
          currentServer.server.value = serverDb;
          await currentServer.server.save();
          return _AffectedSelected.selectedAffected;
        } else {
          return _AffectedSelected.selectedNotAffected;
        }
      },
    );

    return Ok(affected);
  } catch (ex, st) {
    return Err(ErrorTrace(ex, Some(st)));
  }
}

Future<_RemoveServerResult> _removeServer(Isar isar, Server server) async {
  try {
    final selected =
        await isar.selectedServerDBs.get(SelectedServerDB.selectedId);
    // This load needs to be performed outside of the transaction,
    // because Isar does not support nested transactions.
    await selected?.server.load();
    final affected = await isar.writeTxn(() async {
      final innerSelected = selected ?? SelectedServerDB();
      final _AffectedSelected affected;
      if (innerSelected.server.value?.name == server.name) {
        await isar.selectedServerDBs.put(innerSelected);
        innerSelected.server.value = null;
        await innerSelected.server.save();
        affected = _AffectedSelected.selectedAffected;
      } else {
        affected = _AffectedSelected.selectedNotAffected;
      }
      await isar.serverDBs.deleteByName(server.name);
      return affected;
    });

    return Ok(affected);
  } catch (ex, st) {
    return Err(ErrorTrace(ex, Some(st)));
  }
}

enum _AffectedSelected {
  selectedAffected,
  selectedNotAffected,
}

@freezed
sealed class SaveServerError with _$SaveServerError {
  const factory SaveServerError.noData() = NoData;

  const factory SaveServerError.errorSaving(ErrorTrace<Object> errorTrace) =
      ErrorSaving;

  const factory SaveServerError.errorSettingServer(
    ErrorTrace<Object> errorTrace,
  ) = ErrorSettingServer;
}
