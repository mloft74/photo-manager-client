import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:photo_manager_client/src/consts.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/domain/hosted_image.dart';
import 'package:photo_manager_client/src/manage_photo/pods/delete_photo_pod.dart';
import 'package:photo_manager_client/src/manage_photo/widgets/confirm_delete_photo_dialog.dart';
import 'package:photo_manager_client/src/manage_photo/widgets/manage_photo_body.dart';
import 'package:photo_manager_client/src/manage_photo/widgets/manage_photo_body/pods/manage_photo_image_pod.dart';
import 'package:photo_manager_client/src/util/run_with_toasts.dart';
import 'package:photo_manager_client/src/widgets/photo_manager_bottom_app_bar.dart';
import 'package:photo_manager_client/src/widgets/photo_manager_scaffold.dart';

enum ManagePhotoResponse {
  photoDeleted,
  photoRenamed,
}

class ManagePhoto extends ConsumerWidget {
  final HostedImage initialImage;

  const ManagePhoto({
    required this.initialImage,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final image = ref.watch(
      managePhotoImagePod(initialImage: initialImage)
          .select((value) => value.image),
    );
    return PhotoManagerScaffold(
      bottomAppBar: PhotoManagerBottomAppBar(
        leading: BackButton(
          onPressed: () {
            final renamed = ref
                .read(managePhotoImagePod(initialImage: initialImage))
                .renamed;
            if (renamed) {
              Navigator.pop(context, ManagePhotoResponse.photoRenamed);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        titleText: 'Manage Photo',
        actions: [
          IconButton(
            onPressed: () async {
              await _onDeletePressed(context, ref, image);
            },
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      child: Padding(
        padding: edgeInsetsForRoutePadding,
        child: ManagePhotoBody(
          initialImage: initialImage,
        ),
      ),
    );
  }
}

Future<()> _onDeletePressed(
  BuildContext context,
  WidgetRef ref,
  HostedImage image,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);

  final response = await showDialog<DeletePhotoResponse>(
    context: context,
    builder: (context) => const DeletePhotoDialog(),
  ).toFutureOption();
  final shouldDelete = response
      .andThen(
        (value) => value == DeletePhotoResponse.delete
            ? const Some(())
            : const None<()>(),
      )
      .isSome;
  if (!shouldDelete) {
    return ();
  }

  final deletePhotoRes = ref.read(deletePhotoPod);
  switch (deletePhotoRes) {
    case Err(:final error):
      messenger.showSnackBar(SnackBar(content: Text('Error: $error')));
    case Ok(value: final deletePhoto):
      final res = runWithToasts(
        messenger: messenger,
        op: () => deletePhoto(image),
        startingMsg: 'Deleting ${image.fileName}',
        finishedMsg: 'Deleted ${image.fileName}',
      );
      if (res case Ok()) {
        navigator.pop(ManagePhotoResponse.photoDeleted);
      }
  }

  return ();
}
