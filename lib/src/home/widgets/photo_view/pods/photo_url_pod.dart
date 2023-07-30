import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/persistence/server/pods/current_server_result_pod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'photo_url_pod.g.dart';

@riverpod
Result<String, String> photoUrl(PhotoUrlRef ref, {required String fileName}) {
  final server = ref.watch(currentServerResultPod);
  return server.map((value) => '${value.uri}/image/$fileName');
}
