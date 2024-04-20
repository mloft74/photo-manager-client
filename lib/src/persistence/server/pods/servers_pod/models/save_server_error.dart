import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:photo_manager_client/src/errors/displayable.dart';
import 'package:photo_manager_client/src/errors/error_trace.dart';
import 'package:photo_manager_client/src/persistence/server/pods/current_server_pod/models/set_current_server_error.dart';

part 'save_server_error.freezed.dart';

@freezed
sealed class SaveServerError with _$SaveServerError implements Displayable {
  const SaveServerError._();

  const factory SaveServerError.noData() = SaveNoData;

  const factory SaveServerError.errorSaving(ErrorTrace<Object> errorTrace) =
      ErrorSaving;

  const factory SaveServerError.errorSettingServer(
    SetCurrentServerError error,
  ) = ErrorSettingServer;

  @override
  Iterable<String> toDisplay() => switch (this) {
        SaveNoData() => const ['No data when saving.'],
        ErrorSaving(:final errorTrace) => errorTrace.toDisplay(),
        ErrorSettingServer(:final error) => error.toDisplay()
      };
}
