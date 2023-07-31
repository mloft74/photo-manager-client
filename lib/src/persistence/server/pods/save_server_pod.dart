import 'package:isar/isar.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/domain/server.dart';
import 'package:photo_manager_client/src/persistence/isar_pod.dart';
import 'package:photo_manager_client/src/persistence/server/models/server_db.dart';
import 'package:photo_manager_client/src/persistence/server/pods/errors/server_already_exists.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'save_server_pod.g.dart';

Future<Result<(), ServerAlreadyExists>> _saveServer(
  Isar isar,
  Server server,
) async {
  final existingDB = await isar.serverDBs.getByName(server.name).futureOption;
  final existing = existingDB.andThen((value) => value.toDomain());
  if (existing case Some(:final value)) {
    return Err(ServerAlreadyExists(value));
  }

  await isar.writeTxn(
    () async {
      await isar.serverDBs.put(ServerDB.fromDomain(server));
    },
  );

  return const Ok(());
}

@riverpod
Future<Result<(), ServerAlreadyExists>> Function(Server server) saveServer(
  SaveServerRef ref,
) {
  final isar = ref.watch(isarPod);
  return (server) => _saveServer(isar, server);
}
