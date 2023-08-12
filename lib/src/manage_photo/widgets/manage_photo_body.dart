import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/manage_photo/widgets/manage_photo_body/pods/manage_photo_image_pod.dart';
import 'package:photo_manager_client/src/manage_photo/widgets/manage_photo_body/pods/rename_photo_pod.dart';
import 'package:photo_manager_client/src/manage_photo/widgets/manage_photo_body/widgets/rename_photo_dialog.dart';

class ManagePhotoBody extends HookConsumerWidget {
  final String photoUrl;
  final String fileName;

  const ManagePhotoBody({
    required this.photoUrl,
    required this.fileName,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: CachedNetworkImage(imageUrl: photoUrl),
          ),
        ),
        const SizedBox(height: 4.0),
        Text('Name: $fileName', textAlign: TextAlign.center),
        const SizedBox(height: 8.0),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);

              final newName = await showDialog<String>(
                context: context,
                builder: (context) =>
                    RenamePhotoDialog(currentFileName: fileName),
              ).toFutureOption();
              if (newName case Some(value: final newName)) {
                final res = await _renamePhoto(
                  scaffoldMessenger,
                  ref,
                  oldName: fileName,
                  newName: newName,
                );
                if (res case Ok()) {
                  ref.read(managePhotoImagePod.notifier).fileName = newName;
                }
              }
            },
            child: const Text('Rename'),
          ),
        ),
      ],
    );
  }
}

Future<Result<(), ()>> _renamePhoto(
  ScaffoldMessengerState scaffoldMessenger,
  WidgetRef ref, {
  required String oldName,
  required String newName,
}) async {
  final renamePhotoRes = ref.watch(renamePhotoPod);
  switch (renamePhotoRes) {
    case Err(:final error):
      scaffoldMessenger.showSnackBar(SnackBar(content: Text('$error')));
      return const Err(());
    case Ok(value: final renamePhoto):
      final result = await renamePhoto(oldName: oldName, newName: newName);
      if (result case Err(:final error)) {
        scaffoldMessenger.showSnackBar(SnackBar(content: Text('$error')));
        return const Err(());
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Renamed to $newName')),
        );
        return const Ok(());
      }
  }
}
