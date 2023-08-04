import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/domain/server.dart';
import 'package:photo_manager_client/src/persistence/server/pods/current_server_pod.dart';
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

  final (msg, duration) = res
      .map((value) => const ('Upload finished', Duration(seconds: 1)))
      .mapErr(
        (error) => (
          '$error',
          const Duration(seconds: 4),
        ),
      )
      // ignore: unused_result, it is destructured
      .coalesced;

  scaffoldMessenger.showSnackBar(
    SnackBar(
      content: Text(msg),
      duration: duration,
    ),
  );

  return ();
}
