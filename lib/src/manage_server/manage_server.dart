import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:photo_manager_client/src/consts.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/domain/server.dart';
import 'package:photo_manager_client/src/extensions/pipe_extension.dart';
import 'package:photo_manager_client/src/manage_server/pods/test_connection_pod.dart';
import 'package:photo_manager_client/src/persistence/server/pods/save_server_pod.dart';
import 'package:photo_manager_client/src/widgets/photo_manager_bottom_app_bar.dart';
import 'package:photo_manager_client/src/widgets/photo_manager_scaffold.dart';

class ManageServer extends HookConsumerWidget {
  final Server? server;

  const ManageServer({
    this.server,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final nameTextController = useTextEditingController(text: server?.name);
    final uriTextController =
        useTextEditingController(text: server?.uri.toString());

    return PhotoManagerScaffold(
      bottomAppBar: const PhotoManagerBottomAppBar(
        leading: BackButton(),
        titleText: 'Manage Server',
      ),
      child: Form(
        key: formKey,
        child: ListView(
          padding: edgeInsetsForRoutePadding,
          reverse: true,
          children: [
            FilledButton(
              onPressed: () async {
                final data = _validateForm(
                  formKey: formKey,
                  nameTextController: nameTextController,
                  uriTextController: uriTextController,
                );
                if (data case Some(:final value)) {
                  await _onSave(
                    context: context,
                    ref: ref,
                    server: value,
                  );
                }
              },
              child: const Text('Save'),
            ),
            FilledButton(
              onPressed: () async {
                final data = _validateForm(
                  formKey: formKey,
                  nameTextController: nameTextController,
                  uriTextController: uriTextController,
                );
                if (data case Some(:final value)) {
                  await _onTestConnection(
                    context: context,
                    ref: ref,
                    server: value,
                  );
                }
              },
              child: const Text('Test connection'),
            ),
            TextFormField(
              controller: uriTextController,
              decoration: const InputDecoration(
                helperText: '',
                hintText: 'Server uri',
              ),
              validator: (value) =>
                  value.option.pipe(_validateServerUri).nullable,
            ),
            TextFormField(
              enabled: server == null,
              controller: nameTextController,
              decoration: const InputDecoration(
                helperText: '',
                hintText: 'Server name',
              ),
              validator: (value) =>
                  value.option.pipe(_validateServerName).nullable,
            ),
          ],
        ),
      ),
    );
  }
}

Option<String> _validateServerUri(Option<String> value) => value
    .andThen((value) => value.isNotEmptyOption)
    .andThen((value) => Uri.tryParse(value).option)
    .mapOrElse(
      orElse: () => const Some('Invalid URI'),
      map: (value) => const None(),
    );

Option<String> _validateServerName(Option<String> value) =>
    value.andThen((value) => value.isNotEmptyOption).mapOrElse(
          orElse: () => const Some('Please provide a name'),
          map: (value) => const None(),
        );

Option<Server> _validateForm({
  required GlobalKey<FormState> formKey,
  required TextEditingController nameTextController,
  required TextEditingController uriTextController,
}) {
  final valid = formKey.currentState.option
      .mapOr(or: false, map: (value) => value.validate());
  if (!valid) {
    return const None();
  }

  final name = nameTextController.text;
  final uri = Uri.parse(uriTextController.text);
  return Some(
    Server(name: name, uri: uri),
  );
}

Future<()> _onSave({
  required BuildContext context,
  required WidgetRef ref,
  required Server server,
}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);

  scaffoldMessenger.showSnackBar(
    SnackBar(
      content: Text('Saving ${server.name}'),
      duration: const Duration(seconds: 1),
    ),
  );
  try {
    await ref.read(saveServerPod)(server);
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text('${server.name} saved'),
        duration: const Duration(seconds: 2),
      ),
    );
    navigator.pop();
  } catch (ex, st) {
    log(
      'error saving server',
      error: ex,
      stackTrace: st,
      name: 'ManageServer | _onSave',
    );
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text('Error saving ${server.name}: $ex'),
      ),
    );
  }

  return ();
}

Future<()> _onTestConnection({
  required BuildContext context,
  required WidgetRef ref,
  required Server server,
}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  String message;
  try {
    final result = await ref.read(testConnectionPod)(server);
    message = result.map((value) => 'Connection successful').coalesced;
  } catch (ex, st) {
    log(
      'error connecting to server',
      name: 'ManageServer',
      error: ex,
      stackTrace: st,
    );
    message = 'Error connecting to server: $ex';
  }

  scaffoldMessenger.showSnackBar(SnackBar(content: Text(message)));

  return ();
}
