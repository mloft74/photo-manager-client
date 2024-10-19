import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_manager_client/src/consts.dart';
import 'package:photo_manager_client/src/pods/models/log.dart';
import 'package:photo_manager_client/src/widgets/photo_manager_bottom_app_bar.dart';
import 'package:photo_manager_client/src/widgets/photo_manager_scaffold.dart';

final class LogsDisplay extends StatelessWidget {
  final IList<Log> logs;

  const LogsDisplay({
    required this.logs,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return PhotoManagerScaffold(
      bottomAppBar: const PhotoManagerBottomAppBar(
        leading: BackButton(),
        titleText: 'Viewing Logs',
      ),
      child: ListView.builder(
        padding: edgeInsetsForRoutePadding,
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final log = logs[index];
          final msg = '<${log.topic}> ${log.log.join('\n')}';
          return Card(
            child: ListTile(
              onTap: () {
                // TODO(mloft74): Add snackbar display saying message was copied to clipboard
                unawaited(
                  Clipboard.setData(ClipboardData(text: log.toLogMessage())),
                );
              },
              isThreeLine: true,
              title: Text(msg),
              subtitle: Text('${log.level}\n${log.timestamp}'),
            ),
          );
        },
      ),
    );
  }
}
