import 'package:photo_manager_client/src/domain/hosted_image.dart';
import 'package:photo_manager_client/src/manage_photo/widgets/manage_photo_body/pods/models/manage_photo_image_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'manage_photo_image_pod.g.dart';

@riverpod
class ManagePhotoImage extends _$ManagePhotoImage {
  @override
  ManagePhotoImageState build({
    required HostedImage initialImage,
  }) {
    return ManagePhotoImageState(image: initialImage);
  }

  void updateFileName(String value) {
    state = ManagePhotoImageState(
      image: state.image.copyWith(fileName: value),
      renamed: true,
    );
  }
}
