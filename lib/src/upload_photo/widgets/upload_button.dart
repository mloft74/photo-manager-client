import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/extensions/partition_extension.dart';
import 'package:photo_manager_client/src/extensions/show_error_logged_snackbar.dart';
import 'package:photo_manager_client/src/home/pods/paginated_photos_pod.dart';
import 'package:photo_manager_client/src/upload_photo/widgets/pods/models/upload_candidates_state.dart';
import 'package:photo_manager_client/src/upload_photo/widgets/pods/upload_candidates_pod.dart';
import 'package:photo_manager_client/src/upload_photo/widgets/pods/upload_photo_pod.dart';

class UploadButton extends ConsumerWidget {
  const UploadButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final candidates = ref.watch(uploadCandidatesPod);

    return FilledButton.icon(
      onPressed: candidates.statuses.isEmpty ||
              candidates.statuses.any(
                (path, status) => status == UploadCandidateStatus.error,
              )
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

  messenger.showSnackBar(const SnackBar(content: Text('Starting uploads')));

  final res = await ref.read(uploadCandidatesPod.notifier).upload();

  switch (res) {
    case Err(:final error):
      messenger.clearSnackBars();
      final msg = switch (error) {
        UploadError.noCandidates => 'No photos to upload',
        UploadError.uploadInProgress => 'Upload already in progress',
      };
      messenger.showSnackBar(SnackBar(content: Text(msg)));
      return ();
    case Ok(value: final statuses):
      if (statuses.values.any((r) => r.isOk)) {
        await ref.read(paginatedPhotosPod.notifier).reset();
      }

      messenger.clearSnackBars();
      final errs = statuses.values.whereErr();
      final (pass: exists, fail: innerErr) = errs.partition(
        (e) => switch (e) {
          ImageAlreadyExists() => true,
          UnknownBody() || ErrorOccurred() || TimedOut() => false,
        },
      );
      if (innerErr.isNotEmpty) {
        messenger.showErrorLoggedSnackbar();
      } else {
        if (exists.isNotEmpty) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text(
                'Finished uploads, some already existed on the server',
              ),
            ),
          );
        } else {
          messenger
              .showSnackBar(const SnackBar(content: Text('Finished uploads')));
          navigator.pop();
        }
      }
  }

  return ();
}
