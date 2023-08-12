import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:photo_manager_client/src/domain/hosted_image.dart';

part 'manage_photo_image_state.freezed.dart';

@freezed
class ManagePhotoImageState with _$ManagePhotoImageState {
  const factory ManagePhotoImageState({
    required HostedImage image,
    @Default(false) bool renamed,
  }) = _ManagePhotoImageState;
}
