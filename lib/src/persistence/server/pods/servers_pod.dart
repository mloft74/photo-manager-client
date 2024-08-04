import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/domain/server.dart';
import 'package:photo_manager_client/src/errors/error_trace.dart';
import 'package:photo_manager_client/src/persistence/db_pod.dart';
import 'package:photo_manager_client/src/persistence/schemas/server.dart'
    as server_schema;
import 'package:photo_manager_client/src/persistence/server/models/server_db.dart';
import 'package:photo_manager_client/src/persistence/server/pods/selected_server_name_pod.dart';
import 'package:photo_manager_client/src/persistence/server/pods/servers_pod/models/remove_server_error.dart';
import 'package:photo_manager_client/src/persistence/server/pods/servers_pod/models/save_server_error.dart';
import 'package:photo_manager_client/src/persistence/server/pods/servers_pod/models/update_server_error.dart';
import 'package:photo_manager_client/src/state_management/async_notifier_async_rollback_update.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';

part 'servers_pod.g.dart';

typedef ServersState = IMap<String, Server>;
typedef SaveServerResult = Result<(), SaveServerError>;
typedef UpdateServerResult = Result<(), UpdateServerError>;
typedef RemoveServerResult = Result<(), RemoveServerError>;

@riverpod
final class Servers extends _$Servers
    with AsyncNotifierAsyncRollbackUpdate<ServersState> {
  @override
  Future<ServersState> build() async {
    final db = ref.watch(dbPod);
    final raw = await db.query(server_schema.tableName);
    final dbs = raw.map(ServerDB.fromDBMap);
    final domains = dbs.map((e) => e.toDomain()).whereSome();

    return Map.fromEntries(domains.map((e) => MapEntry(e.name, e))).lock;
  }

  Future<SaveServerResult> saveServer(Server server) async =>
      await updateWithRollbackSynchronized(
        onNoData: const NoDataSave(),
        update: (value) async {
          if (value.containsKey(server.name)) {
            return const Err(ServerNameInUse());
          }
          state = AsyncData(value.add(server.name, server));
          return await _handleSave(ref, server);
        },
      );

  Future<UpdateServerResult> updateServer(Server server) async =>
      await updateWithRollbackSynchronized(
        onNoData: const NoDataUpdate(),
        update: (value) async {
          if (!value.containsKey(server.name)) {
            return const Err(ServerNotFoundUpdate());
          }
          state = AsyncData(value.add(server.name, server));
          return await _handleUpdate(ref, server);
        },
      );

  Future<RemoveServerResult> removeServer(Server server) async =>
      await updateWithRollbackSynchronized(
        onNoData: const NoDataRemove(),
        update: (value) async {
          if (!value.containsKey(server.name)) {
            return const Err(ServerNotFoundRemove());
          }
          state = AsyncData(value.remove(server.name));
          return await _handleRemove(ref, server);
        },
      );
}

Future<SaveServerResult> _handleSave(
  AutoDisposeAsyncNotifierProviderRef<ServersState> ref,
  Server server,
) async {
  final db = ref.read(dbPod);
  final insertRes = await _insertServer(db, server);

  return insertRes.mapErr(SaveServerError.errorSaving);
}

Future<Result<(), ErrorTrace<Object>>> _insertServer(
  Database db,
  Server server,
) async {
  try {
    final serverDb = ServerDB.fromDomain(server);
    await db.insert(
      server_schema.tableName,
      serverDb.toDBMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return const Ok(());
  } catch (ex, st) {
    return Err(ErrorTrace(ex, Some(st)));
  }
}

Future<UpdateServerResult> _handleUpdate(
  AutoDisposeAsyncNotifierProviderRef<ServersState> ref,
  Server server,
) async {
  final db = ref.read(dbPod);
  final updateRes = await _updateServer(db, server);

  return updateRes.mapErr(UpdateServerError.errorUpdating);
}

Future<Result<(), ErrorTrace<Object>>> _updateServer(
  Database db,
  Server server,
) async {
  try {
    final serverDb = ServerDB.fromDomain(server);
    await db.update(
      server_schema.tableName,
      serverDb.toDBMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
      where: '${server_schema.nameCol} = ?',
      whereArgs: [serverDb.name],
    );
    return const Ok(());
  } catch (ex, st) {
    return Err(ErrorTrace(ex, Some(st)));
  }
}

Future<RemoveServerResult> _handleRemove(
  AutoDisposeAsyncNotifierProviderRef<ServersState> ref,
  Server server,
) async {
  final db = ref.read(dbPod);
  final removeRes = await _deleteServer(db, server);

  return await removeRes
      .mapErr(RemoveServerError.errorRemoving)
      .andThenAsync((value) async {
    final selectedName = ref.read(selectedServerNamePod).toNullable();
    if (selectedName == server.name) {
      final res = await ref
          .read(selectedServerNamePod.notifier)
          .setServerName(const None());
      return res.mapErr(ErrorUnsettingServer.new);
    } else {
      return const Ok(());
    }
  });
}

Future<Result<(), ErrorTrace<Object>>> _deleteServer(
  Database db,
  Server server,
) async {
  try {
    final serverDb = ServerDB.fromDomain(server);
    await db.delete(
      server_schema.tableName,
      where: '${server_schema.nameCol} = ?',
      whereArgs: [serverDb.name],
    );
    return const Ok(());
  } catch (ex, st) {
    return Err(ErrorTrace(ex, Some(st)));
  }
}
