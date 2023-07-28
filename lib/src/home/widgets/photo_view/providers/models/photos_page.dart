import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/domain/hosted_image.dart';

part 'photos_page.freezed.dart';

@freezed
class PhotosPage with _$PhotosPage {
  const factory PhotosPage({
    required List<HostedImage> images,
    required Option<int> cursor,
    @Default([]) List<String> errors,
  }) = _PhotosState;
}
