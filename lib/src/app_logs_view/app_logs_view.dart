import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager_client/src/app_logs_view/widgets/historical_logs.dart';
import 'package:photo_manager_client/src/app_logs_view/widgets/today_logs.dart';
import 'package:photo_manager_client/src/consts.dart';
import 'package:photo_manager_client/src/extensions/widget_extension.dart';
import 'package:photo_manager_client/src/persistence/keys.dart';
import 'package:photo_manager_client/src/persistence/shared_prefs_pod.dart';
import 'package:photo_manager_client/src/widgets/photo_manager_bottom_app_bar.dart';
import 'package:photo_manager_client/src/widgets/photo_manager_scaffold.dart';

const _todayText = 'Today';

final class AppLogsView extends ConsumerWidget {
  const AppLogsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(sharedPrefsPod);
    final keys = prefs.keys.lock;
    final fixedKeys = keys
        .where((e) => e.startsWith(logsPrefix))
        .toISet()
        .remove(logsKeyForDate(DateTime.timestamp()));
    final sorted = fixedKeys.toIList().sortReversed().insert(0, _todayText);
    return PhotoManagerScaffold(
      bottomAppBar: const PhotoManagerBottomAppBar(
        leading: BackButton(),
        titleText: 'App Logs',
      ),
      child: ListView.builder(
        padding: edgeInsetsForRoutePadding,
        itemCount: sorted.length,
        reverse: true,
        itemBuilder: (context, index) {
          final key = sorted[index];
          return Card(
            child: ListTile(
              onTap: () {
                if (key == _todayText) {
                  const TodayLogs().pushMaterialRouteUnawaited(context);
                } else {
                  HistoricalLogs(logsKey: key)
                      .pushMaterialRouteUnawaited(context);
                }
              },
              title: Text(key),
            ),
          );
        },
      ),
    );
  }
}
