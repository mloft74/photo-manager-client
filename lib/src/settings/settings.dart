import 'package:flutter/material.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/widgets/bottom_app_bar_title.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final _formKey = GlobalKey<FormState>();
  final _uriTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomAppBar(
        child: Row(
          children: [
            BackButton(),
            BottomAppBarTitle('Settings'),
          ],
        ),
      ),
      body: SafeArea(
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
      ),
    );
  }

  @override
  void dispose() {
    _uriTextController.dispose();
    super.dispose();
  }
}
