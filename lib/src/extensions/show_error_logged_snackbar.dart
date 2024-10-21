import 'package:flutter/material.dart';
import 'package:photo_manager_client/src/app_logs_view/widgets/today_logs.dart';
import 'package:photo_manager_client/src/extensions/widget_extension.dart';

extension ShowErrorLoggedSnackbar on ScaffoldMessengerState {
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>
      showErrorLoggedSnackbar() => showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Text('An error occurred, logged'),
                  const Spacer(),
                  Builder(
                    builder: (context) => FilledButton(
                      onPressed: () {
                        const TodayLogs().pushMaterialRouteUnawaited(context);
                      },
                      child: const Text('Open logs'),
                    ),
                  ),
                ],
              ),
            ),
          );
}
