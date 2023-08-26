import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      AsyncError(:final error, :final stackTrace) => Builder(
          builder: (context) {
            if (errorBuilder case final errorBuilder?) {
              return errorBuilder(context, error, stackTrace);
            }

            final theme = Theme.of(context);
            return Center(
              child: Text(
                'Error occurred: $error',
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
