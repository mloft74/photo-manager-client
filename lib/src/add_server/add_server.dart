import 'package:flutter/material.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/widgets/photo_manager_bottom_app_bar.dart';
import 'package:photo_manager_client/src/widgets/photo_manager_scaffold.dart';

class AddServer extends StatefulWidget {
  const AddServer({super.key});

  @override
  State<AddServer> createState() => _AddServerState();
}

class _AddServerState extends State<AddServer> {
  final _formKey = GlobalKey<FormState>();
  final _uriTextController = TextEditingController();

  @override
  void dispose() {
    _uriTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PhotoManagerScaffold(
      bottomAppBar: const PhotoManagerBottomAppBar(
        leading: BackButton(),
        titleText: 'Add Server',
      ),
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        reverse: true,
        children: [
          FilledButton(
            onPressed: () {
              final valid = _formKey.currentState.option
                  .mapOr(or: false, map: (value) => value.validate());
              debugPrint(valid ? _uriTextController.text : 'invalid');
            },
            child: const Text('Save'),
          ),
          Form(
            key: _formKey,
            child: TextFormField(
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
          ),
        ],
      ),
    );
  }
}
