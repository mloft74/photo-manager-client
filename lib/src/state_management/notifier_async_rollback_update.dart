import 'package:flutter/foundation.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:synchronized/synchronized.dart';

typedef UpdateRes<T extends Object, E extends Object> = FutureOr<Result<T, E>>;
typedef UpdateFn<TResVal extends Object, TResErr extends Object, TState>
    = UpdateRes<TResVal, TResErr> Function(TState value);

mixin NotifierAsyncRollbackUpdate<TState> on AutoDisposeNotifier<TState> {
  @protected
  UpdateRes<TResVal, TResErr>
      updateWithRollback<TResVal extends Object, TResErr extends Object>(
    UpdateFn<TResVal, TResErr, TState> update,
  ) async {
    final oldState = state;

    final res = update(oldState);
    final Result<TResVal, TResErr> awaited;
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

  final _stateLock = Lock();
  @protected
  Future<Result<TResVal, TResErr>> updateWithRollbackSynchronized<
          TResVal extends Object, TResErr extends Object>(
    UpdateFn<TResVal, TResErr, TState> update,
  ) async =>
      await _stateLock.synchronized(
        () async => await updateWithRollback(
          update,
        ),
      );
}
