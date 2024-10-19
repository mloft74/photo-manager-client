import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager_client/src/widgets/photo_manager_bottom_app_bar.dart';
import 'package:photo_manager_client/src/widgets/photo_manager_scaffold.dart';

final class AppLogsView extends ConsumerWidget {
  const AppLogsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const PhotoManagerScaffold(
      bottomAppBar: PhotoManagerBottomAppBar(
        leading: BackButton(),
        titleText: 'App Logs',
      ),
      child: Placeholder(),
    );
  }
}
