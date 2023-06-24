import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/domain/server.dart';
import 'package:photo_manager_client/src/manage_server/widgets/manage_server.dart';
import 'package:photo_manager_client/src/persistence/server/add_server_provider.dart';
import 'package:photo_manager_client/src/widgets/photo_manager_bottom_app_bar.dart';

class AddServer extends ConsumerStatefulWidget {
  const AddServer({super.key});

  @override
  ConsumerState<AddServer> createState() => _AddServerState();
}

class _AddServerState extends ConsumerState<AddServer> {
  Option<Server> _server = const None<Server>();

  @override
  Widget build(BuildContext context) {
    _server.inspect(
      (value) {
        ref.listen(addServerProvider(value), (previous, next) {
          switch (next) {
            case AsyncError(:final error, :final stackTrace):
              log('$error', stackTrace: stackTrace, name: 'add_server');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error saving server: $error')),
              );
              setState(() {
                _server = const None();
              });
            case AsyncData():
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Server ${value.name} saved')),
              );
              setState(() {
                _server = const None();
              });
            case _:
              log('loading', name: 'add_server');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Server ${value.name} saved')),
              );
          }
        });
      },
    );
    return ManageServer(
      onSave: (data) {
        log(
          'name: ${data.uri}, uri: ${data.uri}',
          name: 'add_server',
        );
        setState(() {
          _server = Some(data);
        });
      },
      bottomAppBar: const PhotoManagerBottomAppBar(
        leading: BackButton(),
        titleText: 'Add Server',
      ),
    );
  }
}
