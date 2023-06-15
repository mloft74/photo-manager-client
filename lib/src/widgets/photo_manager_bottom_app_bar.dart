import 'package:flutter/material.dart';
import 'package:photo_manager_client/src/widgets/bottom_app_bar_title.dart';

class PhotoManagerBottomAppBar extends StatelessWidget {
  final String titleText;
  final Widget? leading;
  final List<Widget> actions;

  const PhotoManagerBottomAppBar({
    required this.titleText,
    this.leading,
    this.actions = const [],
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final leading = this.leading;

    return BottomAppBar(
      child: Row(
        children: [
          if (leading != null) leading,
          BottomAppBarTitle(titleText),
          const Spacer(),
          ...actions,
        ],
      ),
    );
  }
}
