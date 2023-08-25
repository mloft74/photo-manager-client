import 'package:http/http.dart' as http;
import 'package:photo_manager_client/src/data_structures/result.dart';

extension ResponseExtension on http.Response {
  Err<T, String> reasonPhraseErr<T extends Object>() {
    final reason = reasonPhrase ?? 'NO REASON FOUND';
    final error = 'Reason: $reason, Body: $body';
    return Err(error);
  }

  String get reasonPhraseNonNull => reasonPhrase ?? 'UNKNOWN_REASON';
}
