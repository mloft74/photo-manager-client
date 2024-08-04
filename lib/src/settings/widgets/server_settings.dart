import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager_client/src/extensions/widget_extension.dart';
import 'package:photo_manager_client/src/persistence/server/pods/selected_server_pod.dart';
import 'package:photo_manager_client/src/server_list/server_list.dart';

class ServerSettings extends ConsumerWidget {
  const ServerSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedServerPod);
    return ListTile(
      onTap: () {
        const ServerList().pushMaterialRouteUnawaited(context);
      },
      title: const Text('Servers'),
      subtitle: selected.map((value) => Text(value.name)).toNullable(),
      trailing: const Icon(Icons.arrow_forward),
    );
  }
}
