import 'dart:convert';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/errors/error_trace.dart';
import 'package:photo_manager_client/src/pods/models/log.dart';
import 'package:shared_preferences/shared_preferences.dart';

Result<IList<Log>, ErrorTrace> parseLogs(SharedPreferencesWithCache sharedPrefs, String key) {
  try {
    final rawLogs = sharedPrefs.getStringList(key);
    final parsedLogs = rawLogs?.map(_parseLog).toIList() ?? const IListConst([]);
    return Ok(parsedLogs);
  } catch (ex, st) {
    return Err(ErrorTrace(ex, Some(st)));
  }
}

Log _parseLog(String value) {
  final decoded = jsonDecode(value) as Map<dynamic, dynamic>;
  return Log.fromJson(
    decoded.cast<String, dynamic>(),
  );
}
