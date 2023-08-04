import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:photo_manager_client/src/extensions/widget_extension.dart';
import 'package:photo_manager_client/src/persistence/server/pods/current_server_pod.dart';
import 'package:photo_manager_client/src/server_list/server_list.dart';
import 'package:photo_manager_client/src/widgets/async_value_builder.dart';

class ServerSettings extends ConsumerWidget {
  const ServerSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentServer = ref.watch(currentServerPod);
    return AsyncValueBuilder(
      asyncValue: currentServer,
      builder: (context, value) {
        return ListTile(
          onTap: () {
            const ServerList().pushMaterialRouteUnawaited(context);
          },
          title: const Text('Servers'),
          subtitle: value.map((value) => Text(value.name)).toNullable(),
          trailing: const Icon(Icons.arrow_forward),
        );
      },
    );
  }
}
