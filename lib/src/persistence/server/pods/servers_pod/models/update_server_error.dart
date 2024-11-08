import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:photo_manager_client/src/errors/displayable.dart';
import 'package:photo_manager_client/src/errors/error_trace.dart';
import 'package:photo_manager_client/src/persistence/server/pods/selected_server_pod/models/set_selected_server_error.dart';

part 'update_server_error.freezed.dart';

@freezed
sealed class UpdateServerError with _$UpdateServerError implements Displayable {
  const UpdateServerError._();

  const factory UpdateServerError.noData() = NoDataUpdate;

  const factory UpdateServerError.serverNotFound(String name) = ServerNotFoundUpdate;

  const factory UpdateServerError.errorUpdating(ErrorTrace<Object> errorTrace) =
      ErrorUpdating;

  const factory UpdateServerError.errorUnsettingServer(
    SetSelectedServerError error,
  ) = ErrorSettingServerUpdate;

  @override
  Iterable<String> toDisplay() => switch (this) {
        NoDataUpdate() => const ['No data when updating.'],
        ServerNotFoundUpdate(:final name) => ['No server with the name $name was found.'],
        ErrorUpdating(:final errorTrace) => errorTrace.toDisplay(),
        ErrorSettingServerUpdate(:final error) => error.toDisplay(),
      };
}
