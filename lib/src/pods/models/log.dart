import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:photo_manager_client/src/pods/models/log_level.dart';
import 'package:photo_manager_client/src/pods/models/log_topic.dart';

part 'log.freezed.dart';
part 'log.g.dart';

@freezed
class Log with _$Log {
  const Log._();

  const factory Log({
    required LogLevel level,
    required LogTopic topic,
    required DateTime timestamp,
    required IList<String> log,
  }) = _Log;

  factory Log.fromJson(Map<String, dynamic> json) => _$LogFromJson(json);

  String toLogMessage() {
    return '[${level.name}] <${topic.name}> {$timestamp} ${log.map(
          (s) => s.replaceAllMapped(
            RegExp(r'(\r?\n)'),
            (match) => '${match[0]}\t',
          ),
        ).join('\n\t')}';
  }
}
