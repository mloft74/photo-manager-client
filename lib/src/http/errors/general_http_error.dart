import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:photo_manager_client/src/errors/displayable.dart';
import 'package:photo_manager_client/src/errors/error_trace.dart';
import 'package:photo_manager_client/src/http/errors/displayable_impls.dart';

part 'general_http_error.freezed.dart';

@freezed
sealed class GeneralHttpError with _$GeneralHttpError implements Displayable {
  const GeneralHttpError._();

  const factory GeneralHttpError.notOk(String reason) = NotOk;

  const factory GeneralHttpError.timedOut() = TimedOut;

  const factory GeneralHttpError.unknownBody(String body) = UnknownBody;

  const factory GeneralHttpError.errorOccurred(ErrorTrace<Object> errorTrace) =
      ErrorOccurred;

  @override
  Iterable<String> toDisplay() => switch (this) {
        NotOk(:final reason) => notOk(reason),
        TimedOut() => timedOut,
        UnknownBody(:final body) => unknownBody(body),
        ErrorOccurred(:final errorTrace) => errorTrace.toDisplay(),
      };
}
