import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:photo_manager_client/src/add_server/add_server.dart';
import 'package:photo_manager_client/src/edit_server/edit_server.dart';
import 'package:photo_manager_client/src/widgets/photo_manager_bottom_app_bar.dart';
import 'package:photo_manager_client/src/widgets/photo_manager_scaffold.dart';

const _fakeServers = [
  'https://10.0.0.12',
  'http://10.0.0.170',
  'https://192.168.0.12',
];

class ServerList extends StatelessWidget {
  const ServerList({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedIndex = Random().nextInt(_fakeServers.length);
    return PhotoManagerScaffold(
      bottomAppBar: PhotoManagerBottomAppBar(
        leading: const BackButton(),
        titleText: 'Servers',
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              unawaited(
                Navigator.of(context).push<void>(
                  MaterialPageRoute(builder: (context) => const AddServer()),
                ),
              );
            },
          ),
        ],
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        reverse: true,
        itemCount: _fakeServers.length,
        itemBuilder: (context, index) {
          final item = _fakeServers[index];
          return ListTile(
            title: Text(item),
            selected: index == selectedIndex,
            onTap: () {
              debugPrint('set selected server');
            },
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                unawaited(
                  Navigator.push<void>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditServer(),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
