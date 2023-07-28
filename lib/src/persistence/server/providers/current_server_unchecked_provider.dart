import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/domain/server.dart';
import 'package:photo_manager_client/src/persistence/server/providers/current_server_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_server_unchecked_provider.g.dart';

@riverpod
Server currentServerUnchecked(CurrentServerUncheckedRef ref) => ref
    .watch(currentServerProvider)
    .asData
    .option
    .andThen((value) => value.value)
    .unwrap();
