import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager_client/src/consts.dart';
import 'package:photo_manager_client/src/extensions/widget_extension.dart';
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
            const UploadPhoto().pushMaterialRouteUnawaited(context);
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
