import 'package:freezed_annotation/freezed_annotation.dart';

part 'upload_photo_error.freezed.dart';

@freezed
sealed class UploadPhotoError with _$UploadPhotoError {
  const factory UploadPhotoError.generalMessage(String message) =
      GeneralMessage;

  const factory UploadPhotoError.second(Object ex, StackTrace st) =
      ExceptionOccurred;
}
