import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:photo_manager_client/src/domain/hosted_image.dart';
import 'package:photo_manager_client/src/errors/displayable.dart';
import 'package:photo_manager_client/src/http/errors/general_http_error.dart';
import 'package:photo_manager_client/src/persistence/server/pods/current_server_result_pod.dart';

part 'photos_state.freezed.dart';

@freezed
class PhotosState with _$PhotosState {
  const factory PhotosState({
    required PhotosLoadingState loadingState,
    required IList<HostedImage> images,
  }) = _PhotosState;
}

enum PhotosLoadingState {
  ready,
  loading,
}

@freezed
sealed class PhotosError with _$PhotosError implements Displayable {
  const PhotosError._();

  const factory PhotosError.currentServer(
    CurrentServerResultError error,
  ) = CurrentServerError;

  const factory PhotosError.http(GeneralHttpError error) = HttpError;

  @override
  Iterable<String> toDisplay() => switch (this) {
        CurrentServerError(:final error) => error.toDisplay(),
        HttpError(:final error) => error.toDisplay(),
      };
}
