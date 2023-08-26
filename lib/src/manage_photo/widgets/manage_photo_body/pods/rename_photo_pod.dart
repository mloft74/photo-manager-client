import 'dart:async';
import 'dart:convert';

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

part 'rename_photo_pod.g.dart';

typedef RenamePhotoResult = Result<(), BasicHttpError>;

Future<RenamePhotoResult> _renamePhoto(
  http.Client client,
  Server server, {
  required String oldName,
  required String newName,
}) async {
  try {
    final uri = Uri.parse('${server.uri}/api/image/rename');
    final response = await client
        .post(
          uri,
          headers: {'content-type': 'application/json'},
          body: jsonEncode({
            'old_name': oldName,
            'new_name': newName,
          }),
        )
        .timeout(shortTimeout);

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

typedef RenamePhotoFn = Future<RenamePhotoResult> Function({
  required String oldName,
  required String newName,
});

@riverpod
Result<RenamePhotoFn, CurrentServerResultError> renamePhoto(
  RenamePhotoRef ref,
) {
  final client = ref.watch(httpClientPod);
  final server = ref.watch(currentServerResultPod);
  return server.map(
    (value) => ({
      required oldName,
      required newName,
    }) async =>
        await _renamePhoto(
          client,
          value,
          oldName: oldName,
          newName: newName,
        ),
  );
}
