import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/live_debug/debug_connection.dart';
import 'package:photo_manager_client/src/persistence/server/pods/selected_server_pod.dart';
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

  DebugConnection? _connection;
  // Cancelled under an alias
  // ignore: cancel_subscriptions
  StreamSubscription<String>? _sub;

  @override
  void initState() {
    super.initState();

    final server = ref.read(selectedServerPod);
    switch (server) {
      case Some(value: final server):
        unawaited(_createConnection(server.uri.host));
      case None():
        _state = 'error: no server selected';
    }
  }

  Future<()> _createConnection(String host) async {
    log('host: $host', name: 'live_debug');
    final connection = await DebugConnection.connect(host, 4000);
    if (_disposed) {
      connection.close();
    } else {
      _sub = connection.events.listen(
        (event) {
          setState(() {
            _msgs.add(event);
          });
        },
        // onError needs types.
        // ignore: avoid_types_on_closure_parameters
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
      _connection = connection;
      setState(() {
        _state = 'connected';
      });
    }
    return ();
  }

  var _disposed = false;
  @override
  void dispose() {
    _disposed = true;

    final connection = _connection;
    _connection = null;
    connection?.close();

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
          Expanded(
            child: ListView.builder(
              itemCount: _msgs.length,
              itemBuilder: (context, index) => Text(_msgs[index]),
            ),
          ),
        ],
      ),
    );
  }
}
