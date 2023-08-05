import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:photo_manager_client/src/consts.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/home/widgets/photo_view/pods/models/paginated_photos_state.dart';
import 'package:photo_manager_client/src/home/widgets/photo_view/pods/paginated_photos_pod.dart';
import 'package:photo_manager_client/src/home/widgets/photo_view/pods/photo_url_pod.dart';
import 'package:photo_manager_client/src/widgets/async_value_builder.dart';

class NewPhotoView extends ConsumerWidget {
  const NewPhotoView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncValueBuilder(
      asyncValue: ref.watch(paginatedPhotosPod),
      builder: (context, state) {
        const maxCrossAxisExtent = 256.0;
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(paginatedPhotosPod);
          },
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: edgeInsetsForRoutePadding.copyWith(bottom: 0.0),
                sliver: SliverGrid.builder(
                  itemCount: state.images.length,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: maxCrossAxisExtent,
                    mainAxisSpacing: 8.0,
                    crossAxisSpacing: 8.0,
                  ),
                  itemBuilder: (context, index) {
                    final image = state.images[index];
                    return Consumer(
                      builder: (context, ref, child) {
                        final url = ref.watch(
                          photoUrlPod(fileName: image.fileName),
                        );
                        // TODO(mloft74): make this touchable
                        return url.mapOrElse(
                          orElse: (error) => Text('$error'),
                          map: (value) => CachedNetworkImage(
                            imageUrl: value,
                            progressIndicatorBuilder: (context, url, progress) {
                              return CircularProgressIndicator(
                                value: progress.progress,
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              switch (state.loading) {
                Ok(value: PaginatedPhotosLoadingState.ready) =>
                  const SliverPadding(padding: EdgeInsets.zero),
                Ok(value: PaginatedPhotosLoadingState.loading) => SliverPadding(
                    padding: edgeInsetsForRoutePadding.copyWith(top: 8.0),
                    sliver: const SliverToBoxAdapter(
                      child: Center(
                        child: SizedBox.square(
                          dimension: maxCrossAxisExtent,
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                  ),
                Err(:final error) => SliverPadding(
                    padding: edgeInsetsForRoutePadding.copyWith(top: 8.0),
                    sliver: SliverToBoxAdapter(
                      child: Center(
                        child: Text(error, textAlign: TextAlign.center),
                      ),
                    ),
                  ),
              },
              SliverPadding(
                padding: edgeInsetsForRoutePadding.copyWith(top: 0.0),
              )
            ],
          ),
        );
      },
    );
  }
}
