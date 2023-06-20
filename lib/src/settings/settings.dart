import 'dart:async';

import 'package:flutter/material.dart';
import 'package:photo_manager_client/src/consts.dart';
import 'package:photo_manager_client/src/server_list/server_list.dart';
import 'package:photo_manager_client/src/widgets/photo_manager_bottom_app_bar.dart';
import 'package:photo_manager_client/src/widgets/photo_manager_scaffold.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return PhotoManagerScaffold(
      bottomAppBar: const PhotoManagerBottomAppBar(
        leading: BackButton(),
        titleText: 'Settings',
      ),
      child: ListView(
        padding: edgeInsetsForRoutePadding,
        reverse: true,
        children: [
          ListTile(
            onTap: () {
              unawaited(
                Navigator.push<void>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ServerList(),
                  ),
                ),
              );
            },
            title: const Text('Servers'),
            subtitle: const Text('Current server: TODO'),
            trailing: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
    );
  }
}
