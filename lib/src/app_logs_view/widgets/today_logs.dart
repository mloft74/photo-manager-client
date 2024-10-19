import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager_client/src/app_logs_view/widgets/logs_display.dart';
import 'package:photo_manager_client/src/extensions/date_time_keep_extension.dart';
import 'package:photo_manager_client/src/pods/logs_pod.dart';

final class TodayLogs extends ConsumerWidget {
  const TodayLogs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(logsPod);
    final timestamp = DateTime.timestamp().withPrecision(DateTimeComponent.day);
    final fixed = logs
        .where(
          (l) => l.timestamp.withPrecision(DateTimeComponent.day) == timestamp,
        )
        .toIList();
    return LogsDisplay(logs: fixed);
  }
}
