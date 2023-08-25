import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:photo_manager_client/src/errors/error_trace.dart';

part 'general_http_error.freezed.dart';

@freezed
sealed class GeneralHttpError with _$GeneralHttpError {
  const factory GeneralHttpError.notOk(String reason) = NotOk;

  const factory GeneralHttpError.timedOut() = TimedOut;

  const factory GeneralHttpError.unknownBody(String body) = UnknownBody;

  const factory GeneralHttpError.errorOccurred(ErrorTrace<Object> errorTrace) =
      ErrorOccurred;
}
