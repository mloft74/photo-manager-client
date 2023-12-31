import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/upload_photo/widgets/pods/photo_pod.dart';
import 'package:photo_manager_client/src/widgets/async_value_builder.dart';

class ImageDisplay extends ConsumerWidget {
  const ImageDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncValueBuilder(
      asyncValue: ref.watch(photoPod),
      builder: (context, value) {
        return switch (value) {
          Some(:final value) => Image.file(File(value)),
          None() => const Text('Select an image'),
        };
      },
    );
  }
}
