import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager_client/src/app_logs_view/widgets/today_logs.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/errors/displayable.dart';
import 'package:photo_manager_client/src/extensions/widget_extension.dart';
import 'package:photo_manager_client/src/pods/logs_pod.dart';
import 'package:photo_manager_client/src/pods/models/log_level.dart';
import 'package:photo_manager_client/src/pods/models/log_topic.dart';

/// Runs a closure and shows toasts.
Future<Result<R, E>> runWithToasts<R extends Object, E extends Displayable>({
  required ScaffoldMessengerState messenger,
  required Logs logs,
  required Future<Result<R, E>> Function() op,
  required String startingMsg,
  required String finishedMsg,
  LogLevel level = LogLevel.error,
  LogTopic topic = LogTopic.parsing,
}) async {
  logs.logInfo(topic, DefaultDisplayable(IList([startingMsg])));
  messenger.showSnackBar(SnackBar(content: Text(startingMsg)));
  final res = await op();
  messenger
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: switch (res) {
          Ok() => Text(finishedMsg),
          Err() => Row(
              children: [
                const Text('An error occurred, logged'),
                const Spacer(),
                Builder(
                  builder: (context) => FilledButton(
                    onPressed: () {
                      const TodayLogs().pushMaterialRouteUnawaited(context);
                    },
                    child: const Text('Open logs'),
                  ),
                ),
              ],
            ),
        },
      ),
    );

  if (res case Err(:final error)) {
    logs.log(level, topic, error);
  } else {
    logs.logInfo(topic, DefaultDisplayable(IList([finishedMsg])));
  }

  return res;
}
