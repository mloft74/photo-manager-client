import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/domain/server.dart';
import 'package:photo_manager_client/src/persistence/isar_provider.dart';
import 'package:photo_manager_client/src/persistence/server/models/selected_server_db.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_server_provider.g.dart';

typedef CurrentServerState = Option<Server>;

@riverpod
class CurrentServer extends _$CurrentServer {
  @override
  FutureOr<CurrentServerState> build() async {
    final isar = ref.watch(isarProvider);
    final selectedServer =
        await isar.selectedServerDBs.get(SelectedServerDB.selectedId);
    final listener = isar.selectedServerDBs
        .watchObject(SelectedServerDB.selectedId)
        .map((event) => event.option.andThen((value) => value.toDomain()))
        .listen(
      (event) {
        state = AsyncValue.data(event);
      },
    );
    ref.onDispose(listener.cancel);
    return selectedServer.option.andThen((value) => value.toDomain());
  }
}
