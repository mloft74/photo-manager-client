import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/errors/error_trace.dart';
import 'package:photo_manager_client/src/extensions/date_time_keep_extension.dart';
import 'package:photo_manager_client/src/persistence/keys.dart';
import 'package:photo_manager_client/src/persistence/shared_prefs_pod.dart';
import 'package:photo_manager_client/src/pods/logs_pod.dart';

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
      _saveLogs();
    }
  }

  () _saveLogs() {
    final logs = ref.read(logsPod);
    if (logs.isEmpty) {
      return ();
    }
    ref.read(logsPod.notifier).keepLogsWithDay(DateTime.timestamp());

    final grouped = groupBy(
      logs,
      (l) => l.timestamp.withPrecision(DateTimeComponent.day),
    );

    final prefs = ref.read(sharedPrefsPod);
    for (final MapEntry(key: date, value: logs) in grouped.entries) {
      final key = logsKeyForDate(date);
      unawaited(
        prefs
            .setStringList(
              key,
              logs.map((l) => jsonEncode(l.toJson())).toList(),
            )
            .catchError(
              (Object ex, StackTrace st) => ref.read(logsPod.notifier).logError(
                    ErrorTrace<Object>(
                      ex,
                      Some(st),
                    ),
                  ),
            ),
      );
    }

    return ();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
