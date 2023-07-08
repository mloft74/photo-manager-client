import 'dart:async';

import 'package:http/http.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/upload_photo/providers/errors/upload_photo_error.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'upload_photo_provider.g.dart';

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
      final responseParsed = await response.stream.bytesToString();
      return Err(GeneralMessage(responseParsed));
    }
  } catch (ex, st) {
    return Err(ExceptionOccurred(ex, st));
  }
}

@riverpod
Future<Result<(), UploadPhotoError>> Function({
  required String path,
  required Uri serverUri,
}) uploadPhoto(UploadPhotoRef ref) => _uploadPhoto;
