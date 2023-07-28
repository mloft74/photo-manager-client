import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:photo_manager_client/src/consts.dart';
import 'package:photo_manager_client/src/manage_photo/manage_photo.dart';

class PhotoView extends ConsumerWidget {
  const PhotoView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async {
        log('started refresh', name: 'Home | onRefresh');
        await Future<void>.delayed(const Duration(seconds: 1));
        log('ended refresh', name: 'Home | onRefresh');
      },
      child: GridView.builder(
        itemCount: 360,
        padding: edgeInsetsForRoutePadding,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 72.0,
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
        ),
        itemBuilder: (context, index) {
          final color =
              HSLColor.fromAHSL(1.0, index.toDouble(), 1.0, 0.5).toColor();
          return InkWell(
            onTap: () {
              unawaited(
                Navigator.push<void>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManagePhoto(color: color),
                  ),
                ),
              );
            },
            child: ColoredBox(
              color: color,
            ),
          );
        },
      ),
    );
  }
}
