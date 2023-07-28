import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:photo_manager_client/src/consts.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/domain/hosted_image.dart';
import 'package:photo_manager_client/src/home/widgets/photo_view/providers/photo_url_provider.dart';
import 'package:photo_manager_client/src/home/widgets/photo_view/providers/photos_page_provider.dart';

class PhotoView extends ConsumerStatefulWidget {
  const PhotoView({super.key});

  @override
  ConsumerState<PhotoView> createState() => _PhotoViewState();
}

class _PhotoViewState extends ConsumerState<PhotoView> {
  final _controller = ScrollController();

  var _loading = false;

  var _hasNextPage = true;
  var _cursor = const Option<int>.none();
  var _images = const <HostedImage>[];

  @override
  void initState() {
    super.initState();
    _controller.addListener(_listenToScrollController);
    unawaited(_nextPage());
  }

  @override
  void dispose() {
    _controller.removeListener(_listenToScrollController);
    super.dispose();
  }

  void _listenToScrollController() {
    if (_controller.position.extentAfter < 100.0) {
      unawaited(_nextPage());
    }
  }

  Future<void> _nextPage() async {
    if (_loading || !_hasNextPage) {
      return;
    }
    setState(() {
      _loading = true;
    });
    final result = await ref.read(photosPageProvider)(after: _cursor);
    switch (result) {
      case Ok(:final value):
        if (mounted) {
          setState(() {
            _loading = false;
            _cursor = value.cursor;
            _hasNextPage = _cursor.isSome;
            _images = _images + value.images;
          });
        }
        _cursor = value.cursor;

      case Err(:final error):
        log(
          'error fetching page',
          name: 'PhotoView | _nextPage',
          error: error,
        );
        if (mounted) {
          setState(() {
            _hasNextPage = false;
            _loading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error fetching page: $error'),
              duration: const Duration(seconds: 10),
            ),
          );
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _hasNextPage = true;
          _cursor = const None();
          _images = const [];
        });
        await _nextPage();
      },
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: edgeInsetsForRoutePadding.copyWith(bottom: 0.0),
            sliver: SliverGrid.builder(
              itemCount: _images.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 72.0,
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
              ),
              itemBuilder: (context, index) {
                final image = _images[index];
                return Consumer(
                  builder: (context, ref, child) {
                    final url = ref.watch(
                      photoUrlProvider(fileName: image.fileName),
                    );
                    return Image.network(url);
                  },
                );
              },
            ),
          ),
          if (_loading)
            SliverPadding(
              padding: edgeInsetsForRoutePadding.copyWith(top: 8.0),
              sliver: const SliverToBoxAdapter(
                child: CircularProgressIndicator(),
              ),
            ),
          SliverPadding(
            padding: edgeInsetsForRoutePadding.copyWith(top: 0.0),
          )
        ],
      ),
    );
  }
}
