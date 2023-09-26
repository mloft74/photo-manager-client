import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/home/pods/models/photos_state.dart';
import 'package:photo_manager_client/src/home/pods/paginated_photos_pod/pods/fetch_photos_page_pod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'paginated_photos_pod.g.dart';

typedef PaginatedPhotosState = Result<PhotosState, PhotosError>;

@riverpod
class PaginatedPhotos extends _$PaginatedPhotos {
  var _cursor = const Option<int>.none();
  var _hasNextPage = true;

  @override
  Future<PaginatedPhotosState> build() async {
    _cursor = const None();
    _hasNextPage = true;

    final fetchPhotosPageRes = ref.watch(fetchPhotosPagePod);
    return await _fetchPhotosPageSafe(
      fetchPhotosPageRes,
      const PhotosState(
        loadingState: PhotosLoadingState.loading,
        images: IListConst([]),
      ),
    );
  }

  Future<()> nextPage() async {
    if (state case AsyncData(value: Ok(value: final stateData))) {
      final isLoading = stateData.loadingState == PhotosLoadingState.loading;
      if (isLoading || !_hasNextPage) {
        return ();
      }
      state = AsyncData(
        Ok(
          stateData.copyWith(
            loadingState: PhotosLoadingState.loading,
          ),
        ),
      );

      final fetchPhotosPageRes = ref.read(fetchPhotosPagePod);
      state =
          AsyncData(await _fetchPhotosPageSafe(fetchPhotosPageRes, stateData));
    }

    return ();
  }

  Future<PaginatedPhotosState> _fetchPhotosPageSafe(
    FetchPhotosPagePodResult podRes,
    PhotosState stateData,
  ) async {
    switch (podRes) {
      case Ok(value: final fetchPhotosPage):
        final res = await fetchPhotosPage(_cursor);
        return _stateFromResult(
          res,
          stateData,
        );
      case Err(:final error):
        return Err(CurrentServerError(error));
    }
  }

  PaginatedPhotosState _stateFromResult(
    FetchPhotosPageResult res,
    PhotosState stateData,
  ) {
    switch (res) {
      case Ok(:final value):
        _cursor = value.cursor;
        _hasNextPage = _cursor.isSome;

        return Ok(
          stateData.copyWith(
            loadingState: PhotosLoadingState.ready,
            images: stateData.images + value.images,
          ),
        );
      case Err(:final error):
        _hasNextPage = false;

        return Err(HttpError(error));
    }
  }
}
