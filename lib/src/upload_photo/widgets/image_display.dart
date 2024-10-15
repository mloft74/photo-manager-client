import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager_client/src/consts.dart';
import 'package:photo_manager_client/src/upload_photo/widgets/pods/upload_candidates_pod.dart';

class ImageDisplay extends ConsumerWidget {
  const ImageDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final candidates = ref.watch(uploadCandidatesPod).entries.toList();
    if (candidates.isEmpty) {
      return const Text('Select an image');
    }

    return GridView.builder(
      itemCount: candidates.length,
      gridDelegate: gridDelegate,
      itemBuilder: (context, index) {
        final candidate = candidates[index];
        final (color, text) = switch (candidate.value) {
          UploadCandidateStatus.pending => (Colors.grey.shade800, 'Pending'),
          UploadCandidateStatus.uploading => (
              Colors.blue.shade800,
              'Uploading'
            ),
          UploadCandidateStatus.uploaded => (Colors.green.shade800, 'Uploaded'),
          UploadCandidateStatus.error => (
              Colors.red.shade800,
              'Error',
            ),
        };
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Image.file(
                File(candidate.key),
                cacheWidth: maxGridImageWith,
              ),
            ),
            ColoredBox(
              color: color,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(text),
              ),
            ),
          ],
        );
      },
    );
  }
}
