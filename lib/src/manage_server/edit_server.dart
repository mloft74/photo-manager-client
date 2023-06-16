import 'package:flutter/material.dart';
import 'package:photo_manager_client/src/manage_server/widgets/manage_server/manage_server.dart';
import 'package:photo_manager_client/src/widgets/photo_manager_bottom_app_bar.dart';

enum _RemoveServerOption {
  remove,
  cancel,
}

class EditServer extends StatelessWidget {
  const EditServer({super.key});

  @override
  Widget build(BuildContext context) {
    return ManageServer(
      onSave: (data) {
        debugPrint('edit | name: ${data.serverName}, uri: ${data.serverUri}');
      },
      bottomAppBar: PhotoManagerBottomAppBar(
        leading: const BackButton(),
        titleText: 'Edit Server',
        actions: [
          IconButton(
            onPressed: () async {
              final decision = await showDialog<_RemoveServerOption>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Remove server?'),
                    content: const Text(
                      'This will remove this server as an option for managing photos',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(
                            context,
                            _RemoveServerOption.cancel,
                          );
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(
                            context,
                            _RemoveServerOption.remove,
                          );
                        },
                        child: const Text('Remove'),
                      ),
                    ],
                  );
                },
              );
              debugPrint('decision: $decision');
            },
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
    );
  }
}
