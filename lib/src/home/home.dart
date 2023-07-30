import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/extensions/widget_extension.dart';
import 'package:photo_manager_client/src/home/widgets/photo_view.dart';
import 'package:photo_manager_client/src/home/widgets/server_not_selected.dart';
import 'package:photo_manager_client/src/persistence/server/pods/current_server_pod.dart';
import 'package:photo_manager_client/src/settings/settings.dart';
import 'package:photo_manager_client/src/upload_photo/upload_photo.dart';
import 'package:photo_manager_client/src/widgets/async_value_builder.dart';
import 'package:photo_manager_client/src/widgets/photo_manager_bottom_app_bar.dart';
import 'package:photo_manager_client/src/widgets/photo_manager_scaffold.dart';

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentServer = ref.watch(currentServerPod);
    return PhotoManagerScaffold(
      bottomAppBar: PhotoManagerBottomAppBar(
        titleText: 'Home',
        actions: [
          IconButton(
            onPressed: () {
              const Settings().pushMaterialRouteUnawaited(context);
            },
            icon: const Icon(Icons.settings),
          ),
          if (currentServer case AsyncData(value: Some()))
            IconButton(
              onPressed: () {
                const UploadPhoto().pushMaterialRouteUnawaited(context);
              },
              icon: const Icon(Icons.add),
            ),
        ],
      ),
      child: AsyncValueBuilder(
        asyncValue: currentServer,
        builder: (context, value) {
          return switch (value) {
            None() => const ServerNotSelected(),
            Some() => const NewPhotoView(),
          };
        },
      ),
    );
  }
}
