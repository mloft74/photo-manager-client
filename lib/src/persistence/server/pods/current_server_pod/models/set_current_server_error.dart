import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:photo_manager_client/src/errors/displayable.dart';
import 'package:photo_manager_client/src/errors/error_trace.dart';

part 'set_current_server_error.freezed.dart';

@freezed
sealed class SetCurrentServerError
    with _$SetCurrentServerError
    implements Displayable {
  const SetCurrentServerError._();

  const factory SetCurrentServerError.noData() = NoData;

  const factory SetCurrentServerError.errorOccurred(
    ErrorTrace<Object> errorTrace,
  ) = ErrorOccurred;

  @override
  Iterable<String> toDisplay() => switch (this) {
        NoData() => const ['No data when setting current server'],
        ErrorOccurred(:final errorTrace) => errorTrace.toDisplay()
      };
}
