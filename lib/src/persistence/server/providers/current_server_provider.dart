import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/domain/server.dart';
import 'package:photo_manager_client/src/persistence/isar_provider.dart';
import 'package:photo_manager_client/src/persistence/server/models/selected_server_db.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_server_provider.g.dart';

typedef CurrentServerState = Option<Server>;

@riverpod
Stream<CurrentServerState> currentServer(CurrentServerRef ref) {
  final isar = ref.watch(isarProvider);
  return isar.selectedServerDBs
      .watchObject(SelectedServerDB.selectedId, fireImmediately: true)
      .asyncMap((event) => event.option.andThen((value) => value.toDomain()));
}
