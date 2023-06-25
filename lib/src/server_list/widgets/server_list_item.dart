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

  @override
  Widget build(BuildContext context) {
    final server = widget.server;
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
                onDismissed: (direction) async {
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  setState(() {
                    _removingServer = true;
                  });
                  try {
                    await ref.read(removeServerProvider)(server);
                  } catch (ex, st) {
                    log(
                      'error removing server: $ex',
                      stackTrace: st,
                      name: 'ServerListItem | onDismissed',
                    );
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text('Error removing ${server.name}: $ex'),
                      ),
                    );
                  }
                },
                child: ListTile(
                  selected: selected,
                  onTap: () async {
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    try {
                      await ref.read(updateCurrentServerProvider)(server);
                    } catch (ex, st) {
                      log(
                        'error selecting server: $ex',
                        stackTrace: st,
                        name: 'ServerListItem | select server',
                      );
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text('Error selecting ${server.name}: $ex'),
                        ),
                      );
                    }
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
