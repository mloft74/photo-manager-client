import 'dart:async';
import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart' as http;
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/domain/server.dart';
import 'package:photo_manager_client/src/errors/displayable.dart';
import 'package:photo_manager_client/src/errors/error_trace.dart';
import 'package:photo_manager_client/src/http/errors/displayable_impls.dart';
import 'package:photo_manager_client/src/http/pods/http_client_pod.dart';
import 'package:photo_manager_client/src/http/timeout.dart';
import 'package:photo_manager_client/src/persistence/server/pods/selected_server_pod.dart';
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
    final response = await client.send(request).timeout(shortTimeout);
    if (response.statusCode == 200) {
      return const Ok(());
    } else {
      final bodyString = await response.stream.bytesToString();
      final body = jsonDecode(bodyString);
      return switch (body) {
        {'error': 'imageAlreadyExists'} => const Err(ImageAlreadyExists()),
        _ => Err(UnknownBody(bodyString)),
      };
    }
  } on TimeoutException {
    return const Err(TimedOut());
  } catch (ex, st) {
    return Err(ErrorOccurred(ErrorTrace(ex, Some(st))));
  }
}

typedef UploadPhotoFn = Future<Result<(), UploadPhotoError>> Function(
  String imagePath,
);

/// Returns [None] if no server is selected.
@riverpod
Option<UploadPhotoFn> uploadPhoto(
  UploadPhotoRef ref,
) {
  final client = ref.watch(httpClientPod);
  final server = ref.watch(selectedServerPod);
  return server.map(
    (value) =>
        (imagePath) async => await _uploadPhoto(client, value, imagePath),
  );
}

@freezed
sealed class UploadPhotoError with _$UploadPhotoError implements Displayable {
  const UploadPhotoError._();

  const factory UploadPhotoError.unknownBody(String body) = UnknownBody;

  const factory UploadPhotoError.imageAlreadyExists() = ImageAlreadyExists;

  const factory UploadPhotoError.errorOccurred(ErrorTrace<Object> errorTrace) =
      ErrorOccurred;

  const factory UploadPhotoError.timedOuter() = TimedOut;

  @override
  Iterable<String> toDisplay() => switch (this) {
        UnknownBody(:final body) => unknownBody(body),
        ImageAlreadyExists() => const [
            'An image with that name already exists',
          ],
        ErrorOccurred(:final errorTrace) => errorTrace.toDisplay(),
        TimedOut() => timedOut,
      };
}
