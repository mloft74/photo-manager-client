import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager_client/src/consts.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/domain/server.dart';
import 'package:photo_manager_client/src/extensions/pipe_extension.dart';
import 'package:photo_manager_client/src/manage_server/pods/test_connection_pod.dart';
import 'package:photo_manager_client/src/persistence/server/pods/servers_pod.dart';
import 'package:photo_manager_client/src/util/run_with_toasts.dart';
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

  late final TextEditingController _nameController;
  late final TextEditingController _uriController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.server?.name);
    _uriController = TextEditingController(text: widget.server?.uri.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _uriController.dispose();
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
                final data = _validateForm(
                  formKey: _formKey,
                  nameController: _nameController,
                  uriController: _uriController,
                );
                if (data case Some(:final value)) {
                  await _onSave(
                    context: context,
                    ref: ref,
                    server: value,
                    newServer: widget.server == null,
                  );
                }
              },
              child: const Text('Save'),
            ),
            FilledButton(
              onPressed: () async {
                final data = _validateForm(
                  formKey: _formKey,
                  nameController: _nameController,
                  uriController: _uriController,
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
              controller: _uriController,
              decoration: const InputDecoration(
                helperText: '',
                hintText: 'Server uri',
              ),
              validator: (value) =>
                  value.toOption().pipe(_validateServerUri).toNullable(),
            ),
            TextFormField(
              enabled: widget.server == null,
              controller: _nameController,
              decoration: const InputDecoration(
                helperText: '',
                hintText: 'Server name',
              ),
              validator: (value) =>
                  value.toOption().pipe(_validateServerName).toNullable(),
            ),
          ],
        ),
      ),
    );
  }
}

Option<String> _validateServerUri(Option<String> value) => value
    .andThen((value) => value.toNotEmptyOption())
    .andThen((value) => Uri.tryParse(value).toOption())
    .mapOrElse(
      orElse: () => const Some('Invalid URI'),
      map: (value) => const None(),
    );

Option<String> _validateServerName(Option<String> value) =>
    value.andThen((value) => value.toNotEmptyOption()).mapOrElse(
          orElse: () => const Some('Please provide a name'),
          map: (value) => const None(),
        );

Option<Server> _validateForm({
  required GlobalKey<FormState> formKey,
  required TextEditingController nameController,
  required TextEditingController uriController,
}) {
  final valid = formKey.currentState
      .toOption()
      .mapOr(or: false, map: (value) => value.validate());
  if (!valid) {
    return const None();
  }

  final name = nameController.text;
  final uri = Uri.parse(uriController.text);
  return Some(
    Server(name: name, uri: uri),
  );
}

Future<()> _onSave({
  required BuildContext context,
  required WidgetRef ref,
  required Server server,
  required bool newServer,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);

  final res = await runWithToasts(
    messenger: messenger,
    op: () {
      final notifier = ref.read(serversPod.notifier);
      return newServer
          ? notifier.saveServer(server)
          : notifier.updateServer(server);
    },
    startingMsg: 'Saving ${server.name}',
    finishedMsg: '${server.name} saved',
  );
  if (res.isOk) {
    navigator.pop();
  }

  return ();
}

Future<()> _onTestConnection({
  required BuildContext context,
  required WidgetRef ref,
  required Server server,
}) async {
  final messenger = ScaffoldMessenger.of(context);

  await runWithToasts(
    messenger: messenger,
    op: () => ref.read(testConnectionPod)(server),
    startingMsg: 'Testing connection',
    finishedMsg: 'Connection successful',
  );

  return ();
}
