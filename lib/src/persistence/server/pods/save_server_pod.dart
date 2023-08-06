import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:isar/isar.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/domain/server.dart';
import 'package:photo_manager_client/src/errors/error_trace.dart';
import 'package:photo_manager_client/src/persistence/isar_pod.dart';
import 'package:photo_manager_client/src/persistence/server/models/server_db.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'save_server_pod.freezed.dart';
part 'save_server_pod.g.dart';

typedef SaveServerResult = Result<(), SaveServerError>;

Future<SaveServerResult> _saveServer(
  Isar isar,
  Server server,
) async {
  try {
    final existingDB =
        await isar.serverDBs.getByName(server.name).toFutureOption();
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
  } catch (ex, st) {
    return Err(ErrorOccurred(ErrorTrace(ex, Some(st))));
  }
}

@riverpod
Future<SaveServerResult> Function(Server server) saveServer(
  SaveServerRef ref,
) {
  final isar = ref.watch(isarPod);
  return (server) => _saveServer(isar, server);
}

@freezed
sealed class SaveServerError with _$SaveServerError {
  const factory SaveServerError.serverAlreadyExists(Server server) =
      ServerAlreadyExists;

  const factory SaveServerError.errorOccurred(ErrorTrace<Object> errorTrace) =
      ErrorOccurred;
}
