import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:photo_manager_client/src/persistence/server/providers/current_server_provider.dart';
import 'package:photo_manager_client/src/server_list/server_list.dart';
import 'package:photo_manager_client/src/widgets/async_value_builder.dart';

class ServerSettings extends ConsumerWidget {
  const ServerSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentServer = ref.watch(currentServerProvider);
    return AsyncValueBuilder(
      asyncValue: currentServer,
      builder: (context, value) {
        return ListTile(
          onTap: () {
            unawaited(
              Navigator.push<void>(
                context,
                MaterialPageRoute(
                  builder: (context) => const ServerList(),
                ),
              ),
            );
          },
          title: const Text('Servers'),
          subtitle: value.map((value) => Text(value.name)).nullable,
          trailing: const Icon(Icons.arrow_forward),
        );
      },
    );
  }
}
