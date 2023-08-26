import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/domain/server.dart';
import 'package:photo_manager_client/src/errors/error_trace.dart';
import 'package:photo_manager_client/src/extensions/response_extension.dart';
import 'package:photo_manager_client/src/http/errors/basic_http_error.dart';
import 'package:photo_manager_client/src/http/pods/http_client_pod.dart';
import 'package:photo_manager_client/src/http/timeout.dart';
import 'package:photo_manager_client/src/persistence/server/pods/current_server_result_pod.dart'
    hide ErrorOccurred;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'update_canon_pod.g.dart';

typedef UpdateCanonResult = Result<(), BasicHttpError>;

Future<UpdateCanonResult> _updateCanon(
  http.Client client,
  Server server,
) async {
  try {
    final uri = Uri.parse('${server.uri}/api/image/update_canon');

    final response = await client.post(uri).timeout(longTimeout);
    if (response.statusCode != 200) {
      return Err(NotOk(response.reasonPhraseNonNull));
    }

    return const Ok(());
  } on TimeoutException {
    return const Err(TimedOut());
  } catch (ex, st) {
    return Err(ErrorOccurred(ErrorTrace(ex, Some(st))));
  }
}

typedef UpdateCanonFn = Future<UpdateCanonResult> Function();

@riverpod
Result<UpdateCanonFn, CurrentServerResultError> updateCanon(
  UpdateCanonRef ref,
) {
  final client = ref.watch(httpClientPod);
  final serverRes = ref.watch(currentServerResultPod);
  return serverRes
      .map((value) => () async => await _updateCanon(client, value));
}
