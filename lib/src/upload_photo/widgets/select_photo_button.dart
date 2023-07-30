import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/upload_photo/widgets/pods/photo_pod.dart';

class SelectPhotoButton extends ConsumerWidget {
  const SelectPhotoButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FilledButton(
      onPressed: () {
        unawaited(
          ref.read(photoPod.notifier).updateAsync(
                () async => (await FilePicker.platform.pickFiles())
                    .option
                    .andThen((value) => value.paths.first.option),
              ),
        );
      },
      child: const Text('Choose image'),
    );
  }
}
