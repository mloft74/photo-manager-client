import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/upload_photo/providers/photo.dart';

class ImageDisplay extends ConsumerWidget {
  const ImageDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (ref.watch(photoProvider)) {
      AsyncData(value: Some(:final value)) => Image.file(File(value.path)),
      AsyncData(value: None()) => const Text('Select an image'),
      AsyncError(:final error) => Text('$error'),
      _ => const SizedBox.shrink(),
    };
  }
}
