import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager_client/src/consts.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/domain/server.dart';
import 'package:photo_manager_client/src/persistence/server/providers/save_server_provider.dart';
import 'package:photo_manager_client/src/persistence/server/providers/update_current_server_provider.dart';
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

  Option<Server> _serverToSelect = const None<Server>();

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
    _serverToSelect.inspect(
      (server) {
        ref.listen(updateCurrentServerProvider(server), (previous, next) {
          switch (next) {
            case AsyncError(:final error, :final stackTrace):
              log(
                'error setting current server: $error',
                stackTrace: stackTrace,
                name: 'manage_server',
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('Error setting ${server.name} as current: $error'),
                ),
              );
              setState(() {
                _serverToSelect = const None();
              });
            case AsyncData():
              log(
                'updated current to ${server.name}',
                name: 'manage_server',
              );
              WidgetsBinding.instance.addPostFrameCallback(
                (timeStamp) {
                  if (!mounted) {
                    return;
                  }
                  Navigator.pop(context);
                },
              );
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
              onPressed: () async {
                final data = _validateForm();
                if (data case Some(:final value)) {
                  await _onSave(value);
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

  Future<void> _onSave(Server server) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Saving ${server.name}'),
        duration: const Duration(seconds: 1),
      ),
    );
    await ref.read(saveServerProvider)(server);
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${server.name} saved'),
        duration: const Duration(seconds: 2),
      ),
    );
    setState(() {
      _serverToSelect = Some(server);
    });
  }
}
