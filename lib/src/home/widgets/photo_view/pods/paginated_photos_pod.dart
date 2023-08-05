import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/home/widgets/photo_view/pods/models/paginated_photos_state.dart';
import 'package:photo_manager_client/src/home/widgets/photo_view/pods/paginated_photos_pod/pods/fetch_photos_page_pod.dart';
import 'package:photo_manager_client/src/persistence/server/pods/current_server_result_pod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'paginated_photos_pod.g.dart';

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
      const PaginatedPhotosState(
        loading: Ok(PaginatedPhotosLoadingState.loading),
        images: IListConst([]),
      ),
    );
  }

  Future<()> nextPage() async {
    if (state case AsyncData(value: final stateData)) {
      final shouldShortCircuitLoading = stateData.loading
          .map((value) => value == PaginatedPhotosLoadingState.loading)
          .unwrapOr(true);
      if (shouldShortCircuitLoading || !_hasNextPage) {
        return ();
      }
      state = AsyncData(
        stateData.copyWith(
          loading: const Ok(PaginatedPhotosLoadingState.loading),
        ),
      );

      final fetchPhotosPageRes = ref.read(fetchPhotosPagePod);
      state =
          AsyncData(await _fetchPhotosPageSafe(fetchPhotosPageRes, stateData));
    }

    return ();
  }

  Future<PaginatedPhotosState> _fetchPhotosPageSafe(
    Result<FetchPhotosPageFn, CurrentServerResultError> fetchPhotosPageRes,
    PaginatedPhotosState stateData,
  ) async {
    switch (fetchPhotosPageRes) {
      case Ok(value: final fetchPhotosPage):
        final result = await fetchPhotosPage(_cursor);
        return _stateFromResult(
          result,
          stateData,
        );
      case Err(:final error):
        return stateData.copyWith(loading: Err('$error'));
    }
  }

  PaginatedPhotosState _stateFromResult(
    FetchPhotosPageResult result,
    PaginatedPhotosState stateData,
  ) {
    switch (result) {
      case Ok(:final value):
        _cursor = value.cursor;
        _hasNextPage = _cursor.isSome;

        return stateData.copyWith(
          loading: const Ok(PaginatedPhotosLoadingState.ready),
          images: stateData.images + value.images,
        );
      case Err(:final error):
        _hasNextPage = false;

        return stateData.copyWith(loading: Err('$error'));
    }
  }
}