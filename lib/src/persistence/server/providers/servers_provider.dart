import 'package:isar/isar.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/domain/server.dart';
import 'package:photo_manager_client/src/persistence/isar_provider.dart';
import 'package:photo_manager_client/src/persistence/server/models/server_db.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'servers_provider.g.dart';

@riverpod
Stream<Iterable<Server>> servers(ServersRef ref) {
  final isar = ref.watch(isarProvider);
  return isar.serverDBs.where().watch(fireImmediately: true).map(
        (event) => event
            .map(
              (e) => Uri.tryParse(e.uri).option.andThen(
                    (uri) => Some(Server(name: e.name, uri: uri)),
                  ),
            )
            .whereSome(),
      );
}
