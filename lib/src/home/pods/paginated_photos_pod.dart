import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/home/pods/models/photos_state.dart';
import 'package:photo_manager_client/src/home/pods/paginated_photos_pod/pods/fetch_photos_page_pod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'paginated_photos_pod.g.dart';

typedef PaginatedPhotosState = Result<PhotosState, PhotosError>;

const _defaultState = PhotosState(
  loadingState: PhotosLoadingState.loading,
  images: IListConst([]),
);
const Option<int> _defaultCursor = None();
const _defaultHasNextPage = true;

@riverpod
class PaginatedPhotos extends _$PaginatedPhotos {
  var _cursor = _defaultCursor;
  var _hasNextPage = _defaultHasNextPage;

  () _initMembers() {
    _cursor = _defaultCursor;
    _hasNextPage = _defaultHasNextPage;

    return ();
  }

  @override
  Future<PaginatedPhotosState> build() async {
    _initMembers();

    final fetchPhotosPageRes = ref.watch(fetchPhotosPagePod);
    return await _fetchPhotosPageSafe(
      fetchPhotosPageRes,
      _defaultState,
    );
  }

  /// Load the next page given the internal state.
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

  /// Reset the state back to defaults and load the first page again.
  Future<()> reset() async {
    if (state
        case AsyncData(
          value: Ok(
            value: PhotosState(
              loadingState: PhotosLoadingState.loading,
            ),
          )
        )) {
      return ();
    }

    state = const AsyncLoading();

    _initMembers();

    final fetchPhotosPageRes = ref.read(fetchPhotosPagePod);
    state = AsyncData(
      await _fetchPhotosPageSafe(
        fetchPhotosPageRes,
        _defaultState,
      ),
    );

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
