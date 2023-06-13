import 'package:flutter/material.dart';

class UploadPhoto extends StatelessWidget {
  const UploadPhoto({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Upload Photo'),
      ),
      body: const Placeholder(),
    );
  }
}
