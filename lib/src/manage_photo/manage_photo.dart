import 'package:flutter/material.dart';

class ManagePhoto extends StatelessWidget {
  final Color color;
  const ManagePhoto({
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Manage Photo'),
      ),
      body: Placeholder(
        color: color,
      ),
    );
  }
}
