import 'package:flutter/material.dart';

enum DeletePhotoResponse {
  delete,
}

class DeletePhotoDialog extends StatelessWidget {
  const DeletePhotoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete image?'),
      content:
          const Text('This will permanently remove this image from the server'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, DeletePhotoResponse.delete);
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
