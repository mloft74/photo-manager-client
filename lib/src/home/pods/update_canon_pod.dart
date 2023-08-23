import 'package:http/http.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/domain/server.dart';
import 'package:photo_manager_client/src/errors/basic_http_error.dart';
import 'package:photo_manager_client/src/errors/error_trace.dart';
import 'package:photo_manager_client/src/extensions/response_extension.dart';
import 'package:photo_manager_client/src/persistence/server/pods/current_server_result_pod.dart'
    hide ErrorOccurred;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'update_canon_pod.g.dart';

typedef UpdateCanonResult = Result<(), BasicHttpError>;

Future<UpdateCanonResult> _updateCanon(Server server) async {
  try {
    final uri = Uri.parse('${server.uri}/api/image/update_canon');

    final response = await post(uri);
    if (response.statusCode != 200) {
      return Err(NotOk(response.reasonPhraseNonNull));
    }

    return const Ok(());
  } catch (ex, st) {
    return Err(ErrorOccurred(ErrorTrace(ex, Some(st))));
  }
}

typedef UpdateCanonFn = Future<UpdateCanonResult> Function();

@riverpod
Result<UpdateCanonFn, CurrentServerResultError> updateCanon(
  UpdateCanonRef ref,
) {
  final serverRes = ref.watch(currentServerResultPod);
  return serverRes.map((value) => () async => await _updateCanon(value));
}