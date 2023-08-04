import 'package:freezed_annotation/freezed_annotation.dart';

part 'upload_photo_error.freezed.dart';

@freezed
sealed class UploadPhotoError with _$UploadPhotoError {
  const factory UploadPhotoError.unknownBody(String body) = UnknownBody;

  const factory UploadPhotoError.imageAlreadyExists() = ImageAlreadyExists;

  const factory UploadPhotoError.errorOccurred(
    Object error,
    StackTrace stackTrace,
  ) = ErrorOccurred;
}
