import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class RenamePhotoDialog extends HookWidget {
  final String currentFileName;

  const RenamePhotoDialog({
    required this.currentFileName,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController(text: currentFileName);
    return AlertDialog(
      title: const Text('Rename photo'),
      content: TextField(
        controller: controller,
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
            final text = controller.text;
            if (currentFileName != text) {
              Navigator.pop(context, text);
            } else {
              Navigator.pop(context);
            }
          },
          child: const Text('Rename'),
        ),
      ],
    );
  }
}
