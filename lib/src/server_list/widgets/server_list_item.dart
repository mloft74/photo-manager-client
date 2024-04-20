import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/domain/server.dart';
import 'package:photo_manager_client/src/errors/displayable.dart';
import 'package:photo_manager_client/src/extensions/widget_extension.dart';
import 'package:photo_manager_client/src/manage_server/manage_server.dart';
import 'package:photo_manager_client/src/persistence/server/pods/current_server_pod.dart';
import 'package:photo_manager_client/src/persistence/server/pods/servers_pod.dart';
import 'package:photo_manager_client/src/server_list/widgets/server_list_item/widgets/delete_server_dialog.dart';
import 'package:photo_manager_client/src/widgets/async_value_builder.dart';

class ServerListItem extends ConsumerWidget {
  final Server server;

  const ServerListItem({
    required this.server,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentServer = ref.watch(currentServerPod);

    return AsyncValueBuilder(
      asyncValue: currentServer,
      builder: (context, value) {
        final selected = value.isSomeAnd((value) => value == server);
        return Dismissible(
          key: ValueKey(server),
          background: ColoredBox(
            color: Theme.of(context).colorScheme.error,
          ),
          confirmDismiss: (direction) async {
            final response = await showDialog<DeleteServerResponse>(
              context: context,
              builder: (context) => DeleteServerDialog(server),
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

            final res =
                await ref.read(serversPod.notifier).removeServer(server);
            if (res case Err(:final error)) {
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text(
                    'Error removing ${server.name}:\n${error.toDisplayJoined()}',
                  ),
                ),
              );
            }
          },
          child: ListTile(
            selected: selected,
            onTap: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final res = await ref
                  .read(currentServerPod.notifier)
                  .setServer(Some(server));
              if (res case Err(:final error)) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      'Error selecting ${server.name}:\n${error.toDisplayJoined()}',
                    ),
                  ),
                );
              }
            },
            title: Text(server.name),
            subtitle: Text('${server.uri}'),
            trailing: IconButton(
              onPressed: () {
                ManageServer(server: server)
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
