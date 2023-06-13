import 'package:flutter/material.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Form(
            key: _formKey,
            child: TextFormField(
              decoration: const InputDecoration(
                helperText: '',
              ),
              validator: (value) {
                return value.option
                    .andThen((value) => Uri.tryParse(value).option)
                    .mapOr('Not a valid URI', (value) => '');
              },
            ),
          ),
          FilledButton(
            onPressed: () {
              final valid = _formKey.currentState.option
                  .mapOr(false, (value) => value.validate());
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('Form valid: $valid')));
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
