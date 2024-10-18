import 'package:freezed_annotation/freezed_annotation.dart';

@JsonEnum()
enum LogTopic {
  photoUpload,
  persistence,
  parsing,
}
