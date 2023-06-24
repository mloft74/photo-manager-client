import 'package:flutter/material.dart';
import 'package:photo_manager_client/src/consts.dart';
import 'package:photo_manager_client/src/settings/widgets/server_settings.dart';
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
        children: const [
          ServerSettings(),
        ],
      ),
    );
  }
}
