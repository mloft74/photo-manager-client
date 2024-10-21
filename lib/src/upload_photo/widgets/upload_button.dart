import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager_client/src/upload_photo/widgets/pods/upload_candidates_pod.dart';

class UploadButton extends ConsumerWidget {
  const UploadButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final candidates = ref.watch(uploadCandidatesPod);

    return FilledButton.icon(
      onPressed: candidates.statuses.isEmpty
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
}
