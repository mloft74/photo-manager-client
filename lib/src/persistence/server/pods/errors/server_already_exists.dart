import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:photo_manager_client/src/domain/server.dart';

part 'server_already_exists.freezed.dart';

@freezed
class ServerAlreadyExists with _$ServerAlreadyExists {
  const factory ServerAlreadyExists(Server server) = _ServerAlreadyExists;
}
