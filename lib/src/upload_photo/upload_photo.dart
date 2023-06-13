import 'package:flutter/material.dart';
import 'package:photo_manager_client/src/widgets/bottom_app_bar_title.dart';

class UploadPhoto extends StatelessWidget {
  const UploadPhoto({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            BackButton(),
            BottomAppBarTitle('Upload Photo'),
          ],
        ),
      ),
      body: SafeArea(child: Placeholder()),
    );
  }
}
