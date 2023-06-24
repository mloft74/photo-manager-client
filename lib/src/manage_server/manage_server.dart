import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager_client/src/consts.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/domain/server.dart';
import 'package:photo_manager_client/src/persistence/server/providers/save_server_provider.dart';
import 'package:photo_manager_client/src/widgets/photo_manager_bottom_app_bar.dart';
import 'package:photo_manager_client/src/widgets/photo_manager_scaffold.dart';

class ManageServer extends ConsumerStatefulWidget {
  final Server? server;

  const ManageServer({
    this.server,
    super.key,
  });

  @override
  ConsumerState<ManageServer> createState() => _ManageServerState();
}

class _ManageServerState extends ConsumerState<ManageServer> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _uriTextController;
  late final TextEditingController _nameTextController;

  Option<Server> _serverToSave = const None<Server>();

  @override
  void initState() {
    super.initState();
    _uriTextController =
        TextEditingController(text: widget.server?.uri.toString());
    _nameTextController = TextEditingController(text: widget.server?.name);
  }

  @override
  void dispose() {
    _uriTextController.dispose();
    _nameTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _serverToSave.inspect(
      (server) {
        ref.listen(saveServerProvider(server), (previous, next) {
          switch (next) {
            case AsyncError(:final error, :final stackTrace):
              log('$error', stackTrace: stackTrace, name: 'add_server');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error saving ${server.name}: $error'),
                ),
              );
              setState(() {
                _serverToSave = const None();
              });
            case AsyncData():
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${server.name} saved'),
                  duration: const Duration(seconds: 2),
                ),
              );
              setState(() {
                _serverToSave = const None();
              });
          }
        });
      },
    );

    return PhotoManagerScaffold(
      bottomAppBar: const PhotoManagerBottomAppBar(
        leading: BackButton(),
        titleText: 'Manage Server',
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          padding: edgeInsetsForRoutePadding,
          reverse: true,
          children: [
            FilledButton(
              onPressed: () {
                final data = _validateForm();
                if (data case Some(:final value)) {
                  _onSave(value);
                }
              },
              child: const Text('Save'),
            ),
            FilledButton(
              onPressed: () {
                final data = _validateForm();
                if (data case Some()) {
                  log('test connection', name: 'manage_server');
                }
              },
              child: const Text('Test connection'),
            ),
            TextFormField(
              controller: _uriTextController,
              decoration: const InputDecoration(
                helperText: '',
                hintText: 'Server uri',
              ),
              validator: (value) {
                return value.option
                    .andThen((value) => value.isNotEmptyOption)
                    .andThen((value) => Uri.tryParse(value).option)
                    .mapOrElse(
                      orElse: () => const Some('Invalid URI'),
                      map: (value) => const None<String>(),
                    )
                    .nullable;
              },
            ),
            TextFormField(
              enabled: widget.server == null,
              controller: _nameTextController,
              decoration: const InputDecoration(
                helperText: '',
                hintText: 'Server name',
              ),
              validator: (value) {
                return value.option
                    .andThen((value) => value.isNotEmptyOption)
                    .mapOrElse(
                      orElse: () => const Some('Please provide a name'),
                      map: (value) => const Option<String>.none(),
                    )
                    .nullable;
              },
            ),
          ],
        ),
      ),
    );
  }

  Option<Server> _validateForm() {
    final valid = _formKey.currentState.option
        .mapOr(or: false, map: (value) => value.validate());
    if (!valid) {
      return const None();
    }

    final name = _nameTextController.text;
    final uri = Uri.parse(_uriTextController.text);
    return Some(
      Server(name: name, uri: uri),
    );
  }

  void _onSave(Server server) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Saving ${server.name}'),
        duration: const Duration(seconds: 1),
      ),
    );
    setState(() {
      _serverToSave = Some(server);
    });
  }
}
