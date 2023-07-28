import 'package:photo_manager_client/src/persistence/server/providers/current_server_unchecked_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'photo_url_provider.g.dart';

@riverpod
String photoUrl(PhotoUrlRef ref, {required String fileName}) {
  final server = ref.watch(currentServerUncheckedProvider);
  return '${server.uri}/image/$fileName';
}
