import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/domain/hosted_image.dart';
import 'package:photo_manager_client/src/manage_photo/pods/delete_photo_pod.dart';
import 'package:photo_manager_client/src/manage_photo/widgets/confirm_delete_photo_dialog.dart';
import 'package:photo_manager_client/src/pods/photo_url_pod.dart';
import 'package:photo_manager_client/src/widgets/photo_manager_bottom_app_bar.dart';
import 'package:photo_manager_client/src/widgets/photo_manager_scaffold.dart';

enum ManagePhotoResponse { photoDeleted, photoNotDeleted }

class ManagePhoto extends ConsumerWidget {
  final HostedImage image;
  const ManagePhoto({
    required this.image,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final res = ref.watch(photoUrlPod(fileName: image.fileName));
    final child = switch (res) {
      Ok(:final value) => CachedNetworkImage(imageUrl: value),
      Err(:final error) => Center(child: Text('$error')),
    };
    return PhotoManagerScaffold(
      bottomAppBar: PhotoManagerBottomAppBar(
        leading: BackButton(
          onPressed: () =>
              Navigator.pop(context, ManagePhotoResponse.photoNotDeleted),
        ),
        titleText: 'Manage Photo',
        actions: [
          IconButton(
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context);
              final shouldDelete = await showDialog<bool>(
                    context: context,
                    builder: (context) => const ConfirmDeletePhotoDialog(),
                  ) ??
                  false;
              if (!shouldDelete) {
                return;
              }

              final deletePhotoRes = ref.read(deletePhotoPod);
              switch (deletePhotoRes) {
                case Err(:final error):
                  scaffoldMessenger
                      .showSnackBar(SnackBar(content: Text('$error')));
                case Ok(value: final deletePhoto):
                  final result = await deletePhoto(image);
                  if (result case Err(:final error)) {
                    scaffoldMessenger
                        .showSnackBar(SnackBar(content: Text('$error')));
                  } else {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(content: Text('Deleted ${image.fileName}')),
                    );
                    navigator.pop(ManagePhotoResponse.photoDeleted);
                  }
              }
            },
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      child: child,
    );
  }
}
