import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager_client/src/consts.dart';
import 'package:photo_manager_client/src/extensions/widget_extension.dart';
import 'package:photo_manager_client/src/manage_server/manage_server.dart';
import 'package:photo_manager_client/src/persistence/server/pods/servers_pod.dart';
import 'package:photo_manager_client/src/server_list/widgets/server_list_item.dart';
import 'package:photo_manager_client/src/widgets/async_value_builder.dart';
import 'package:photo_manager_client/src/widgets/photo_manager_bottom_app_bar.dart';
import 'package:photo_manager_client/src/widgets/photo_manager_scaffold.dart';

class ServerList extends ConsumerWidget {
  const ServerList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servers = ref.watch(serversPod);
    return PhotoManagerScaffold(
      bottomAppBar: PhotoManagerBottomAppBar(
        leading: const BackButton(),
        titleText: 'Servers',
        actions: [
          IconButton(
            onPressed: () {
              const ManageServer().pushMaterialRouteUnawaited(context);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      child: AsyncValueBuilder(
        asyncValue: servers,
        builder: (context, servers) {
          if (servers.isEmpty) {
            return ListView(
              reverse: true,
              padding: edgeInsetsForRoutePadding,
              children: [
                FilledButton(
                  onPressed: () {
                    const ManageServer().pushMaterialRouteUnawaited(context);
                  },
                  child: const Text('Add server'),
                ),
                const SizedBox(height: 16.0),
                Text(
                  "You don't have any servers",
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ],
            );
          }

          final values = servers.values.sortedBy((element) => element.name);
          return ListView.builder(
            padding: edgeInsetsForRoutePadding,
            reverse: true,
            itemCount: values.length,
            itemBuilder: (context, index) {
              final item = values[index];
              return ServerListItem(
                server: item,
                key: ValueKey(item),
              );
            },
          );
        },
      ),
    );
  }
}
