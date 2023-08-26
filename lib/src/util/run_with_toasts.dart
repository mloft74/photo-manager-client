import 'package:flutter/material.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';

/// Runs a closure and shows toasts.
///
/// Use [errorBuilder] to customize the error message.
Future<Result<R, E>> runWithToasts<R extends Object, E extends Object>({
  required ScaffoldMessengerState messenger,
  required Future<Result<R, E>> Function() op,
  required String startingMsg,
  required String finishedMsg,
  Option<String> Function(E error)? errorBuilder,
}) async {
  messenger.showSnackBar(SnackBar(content: Text(startingMsg)));
  final res = await op();
  messenger
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: Text(
          switch (res) {
            Err(:final error) => errorBuilder
                    ?.call(error)
                    .unwrapOrElse(() => _defaultError(error)) ??
                _defaultError(error),
            Ok() => finishedMsg,
          },
        ),
      ),
    );

  return res;
}

String _defaultError<E extends Object>(E error) => 'Error: $error';
