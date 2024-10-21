import 'package:freezed_annotation/freezed_annotation.dart';

@JsonEnum()
enum LogTopic {
  general,
  build,
  photoUpload,
  persistence,
  parsing,
  photoManagement,
  serverManagement,
}
