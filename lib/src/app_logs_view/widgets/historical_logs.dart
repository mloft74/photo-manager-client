import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager_client/src/app_logs_view/widgets/error_parsing_logs.dart';
import 'package:photo_manager_client/src/app_logs_view/widgets/logs_display.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/persistence/parse_logs.dart';
import 'package:photo_manager_client/src/persistence/shared_prefs_pod.dart';

final class HistoricalLogs extends ConsumerWidget {
  final String logsKey;

  const HistoricalLogs({
    required this.logsKey,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(sharedPrefsPod);
    final parsedLogs = parseLogs(prefs, logsKey);
    switch (parsedLogs) {
      case Ok(:final value):
        return LogsDisplay(logs: value);
      case Err(:final error):
        return ErrorParsingLogs(error: error);
    }
  }
}
