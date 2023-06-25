import 'dart:developer';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectPhotoButton extends ConsumerWidget {
  const SelectPhotoButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FilledButton(
      onPressed: () async {
        final foo = await FilePicker.platform.getDirectoryPath();
        log('foo: $foo', name: 'select_photo_button');
        //   unawaited(
        //   ref.read(photoProvider.notifier).updateAsync(
        //         () async =>
        //             (await ImagePicker().pickImage(source: ImageSource.gallery))
        //                 .option,
        //       ),
        // );
      },
      child: const Text('Choose image'),
    );
  }
}
