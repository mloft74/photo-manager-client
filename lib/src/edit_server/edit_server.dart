import 'package:flutter/material.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/widgets/photo_manager_bottom_app_bar.dart';
import 'package:photo_manager_client/src/widgets/photo_manager_scaffold.dart';

enum _RemoveServerOption {
  remove,
  cancel,
}

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
            onPressed: () async {
              final decision = await showDialog<_RemoveServerOption>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Remove server?'),
                    content: const Text(
                      'This will remove this server as an option for managing photos',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(
                            context,
                            _RemoveServerOption.cancel,
                          );
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(
                            context,
                            _RemoveServerOption.remove,
                          );
                        },
                        child: const Text('Remove'),
                      ),
                    ],
                  );
                },
              );
              debugPrint('decision: $decision');
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
            ),
          ],
        ),
      ),
    );
  }
}
