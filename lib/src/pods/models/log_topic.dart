import 'package:freezed_annotation/freezed_annotation.dart';

@JsonEnum()
enum LogTopic {
  general,
  photoUpload,
  persistence,
  parsing,
  photoManagement,
  serverManagement,
}
