import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager_client/src/persistence/isar_pod.dart';
import 'package:photo_manager_client/src/persistence/schemas.dart';
import 'package:photo_manager_client/src/photo_manager_app.dart';

Future<()> main() async {
  // FlutterError.onError can be assigned to if custom error handling is needed.

  PlatformDispatcher.instance.onError = (ex, st) {
    log(
      'error caught by PlatformDispatcher',
      error: ex,
      stackTrace: st,
      name: 'PlatformDispatcher',
    );
    return true;
  };

  WidgetsFlutterBinding.ensureInitialized();

  final appDocumentsDir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    isarSchemas,
    directory: appDocumentsDir.path,
  );

  runApp(
    ProviderScope(
      overrides: [
        isarPod.overrideWithValue(isar),
      ],
      child: const PhotoManagerApp(),
    ),
  );

  return ();
}
