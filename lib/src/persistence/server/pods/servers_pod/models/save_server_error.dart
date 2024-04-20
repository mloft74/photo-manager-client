import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:photo_manager_client/src/errors/displayable.dart';
import 'package:photo_manager_client/src/errors/error_trace.dart';

part 'save_server_error.freezed.dart';

@freezed
sealed class SaveServerError with _$SaveServerError implements Displayable {
  const SaveServerError._();

  const factory SaveServerError.noData() = SaveNoData;

  const factory SaveServerError.errorSaving(ErrorTrace<Object> errorTrace) =
      ErrorSaving;

  const factory SaveServerError.errorSettingServer(
    ErrorTrace<Object> errorTrace,
  ) = ErrorSettingServer;

  @override
  Iterable<String> toDisplay() {
    switch (this) {
      case SaveNoData():
        return const ['No data when saving.'];
      case ErrorSaving(:final errorTrace):
      case ErrorSettingServer(:final errorTrace):
        return errorTrace.toDisplay();
    }
  }
}
