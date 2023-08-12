import 'package:photo_manager_client/src/domain/hosted_image.dart';
import 'package:photo_manager_client/src/manage_photo/widgets/manage_photo_body/pods/models/manage_photo_image_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'manage_photo_image_pod.g.dart';

@Riverpod(dependencies: [])
class ManagePhotoImage extends _$ManagePhotoImage {
  // Needed to override the starting value
  // ignore: avoid_public_notifier_properties
  late final HostedImage initialImage;

  @override
  ManagePhotoImageState build() {
    return ManagePhotoImageState(image: initialImage);
  }

  // The pod is the setter.
  // ignore: avoid_setters_without_getters
  set fileName(String value) {
    state = ManagePhotoImageState(
      image: state.image.copyWith(fileName: value),
      renamed: true,
    );
  }
}
