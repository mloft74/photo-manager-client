import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/upload_photo/upload_photo.dart';
import 'package:photo_manager_client/src/upload_photo/widgets/pods/upload_candidates_pod.dart';
import 'package:photo_manager_client/src/upload_photo/widgets/pods/upload_photo_pod.dart';
import 'package:photo_manager_client/src/util/run_with_toasts.dart';

class UploadButton extends ConsumerWidget {
  const UploadButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final candidates = ref.watch(uploadCandidatesPod);

    return FilledButton.icon(
      onPressed: candidates.isEmpty
          ? null
          : () {
              unawaited(
                _onButtonPressed(
                  context: context,
                  ref: ref,
                ),
              );
            },
      icon: const Icon(Icons.upload),
      label: const Text('Upload'),
    );
  }
}

Future<()> _onButtonPressed({
  required BuildContext context,
  required WidgetRef ref,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);

  ref.read(uploadCandidatesPod.notifier).upload();

  return ();

  //final uploadPhotoRes = ref.read(uploadPhotoPod);

  //switch (uploadPhotoRes) {
  //  case None():
  //    messenger
  //        .showSnackBar(const SnackBar(content: Text('No server selected')));
  //  case Some(value: final uploadPhoto):
  //    final res = await runWithToasts(
  //      messenger: messenger,
  //      op: () => uploadPhoto(photoPath),
  //      startingMsg: 'Uploading',
  //      finishedMsg: 'Upload finished',
  //    );
  //    if (res case Ok()) {
  //      navigator.pop(UploadPhotoResponse.photoUploaded);
  //    }
  //}

  //return ();
}
