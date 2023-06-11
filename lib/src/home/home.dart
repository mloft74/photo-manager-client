import 'dart:async';

import 'package:flutter/material.dart';
import 'package:photo_manager_client/src/settings/settings.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              unawaited(
                Navigator.push<void>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Settings(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: const Placeholder(),
    );
  }
}
