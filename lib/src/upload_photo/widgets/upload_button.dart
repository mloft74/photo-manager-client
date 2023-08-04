import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/domain/server.dart';
import 'package:photo_manager_client/src/persistence/server/pods/current_server_pod.dart';
import 'package:photo_manager_client/src/upload_photo/widgets/pods/errors/upload_photo_error.dart';
import 'package:photo_manager_client/src/upload_photo/widgets/pods/photo_pod.dart';
import 'package:photo_manager_client/src/upload_photo/widgets/pods/upload_photo_pod.dart';

class UploadButton extends ConsumerWidget {
  const UploadButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoPath =
        ref.watch(photoPod).asData.option.andThen((value) => value.value);
    final currentServer = ref
        .watch(currentServerPod)
        .asData
        .option
        .andThen((value) => value.value);

    return FilledButton.icon(
      onPressed: photoPath
          .zip(currentServer)
          .map(
            (value) => () async {
              final (photoPath, server) = value;
              await _onButtonPressed(
                context: context,
                ref: ref,
                photoPath: photoPath,
                server: server,
              );
            },
          )
          .nullable,
      icon: const Icon(Icons.upload),
      label: const Text('Upload'),
    );
  }
}

Future<()> _onButtonPressed({
  required BuildContext context,
  required WidgetRef ref,
  required String photoPath,
  required Server server,
}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context)
    ..showSnackBar(
      SnackBar(
        content: Text('Uploading $photoPath'),
        duration: const Duration(seconds: 1),
      ),
    );

  final res = await ref.read(uploadPhotoPod)(
    path: photoPath,
    serverUri: server.uri,
  );

  final String msg;
  final Duration duration;
  switch (res) {
    case Ok():
      msg = 'Upload finished';
      duration = const Duration(seconds: 1);
    case Err(error: ImageAlreadyExists()):
      msg = 'Image already exists';
      duration = const Duration(seconds: 4);
    case Err(error: UnknownBody(:final body)):
      msg = 'Unknown body: $body';
      duration = const Duration(seconds: 4);
    case Err(error: ErrorOccurred(:final error)):
      msg = 'Error occurred: $error';
      duration = const Duration(seconds: 4);
  }

  scaffoldMessenger.showSnackBar(
    SnackBar(
      content: Text(msg),
      duration: duration,
    ),
  );

  return ();
}
