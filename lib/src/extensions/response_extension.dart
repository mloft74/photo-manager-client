import 'package:http/http.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';

extension ResponseExtension on Response {
  Err<T, String> reasonPhraseErr<T extends Object>() {
    final reason = reasonPhrase ?? 'NO REASON FOUND';
    final error = 'Reason: $reason, Body: $body';
    return Err(error);
  }
}
