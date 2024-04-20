import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

mixin AsyncNotifierAsyncRollbackUpdate<TState>
    on AutoDisposeAsyncNotifier<TState> {
  FutureOr<Result<T, E>>
      updateWithRollback<T extends Object, E extends Object>({
    required E onNoData,
    required FutureOr<Result<T, E>> Function(TState value) update,
  }) async {
    final oldState = state;
    final value = oldState.value;
    if (value == null) {
      return Err(onNoData);
    }

    final res = update(value);
    final Result<T, E> awaited;
    if (res is Future) {
      awaited = await res;
    } else {
      awaited = res;
    }

    if (awaited.isErr) {
      state = oldState;
    }
    return awaited;
  }
}
