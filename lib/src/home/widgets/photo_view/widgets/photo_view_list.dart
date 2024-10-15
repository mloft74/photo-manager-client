import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager_client/src/consts.dart';
import 'package:photo_manager_client/src/home/pods/models/photos_state.dart';
import 'package:photo_manager_client/src/home/pods/paginated_photos_pod.dart';
import 'package:photo_manager_client/src/home/widgets/photo_view/widgets/photo_view_list/widgets/photo_view_photo.dart';

class PhotoViewList extends ConsumerStatefulWidget {
  final PhotosState state;

  const PhotoViewList({
    required this.state,
    super.key,
  });

  @override
  ConsumerState<PhotoViewList> createState() => _PhotoViewState();
}

class _PhotoViewState extends ConsumerState<PhotoViewList> {
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();

    _controller.addListener(_loadPageListener);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_loadPageListener)
      ..dispose();

    super.dispose();
  }

  Future<()> _loadPageListener() async {
    if (_controller.position.extentAfter < 200.0) {
      await ref.read(paginatedPhotosPod.notifier).nextPage();
    }

    return ();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(paginatedPhotosPod.notifier).reset();
      },
      child: CustomScrollView(
        // These physics ensure that the RefreshIndicator will always work.
        physics: const AlwaysScrollableScrollPhysics(),
        controller: _controller,
        slivers: [
          SliverPadding(
            padding: edgeInsetsForRoutePadding.copyWith(bottom: 0.0),
            sliver: SliverGrid.builder(
              itemCount: widget.state.images.length,
              gridDelegate: gridDelegate,
              itemBuilder: (context, index) {
                final image = widget.state.images[index];
                return PhotoViewPhoto(image: image);
              },
            ),
          ),
          if (widget.state.loadingState == PhotosLoadingState.loading)
            SliverPadding(
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
          SliverPadding(
            padding: edgeInsetsForRoutePadding.copyWith(top: 0.0),
          ),
        ],
      ),
    );
  }
}
