import 'package:http/http.dart' as http;

extension ResponseExtension on http.Response {
  String get reasonPhraseNonNull => reasonPhrase ?? 'UNKNOWN_REASON';
}
