import 'package:flutter/material.dart';
import 'package:photo_manager_client/src/widgets/photo_manager_bottom_app_bar.dart';
import 'package:photo_manager_client/src/widgets/photo_manager_scaffold.dart';

class EditServer extends StatefulWidget {
  const EditServer({super.key});

  @override
  State<EditServer> createState() => _EditServerState();
}

class _EditServerState extends State<EditServer> {
  @override
  Widget build(BuildContext context) {
    return PhotoManagerScaffold(
      bottomAppBar: PhotoManagerBottomAppBar(
        leading: const BackButton(),
        titleText: 'Edit Server',
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              debugPrint('delete server');
            },
          )
        ],
      ),
      child: const Placeholder(),
    );
  }
}
