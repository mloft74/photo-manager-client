import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager_client/src/photo_manager_app.dart';

void main() {
  runApp(const ProviderScope(child: PhotoManagerApp()));
}
