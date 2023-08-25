import 'dart:async';
import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart' as http;
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/domain/server.dart';
import 'package:photo_manager_client/src/errors/error_trace.dart';
import 'package:photo_manager_client/src/http/pods/http_client_pod.dart';
import 'package:photo_manager_client/src/persistence/server/pods/current_server_result_pod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'upload_photo_pod.freezed.dart';
part 'upload_photo_pod.g.dart';

typedef UploadPhotoResult = Result<(), UploadPhotoError>;

Future<UploadPhotoResult> _uploadPhoto(
  http.Client client,
  Server server,
  String imagePath,
) async {
  try {
    final uploadUri = Uri.parse('${server.uri}/api/image/upload');
    final request = http.MultipartRequest('POST', uploadUri)
      ..files.add(await http.MultipartFile.fromPath('', imagePath));
    final response = await client.send(request);
    if (response.statusCode == 200) {
      return const Ok(());
    } else {
      final bodyString = await response.stream.bytesToString();
      final body = jsonDecode(bodyString);
      return switch (body) {
        {'error': 'ImageAlreadyExists'} => const Err(ImageAlreadyExists()),
        _ => Err(UnknownBody(bodyString)),
      };
    }
  } catch (ex, st) {
    return Err(ErrorOccurred(ErrorTrace(ex, Some(st))));
  }
}

typedef UploadPhotoFn = Future<Result<(), UploadPhotoError>> Function(
  String imagePath,
);

@riverpod
Result<UploadPhotoFn, CurrentServerResultError> uploadPhoto(
  UploadPhotoRef ref,
) {
  final client = ref.watch(httpClientPod);
  final serverRes = ref.watch(currentServerResultPod);
  return serverRes.map(
    (value) =>
        (imagePath) async => await _uploadPhoto(client, value, imagePath),
  );
}

@freezed
sealed class UploadPhotoError with _$UploadPhotoError {
  const factory UploadPhotoError.unknownBody(String body) = UnknownBody;

  const factory UploadPhotoError.imageAlreadyExists() = ImageAlreadyExists;

  const factory UploadPhotoError.errorOccurred(ErrorTrace<Object> errorTrace) =
      ErrorOccurred;
}
