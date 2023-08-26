import 'package:flutter/material.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/errors/displayable.dart';

/// Runs a closure and shows toasts.
Future<Result<R, E>> runWithToasts<R extends Object, E extends Displayable>({
  required ScaffoldMessengerState messenger,
  required Future<Result<R, E>> Function() op,
  required String startingMsg,
  required String finishedMsg,
}) async {
  messenger.showSnackBar(SnackBar(content: Text(startingMsg)));
  final res = await op();
  messenger
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: Text(
          switch (res) {
            Err(:final error) => error.toDisplayJoined(),
            Ok() => finishedMsg,
          },
        ),
      ),
    );

  return res;
}
