import 'package:isar/isar.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/domain/server.dart';
import 'package:photo_manager_client/src/errors/error_trace.dart';
import 'package:photo_manager_client/src/persistence/isar_pod.dart';
import 'package:photo_manager_client/src/persistence/server/models/server_db.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'save_server_pod.g.dart';

typedef SaveServerResult = Result<(), ErrorTrace>;

Future<SaveServerResult> _saveServer(
  Isar isar,
  Server server,
) async {
  try {
    await isar.writeTxn(
      () async {
        await isar.serverDBs.put(ServerDB.fromDomain(server));
      },
    );

    return const Ok(());
  } catch (ex, st) {
    return Err(ErrorTrace(ex, Some(st)));
  }
}

@riverpod
Future<SaveServerResult> Function(Server server) saveServer(
  SaveServerRef ref,
) {
  final isar = ref.watch(isarPod);
  return (server) => _saveServer(isar, server);
}
