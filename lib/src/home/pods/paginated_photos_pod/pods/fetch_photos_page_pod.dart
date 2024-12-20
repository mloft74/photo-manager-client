import 'dart:async';
import 'dart:convert';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/domain/hosted_image.dart';
import 'package:photo_manager_client/src/domain/server.dart';
import 'package:photo_manager_client/src/errors/error_trace.dart';
import 'package:photo_manager_client/src/extensions/pipe_extension.dart';
import 'package:photo_manager_client/src/extensions/response_extension.dart';
import 'package:photo_manager_client/src/home/pods/date_sorting_pod.dart';
import 'package:photo_manager_client/src/home/pods/paginated_photos_pod/models/photos_page.dart';
import 'package:photo_manager_client/src/http/errors/general_http_error.dart';
import 'package:photo_manager_client/src/http/pods/http_client_pod.dart';
import 'package:photo_manager_client/src/http/timeout.dart';
import 'package:photo_manager_client/src/persistence/server/pods/selected_server_pod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'fetch_photos_page_pod.g.dart';

typedef FetchPhotosPageResult = Result<PhotosPage, GeneralHttpError>;

Future<FetchPhotosPageResult> _fetchPhotosPage(
  http.Client client,
  Server server,
  DateSortingState sorting,
  Option<int> after,
) async {
  try {
    const countParam = 'count=50';
    final sortingValue = switch (sorting) {
      DateSortingState.newToOld => 'newToOld',
      DateSortingState.oldToNew => 'oldToNew',
    };
    final sortingParam = 'order=$sortingValue';
    final alwaysParams = '$countParam&$sortingParam';
    final params = after.mapOr(
      map: (value) => '$alwaysParams&after=$value',
      or: alwaysParams,
    );
    final uri = Uri.parse('${server.uri}/api/image/paginated?$params');

    final response = await client.get(uri).timeout(mediumTimeout);
    if (response.statusCode != 200) {
      return Err(NotOk(response.reasonPhraseNonNull));
    }

    final bodyStr = response.body;
    final body = jsonDecode(bodyStr);
    if (body
        case {
          'cursor': final int? cursor,
          'images': final List<dynamic> images,
        }) {
      final parsedImages = images
          .map(
            (e) => HostedImage(
              // ignore: avoid_dynamic_calls
              fileName: e['fileName'] as String,
              // ignore: avoid_dynamic_calls
              width: e['width'] as int,
              // ignore: avoid_dynamic_calls
              height: e['height'] as int,
            ),
          )
          .pipe(IList.new);

      return Ok(
        PhotosPage(
          images: parsedImages,
          cursor: cursor.toOption(),
        ),
      );
    } else {
      return Err(UnknownBody(bodyStr));
    }
  } on TimeoutException {
    return const Err(TimedOut());
  } catch (ex, st) {
    return Err(ErrorOccurred(ErrorTrace(ex, Some(st))));
  }
}

typedef FetchPhotosPageFn = Future<FetchPhotosPageResult> Function(
  Option<int> after,
);

typedef FetchPhotosPagePodOption = Option<FetchPhotosPageFn>;

@riverpod
Option<FetchPhotosPageFn> fetchPhotosPage(
  Ref ref,
) {
  final client = ref.watch(httpClientPod);
  final server = ref.watch(selectedServerPod);
  final sorting = ref.watch(dateSortingPod);
  return server.map(
    (value) =>
        (after) async => await _fetchPhotosPage(client, value, sorting, after),
  );
}
