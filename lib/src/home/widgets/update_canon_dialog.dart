import 'package:flutter/material.dart';

enum UpdateCanonResponse {
  update,
}

class UpdateCanonDialog extends StatelessWidget {
  const UpdateCanonDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update canon?'),
      content: const Text(
        'This will make the server scan all of the photos it has to ensure everything is up to date. Do you want to continue?',
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, UpdateCanonResponse.update);
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}
