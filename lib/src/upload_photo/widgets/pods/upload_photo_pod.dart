import 'dart:async';
import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/errors/error_trace.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'upload_photo_pod.freezed.dart';
part 'upload_photo_pod.g.dart';

Future<Result<(), UploadPhotoError>> _uploadPhoto({
  required String path,
  required Uri serverUri,
}) async {
  try {
    final uploadUri = Uri.parse('$serverUri/api/image/upload');
    final request = MultipartRequest('POST', uploadUri)
      ..files.add(await MultipartFile.fromPath('', path));
    final response = await request.send();
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

@riverpod
Future<Result<(), UploadPhotoError>> Function({
  required String path,
  required Uri serverUri,
}) uploadPhoto(UploadPhotoRef ref) => _uploadPhoto;

@freezed
sealed class UploadPhotoError with _$UploadPhotoError {
  const factory UploadPhotoError.unknownBody(String body) = UnknownBody;

  const factory UploadPhotoError.imageAlreadyExists() = ImageAlreadyExists;

  const factory UploadPhotoError.errorOccurred(ErrorTrace<Object> errorTrace) =
      ErrorOccurred;
}
