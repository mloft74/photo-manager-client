import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/persistence/server/pods/selected_server_pod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'photo_url_pod.g.dart';

@riverpod
Option<String> photoUrl(
  Ref ref, {
  required String fileName,
}) {
  final server = ref.watch(selectedServerPod);
  return server.map((value) => '${value.uri}/image/$fileName');
}
