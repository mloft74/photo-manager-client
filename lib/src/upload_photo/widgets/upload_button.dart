import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/domain/server.dart';
import 'package:photo_manager_client/src/persistence/server/pods/current_server_pod.dart';
import 'package:photo_manager_client/src/upload_photo/pods/errors/upload_photo_error.dart';
import 'package:photo_manager_client/src/upload_photo/pods/photo_pod.dart';
import 'package:photo_manager_client/src/upload_photo/pods/upload_photo_pod.dart';

class UploadButton extends ConsumerWidget {
  const UploadButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photo = switch (ref.watch(photoPod)) {
      AsyncData(:final value) => value,
      _ => const None<PhotoStateValue>(),
    };
    final currentServer = switch (ref.watch(currentServerPod)) {
      AsyncData(:final value) => value,
      _ => const None<Server>(),
    };

    return FilledButton.icon(
      onPressed: photo
          .zip(currentServer)
          .map(
            (value) => () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final (path, server) = value;
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text('Uploading $path'),
                  duration: const Duration(seconds: 1),
                ),
              );
              final res = await ref.read(uploadPhotoPod)(
                path: path,
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
                case Err(error: GeneralMessage(:final message)):
                  msg = message;
                  duration = const Duration(seconds: 4);
                case Err(error: ExceptionOccurred(:final ex, :final st)):
                  log(
                    'error uploading photo $path',
                    error: ex,
                    stackTrace: st,
                    name: 'UploadButton | onPressed',
                  );
                  msg = ex.toString();
                  duration = const Duration(seconds: 4);
              }
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text(msg),
                  duration: duration,
                ),
              );
            },
          )
          .nullable,
      icon: const Icon(Icons.upload),
      label: const Text('Upload'),
    );
  }
}
