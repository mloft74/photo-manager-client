import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager_client/src/consts.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/manage_photo/manage_photo.dart';
import 'package:photo_manager_client/src/persistence/server/providers/current_server_provider.dart';
import 'package:photo_manager_client/src/server_list/server_list.dart';
import 'package:photo_manager_client/src/settings/settings.dart';
import 'package:photo_manager_client/src/upload_photo/upload_photo.dart';
import 'package:photo_manager_client/src/widgets/async_value_builder.dart';
import 'package:photo_manager_client/src/widgets/photo_manager_bottom_app_bar.dart';
import 'package:photo_manager_client/src/widgets/photo_manager_scaffold.dart';

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentServer = ref.watch(currentServerProvider);
    return PhotoManagerScaffold(
      bottomAppBar: PhotoManagerBottomAppBar(
        titleText: 'Home',
        actions: [
          IconButton(
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
            icon: const Icon(Icons.settings),
          ),
          if (currentServer case AsyncData(value: Some()))
            IconButton(
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
              icon: const Icon(Icons.add),
            ),
        ],
      ),
      child: AsyncValueBuilder(
        asyncValue: currentServer,
        builder: (context, value) {
          return switch (value) {
            None() => ListView(
                reverse: true,
                padding: edgeInsetsForRoutePadding,
                children: [
                  FilledButton(
                    onPressed: () {
                      unawaited(
                        Navigator.push<void>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ServerList(),
                          ),
                        ),
                      );
                    },
                    child: const Text('Select server'),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    'No server is selected',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            Some() => RefreshIndicator(
                onRefresh: () async {
                  log('started refresh', name: 'home');
                  await Future<void>.delayed(const Duration(seconds: 1));
                  log('ended refresh', name: 'home');
                },
                child: GridView.builder(
                  itemCount: 360,
                  padding: edgeInsetsForRoutePadding,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 72.0,
                    mainAxisSpacing: 8.0,
                    crossAxisSpacing: 8.0,
                  ),
                  itemBuilder: (context, index) {
                    final color =
                        HSLColor.fromAHSL(1.0, index.toDouble(), 1.0, 0.5)
                            .toColor();
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
              )
          };
        },
      ),
    );
  }
}
