import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/upload_photo/providers/photo_provider.dart';

class SelectPhotoButton extends ConsumerWidget {
  const SelectPhotoButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FilledButton(
      onPressed: () => unawaited(
        ref.read(photoProvider.notifier).updateAsync(
              () async =>
                  (await ImagePicker().pickImage(source: ImageSource.gallery))
                      .option,
            ),
      ),
      child: const Text('Choose image'),
    );
  }
}
