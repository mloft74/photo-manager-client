import 'package:flutter/material.dart';
import 'package:photo_manager_client/src/consts.dart';
import 'package:photo_manager_client/src/errors/displayable.dart';
import 'package:photo_manager_client/src/errors/error_trace.dart';
import 'package:photo_manager_client/src/widgets/photo_manager_bottom_app_bar.dart';
import 'package:photo_manager_client/src/widgets/photo_manager_scaffold.dart';

final class ErrorParsingLogs extends StatelessWidget {
  final ErrorTrace<Object> error;

  const ErrorParsingLogs({
    required this.error,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return PhotoManagerScaffold(
      bottomAppBar: const PhotoManagerBottomAppBar(
        leading: BackButton(),
        titleText: 'Viewing Logs',
      ),
      child: ListView(
        padding: edgeInsetsForRoutePadding,
        children: [
          Card(
            child: ListTile(
              title: Text(error.toDisplayJoined()),
            ),
          ),
        ],
      ),
    );
  }
}
