import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:photo_manager_client/src/domain/server.dart';
import 'package:photo_manager_client/src/persistence/server/pods/current_server_pod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_server_result_pod.freezed.dart';
part 'current_server_result_pod.g.dart';

@riverpod
Result<Server, CurrentServerResultError> currentServerResult(
  CurrentServerResultRef ref,
) {
  final x = ref.watch(currentServerPod);
  return switch (x) {
    AsyncData(value: Some(:final value)) => Ok(value),
    AsyncData() => const Err(NoServerSelected()),
    AsyncError(:final error, :final stackTrace) =>
      Err(ErrorOccurred(error, stackTrace)),
    _ => const Err(Loading()),
  };
}

@freezed
sealed class CurrentServerResultError with _$CurrentServerResultError {
  const factory CurrentServerResultError.noServerSelected() = NoServerSelected;

  const factory CurrentServerResultError.errorOccurred(
    Object error,
    StackTrace stackTrace,
  ) = ErrorOccurred;

  const factory CurrentServerResultError.loading() = Loading;
}
