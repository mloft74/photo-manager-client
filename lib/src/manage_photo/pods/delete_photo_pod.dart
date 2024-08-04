import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/domain/hosted_image.dart';
import 'package:photo_manager_client/src/domain/server.dart';
import 'package:photo_manager_client/src/errors/error_trace.dart';
import 'package:photo_manager_client/src/extensions/response_extension.dart';
import 'package:photo_manager_client/src/http/errors/basic_http_error.dart';
import 'package:photo_manager_client/src/http/pods/http_client_pod.dart';
import 'package:photo_manager_client/src/http/timeout.dart';
import 'package:photo_manager_client/src/persistence/server/pods/selected_server_pod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'delete_photo_pod.g.dart';

typedef DeletePhotoResult = Result<(), BasicHttpError>;

Future<DeletePhotoResult> _deletePhoto(
  http.Client client,
  Server server,
  HostedImage hostedImage,
) async {
  try {
    final uri = Uri.parse('${server.uri}/api/image/delete');
    final response = await client
        .post(
          uri,
          headers: {'content-type': 'application/json'},
          body: jsonEncode({
            'fileName': hostedImage.fileName,
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

typedef DeletePhotoFn = Future<DeletePhotoResult> Function(
  HostedImage hostedImage,
);

@riverpod
Option<DeletePhotoFn> deletePhoto(
  DeletePhotoRef ref,
) {
  final client = ref.watch(httpClientPod);
  final server = ref.watch(selectedServerPod);
  return server.map(
    (value) =>
        (hostedImage) async => await _deletePhoto(client, value, hostedImage),
  );
}
