import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:photo_manager_client/src/errors/displayable.dart';
import 'package:photo_manager_client/src/errors/error_trace.dart';
import 'package:photo_manager_client/src/persistence/server/pods/selected_server_pod/models/set_selected_server_error.dart';

part 'save_server_error.freezed.dart';

@freezed
sealed class SaveServerError with _$SaveServerError implements Displayable {
  const SaveServerError._();

  const factory SaveServerError.noData() = NoDataSave;

  const factory SaveServerError.errorSaving(ErrorTrace<Object> errorTrace) =
      ErrorSaving;

  const factory SaveServerError.errorSettingServer(
    SetSelectedServerNameError error,
  ) = ErrorSettingServerSave;

  const factory SaveServerError.serverNameInUse() = ServerNameInUse;

  @override
  Iterable<String> toDisplay() => switch (this) {
        NoDataSave() => const ['No data when saving.'],
        ErrorSaving(:final errorTrace) => errorTrace.toDisplay(),
        ErrorSettingServerSave(:final error) => error.toDisplay(),
        ServerNameInUse() => const [
            'This server name is already used. Please edit the existing server to update its url, or choose a new name for this server.',
          ],
      };
}
