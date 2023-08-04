import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/upload_photo/widgets/pods/errors/upload_photo_error.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
    return Err(ErrorOccurred(ex, st));
  }
}

@riverpod
Future<Result<(), UploadPhotoError>> Function({
  required String path,
  required Uri serverUri,
}) uploadPhoto(UploadPhotoRef ref) => _uploadPhoto;
