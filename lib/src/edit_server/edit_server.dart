import 'package:flutter/material.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/widgets/photo_manager_bottom_app_bar.dart';
import 'package:photo_manager_client/src/widgets/photo_manager_scaffold.dart';

class EditServer extends StatefulWidget {
  const EditServer({super.key});

  @override
  State<EditServer> createState() => _EditServerState();
}

class _EditServerState extends State<EditServer> {
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
      bottomAppBar: PhotoManagerBottomAppBar(
        leading: const BackButton(),
        titleText: 'Edit Server',
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              debugPrint('delete server');
            },
          )
        ],
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          reverse: true,
          children: [
            FilledButton(
              onPressed: () {
                final valid = _formKey.currentState.option
                    .mapOr(or: false, map: (value) => value.validate());
                debugPrint(
                  valid
                      ? 'uri: ${_uriTextController.text}, name: ${_nameTextController.text}'
                      : 'invalid',
                );
              },
              child: const Text('Save'),
            ),
            TextFormField(
              controller: _uriTextController,
              decoration: const InputDecoration(
                helperText: '',
                hintText: 'Server uri',
              ),
              validator: (value) {
                debugPrint('value: $value');
                return value.option
                    .andThen((value) => Uri.tryParse(value).option)
                    .mapOrElse(
                      orElse: () => const Option.some('Invalid URI'),
                      map: (value) => const Option<String>.none(),
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
            ),
          ],
        ),
      ),
    );
  }
}
