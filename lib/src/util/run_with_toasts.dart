import 'package:flutter/material.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';

Future<Result<R, E>> runWithToasts<R extends Object, E extends Object>({
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
            Err(:final error) => 'Error: $error',
            Ok() => finishedMsg,
          },
        ),
      ),
    );

  return res;
}
