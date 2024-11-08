import 'package:flutter/material.dart';
import 'package:photo_manager_client/src/app_logs_view/app_logs_view.dart';
import 'package:photo_manager_client/src/extensions/widget_extension.dart';

final class AppLogsTile extends StatelessWidget {
  const AppLogsTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () {
          const AppLogsView().pushMaterialRouteUnawaited(context);
        },
        title: const Text('App Logs'),
        trailing: const Icon(Icons.arrow_forward),
      ),
    );
  }
}
