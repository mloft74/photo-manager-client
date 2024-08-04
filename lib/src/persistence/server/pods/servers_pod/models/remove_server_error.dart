import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:photo_manager_client/src/errors/displayable.dart';
import 'package:photo_manager_client/src/errors/error_trace.dart';
import 'package:photo_manager_client/src/persistence/server/pods/selected_server_pod/models/set_selected_server_name_error.dart';

part 'remove_server_error.freezed.dart';

@freezed
sealed class RemoveServerError with _$RemoveServerError implements Displayable {
  const RemoveServerError._();

  const factory RemoveServerError.noData() = NoDataRemove;

  const factory RemoveServerError.serverNotFound() = ServerNotFoundRemove;

  const factory RemoveServerError.errorRemoving(ErrorTrace<Object> errorTrace) =
      ErrorRemoving;

  const factory RemoveServerError.errorUnsettingServer(
    SetSelectedServerNameError error,
  ) = ErrorUnsettingServer;

  @override
  Iterable<String> toDisplay() => switch (this) {
        NoDataRemove() => const ['No data when removing.'],
        ErrorRemoving(:final errorTrace) => errorTrace.toDisplay(),
        ErrorUnsettingServer(:final error) => error.toDisplay(),
        ServerNotFoundRemove() => const ['No server with that name was found.'],
      };
}
