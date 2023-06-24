import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:photo_manager_client/src/manage_server/widgets/manage_server/manage_server.dart';
import 'package:photo_manager_client/src/widgets/photo_manager_bottom_app_bar.dart';

class AddServer extends StatelessWidget {
  const AddServer({super.key});

  @override
  Widget build(BuildContext context) {
    return ManageServer(
      onSave: (data) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'name: ${data.serverName}, uri: ${data.serverUri}',
            ),
          ),
        );
        log(
          'name: ${data.serverName}, uri: ${data.serverUri}',
          name: 'add_server',
        );
      },
      bottomAppBar: const PhotoManagerBottomAppBar(
        leading: BackButton(),
        titleText: 'Add Server',
      ),
    );
  }
}
