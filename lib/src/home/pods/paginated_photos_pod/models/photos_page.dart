import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/domain/hosted_image.dart';

part 'photos_page.freezed.dart';

@freezed
class PhotosPage with _$PhotosPage {
  const factory PhotosPage({
    required IList<HostedImage> images,
    required Option<int> cursor,
  }) = _PhotosState;
}
