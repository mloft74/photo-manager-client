import 'dart:async';

import 'package:flutter/material.dart';
import 'package:photo_manager_client/src/consts.dart';
import 'package:photo_manager_client/src/extensions/widget_extension.dart';
import 'package:photo_manager_client/src/server_list/server_list.dart';

class ServerNotSelected extends StatelessWidget {
  const ServerNotSelected({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      reverse: true,
      padding: edgeInsetsForRoutePadding,
      children: [
        FilledButton(
          onPressed: () {
            unawaited(
              Navigator.push<void>(
                context,
                const ServerList().materialPageRoute(),
              ),
            );
          },
          child: const Text('Select server'),
        ),
        const SizedBox(height: 16.0),
        Text(
          'No server is selected',
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
