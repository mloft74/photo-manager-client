import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager_client/src/consts.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/home/pods/models/paginated_photos_state.dart';
import 'package:photo_manager_client/src/home/pods/paginated_photos_pod.dart';
import 'package:photo_manager_client/src/home/widgets/photo_view/widgets/photo_view_photo.dart';
import 'package:photo_manager_client/src/http/errors/general_http_error.dart'
    as ghe;
import 'package:photo_manager_client/src/persistence/server/pods/current_server_result_pod.dart'
    as csrp;
import 'package:photo_manager_client/src/widgets/async_value_builder.dart';

class NewPhotoView extends ConsumerStatefulWidget {
  const NewPhotoView({super.key});

  @override
  ConsumerState<NewPhotoView> createState() => _NewPhotoViewState();
}

class _NewPhotoViewState extends ConsumerState<NewPhotoView> {
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
    return AsyncValueBuilder(
      asyncValue: ref.watch(paginatedPhotosPod),
      builder: (context, state) {
        const maxCrossAxisExtent = 256.0;
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(paginatedPhotosPod);
          },
          child: CustomScrollView(
            controller: _controller,
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
                    return PhotoViewPhoto(image: image);
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
                        child: Text(
                          switch (error) {
                            CurrentServerError(
                              error: csrp.ErrorOccurred(:final errorTrace)
                            ) ||
                            HttpError(
                              error: ghe.ErrorOccurred(:final errorTrace)
                            ) =>
                              'Error occurred:\n'
                                  '${errorTrace.error}\n'
                                  'Stack trace:\n'
                                  '${errorTrace.stackTrace}',
                            CurrentServerError(
                              error: csrp.NoServerSelected()
                            ) =>
                              'No server selected',
                            CurrentServerError(error: csrp.Loading()) =>
                              'Loading current server',
                            HttpError(error: ghe.NotOk(:final reason)) =>
                              'Http call failed; reason: $reason',
                            HttpError(error: ghe.TimedOut()) =>
                              'Call timed out. Are you on the right network?',
                            HttpError(error: ghe.UnknownBody(:final body)) =>
                              'Unknown http response body:\n'
                                  '$body',
                          },
                        ),
                      ),
                    ),
                  ),
              },
              SliverPadding(
                padding: edgeInsetsForRoutePadding.copyWith(top: 0.0),
              ),
            ],
          ),
        );
      },
    );
  }
}
