import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:isar/isar.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/domain/server.dart';
import 'package:photo_manager_client/src/extensions/pipe_extension.dart';
import 'package:photo_manager_client/src/persistence/isar_pod.dart';
import 'package:photo_manager_client/src/persistence/server/models/server_db.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'servers_pod.g.dart';

@riverpod
Stream<IList<Server>> servers(ServersRef ref) {
  final isar = ref.watch(isarPod);
  return isar.serverDBs.where().watch(fireImmediately: true).map(
        (event) => event.map((e) => e.toDomain()).whereSome().pipe(IList.new),
      );
}
