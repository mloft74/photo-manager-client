import 'package:photo_manager_client/src/home/widgets/photo_view/providers/models/photos_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'photos_provider.g.dart';

@riverpod
class Photos extends _$Photos {
  @override
  PhotosState build() {
    return const PhotosState(
      images: [],
      loadingState: PhotosLoadingState.loading(),
    );
  }
}
