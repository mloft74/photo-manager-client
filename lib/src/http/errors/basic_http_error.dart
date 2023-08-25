import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:photo_manager_client/src/errors/error_trace.dart';

part 'basic_http_error.freezed.dart';

@freezed
sealed class BasicHttpError with _$BasicHttpError {
  const factory BasicHttpError.notOk(String reason) = NotOk;

  const factory BasicHttpError.timedOut() = TimedOut;

  const factory BasicHttpError.errorOccurred(ErrorTrace<Object> errorTrace) =
      ErrorOccurred;
}
