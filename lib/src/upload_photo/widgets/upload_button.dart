import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/upload_photo/upload_photo.dart';
import 'package:photo_manager_client/src/upload_photo/widgets/pods/photo_pod.dart';
import 'package:photo_manager_client/src/upload_photo/widgets/pods/upload_photo_pod.dart';

class UploadButton extends ConsumerWidget {
  const UploadButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoPath =
        ref.watch(photoPod).asData.toOption().andThen((value) => value.value);

    return FilledButton.icon(
      onPressed: photoPath
          .map(
            (value) => () async {
              await _onButtonPressed(
                context: context,
                ref: ref,
                photoPath: value,
              );
            },
          )
          .toNullable(),
      icon: const Icon(Icons.upload),
      label: const Text('Upload'),
    );
  }
}

Future<()> _onButtonPressed({
  required BuildContext context,
  required WidgetRef ref,
  required String photoPath,
}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);

  final uploadPhotoRes = ref.read(uploadPhotoPod);

  switch (uploadPhotoRes) {
    case Err(:final error):
      scaffoldMessenger.showSnackBar(SnackBar(content: Text('$error')));
    case Ok(value: final uploadPhoto):
      final res = await uploadPhoto(photoPath);
      if (res case Err(:final error)) {
        scaffoldMessenger.showSnackBar(SnackBar(content: Text('$error')));
      } else {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Upload finished'),
          ),
        );
        navigator.pop(UploadPhotoResponse.photoUploaded);
      }
  }

  return ();
}
