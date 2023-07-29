import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:photo_manager_client/src/consts.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/domain/server.dart';
import 'package:photo_manager_client/src/persistence/server/providers/save_server_provider.dart';
import 'package:photo_manager_client/src/widgets/async_value_builder.dart';
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
    // TODO(mloft74): prevent save button from being hit multiple times
    final serverToSave = useState(const Option<Server>.none());

    final formKey = useMemoized(GlobalKey<FormState>.new);
    final nameTextController =
        useTextEditingController(text: server?.uri.toString());
    final uriTextController = useTextEditingController(text: server?.name);

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
                  serverToSave.value = Some(value);
                }
              },
              child: const Text('Save'),
            ),
            FilledButton(
              onPressed: () {
                final data = _validateForm(
                  formKey: formKey,
                  nameTextController: nameTextController,
                  uriTextController: uriTextController,
                );
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
              controller: uriTextController,
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
              enabled: server == null,
              controller: nameTextController,
              decoration: const InputDecoration(
                helperText: '',
                hintText: 'Server name',
              ),
              validator: (value) {
                return value.option
                    .andThen((value) => value.isNotEmptyOption)
                    .mapOrElse(
                      orElse: () => const Some('Please provide a name'),
                      map: (value) => const None<String>(),
                    )
                    .nullable;
              },
            ),
            if (serverToSave.value case Some(value: final serverToSave))
              AsyncValueBuilder(
                asyncValue: ref.watch(saveServerProvider(serverToSave)),
                loadingBuilder: (context) => const Text(
                  'Saving server...',
                  textAlign: TextAlign.center,
                ),
                builder: (context, value) => const Text(
                  'Server saved',
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

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
