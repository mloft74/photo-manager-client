import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/errors/displayable.dart';
import 'package:photo_manager_client/src/errors/error_trace.dart';
import 'package:photo_manager_client/src/extensions/date_time_keep_extension.dart';
import 'package:photo_manager_client/src/persistence/keys.dart';
import 'package:photo_manager_client/src/persistence/shared_prefs_pod.dart';
import 'package:photo_manager_client/src/pods/logs_pod.dart';
import 'package:photo_manager_client/src/pods/models/log_topic.dart';

final class LogSaver extends ConsumerStatefulWidget {
  final Widget child;

  const LogSaver({
    required this.child,
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LogSaverState();
}

final class _LogSaverState extends ConsumerState<LogSaver>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.hidden) {
      unawaited(_saveLogs());
    }
  }

  Future<()> _saveLogs() async {
    final logs = ref.read(logsPod);
    if (logs.isEmpty) {
      return ();
    }
    final timestamp = DateTime.timestamp().withPrecision(DateTimeComponent.day);
    ref.read(logsPod.notifier).keepLogsWithDay(timestamp);

    final prefs = ref.read(sharedPrefsPod);

    final grouped = groupBy(
      logs,
      (l) => l.timestamp.withPrecision(DateTimeComponent.day),
    );
    final setFuts = <Future<void>>[];
    for (final MapEntry(key: date, value: logs) in grouped.entries) {
      final key = logsKeyForDate(date);
      setFuts.add(
        prefs
            .setStringList(
              key,
              logs.map((l) => jsonEncode(l.toJson())).toList(),
            )
            .catchError(
              (Object ex, StackTrace st) => ref.read(logsPod.notifier).logError(
                    LogTopic.persistence,
                    CompoundDisplayable(
                      IList([
                        DefaultDisplayable(IList(['Error saving logs $key'])),
                        ErrorTrace(
                          ex,
                          Some(st),
                        ),
                      ]),
                    ),
                  ),
            ),
      );
    }

    await Future.wait(setFuts);

    final dates = prefs.keys
        .where((e) => e.startsWith(logsPrefix))
        .map((e) => (e, dateTimeFromKey(e)));
    final cutoff = timestamp.subtract(const Duration(days: 30));
    final deleteFuts = <Future<void>>[];
    for (final (key, date) in dates) {
      if (date.isBefore(cutoff)) {
        deleteFuts.add(
          prefs.remove(key).catchError(
                (Object ex, StackTrace st) =>
                    ref.read(logsPod.notifier).logError(
                          LogTopic.persistence,
                          CompoundDisplayable(
                            IList([
                              DefaultDisplayable(
                                IList(['Error deleting logs $key']),
                              ),
                              ErrorTrace(
                                ex,
                                Some(st),
                              ),
                            ]),
                          ),
                        ),
              ),
        );
      }
    }

    await Future.wait(deleteFuts);

    return ();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
