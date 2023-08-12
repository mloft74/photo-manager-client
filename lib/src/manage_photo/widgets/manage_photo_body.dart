import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/manage_photo/widgets/manage_photo_body/widgets/rename_photo_dialog.dart';

class ManagePhotoBody extends StatelessWidget {
  final String photoUrl;
  final String fileName;

  const ManagePhotoBody({
    required this.photoUrl,
    required this.fileName,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: CachedNetworkImage(imageUrl: photoUrl),
          ),
        ),
        const SizedBox(height: 4.0),
        Text('Name: $fileName', textAlign: TextAlign.center),
        const SizedBox(height: 8.0),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () async {
              final foo = await showDialog<String>(
                context: context,
                builder: (context) =>
                    RenamePhotoDialog(currentFileName: fileName),
              ).toFutureOption();
              log('foo: $foo', name: 'ManagePhotoBody | onPressed');
            },
            child: const Text('Rename'),
          ),
        ),
      ],
    );
  }
}
