import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/upload_photo/providers/photo_provider.dart';

class UploadButton extends ConsumerWidget {
  const UploadButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photo = switch (ref.watch(photoProvider)) {
      AsyncData(:final value) => value,
      _ => const None<XFile>(),
    };
    return FilledButton.icon(
      onPressed: photo
          .andThen(
            (value) => Some(() {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Name: ${value.name}')),
              );
            }),
          )
          .nullable,
      icon: const Icon(Icons.upload),
      label: const Text('Upload'),
    );
  }
}
