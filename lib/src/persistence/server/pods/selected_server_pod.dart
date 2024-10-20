import 'dart:async';
import 'dart:convert';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/domain/server.dart';
import 'package:photo_manager_client/src/errors/displayable.dart';
import 'package:photo_manager_client/src/errors/error_trace.dart';
import 'package:photo_manager_client/src/persistence/keys.dart';
import 'package:photo_manager_client/src/persistence/server/models/server_db.dart';
import 'package:photo_manager_client/src/persistence/server/pods/selected_server_pod/models/set_selected_server_error.dart';
import 'package:photo_manager_client/src/persistence/shared_prefs_pod.dart';
import 'package:photo_manager_client/src/pods/logs_pod.dart';
import 'package:photo_manager_client/src/pods/models/log_topic.dart';
import 'package:photo_manager_client/src/state_management/notifier_async_rollback_update.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'selected_server_pod.g.dart';

typedef SelectedServerState = Option<Server>;
typedef SetSelectedServerResult = Result<(), SetSelectedServerError>;
typedef _SetSelectedServerResult = Result<(), ErrorTrace<Object>>;

@riverpod
final class SelectedServer extends _$SelectedServer
    with NotifierAsyncRollbackUpdate<SelectedServerState> {
  @override
  SelectedServerState build() {
    final sharedPrefs = ref.watch(sharedPrefsPod);
    final rawJson = sharedPrefs.getString(selectedServerKey).toOption();
    return rawJson.andThen(
      (value) {
        final json = jsonDecode(value) as Map<String, dynamic>;
        final serverDB = ServerDB.fromDBMap(json);

        final domainRes = serverDB.toDomain();
        if (domainRes.isErr) {
          final error = domainRes.expectErr('Should have checked for isErr');
          ref.read(logsPod.notifier).logError(
                LogTopic.parsing,
                CompoundDisplayable(
                  IList([
                    const DefaultDisplayable(
                      IListConst(['Could not parse server']),
                    ),
                    error,
                  ]),
                ),
              );
        }
        return domainRes.okToOption();
      },
    );
  }

  Future<SetSelectedServerResult> setServer(Option<Server> server) async {
    return await updateWithRollbackSynchronized(
      (value) async {
        state = server;
        final sharedPrefs = ref.read(sharedPrefsPod);
        final res = await _handleSelectedServerChange(
          sharedPrefs,
          server.toNullable(),
        );
        return res.mapErr(ErrorOccurred.new);
      },
    );
  }
}

Future<_SetSelectedServerResult> _handleSelectedServerChange(
  SharedPreferencesWithCache sharedPrefs,
  Server? server,
) async {
  try {
    if (server != null) {
      final serverDB = ServerDB.fromDomain(server);
      final json = serverDB.toDBMap();
      final rawJson = jsonEncode(json);
      await sharedPrefs.setString(selectedServerKey, rawJson);
    } else {
      await sharedPrefs.remove(selectedServerKey);
    }

    return const Ok(());
  } catch (ex, st) {
    return Err(ErrorTrace(ex, Some(st)));
  }
}
