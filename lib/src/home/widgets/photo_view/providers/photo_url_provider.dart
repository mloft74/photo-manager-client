import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/persistence/server/providers/current_server_result_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'photo_url_provider.g.dart';

@riverpod
Result<String, String> photoUrl(PhotoUrlRef ref, {required String fileName}) {
  final server = ref.watch(currentServerResultProvider);
  return server.map((value) => '${value.uri}/image/$fileName');
}
