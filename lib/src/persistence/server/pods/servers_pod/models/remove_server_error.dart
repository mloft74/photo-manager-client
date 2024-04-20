import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:photo_manager_client/src/errors/displayable.dart';
import 'package:photo_manager_client/src/errors/error_trace.dart';
import 'package:photo_manager_client/src/persistence/server/pods/current_server_pod/models/set_current_server_error.dart';

part 'remove_server_error.freezed.dart';

@freezed
sealed class RemoveServerError with _$RemoveServerError implements Displayable {
  const RemoveServerError._();

  const factory RemoveServerError.noData() = RemoveNoData;

  const factory RemoveServerError.errorRemoving(ErrorTrace<Object> errorTrace) =
      ErrorRemoving;

  const factory RemoveServerError.errorUnsettingServer(
    SetCurrentServerError error,
  ) = ErrorUnsettingServer;

  const factory RemoveServerError.serverNotFound() = ServerNotFound;

  @override
  Iterable<String> toDisplay() => switch (this) {
        RemoveNoData() => const ['No data when removing.'],
        ErrorRemoving(:final errorTrace) => errorTrace.toDisplay(),
        ErrorUnsettingServer(:final error) => error.toDisplay(),
        ServerNotFound() => const ['No server with that name was found.'],
      };
}
