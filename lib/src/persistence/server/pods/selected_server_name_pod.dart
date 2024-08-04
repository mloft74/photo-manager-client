import 'dart:async';

import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/errors/error_trace.dart';
import 'package:photo_manager_client/src/persistence/keys.dart';
import 'package:photo_manager_client/src/persistence/server/pods/selected_server_pod/models/set_selected_server_name_error.dart';
import 'package:photo_manager_client/src/persistence/shared_prefs_pod.dart';
import 'package:photo_manager_client/src/state_management/notifier_async_rollback_update.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'selected_server_name_pod.g.dart';

typedef SelectedServerNameState = Option<String>;
typedef SetSelectedServerNameResult = Result<(), SetSelectedServerNameError>;
typedef _SetSelectedServerNameResult = Result<(), ErrorTrace<Object>>;

@riverpod
final class SelectedServerName extends _$SelectedServerName
    with NotifierAsyncRollbackUpdate<SelectedServerNameState> {
  @override
  SelectedServerNameState build() {
    final sharedPrefs = ref.watch(sharedPrefsPod);
    final name = sharedPrefs.getString(selectedServerKey);
    return name.toOption();
  }

  Future<SetSelectedServerNameResult> setServerName(Option<String> name) async {
    return await updateWithRollbackSynchronized(
      (value) async {
        state = name;
        final sharedPrefs = ref.read(sharedPrefsPod);
        final res = await _handleSelectedServerNameChange(
          sharedPrefs,
          name.toNullable(),
        );
        return res.mapErr(ErrorOccurred.new);
      },
    );
  }
}

Future<_SetSelectedServerNameResult> _handleSelectedServerNameChange(
  SharedPreferencesWithCache sharedPrefs,
  String? name,
) async {
  try {
    if (name != null) {
      await sharedPrefs.setString(selectedServerKey, name);
    } else {
      await sharedPrefs.remove(selectedServerKey);
    }

    return const Ok(());
  } catch (ex, st) {
    return Err(ErrorTrace(ex, Some(st)));
  }
}
