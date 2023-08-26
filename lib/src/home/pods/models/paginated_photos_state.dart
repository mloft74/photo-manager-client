import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/domain/hosted_image.dart';
import 'package:photo_manager_client/src/errors/displayable.dart';
import 'package:photo_manager_client/src/http/errors/general_http_error.dart';
import 'package:photo_manager_client/src/persistence/server/pods/current_server_result_pod.dart';

part 'paginated_photos_state.freezed.dart';

@freezed
class PaginatedPhotosState with _$PaginatedPhotosState {
  const factory PaginatedPhotosState({
    required Result<PaginatedPhotosLoadingState, PaginatedPhotosStateError>
        loading,
    required IList<HostedImage> images,
  }) = _PaginatedPhotosState;
}

enum PaginatedPhotosLoadingState {
  ready,
  loading,
}

@freezed
sealed class PaginatedPhotosStateError
    with _$PaginatedPhotosStateError
    implements Displayable {
  const PaginatedPhotosStateError._();

  const factory PaginatedPhotosStateError.currentServer(
    CurrentServerResultError error,
  ) = CurrentServerError;

  const factory PaginatedPhotosStateError.http(GeneralHttpError error) =
      HttpError;

  @override
  Iterable<String> toDisplay() => switch (this) {
        CurrentServerError(:final error) => error.toDisplay(),
        HttpError(:final error) => error.toDisplay(),
      };
}
