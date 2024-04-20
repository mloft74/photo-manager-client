import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:photo_manager_client/src/errors/displayable.dart';
import 'package:photo_manager_client/src/errors/error_trace.dart';

part 'remove_server_error.freezed.dart';

@freezed
sealed class RemoveServerError with _$RemoveServerError implements Displayable {
  const RemoveServerError._();

  const factory RemoveServerError.noData() = RemoveNoData;

  const factory RemoveServerError.errorRemoving(ErrorTrace<Object> errorTrace) =
      ErrorRemoving;

  const factory RemoveServerError.errorUnsettingServer(
    ErrorTrace<Object> errorTrace,
  ) = ErrorUnsettingServer;

  @override
  Iterable<String> toDisplay() {
    switch (this) {
      case RemoveNoData():
        return const ['No data when removing.'];
      case ErrorRemoving(:final errorTrace):
      case ErrorUnsettingServer(:final errorTrace):
        return errorTrace.toDisplay();
    }
  }
}
