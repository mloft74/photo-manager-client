import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/foundation.dart';
import 'package:photo_manager_client/src/errors/displayable.dart';
import 'package:photo_manager_client/src/extensions/date_time_keep_extension.dart';
import 'package:photo_manager_client/src/pods/models/log.dart';
import 'package:photo_manager_client/src/pods/models/log_level.dart';
import 'package:photo_manager_client/src/pods/models/log_topic.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'logs_pod.g.dart';

() _printLogInDebugMode(Log log) {
  if (kDebugMode) {
    _printLog(log);
  }

  return ();
}

() _printLog(Log log) {
  debugPrint(
    '[${log.level.name}] <${log.topic.name}> {${log.timestamp}} ${log.log.join('\n\t')}',
  );

  return ();
}

@Riverpod(keepAlive: true)
class Logs extends _$Logs {
  // ---START: EVIL HACKS TO AVOID ASYNC BUILD---
  static IList<Log> _startingLogs = const IListConst([]);

  static var _injected = false;
  static () inject(IList<Log> logs) {
    if (_injected) {
      throw StateError('Logs have already been injected');
    }

    if (kDebugMode) {
      for (final log in logs) {
        _printLog(log);
      }
    }

    _startingLogs = logs;
    _injected = true;

    return ();
  }

  @override
  IList<Log> build() {
    return _startingLogs;
  }
  // ---END: EVIL HACKS TO AVOID ASYNC BUILD---

  /// Converts to UTC first.
  () keepLogsWithDay(DateTime date) {
    final utc = date.toUtc();
    final fixed = utc.withPrecision(DateTimeComponent.day);
    state = state
        .where((l) => l.timestamp.withPrecision(DateTimeComponent.day) == fixed)
        .toIList();

    return ();
  }

  () log(LogLevel level, LogTopic topic, Displayable msg) {
    final log = Log(
      log: msg.toDisplay().toIList(),
      topic: topic,
      level: level,
      timestamp: DateTime.timestamp(),
    );
    _printLogInDebugMode(log);
    state = state.add(log);
    return ();
  }

  () logError(LogTopic topic, Displayable msg) {
    final log = Log(
      log: msg.toDisplay().toIList(),
      topic: topic,
      level: LogLevel.error,
      timestamp: DateTime.timestamp(),
    );
    _printLogInDebugMode(log);
    state = state.add(log);
    return ();
  }

  () logWarning(LogTopic topic, Displayable msg) {
    final log = Log(
      log: msg.toDisplay().toIList(),
      topic: topic,
      level: LogLevel.warning,
      timestamp: DateTime.timestamp(),
    );
    _printLogInDebugMode(log);
    state = state.add(log);
    return ();
  }

  () logInfo(LogTopic topic, Displayable msg) {
    final log = Log(
      log: msg.toDisplay().toIList(),
      topic: topic,
      level: LogLevel.info,
      timestamp: DateTime.timestamp(),
    );
    _printLogInDebugMode(log);
    state = state.add(log);
    return ();
  }

  () logDebug(LogTopic topic, Displayable msg) {
    final log = Log(
      log: msg.toDisplay().toIList(),
      topic: topic,
      level: LogLevel.debug,
      timestamp: DateTime.timestamp(),
    );
    _printLogInDebugMode(log);
    state = state.add(log);
    return ();
  }
}
