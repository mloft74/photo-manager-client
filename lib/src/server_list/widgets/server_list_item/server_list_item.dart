import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/domain/server.dart';
import 'package:photo_manager_client/src/extensions/widget_extension.dart';
import 'package:photo_manager_client/src/manage_server/manage_server.dart';
import 'package:photo_manager_client/src/persistence/server/providers/current_server_provider.dart';
import 'package:photo_manager_client/src/persistence/server/providers/remove_server_provider.dart';
import 'package:photo_manager_client/src/persistence/server/providers/update_current_server_provider.dart';
import 'package:photo_manager_client/src/server_list/widgets/server_list_item/widgets/confirm_server_delete_dialog.dart';
import 'package:photo_manager_client/src/widgets/async_value_builder.dart';

class ServerListItem extends HookConsumerWidget {
  final Server server;

  const ServerListItem({
    required this.server,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final removingServer = useState(false);
    final serverToSet = useState(const Option<Server>.none());
    final currentServer = ref.watch(currentServerProvider);

    return removingServer.value
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
                  builder: (context) => ConfirmServerDeleteDialog(server),
                ),
                onDismissed: (direction) async {
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  removingServer.value = true;
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
                    serverToSet.value = Some(server);
                  },
                  title: serverToSet.value
                      .map<Widget>(
                        (value) => AsyncValueBuilder(
                          asyncValue:
                              ref.watch(updateCurrentServerProvider(server)),
                          loadingBuilder: (context) =>
                              const CircularProgressIndicator(),
                          builder: (context, value) {
                            WidgetsBinding.instance
                                .addPostFrameCallback((timeStamp) {
                              serverToSet.value = const None();
                            });
                            return const SizedBox.shrink();
                          },
                        ),
                      )
                      .unwrapOrElse(() => Text(server.name)),
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
