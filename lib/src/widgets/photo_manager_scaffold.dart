import 'package:flutter/material.dart';
import 'package:photo_manager_client/src/widgets/photo_manager_bottom_app_bar.dart';

class PhotoManagerScaffold extends StatelessWidget {
  final Widget child;
  final PhotoManagerBottomAppBar bottomAppBar;
  final Widget? floatingActionButton;

  const PhotoManagerScaffold({
    required this.bottomAppBar,
    required this.child,
    this.floatingActionButton,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomAppBar,
      body: SafeArea(child: child),
    );
  }
}
