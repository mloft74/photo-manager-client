import 'package:flutter/material.dart';
import 'package:photo_manager_client/src/widgets/photo_manager_bottom_app_bar.dart';
import 'package:photo_manager_client/src/widgets/photo_manager_scaffold.dart';

class UploadPhoto extends StatelessWidget {
  const UploadPhoto({super.key});

  @override
  Widget build(BuildContext context) {
    return const PhotoManagerScaffold(
      bottomAppBar: PhotoManagerBottomAppBar(
        leading: BackButton(),
        titleText: 'Upload Photo',
      ),
      child: Placeholder(),
    );
  }
}
