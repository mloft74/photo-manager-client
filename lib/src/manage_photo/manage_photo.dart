import 'package:flutter/material.dart';
import 'package:photo_manager_client/src/widgets/photo_manager_bottom_app_bar.dart';
import 'package:photo_manager_client/src/widgets/photo_manager_scaffold.dart';

class ManagePhoto extends StatelessWidget {
  final Color color;
  const ManagePhoto({
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return PhotoManagerScaffold(
      bottomAppBar: const PhotoManagerBottomAppBar(
        leading: BackButton(),
        titleText: 'Manage Photo',
      ),
      child: Placeholder(
        color: color,
      ),
    );
  }
}
