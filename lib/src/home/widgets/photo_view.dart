import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager_client/src/home/pods/models/paginated_photos_state.dart';
import 'package:photo_manager_client/src/home/pods/paginated_photos_pod.dart';
import 'package:photo_manager_client/src/home/widgets/photo_view/widgets/photo_view_list.dart';
import 'package:photo_manager_client/src/home/widgets/photo_view/widgets/photo_view_no_images.dart';
import 'package:photo_manager_client/src/widgets/async_value_builder.dart';

class PhotoView extends ConsumerWidget {
  const PhotoView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncValueBuilder(
      asyncValue: ref.watch(paginatedPhotosPod),
      builder: (context, state) {
        final okAndReady = state.loading.isOkAnd(
          (value) => value == PaginatedPhotosLoadingState.ready,
        );
        if (okAndReady && state.images.isEmpty) {
          return const PhotoViewNoImages();
        } else {
          return PhotoViewList(state: state);
        }
      },
    );
  }
}
