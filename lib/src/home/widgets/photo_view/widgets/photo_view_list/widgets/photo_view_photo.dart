import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/domain/hosted_image.dart';
import 'package:photo_manager_client/src/extensions/widget_extension.dart';
import 'package:photo_manager_client/src/home/pods/paginated_photos_pod.dart';
import 'package:photo_manager_client/src/manage_photo/manage_photo.dart';
import 'package:photo_manager_client/src/pods/photo_url_pod.dart';

class PhotoViewPhoto extends ConsumerWidget {
  final HostedImage image;

  const PhotoViewPhoto({
    required this.image,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final url = ref.watch(
      photoUrlPod(fileName: image.fileName),
    );
    return url.mapOrElse(
      orElse: () => const Text('No server selected'),
      map: (value) => InkWell(
        onTap: () async {
          final response = await ManagePhoto(initialImage: image)
              .pushMaterialRoute<ManagePhotoResponse>(
            context,
          );
          if (response
              case Some(
                value: ManagePhotoResponse.photoDeleted ||
                    ManagePhotoResponse.photoRenamed
              )) {
            await ref.read(paginatedPhotosPod.notifier).reset();
          }
        },
        child: CachedNetworkImage(
          imageUrl: value,
          progressIndicatorBuilder: (context, url, progress) {
            return CircularProgressIndicator(
              value: progress.progress,
            );
          },
        ),
      ),
    );
  }
}
