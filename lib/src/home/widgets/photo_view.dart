import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/home/pods/models/photos_state.dart';
import 'package:photo_manager_client/src/home/pods/paginated_photos_pod.dart';
import 'package:photo_manager_client/src/home/widgets/photo_view/widgets/photo_view_error.dart';
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
        return switch (state) {
          Err(:final error) => PhotoViewError(error: error),
          Ok(
            value: PhotosState(
              images: (const IListConst([])),
              loadingState: PhotosLoadingState.ready,
            )
          ) =>
            const PhotoViewNoImages(),
          Ok(value: final state) => PhotoViewList(state: state),
        };
      },
    );
  }
}
