import 'dart:async';
import 'dart:developer';

import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/home/widgets/photo_view/providers/models/paginated_photos_state.dart';
import 'package:photo_manager_client/src/home/widgets/photo_view/providers/paginated_photos_provider/models/photos_page.dart';
import 'package:photo_manager_client/src/home/widgets/photo_view/providers/paginated_photos_provider/providers/fetch_photos_page_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'paginated_photos_provider.g.dart';

@riverpod
class PaginatedPhotos extends _$PaginatedPhotos {
  var _cursor = const Option<int>.none();
  var _hasNextPage = true;

  @override
  Future<PaginatedPhotosState> build() async {
    final fetchPhotosPage = ref.watch(fetchPhotosPageProvider);
    final result = await fetchPhotosPage(
      _cursor,
    );
    return _stateFromResult(
      result,
      const PaginatedPhotosState(
        loading: Ok(PaginatedPhotosLoadingState.loading),
        images: [],
      ),
    );
  }

  Future<void> refreshImages() async {
    _cursor = const None();
    _hasNextPage = true;
    state = const AsyncData(
      PaginatedPhotosState(
        loading: Ok(PaginatedPhotosLoadingState.ready),
        images: [],
      ),
    );

    await nextPage();
  }

  Future<void> nextPage() async {
    if (state case AsyncData(value: final stateData)) {
      final shouldShortCircuitLoading = stateData.loading
          .map((value) => value == PaginatedPhotosLoadingState.loading)
          .unwrapOr(true);
      if (shouldShortCircuitLoading || !_hasNextPage) {
        return;
      }
      state = AsyncData(
        stateData.copyWith(
          loading: const Ok(PaginatedPhotosLoadingState.loading),
        ),
      );

      final fetchPhotosPage = ref.read(fetchPhotosPageProvider);
      final result = await fetchPhotosPage(
        _cursor,
      );
      state = AsyncData(_stateFromResult(result, stateData));
    }
  }

  PaginatedPhotosState _stateFromResult(
    Result<PhotosPage, String> result,
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
        log(
          'error fetching page',
          name: 'paginatedPhotosProvider | nextPage',
          error: error,
        );

        _hasNextPage = false;

        return stateData.copyWith(loading: Err(error));
    }
  }
}
