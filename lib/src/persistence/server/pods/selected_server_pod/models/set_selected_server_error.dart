import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:photo_manager_client/src/errors/displayable.dart';
import 'package:photo_manager_client/src/errors/error_trace.dart';

part 'set_selected_server_error.freezed.dart';

@freezed
sealed class SetSelectedServerError
    with _$SetSelectedServerError
    implements Displayable {
  const SetSelectedServerError._();

  const factory SetSelectedServerError.noData() = NoData;

  const factory SetSelectedServerError.errorOccurred(
    ErrorTrace<Object> errorTrace,
  ) = ErrorOccurred;

  @override
  Iterable<String> toDisplay() => switch (this) {
        NoData() => const ['No data when setting selected server'],
        ErrorOccurred(:final errorTrace) => errorTrace.toDisplay()
      };
}
