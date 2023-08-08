import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/domain/hosted_image.dart';
import 'package:photo_manager_client/src/domain/server.dart';
import 'package:photo_manager_client/src/errors/error_trace.dart';
import 'package:photo_manager_client/src/extensions/response_extension.dart';
import 'package:photo_manager_client/src/persistence/server/pods/current_server_result_pod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'delete_photo_pod.freezed.dart';
part 'delete_photo_pod.g.dart';

typedef DeletePhotoResult = Result<(), DeletePhotoError>;

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

@freezed
sealed class DeletePhotoError with _$DeletePhotoError {
  const factory DeletePhotoError.notOk(String reason) = NotOk;

  const factory DeletePhotoError.errorOccurred(ErrorTrace errorTrace) =
      ErrorOccurred;
}
