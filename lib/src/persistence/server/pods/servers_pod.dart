import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:isar/isar.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/domain/server.dart';
import 'package:photo_manager_client/src/errors/error_trace.dart';
import 'package:photo_manager_client/src/persistence/isar_pod.dart';
import 'package:photo_manager_client/src/persistence/server/models/selected_server_db.dart';
import 'package:photo_manager_client/src/persistence/server/models/server_db.dart';
import 'package:photo_manager_client/src/persistence/server/pods/current_server_pod.dart';
import 'package:photo_manager_client/src/persistence/server/pods/servers_pod/models/remove_server_error.dart';
import 'package:photo_manager_client/src/persistence/server/pods/servers_pod/models/save_server_error.dart';
import 'package:photo_manager_client/src/persistence/server/pods/servers_pod/models/update_server_error.dart';
import 'package:photo_manager_client/src/state_management/async_notifier_async_rollback_update.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:synchronized/synchronized.dart';

part 'servers_pod.g.dart';

typedef ServersState = IMap<String, Server>;
typedef SaveServerResult = Result<(), SaveServerError>;
typedef _PersistServerResult = Result<_AffectedSelected, ErrorTrace<Object>>;
typedef UpdateServerResult = Result<(), UpdateServerError>;
typedef RemoveServerResult = Result<(), RemoveServerError>;
typedef _RemoveServerResult = Result<_AffectedSelected, ErrorTrace<Object>>;

@riverpod
final class Servers extends _$Servers
    with AsyncNotifierAsyncRollbackUpdate<ServersState> {
  @override
  Future<ServersState> build() async {
    final isar = ref.watch(isarPod);
    final dbs = await isar.serverDBs.where().findAll();
    final domains = dbs.map((element) => element.toDomain()).whereSome();
    return Map.fromEntries(domains.map((e) => MapEntry(e.name, e))).toIMap();
  }

  final _saveServerLock = Lock();
  Future<SaveServerResult> saveServer(Server server) async {
    return await _saveServerLock.synchronized(() async {
      return await updateWithRollback(
        onNoData: const NoDataSave(),
        update: (value) async {
          if (value.containsKey(server.name)) {
            return const Err(ServerNameInUse());
          }
          state = AsyncData(value.add(server.name, server));
          return await _handleSave(ref, server);
        },
      );
    });
  }

  final _updateServerLock = Lock();
  Future<UpdateServerResult> updateServer(Server server) async {
    return await _updateServerLock.synchronized(() async {
      return await updateWithRollback(
        onNoData: const NoDataUpdate(),
        update: (value) async {
          if (!value.containsKey(server.name)) {
            return const Err(ServerNotFoundUpdate());
          }
          state = AsyncData(value.add(server.name, server));
          return await _handleUpdate(ref, server);
        },
      );
    });
  }

  final _removeServerLock = Lock();
  Future<RemoveServerResult> removeServer(Server server) async {
    return await _removeServerLock.synchronized(() async {
      return await updateWithRollback(
        onNoData: const NoDataRemove(),
        update: (value) async {
          if (!value.containsKey(server.name)) {
            return const Err(ServerNotFoundRemove());
          }
          state = AsyncData(value.remove(server.name));
          return await _handleRemove(ref, server);
        },
      );
    });
  }
}

Future<SaveServerResult> _handleSave(
  AutoDisposeAsyncNotifierProviderRef<ServersState> ref,
  Server server,
) async {
  final isar = ref.read(isarPod);
  final persistRes = await _persistServer(isar, server);

  return await persistRes
      .mapErr(SaveServerError.errorSaving)
      .andThenAsync((value) async {
    switch (value) {
      case _AffectedSelected.selectedNotAffected:
        return const Ok(());
      case _AffectedSelected.selectedAffected:
        final res =
            await ref.read(currentServerPod.notifier).setServer(Some(server));
        return res.mapErr(ErrorSettingServerSave.new);
    }
  });
}

Future<_PersistServerResult> _persistServer(
  Isar isar,
  Server server,
) async {
  try {
    final currentServer =
        await isar.selectedServerDBs.get(SelectedServerDB.selectedId);
    // This load needs to be performed outside of the transaction,
    // because Isar does not support nested transactions.
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

Future<UpdateServerResult> _handleUpdate(
  AutoDisposeAsyncNotifierProviderRef<ServersState> ref,
  Server server,
) async {
  final isar = ref.read(isarPod);
  final persistRes = await _persistServer(isar, server);

  return await persistRes
      .mapErr(UpdateServerError.errorUpdating)
      .andThenAsync((value) async {
    switch (value) {
      case _AffectedSelected.selectedNotAffected:
        return const Ok(());
      case _AffectedSelected.selectedAffected:
        final res =
            await ref.read(currentServerPod.notifier).setServer(Some(server));
        return res.mapErr(ErrorSettingServerUpdate.new);
    }
  });
}

Future<RemoveServerResult> _handleRemove(
  AutoDisposeAsyncNotifierProviderRef<ServersState> ref,
  Server server,
) async {
  final isar = ref.read(isarPod);
  final removeRes = await _removeServer(isar, server);

  return await removeRes
      .mapErr(RemoveServerError.errorRemoving)
      .andThenAsync((value) async {
    switch (value) {
      case _AffectedSelected.selectedNotAffected:
        return const Ok(());
      case _AffectedSelected.selectedAffected:
        final res =
            await ref.read(currentServerPod.notifier).setServer(const None());
        return res.mapErr(ErrorUnsettingServer.new);
    }
  });
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
