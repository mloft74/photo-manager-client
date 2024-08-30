import 'dart:convert';
import 'dart:io';

final class DebugConnection {
  final Socket _socket;

  Stream<String> get events => _socket.map(utf8.decode);

  DebugConnection._(this._socket);

  static Future<DebugConnection> connect(String host, int port) async {
    // Closed by DebugConnection.close();
    // ignore: close_sinks
    final socket = await Socket.connect(host, port);
    return DebugConnection._(socket);
  }

  () close() {
    _socket.destroy();
    return ();
  }
}
