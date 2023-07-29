import 'package:flutter/material.dart';
import 'package:photo_manager_client/src/domain/server.dart';

class ConfirmServerDeleteDialog extends StatelessWidget {
  final Server server;
  const ConfirmServerDeleteDialog(this.server, {super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Delete ${server.name}?'),
      content: const Text('This will permanently delete this server'),
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
    );
  }
}
