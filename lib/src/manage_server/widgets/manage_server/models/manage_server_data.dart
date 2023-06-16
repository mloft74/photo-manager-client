import 'package:freezed_annotation/freezed_annotation.dart';

part 'manage_server_data.freezed.dart';

@freezed
class ManageServerData with _$ManageServerData {
  const factory ManageServerData({
    required String serverName,
    required Uri serverUri,
  }) = _ManageServerData;
}
