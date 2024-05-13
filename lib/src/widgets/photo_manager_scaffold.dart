import 'package:flutter/material.dart';
import 'package:photo_manager_client/src/extensions/widget_extension.dart';
import 'package:photo_manager_client/src/live_debug/live_debug.dart';
import 'package:photo_manager_client/src/widgets/photo_manager_bottom_app_bar.dart';

class PhotoManagerScaffold extends StatelessWidget {
  final Widget child;
  final PhotoManagerBottomAppBar bottomAppBar;

  const PhotoManagerScaffold({
    required this.bottomAppBar,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          const LiveDebug().pushMaterialRouteUnawaited(context);
        },
      ),
      bottomNavigationBar: bottomAppBar,
      body: SafeArea(child: child),
    );
  }
}
