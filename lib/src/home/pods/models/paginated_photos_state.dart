import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/domain/hosted_image.dart';

part 'paginated_photos_state.freezed.dart';

@freezed
class PaginatedPhotosState with _$PaginatedPhotosState {
  const factory PaginatedPhotosState({
    required Result<PaginatedPhotosLoadingState, String> loading,
    required IList<HostedImage> images,
  }) = _PaginatedPhotosState;
}

enum PaginatedPhotosLoadingState {
  ready,
  loading,
}
