import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager_client/src/photo_manager_app.dart';

void main() {
  // FlutterError.onError can be assigned to if custom error handling is needed.

  PlatformDispatcher.instance.onError = (exception, stackTrace) {
    log(
      'Error caught by PlatformDispactcher',
      error: exception,
      stackTrace: stackTrace,
    );
    return true;
  };

  runApp(const ProviderScope(child: PhotoManagerApp()));
}
