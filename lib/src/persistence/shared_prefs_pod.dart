import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'shared_prefs_pod.g.dart';

@riverpod
SharedPreferencesWithCache sharedPrefs(Ref ref) =>
    throw UnimplementedError(
      'Ensure the shared prefs provider is overridden in the provider scope',
    );
