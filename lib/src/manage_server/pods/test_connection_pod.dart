import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/domain/server.dart';
import 'package:photo_manager_client/src/errors/error_trace.dart';
import 'package:photo_manager_client/src/extensions/response_extension.dart';
import 'package:photo_manager_client/src/http/errors/general_http_error.dart';
import 'package:photo_manager_client/src/http/pods/http_client_pod.dart';
import 'package:photo_manager_client/src/http/timeout.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'test_connection_pod.g.dart';

typedef TestConnectionResult = Result<(), GeneralHttpError>;

Future<TestConnectionResult> _testConnection(
  http.Client client,
  Server server,
) async {
  try {
    final uri = Uri.parse('${server.uri}/api/ping');
    final response = await client.get(uri).timeout(shortTimeout);
    if (response.statusCode != 200) {
      return Err(NotOk(response.reasonPhraseNonNull));
    }

    final bodyStr = response.body;
    final body = jsonDecode(bodyStr);
    if (body case {'message': 'pong'}) {
      return const Ok(());
    } else {
      return Err(UnknownBody(bodyStr));
    }
  } on TimeoutException {
    return const Err(TimedOut());
  } catch (ex, st) {
    return Err(ErrorOccurred(ErrorTrace(ex, Some(st))));
  }
}

@riverpod
Future<TestConnectionResult> Function(Server server) testConnection(
  TestConnectionRef ref,
) {
  final client = ref.watch(httpClientPod);
  return (server) => _testConnection(client, server);
}
