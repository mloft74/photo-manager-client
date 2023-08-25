import 'dart:convert';

import 'package:http/http.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/domain/server.dart';
import 'package:photo_manager_client/src/errors/error_trace.dart';
import 'package:photo_manager_client/src/extensions/response_extension.dart';
import 'package:photo_manager_client/src/http/errors/general_http_error.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'test_connection_pod.g.dart';

typedef TestConnectionResult = Result<(), GeneralHttpError>;

Future<TestConnectionResult> _testConnection(Server server) async {
  try {
    final uri = Uri.parse('${server.uri}/api/ping');
    final response = await get(uri);
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
  } catch (ex, st) {
    return Err(ErrorOccurred(ErrorTrace(ex, Some(st))));
  }
}

@riverpod
Future<TestConnectionResult> Function(Server server) testConnection(
  TestConnectionRef ref,
) {
  return _testConnection;
}
