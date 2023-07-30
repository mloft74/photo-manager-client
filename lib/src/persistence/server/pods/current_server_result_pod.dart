import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/domain/server.dart';
import 'package:photo_manager_client/src/persistence/server/pods/current_server_pod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_server_result_pod.g.dart';

@riverpod
Result<Server, String> currentServerResult(CurrentServerResultRef ref) => ref
    .watch(currentServerPod)
    .asData
    .option
    .andThen((value) => value.value)
    .okOr('No server selected');
