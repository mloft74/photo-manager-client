import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/domain/server.dart';
import 'package:photo_manager_client/src/extensions/widget_extension.dart';
import 'package:photo_manager_client/src/manage_server/manage_server.dart';
import 'package:photo_manager_client/src/persistence/server/pods/current_server_pod.dart';
import 'package:photo_manager_client/src/persistence/server/pods/remove_server_pod.dart';
import 'package:photo_manager_client/src/persistence/server/pods/set_current_server_pod.dart';
import 'package:photo_manager_client/src/server_list/widgets/server_list_item/widgets/delete_server_dialog.dart';
import 'package:photo_manager_client/src/widgets/async_value_builder.dart';

class ServerListItem extends ConsumerStatefulWidget {
  final Server server;

  const ServerListItem({
    required this.server,
    super.key,
  });

  @override
  ConsumerState<ServerListItem> createState() => _ServerListItemState();
}

class _ServerListItemState extends ConsumerState<ServerListItem> {
  var _removingServer = false;

  @override
  Widget build(BuildContext context) {
    final currentServer = ref.watch(currentServerPod);

    return _removingServer
        ? const SizedBox.shrink()
        : AsyncValueBuilder(
            asyncValue: currentServer,
            builder: (context, value) {
              final selected =
                  value.isSomeAnd((value) => value == widget.server);
              return Dismissible(
                key: ValueKey(widget.server),
                background: ColoredBox(
                  color: Theme.of(context).colorScheme.error,
                ),
                confirmDismiss: (direction) async {
                  final response = await showDialog<DeleteServerResponse>(
                    context: context,
                    builder: (context) => DeleteServerDialog(widget.server),
                  ).toFutureOption();
                  final shouldDelete = response
                      .andThen(
                        (value) => value == DeleteServerResponse.delete
                            ? const Some(())
                            : const None<()>(),
                      )
                      .isSome;
                  return shouldDelete;
                },
                onDismissed: (direction) async {
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  setState(() {
                    _removingServer = true;
                  });

                  final res = await ref.read(removeServerPod)(widget.server);
                  if (res case Err(:final error)) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          'Error removing ${widget.server.name}: ${error.error}',
                        ),
                      ),
                    );
                  }
                },
                child: ListTile(
                  selected: selected,
                  onTap: () async {
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    final res =
                        await ref.read(setCurrentServerPod)(widget.server);
                    if (res case Err(:final error)) {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            'Error selecting ${widget.server.name}: $error',
                          ),
                        ),
                      );
                    }
                  },
                  title: Text(widget.server.name),
                  subtitle: Text('${widget.server.uri}'),
                  trailing: IconButton(
                    onPressed: () {
                      ManageServer(server: widget.server)
                          .pushMaterialRouteUnawaited(context);
                    },
                    icon: const Icon(Icons.edit),
                  ),
                ),
              );
            },
          );
  }
}
