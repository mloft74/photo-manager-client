import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:photo_manager_client/src/consts.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/domain/server.dart';
import 'package:photo_manager_client/src/widgets/photo_manager_bottom_app_bar.dart';
import 'package:photo_manager_client/src/widgets/photo_manager_scaffold.dart';

class ManageServer extends StatefulWidget {
  final PhotoManagerBottomAppBar bottomAppBar;
  final void Function(Server data) onSave;

  const ManageServer({
    required this.bottomAppBar,
    required this.onSave,
    super.key,
  });

  @override
  State<ManageServer> createState() => _ManageServerState();
}

class _ManageServerState extends State<ManageServer> {
  final _formKey = GlobalKey<FormState>();
  final _uriTextController = TextEditingController();
  final _nameTextController = TextEditingController();

  @override
  void dispose() {
    _uriTextController.dispose();
    _nameTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PhotoManagerScaffold(
      bottomAppBar: widget.bottomAppBar,
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
                  widget.onSave(value);
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
}