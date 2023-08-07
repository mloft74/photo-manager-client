import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/domain/hosted_image.dart';
import 'package:photo_manager_client/src/pods/photo_url_pod.dart';
import 'package:photo_manager_client/src/widgets/photo_manager_bottom_app_bar.dart';
import 'package:photo_manager_client/src/widgets/photo_manager_scaffold.dart';

class ManagePhoto extends ConsumerWidget {
  final HostedImage image;
  const ManagePhoto({
    required this.image,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final res = ref.watch(photoUrlPod(fileName: image.fileName));
    final child = switch (res) {
      Ok(:final value) => CachedNetworkImage(imageUrl: value),
      Err(:final error) => Center(child: Text('$error')),
    };
    return PhotoManagerScaffold(
      bottomAppBar: const PhotoManagerBottomAppBar(
        leading: BackButton(),
        titleText: 'Manage Photo',
      ),
      child: child,
    );
  }
}
