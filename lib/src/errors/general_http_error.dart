import 'package:freezed_annotation/freezed_annotation.dart';

part 'general_http_error.freezed.dart';

@freezed
sealed class GeneralHttpError with _$GeneralHttpError {
  const factory GeneralHttpError.notOk(String reason) = NotOk;

  const factory GeneralHttpError.unknownBody(String body) = UnknownBody;

  const factory GeneralHttpError.errorOccurred(
    Object error,
    StackTrace stackTrace,
  ) = ErrorOccurred;
}
