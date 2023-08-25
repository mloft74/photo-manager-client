import 'dart:convert';

import 'package:http/http.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/domain/hosted_image.dart';
import 'package:photo_manager_client/src/domain/server.dart';
import 'package:photo_manager_client/src/errors/error_trace.dart';
import 'package:photo_manager_client/src/extensions/response_extension.dart';
import 'package:photo_manager_client/src/http/errors/basic_http_error.dart';
import 'package:photo_manager_client/src/persistence/server/pods/current_server_result_pod.dart'
    hide ErrorOccurred;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'delete_photo_pod.g.dart';

typedef DeletePhotoResult = Result<(), BasicHttpError>;

Future<DeletePhotoResult> _deletePhoto(
  Server server,
  HostedImage hostedImage,
) async {
  try {
    final uri = Uri.parse('${server.uri}/api/image/delete');
    final response = await post(
      uri,
      headers: {'content-type': 'application/json'},
      body: jsonEncode({
        'file_name': hostedImage.fileName,
      }),
    );

    if (response.statusCode != 200) {
      return Err(NotOk(response.reasonPhraseNonNull));
    }

    return const Ok(());
  } catch (ex, st) {
    return Err(ErrorOccurred(ErrorTrace(ex, Some(st))));
  }
}

typedef DeletePhotoFn = Future<DeletePhotoResult> Function(
  HostedImage hostedImage,
);

@riverpod
Result<DeletePhotoFn, CurrentServerResultError> deletePhoto(
  DeletePhotoRef ref,
) {
  final serverRes = ref.watch(currentServerResultPod);
  return serverRes.map(
    (value) => (hostedImage) async => await _deletePhoto(value, hostedImage),
  );
}
