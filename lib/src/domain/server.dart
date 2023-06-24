import 'package:freezed_annotation/freezed_annotation.dart';

part 'server.freezed.dart';

@freezed
class Server with _$Server {
  const factory Server({
    required String name,
    required Uri uri,
  }) = _Server;
}
