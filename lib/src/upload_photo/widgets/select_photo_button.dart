import 'dart:async';

import 'package:collection/collection.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager_client/src/upload_photo/widgets/pods/upload_candidates_pod.dart';

class SelectPhotoButton extends ConsumerWidget {
  const SelectPhotoButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FilledButton(
      onPressed: () {
        unawaited(_onPressed(ref));
      },
      child: const Text('Choose image'),
    );
  }
}

Future<()> _onPressed(WidgetRef ref) async {
  final pickRes = await FilePicker.platform.pickFiles(
    type: FileType.image,
    allowMultiple: true,
  );
  if (pickRes == null) {
    return ();
  }
  final paths = pickRes.paths.whereNotNull();
  final entries =
      paths.map((e) => MapEntry(e, UploadCandidateStatus.pending));
  final state = IMap.fromEntries(entries);
  ref.read(uploadCandidatesPod.notifier).updateState(state);
  return ();
}
