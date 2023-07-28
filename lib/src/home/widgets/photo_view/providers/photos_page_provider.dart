import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/domain/hosted_image.dart';
import 'package:photo_manager_client/src/domain/server.dart';
import 'package:photo_manager_client/src/home/widgets/photo_view/providers/models/photos_page.dart';
import 'package:photo_manager_client/src/persistence/server/providers/current_server_unchecked_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'photos_page_provider.g.dart';

Future<Result<PhotosPage, String>> _photosPage(
  Server server,
  Option<int> after,
) async {
  const countParam = 'count=50';
  final params =
      after.mapOr(map: (value) => '$countParam&after=$value', or: countParam);
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

@riverpod
Future<Result<PhotosPage, String>> Function({required Option<int> after})
    photosPage(
  PhotosPageRef ref,
) {
  final server = ref.read(currentServerUncheckedProvider);
  return ({required after}) => _photosPage(server, after);
}
