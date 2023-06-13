import 'dart:async';

import 'package:flutter/material.dart';
import 'package:photo_manager_client/src/manage_photo/manage_photo.dart';
import 'package:photo_manager_client/src/settings/settings.dart';
import 'package:photo_manager_client/src/upload_photo/upload_photo.dart';
import 'package:photo_manager_client/src/widgets/bottom_app_bar_title.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            const BottomAppBarTitle('Home'),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                unawaited(
                  Navigator.push<void>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Settings(),
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                unawaited(
                  Navigator.push<void>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UploadPhoto(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: GridView.builder(
          itemCount: 360,
          padding: const EdgeInsets.all(8.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 8.0,
            crossAxisSpacing: 8.0,
          ),
          itemBuilder: (context, index) {
            final color =
                HSLColor.fromAHSL(1.0, index.toDouble(), 1.0, 0.5).toColor();
            return InkWell(
              onTap: () {
                unawaited(
                  Navigator.push<void>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ManagePhoto(color: color),
                    ),
                  ),
                );
              },
              child: ColoredBox(
                color: color,
              ),
            );
          },
        ),
      ),
    );
  }
}
