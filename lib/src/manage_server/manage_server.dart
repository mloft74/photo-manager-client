import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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
                  log(
                    'test connection',
                    name: 'ManageServer | test connection',
                  );
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
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);

    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text('Saving ${server.name}'),
        duration: const Duration(seconds: 1),
      ),
    );
    try {
      await ref.read(saveServerProvider)(server);
      await ref.read(updateCurrentServerProvider)(server);
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('${server.name} saved'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (ex, st) {
      log(
        'error saving server: $ex',
        stackTrace: st,
        name: 'ManageServer | _onSave',
      );
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error saving ${server.name}: $ex'),
        ),
      );
    }
  }
}
