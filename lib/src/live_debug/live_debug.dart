import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager_client/src/persistence/server/pods/selected_server_result_pod.dart';
import 'package:photo_manager_client/src/widgets/photo_manager_bottom_app_bar.dart';
import 'package:photo_manager_client/src/widgets/photo_manager_scaffold.dart';

class LiveDebug extends ConsumerStatefulWidget {
  const LiveDebug({super.key});

  @override
  ConsumerState<LiveDebug> createState() => _LiveDebugState();
}

class _LiveDebugState extends ConsumerState<LiveDebug> {
  var _state = 'initializing';

  final _msgs = <String>[];

  Socket? _socket;
  // Cancelled under an alias
  // ignore: cancel_subscriptions
  StreamSubscription<String>? _sub;

  @override
  void initState() {
    super.initState();

    final serverRes = ref.read(currentServerResultPod);
    if (serverRes.isErr) {
      _state = 'error: no server selected';
    } else {
      final server = serverRes.unwrap();
      unawaited(_createSocket(server.uri.host));
    }
  }

  Future<()> _createSocket(String host) async {
    log('host: $host', name: 'live_debug');
    final socket = await Socket.connect(host, 4000);
    if (_disposed) {
      socket.destroy();
    } else {
      _sub = socket.map(utf8.decode).listen(
        (event) {
          setState(() {
            _msgs.add(event);
          });
        },
        onError: (Object? ex, StackTrace? st) {
          if (mounted) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(ex.toString())));
          } else {
            log(
              'error in stream map',
              name: 'live_debug',
              error: ex,
              stackTrace: st,
            );
          }
        },
      );
      _socket = socket;
      setState(() {
        _state = 'socket connected';
      });
    }
    return ();
  }

  var _disposed = false;
  @override
  void dispose() {
    _disposed = true;

    final socket = _socket;
    _socket = null;
    socket?.destroy();

    final sub = _sub;
    _sub = null;
    unawaited(sub?.cancel());

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PhotoManagerScaffold(
      bottomAppBar: const PhotoManagerBottomAppBar(
        leading: BackButton(),
        titleText: 'Live Debug',
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_state),
          if (_socket case final socket?) ...[
            FilledButton(
              onPressed: () {
                socket.add(utf8.encode('test message\n'));
                unawaited(socket.flush());
              },
              child: const Text('Send test message'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _msgs.length,
                itemBuilder: (context, index) => Text(_msgs[index]),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
