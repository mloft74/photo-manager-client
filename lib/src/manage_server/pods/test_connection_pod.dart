import 'dart:convert';

import 'package:http/http.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/domain/server.dart';
import 'package:photo_manager_client/src/extensions/response_extension.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'test_connection_pod.g.dart';

Future<Result<(), String>> _testConnection(Server server) async {
  final uri = Uri.parse('${server.uri}/api/ping');
  final response = await get(uri);
  if (response.statusCode != 200) {
    return response.reasonPhraseErr();
  }

  final body = jsonDecode(response.body);
  if (body case {'message': 'pong'}) {
    return const Ok(());
  } else {
    return Err('Unknown body: $body');
  }
}

@riverpod
Future<Result<(), String>> Function(Server server) testConnection(
  TestConnectionRef ref,
) {
  return _testConnection;
}
