import 'package:freezed_annotation/freezed_annotation.dart';

part 'fetch_photos_page_error.freezed.dart';

@freezed
sealed class FetchPhotosPageError with _$FetchPhotosPageError {
  const factory FetchPhotosPageError.notOk(String reason) = NotOk;

  const factory FetchPhotosPageError.unknownBody(String body) = UnknownBody;

  const factory FetchPhotosPageError.errorOccurred(
    Object error,
    StackTrace stackTrace,
  ) = ErrorOccurred;
}
