import 'package:flutter/material.dart';
import 'package:photo_manager_client/src/consts.dart';
import 'package:photo_manager_client/src/upload_photo/widgets/image_display.dart';
import 'package:photo_manager_client/src/upload_photo/widgets/select_photo_button.dart';
import 'package:photo_manager_client/src/upload_photo/widgets/upload_button.dart';
import 'package:photo_manager_client/src/widgets/photo_manager_bottom_app_bar.dart';
import 'package:photo_manager_client/src/widgets/photo_manager_scaffold.dart';

// TODO(mloft74): implement picking directory
// TODO(mloft74): implement picking multiple photos

class UploadPhoto extends StatelessWidget {
  const UploadPhoto({super.key});

  @override
  Widget build(BuildContext context) {
    return const PhotoManagerScaffold(
      bottomAppBar: PhotoManagerBottomAppBar(
        leading: BackButton(),
        titleText: 'Upload Photo',
      ),
      child: Padding(
        padding: edgeInsetsForRoutePadding,
        child: Column(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ImageDisplay(),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: SelectPhotoButton(),
            ),
            SizedBox(
              width: double.infinity,
              child: UploadButton(),
            ),
          ],
        ),
      ),
    );
  }
}
