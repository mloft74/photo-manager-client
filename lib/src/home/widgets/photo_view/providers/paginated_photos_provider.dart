import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/domain/hosted_image.dart';
import 'package:photo_manager_client/src/home/widgets/photo_view/providers/models/paginated_photos_state.dart';
import 'package:photo_manager_client/src/home/widgets/photo_view/providers/models/photos_page.dart';
import 'package:photo_manager_client/src/persistence/server/providers/current_server_unchecked_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'paginated_photos_provider.g.dart';

@riverpod
class PaginatedPhotos extends _$PaginatedPhotos {
  var _cursor = const Option<int>.none();
  var _hasNextPage = true;

  @override
  PaginatedPhotosState build() {
    return const PaginatedPhotosState(
      loading: Ok(PaginatedPhotosLoadingState.ready),
      images: [],
    );
  }

  Future<void> refreshImages() async {
    _cursor = const None();
    _hasNextPage = true;
    state = const PaginatedPhotosState(
      loading: Ok(PaginatedPhotosLoadingState.ready),
      images: [],
    );

    await nextPage();
  }

  Future<void> nextPage() async {
    final shouldShortCircuitLoading = state.loading
        .map((value) => value == PaginatedPhotosLoadingState.loading)
        .unwrapOr(true);
    if (shouldShortCircuitLoading || !_hasNextPage) {
      return;
    }
    state =
        state.copyWith(loading: const Ok(PaginatedPhotosLoadingState.loading));

    final result = await _fetchPhotosPage();
    switch (result) {
      case Ok(:final value):
        _cursor = value.cursor;
        _hasNextPage = _cursor.isSome;

        state = state.copyWith(
          loading: const Ok(PaginatedPhotosLoadingState.ready),
          images: state.images + value.images,
        );
      case Err(:final error):
        log(
          'error fetching page',
          name: 'PhotoView | _nextPage',
          error: error,
        );

        _hasNextPage = false;

        state = state.copyWith(loading: Err(error));
    }
  }

  Future<Result<PhotosPage, String>> _fetchPhotosPage() async {
    final server = ref.read(currentServerUncheckedProvider);

    const countParam = 'count=50';
    final params = _cursor.mapOr(
      map: (value) => '$countParam&after=$value',
      or: countParam,
    );
    final uri = Uri.parse('${server.uri}/api/image/paginated?$params');
    log('uri: $uri', name: 'photosPageProvider');

    final response = await get(uri);
    if (response.statusCode != 200) {
      final reason = response.reasonPhrase ?? 'NO REASON FOUND';
      final error = 'Reason: $reason, Body: ${response.body}';
      return Err(error);
    }

    final body = jsonDecode(response.body);
    if (body
        case {
          'cursor': final int? cursor,
          'images': final List<dynamic> images,
        }) {
      final parsedImages = images
          .map(
            (e) => HostedImage(
              // ignore: avoid_dynamic_calls
              fileName: e['file_name'] as String,
              // ignore: avoid_dynamic_calls
              width: e['width'] as int,
              // ignore: avoid_dynamic_calls
              height: e['height'] as int,
            ),
          )
          .toList();

      return Ok(
        PhotosPage(
          images: parsedImages,
          cursor: cursor.option,
        ),
      );
    } else {
      return Err('Unknown body: $body');
    }
  }
}
