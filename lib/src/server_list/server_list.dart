import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager_client/src/consts.dart';
import 'package:photo_manager_client/src/manage_server/manage_server.dart';
import 'package:photo_manager_client/src/persistence/server/providers/servers_provider.dart';
import 'package:photo_manager_client/src/server_list/widgets/server_list_item.dart';
import 'package:photo_manager_client/src/widgets/photo_manager_bottom_app_bar.dart';
import 'package:photo_manager_client/src/widgets/photo_manager_scaffold.dart';

class ServerList extends ConsumerWidget {
  const ServerList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servers = ref.watch(serversProvider);
    return PhotoManagerScaffold(
      bottomAppBar: PhotoManagerBottomAppBar(
        leading: const BackButton(),
        titleText: 'Servers',
        actions: [
          IconButton(
            onPressed: () {
              unawaited(
                Navigator.of(context).push<void>(
                  MaterialPageRoute(builder: (context) => const ManageServer()),
                ),
              );
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      child: switch (servers) {
        AsyncError(:final error, :final stackTrace) => Builder(
            builder: (context) {
              final errorStr = '$error';
              final theme = Theme.of(context);
              log(errorStr, stackTrace: stackTrace);
              return Center(
                child: Text(
                  errorStr,
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(color: theme.colorScheme.error),
                ),
              );
            },
          ),
        AsyncData(:final value) => Builder(
            builder: (context) {
              final servers = value.toList();
              return ListView.builder(
                padding: edgeInsetsForRoutePadding,
                reverse: true,
                itemCount: servers.length,
                itemBuilder: (context, index) {
                  final item = servers[index];
                  return ServerListItem(
                    server: item,
                    key: ValueKey(item),
                  );
                },
              );
            },
          ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}
