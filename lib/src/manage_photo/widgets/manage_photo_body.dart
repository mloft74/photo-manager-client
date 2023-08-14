import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/domain/hosted_image.dart';
import 'package:photo_manager_client/src/manage_photo/widgets/manage_photo_body/pods/manage_photo_image_pod.dart';
import 'package:photo_manager_client/src/manage_photo/widgets/manage_photo_body/pods/rename_photo_pod.dart';
import 'package:photo_manager_client/src/manage_photo/widgets/manage_photo_body/widgets/rename_photo_dialog.dart';
import 'package:photo_manager_client/src/pods/photo_url_pod.dart';

class ManagePhotoBody extends HookConsumerWidget {
  final HostedImage initialImage;

  const ManagePhotoBody({
    required this.initialImage,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fileName = ref.watch(
      managePhotoImagePod(initialImage: initialImage)
          .select((value) => value.image.fileName),
    );
    final res = ref.watch(photoUrlPod(fileName: fileName));

    return Column(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: switch (res) {
              Ok(:final value) => CachedNetworkImage(imageUrl: value),
              Err(:final error) => Text(
                  '$error',
                  textAlign: TextAlign.center,
                ),
            },
          ),
        ),
        const SizedBox(height: 4.0),
        Text('Name: $fileName', textAlign: TextAlign.center),
        const SizedBox(height: 8.0),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () async {
              await _onRenamePressed(context, ref, fileName, initialImage);
            },
            child: const Text('Rename'),
          ),
        ),
      ],
    );
  }
}

Future<()> _onRenamePressed(
  BuildContext context,
  WidgetRef ref,
  String fileName,
  HostedImage initialImage,
) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);

  final newName = await showDialog<String>(
    context: context,
    builder: (context) => RenamePhotoDialog(currentFileName: fileName),
  ).toFutureOption();
  if (newName case Some(value: final newName)) {
    final res = await _renamePhoto(
      scaffoldMessenger,
      ref,
      oldName: fileName,
      newName: newName,
    );
    if (res case Ok()) {
      ref
          .read(managePhotoImagePod(initialImage: initialImage).notifier)
          .fileName = newName;
    }
  }

  return ();
}

Future<Result<(), ()>> _renamePhoto(
  ScaffoldMessengerState scaffoldMessenger,
  WidgetRef ref, {
  required String oldName,
  required String newName,
}) async {
  final renamePhotoRes = ref.read(renamePhotoPod);
  switch (renamePhotoRes) {
    case Err(:final error):
      scaffoldMessenger.showSnackBar(SnackBar(content: Text('Error: $error')));
      return const Err(());
    case Ok(value: final renamePhoto):
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Renaming $oldName to $newName')));
      final result = await renamePhoto(oldName: oldName, newName: newName);
      scaffoldMessenger.clearSnackBars();
      if (result case Err(:final error)) {
        scaffoldMessenger
            .showSnackBar(SnackBar(content: Text('Error: $error')));
        return const Err(());
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Renamed $oldName to $newName')),
        );
        return const Ok(());
      }
  }
}
