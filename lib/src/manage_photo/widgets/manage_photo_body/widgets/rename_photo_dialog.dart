import 'package:flutter/material.dart';

class RenamePhotoDialog extends StatefulWidget {
  final String currentFileName;

  const RenamePhotoDialog({
    required this.currentFileName,
    super.key,
  });

  @override
  State<RenamePhotoDialog> createState() => _RenamePhotoDialogState();
}

class _RenamePhotoDialogState extends State<RenamePhotoDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentFileName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rename photo'),
      content: TextField(
        controller: _controller,
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
            final text = _controller.text;
            if (widget.currentFileName != text) {
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
