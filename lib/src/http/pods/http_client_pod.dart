import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'http_client_pod.g.dart';

@riverpod
Client httpClient(Ref ref) {
  final client = Client();
  ref.onDispose(client.close);
  return client;
}
