import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager_client/src/consts.dart';
import 'package:photo_manager_client/src/errors/displayable.dart';
import 'package:photo_manager_client/src/home/pods/models/photos_state.dart';
import 'package:photo_manager_client/src/home/pods/paginated_photos_pod.dart';

class PhotoViewError extends ConsumerWidget {
  final PhotosError error;

  const PhotoViewError({
    required this.error,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      reverse: true,
      padding: edgeInsetsForRoutePadding,
      children: [
        FilledButton(
          onPressed: () async {
            await ref.read(paginatedPhotosPod.notifier).reset();
          },
          child: const Text('Try again'),
        ),
        Text(error.toDisplayJoined()),
      ],
    );
  }
}
