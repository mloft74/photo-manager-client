import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager_client/src/consts.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/extensions/widget_extension.dart';
import 'package:photo_manager_client/src/home/pods/paginated_photos_pod.dart';
import 'package:photo_manager_client/src/upload_photo/upload_photo.dart';

class PhotoViewNoImages extends ConsumerWidget {
  const PhotoViewNoImages({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      reverse: true,
      padding: edgeInsetsForRoutePadding,
      children: [
        FilledButton.icon(
          onPressed: () async {
            final response = await const UploadPhoto()
                .pushMaterialRoute<UploadPhotoResponse>(context);
            if (response case Some(value: UploadPhotoResponse.photoUploaded)) {
              await ref.read(paginatedPhotosPod.notifier).reset();
            }
          },
          icon: const Icon(Icons.add),
          label: const Text('Add image'),
        ),
        const SizedBox(height: 16.0),
        Text(
          'No images found',
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
