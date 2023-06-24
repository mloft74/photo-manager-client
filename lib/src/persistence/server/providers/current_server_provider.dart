import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/domain/server.dart';
import 'package:photo_manager_client/src/persistence/isar_provider.dart';
import 'package:photo_manager_client/src/persistence/server/models/selected_server_db.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';

part 'current_server_provider.g.dart';

@riverpod
Stream<Option<Server>> currentServer(CurrentServerRef ref) {
  final isar = ref.watch(isarProvider);
  return isar.selectedServerDBs
      .watchObject(SelectedServerDB.selectedId, fireImmediately: true)
      .mapNotNull((e) => e?.server.value)
      .map((event) => event.toDomain());
}
