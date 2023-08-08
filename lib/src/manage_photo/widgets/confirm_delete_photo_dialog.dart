import 'package:flutter/material.dart';

class ConfirmDeletePhotoDialog extends StatelessWidget {
  const ConfirmDeletePhotoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete image?'),
      content:
          const Text('This will permanently remove this image from the server'),
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
