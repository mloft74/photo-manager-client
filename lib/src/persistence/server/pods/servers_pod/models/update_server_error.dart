import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:photo_manager_client/src/errors/displayable.dart';
import 'package:photo_manager_client/src/errors/error_trace.dart';
import 'package:photo_manager_client/src/persistence/server/pods/current_server_pod/models/set_current_server_error.dart';

part 'update_server_error.freezed.dart';

@freezed
sealed class UpdateServerError with _$UpdateServerError implements Displayable {
  const UpdateServerError._();

  const factory UpdateServerError.noData() = NoDataUpdate;

  const factory UpdateServerError.serverNotFound() = ServerNotFoundUpdate;

  const factory UpdateServerError.errorUpdating(ErrorTrace<Object> errorTrace) =
      ErrorUpdating;

  const factory UpdateServerError.errorUnsettingServer(
    SetCurrentServerError error,
  ) = ErrorSettingServerUpdate;

  @override
  Iterable<String> toDisplay() => switch (this) {
        NoDataUpdate() => const ['No data when updating.'],
        ServerNotFoundUpdate() => const ['No server with that name was found.'],
        ErrorUpdating() => throw UnimplementedError(),
        ErrorSettingServerUpdate() => throw UnimplementedError(),
      };
}
