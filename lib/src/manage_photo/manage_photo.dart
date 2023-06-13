import 'package:flutter/material.dart';
import 'package:photo_manager_client/src/widgets/bottom_app_bar_title.dart';

class ManagePhoto extends StatelessWidget {
  final Color color;
  const ManagePhoto({
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomAppBar(
        child: Row(
          children: [
            BackButton(),
            BottomAppBarTitle('Manage Photo'),
          ],
        ),
      ),
      body: SafeArea(
        child: Placeholder(
          color: color,
        ),
      ),
    );
  }
}
