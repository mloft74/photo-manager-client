import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager_client/src/domain/server.dart';
import 'package:photo_manager_client/src/manage_server/manage_server.dart';
import 'package:photo_manager_client/src/persistence/server/providers/current_server_provider.dart';
import 'package:photo_manager_client/src/persistence/server/providers/remove_server_provider.dart';
import 'package:photo_manager_client/src/persistence/server/providers/update_current_server_provider.dart';
import 'package:photo_manager_client/src/widgets/async_value_builder.dart';

class ServerListItem extends ConsumerStatefulWidget {
  final Server server;

  const ServerListItem({
    required this.server,
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ServerListItemState();
}

class _ServerListItemState extends ConsumerState<ServerListItem> {
  var _removingServer = false;
  var _updatingCurrent = false;

  @override
  Widget build(BuildContext context) {
    final server = widget.server;

    if (_updatingCurrent) {
      ref.listen(updateCurrentServerProvider(server), (previous, next) {
        switch (next) {
          case AsyncError(:final error, :final stackTrace):
            log(
              'error setting current server: $error',
              stackTrace: stackTrace,
              name: 'server_list_item',
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text('Error setting ${server.name} as current: $error'),
              ),
            );
            setState(() {
              _updatingCurrent = false;
            });
          case AsyncData():
            log(
              'updated current to ${server.name}',
              name: 'server_list_item',
            );
            setState(() {
              _updatingCurrent = false;
            });
        }
      });
    }

    if (_removingServer) {
      ref.listen(removeServerProvider(server), (previous, next) {
        switch (next) {
          case AsyncError(:final error, :final stackTrace):
            log(
              'error removing server: $error',
              stackTrace: stackTrace,
              name: 'server_list_item',
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error removing ${server.name}: $error')),
            );
          case AsyncData():
            log(
              'successfully removed ${server.name}',
              name: 'server_list_item',
            );
        }
      });
    }

    final currentServer = ref.watch(currentServerProvider);

    return _removingServer
        ? const SizedBox.shrink()
        : AsyncValueBuilder(
            asyncValue: currentServer,
            builder: (context, value) {
              final selected = value.isSomeAnd((value) => value == server);
              return Dismissible(
                key: ValueKey(server),
                background: ColoredBox(
                  color: Theme.of(context).colorScheme.error,
                ),
                confirmDismiss: (direction) async => await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Delete ${server.name}?'),
                    content:
                        const Text('This will permanently delete this server'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                ),
                onDismissed: (direction) {
                  setState(() {
                    _removingServer = true;
                  });
                },
                child: ListTile(
                  selected: selected,
                  onTap: () {
                    setState(() {
                      _updatingCurrent = true;
                    });
                  },
                  title: Text(server.name),
                  subtitle: Text('${server.uri}'),
                  trailing: IconButton(
                    onPressed: () {
                      unawaited(
                        Navigator.push<void>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ManageServer(server: server),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit),
                  ),
                ),
              );
            },
          );
  }
}
