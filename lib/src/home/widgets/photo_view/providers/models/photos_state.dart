import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:photo_manager_client/src/domain/image.dart';

part 'photos_state.freezed.dart';

@freezed
class PhotosState with _$PhotosState {
  const factory PhotosState({
    required List<Image> images,
    required PhotosLoadingState loadingState,
  }) = _PhotosState;
}

@freezed
sealed class PhotosLoadingState with _$PhotosLoadingState {
  const factory PhotosLoadingState.loading() = Loading;

  const factory PhotosLoadingState.loaded({required bool hasNextPage}) = Loaded;
}
