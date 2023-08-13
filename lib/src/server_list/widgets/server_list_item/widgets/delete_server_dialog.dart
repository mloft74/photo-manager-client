import 'package:flutter/material.dart';
import 'package:photo_manager_client/src/domain/server.dart';

enum DeleteServerResponse {
  delete,
}

class DeleteServerDialog extends StatelessWidget {
  final Server server;
  const DeleteServerDialog(this.server, {super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Delete ${server.name}?'),
      content: const Text('This will permanently delete this server'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, DeleteServerResponse.delete);
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
