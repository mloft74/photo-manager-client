import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:photo_manager_client/src/errors/displayable.dart';
import 'package:photo_manager_client/src/errors/error_trace.dart';
import 'package:photo_manager_client/src/http/errors/displayable_impls.dart';

part 'basic_http_error.freezed.dart';

@freezed
sealed class BasicHttpError with _$BasicHttpError implements Displayable {
  const BasicHttpError._();

  const factory BasicHttpError.notOk(String reason) = NotOk;

  const factory BasicHttpError.timedOut() = TimedOut;

  const factory BasicHttpError.errorOccurred(ErrorTrace<Object> errorTrace) =
      ErrorOccurred;

  @override
  Iterable<String> toDisplay() => switch (this) {
        NotOk(:final reason) => notOk(reason),
        TimedOut() => timedOut,
        ErrorOccurred(:final errorTrace) => errorTrace.toDisplay(),
      };
}
