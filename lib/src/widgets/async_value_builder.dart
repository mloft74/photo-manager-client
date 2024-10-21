import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/errors/displayable.dart';
import 'package:photo_manager_client/src/errors/error_trace.dart';
import 'package:photo_manager_client/src/extensions/show_error_logged_snackbar.dart';
import 'package:photo_manager_client/src/pods/logs_pod.dart';
import 'package:photo_manager_client/src/pods/models/log_topic.dart';

class AsyncValueBuilder<T> extends StatelessWidget {
  final AsyncValue<T> asyncValue;
  final Widget Function(BuildContext context, T value) builder;
  final Widget Function(
    BuildContext context,
    Object error,
    StackTrace stackTrace,
  )? errorBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;

  const AsyncValueBuilder({
    required this.asyncValue,
    required this.builder,
    this.errorBuilder,
    this.loadingBuilder,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return switch (asyncValue) {
      AsyncData(:final value) =>
        Builder(builder: (context) => builder(context, value)),
      AsyncError(:final error, :final stackTrace) => Consumer(
          builder: (context, ref, _) {
            ref.watch(logsPod.notifier).logError(
                  LogTopic.build,
                  CompoundDisplayable(
                    IList([
                      const DefaultDisplayable(
                        IListConst(['Error occurred during AsyncValueBuilder']),
                      ),
                      ErrorTrace(error, Some(stackTrace)),
                    ]),
                  ),
                );
            ScaffoldMessenger.of(context).showErrorLoggedSnackbar();

            if (errorBuilder case final errorBuilder?) {
              return errorBuilder(context, error, stackTrace);
            }

            final theme = Theme.of(context);
            return Center(
              child: Text(
                'Error occurred: $error\n$stackTrace',
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: theme.colorScheme.error),
              ),
            );
          },
        ),
      _ => Builder(
          builder: (context) {
            if (loadingBuilder case final loadingBuilder?) {
              return loadingBuilder(context);
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
    };
  }
}
