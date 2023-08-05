import 'dart:async';
import 'dart:convert';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:http/http.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/domain/hosted_image.dart';
import 'package:photo_manager_client/src/domain/server.dart';
import 'package:photo_manager_client/src/errors/general_http_error.dart';
import 'package:photo_manager_client/src/extensions/pipe_extension.dart';
import 'package:photo_manager_client/src/extensions/response_extension.dart';
import 'package:photo_manager_client/src/home/widgets/photo_view/pods/paginated_photos_pod/models/photos_page.dart';
import 'package:photo_manager_client/src/persistence/server/pods/current_server_result_pod.dart'
    hide ErrorOccurred;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'fetch_photos_page_pod.g.dart';

typedef FetchPhotosPageResult = Result<PhotosPage, GeneralHttpError>;

Future<FetchPhotosPageResult> _fetchPhotosPage(
  Server server,
  Option<int> after,
) async {
  try {
    const countParam = 'count=50';
    final params = after.mapOr(
      map: (value) => '$countParam&after=$value',
      or: countParam,
    );
    final uri = Uri.parse('${server.uri}/api/image/paginated?$params');

    final response = await get(uri);
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
              fileName: e['file_name'] as String,
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
  } catch (ex, st) {
    return Err(ErrorOccurred(ex, st));
  }
}

typedef FetchPhotosPageFn = Future<FetchPhotosPageResult> Function(
  Option<int> after,
);

@riverpod
Result<FetchPhotosPageFn, CurrentServerResultError> fetchPhotosPage(
  FetchPhotosPageRef ref,
) {
  final server = ref.watch(currentServerResultPod);
  return server
      .map((value) => (after) async => await _fetchPhotosPage(value, after));
}
