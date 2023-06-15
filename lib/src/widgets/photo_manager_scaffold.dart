import 'package:flutter/material.dart';
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
      bottomNavigationBar: bottomAppBar,
      body: SafeArea(child: child),
    );
  }
}
