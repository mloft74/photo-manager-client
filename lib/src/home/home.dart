import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/extensions/widget_extension.dart';
import 'package:photo_manager_client/src/home/pods/date_sorting_pod.dart';
import 'package:photo_manager_client/src/home/pods/paginated_photos_pod.dart';
import 'package:photo_manager_client/src/home/pods/update_canon_pod.dart';
import 'package:photo_manager_client/src/home/widgets/photo_view.dart';
import 'package:photo_manager_client/src/home/widgets/server_not_selected.dart';
import 'package:photo_manager_client/src/home/widgets/update_canon_dialog.dart';
import 'package:photo_manager_client/src/home/widgets/update_date_sorting_dialog.dart';
import 'package:photo_manager_client/src/persistence/server/pods/selected_server_pod.dart';
import 'package:photo_manager_client/src/pods/logs_pod.dart';
import 'package:photo_manager_client/src/pods/models/log_topic.dart';
import 'package:photo_manager_client/src/settings/settings.dart';
import 'package:photo_manager_client/src/upload_photo/upload_photo.dart';
import 'package:photo_manager_client/src/util/run_with_toasts.dart';
import 'package:photo_manager_client/src/widgets/photo_manager_bottom_app_bar.dart';
import 'package:photo_manager_client/src/widgets/photo_manager_scaffold.dart';

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedServer = ref.watch(selectedServerPod);
    return PhotoManagerScaffold(
      bottomAppBar: PhotoManagerBottomAppBar(
        titleText: 'Home',
        actions: [
          if (selectedServer.isSome) ...[
            IconButton(
              onPressed: () async {
                final currentSorting = ref.read(dateSortingPod);
                final newSorting = await showDialog<DateSortingState>(
                  context: context,
                  builder: (context) =>
                      UpdateDateSortingDialog(currentSorting: currentSorting),
                ).toFutureOption();
                if (newSorting case Some(:final value)) {
                  ref.read(dateSortingPod.notifier).sorting = value;
                }
              },
              icon: const Icon(Icons.sort),
            ),
            IconButton(
              onPressed: () async {
                await _onUpdateCanonPressed(context, ref);
              },
              icon: const Icon(Icons.refresh),
            ),
          ],
          IconButton(
            onPressed: () {
              const Settings().pushMaterialRouteUnawaited(context);
            },
            icon: const Icon(Icons.settings),
          ),
          if (selectedServer.isSome)
            IconButton(
              onPressed: () async {
                final response = await const UploadPhoto()
                    .pushMaterialRoute<UploadPhotoResponse>(context);
                if (response
                    case Some(value: UploadPhotoResponse.photoUploaded)) {
                  await ref.read(paginatedPhotosPod.notifier).reset();
                }
              },
              icon: const Icon(Icons.add),
            ),
        ],
      ),
      child: Builder(
        builder: (context) {
          return switch (selectedServer) {
            None() => const ServerNotSelected(),
            Some() => const PhotoView(),
          };
        },
      ),
    );
  }
}

Future<()> _onUpdateCanonPressed(BuildContext context, WidgetRef ref) async {
  final messenger = ScaffoldMessenger.of(context);

  final response = await showDialog<UpdateCanonResponse>(
    context: context,
    builder: (context) => const UpdateCanonDialog(),
  ).toFutureOption();
  if (response case Some(value: UpdateCanonResponse.update)) {
    final updateCanon = ref.read(updateCanonPod);
    switch (updateCanon) {
      case None():
        messenger.showSnackBar(
          const SnackBar(content: Text('No server selected')),
        );
      case Some(value: final updateCanon):
        final logs = ref.read(logsPod.notifier);
        final res = await runWithToasts(
          messenger: messenger,
          logs: logs,
          op: updateCanon,
          startingMsg: 'Updating canon',
          finishedMsg: 'Canon updated',
          topic: LogTopic.photoManagement,
        );
        if (res case Ok()) {
          await ref.read(paginatedPhotosPod.notifier).reset();
        }
    }
  }

  return ();
}
