import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager_client/src/persistence/db_pod.dart';
import 'package:photo_manager_client/src/persistence/migrations/v1.dart';
import 'package:photo_manager_client/src/persistence/shared_prefs_pod.dart';
import 'package:photo_manager_client/src/photo_manager_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

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

  final sharedPrefs = await SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(
      allowList: {'selected_server'},
    ),
  );

  final db = await openDatabase(
    'photo_manager.db',
    version: 1,
    onCreate: (db, version) async {
      final batch = db.batch();
      createTableServerV1(batch);
      await batch.commit();
    },
    onDowngrade: onDatabaseDowngradeDelete,
  );

  runApp(
    ProviderScope(
      overrides: [
        dbPod.overrideWithValue(db),
        sharedPrefsPod.overrideWithValue(sharedPrefs),
      ],
      child: const PhotoManagerApp(),
    ),
  );

  return ();
}
