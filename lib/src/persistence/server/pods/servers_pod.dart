import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/domain/server.dart';
import 'package:photo_manager_client/src/errors/displayable.dart';
import 'package:photo_manager_client/src/errors/error_trace.dart';
import 'package:photo_manager_client/src/extensions/partition_extension.dart';
import 'package:photo_manager_client/src/persistence/db_pod.dart';
import 'package:photo_manager_client/src/persistence/schemas/server.dart'
    as server_schema;
import 'package:photo_manager_client/src/persistence/server/models/server_db.dart';
import 'package:photo_manager_client/src/persistence/server/pods/selected_server_pod.dart';
import 'package:photo_manager_client/src/persistence/server/pods/servers_pod/models/remove_server_error.dart';
import 'package:photo_manager_client/src/persistence/server/pods/servers_pod/models/save_server_error.dart';
import 'package:photo_manager_client/src/persistence/server/pods/servers_pod/models/update_server_error.dart';
import 'package:photo_manager_client/src/pods/logs_pod.dart';
import 'package:photo_manager_client/src/pods/models/log_topic.dart';
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
    final (
      pass: domains,
      fail: errors
    ) = dbs.map((e) => e.toDomain()).partitionMap(
          test: (val) => val.isOk,
          onPass: (val) =>
              val.expect('Should have checked for Ok in test for partionMap'),
          onFail: (val) => val.expectErr(
            'Should have checked for Ok in test for partionMap (inverted since this is failure path)',
          ),
        );
    final logger = ref.read(logsPod.notifier);
    for (final e in errors) {
      logger.logError(
        LogTopic.parsing,
        CompoundDisplayable(
          IList([
            const DefaultDisplayable(
              IListConst(['Could not parse server']),
            ),
            e,
          ]),
        ),
      );
    }

    return Map.fromEntries(domains.map((e) => MapEntry(e.name, e))).lock;
  }

  Future<SaveServerResult> saveServer(Server server) async =>
      await updateWithRollbackSynchronized(
        onNoData: const NoDataSave(),
        update: (value) async {
          if (value.containsKey(server.name)) {
            return Err(ServerNameInUse(server.name));
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
            return Err(ServerNotFoundUpdate(server.name));
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
            return Err(ServerNotFoundRemove(server.name));
          }
          state = AsyncData(value.remove(server.name));
          return await _handleRemove(ref, server);
        },
      );
}

Future<SaveServerResult> _handleSave(
  Ref ref,
  Server server,
) async {
  final db = ref.read(dbPod);
  final insertRes = await _insertServer(db, server);

  return insertRes.mapErr(SaveServerError.errorSaving).andThenAsync(
    (value) async {
      final selectedServer = ref.read(selectedServerPod);
      if (selectedServer.isNone) {
        final res =
            await ref.read(selectedServerPod.notifier).setServer(Some(server));
        return res.mapErr(ErrorSettingServerSave.new);
      } else {
        return const Ok(());
      }
    },
  );
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
  Ref ref,
  Server server,
) async {
  final db = ref.read(dbPod);
  final updateRes = await _updateServer(db, server);

  return updateRes.mapErr(UpdateServerError.errorUpdating).andThenAsync(
    (value) async {
      final selectedServer = ref.read(selectedServerPod).toNullable();
      if (selectedServer?.name == server.name) {
        final res =
            await ref.read(selectedServerPod.notifier).setServer(Some(server));
        return res.mapErr(ErrorSettingServerUpdate.new);
      } else {
        return const Ok(());
      }
    },
  );
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
  Ref ref,
  Server server,
) async {
  final db = ref.read(dbPod);
  final removeRes = await _deleteServer(db, server);

  return await removeRes
      .mapErr(RemoveServerError.errorRemoving)
      .andThenAsync((value) async {
    final selectedServer = ref.read(selectedServerPod).toNullable();
    if (selectedServer?.name == server.name) {
      final res =
          await ref.read(selectedServerPod.notifier).setServer(const None());
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
