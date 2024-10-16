import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:photo_manager_client/src/errors/displayable.dart';
import 'package:photo_manager_client/src/pods/models/log.dart';
import 'package:photo_manager_client/src/pods/models/log_level.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'logs_pod.g.dart';

@Riverpod(keepAlive: true)
class Logs extends _$Logs {
  // ---START: EVIL HACKS TO AVOID ASYNC BUILD---
  static IList<Log> _startingLogs = const IListConst([]);

  static var _injected = false;
  static () inject(IList<Log> logs) {
    if (_injected) {
      throw StateError('Logs have already been injected');
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

  () log(LogLevel level, Displayable log) {
    state = state.add(
      Log(
        log: log.toDisplay().toIList(),
        level: level,
        timestamp: DateTime.now(),
      ),
    );
    return ();
  }

  () logError(Displayable log) {
    state = state.add(
      Log(
        log: log.toDisplay().toIList(),
        level: LogLevel.error,
        timestamp: DateTime.now(),
      ),
    );
    return ();
  }

  () logWarning(Displayable log) {
    state = state.add(
      Log(
        log: log.toDisplay().toIList(),
        level: LogLevel.warning,
        timestamp: DateTime.now(),
      ),
    );
    return ();
  }

  () logInfo(Displayable log) {
    state = state.add(
      Log(
        log: log.toDisplay().toIList(),
        level: LogLevel.info,
        timestamp: DateTime.now(),
      ),
    );
    return ();
  }

  () logDebug(Displayable log) {
    state = state.add(
      Log(
        log: log.toDisplay().toIList(),
        level: LogLevel.debug,
        timestamp: DateTime.now(),
      ),
    );
    return ();
  }
}