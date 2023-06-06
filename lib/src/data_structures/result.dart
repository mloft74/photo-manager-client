import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';

part 'result.freezed.dart';

// TODO(makayden): Document result with Rust api docs.

@Freezed(map: FreezedMapOptions.none)
sealed class Result<T extends Object, E extends Object> with _$Result {
  const Result._();

  const factory Result.ok(T value) = Ok;

  const factory Result.err(E error) = Err;

  bool get isOk => switch (this) {
        Ok() => true,
        Err() => false,
      };

  bool isOkAnd(bool Function(T value) f) => switch (this) {
        Ok(:final value) => f(value),
        Err() => false,
      };

  bool get isErr => !isOk;

  bool isErrAnd(bool Function(E error) f) => switch (this) {
        Ok() => false,
        Err(:final error) => f(error),
      };

  Option<T> get ok => switch (this) {
        Ok(:final value) => Option.some(value),
        Err() => const None(),
      };

  Option<E> get err => switch (this) {
        Ok() => const None(),
        Err(:final error) => Option.some(error),
      };

  Result<U, E> map<U extends Object>(U Function(T value) f) => switch (this) {
        Ok(:final value) => Ok(f(value)),
        Err(:final error) => Err(error),
      };

  U mapOr<U extends Object>(U defaultValue, U Function(T value) f) =>
      switch (this) {
        Ok(:final value) => f(value),
        Err() => defaultValue,
      };

  U mapOrElse<U extends Object>(
    U Function(E error) defaultF,
    U Function(T value) f,
  ) =>
      switch (this) {
        Ok(:final value) => f(value),
        Err(:final error) => defaultF(error),
      };

  Result<T, F> mapErr<F extends Object>(F Function(E error) f) =>
      switch (this) {
        Ok(:final value) => Ok(value),
        Err(:final error) => Err(f(error)),
      };

  void inspect(void Function(T value) f) {
    if (this case Ok(:final value)) {
      f(value);
    }
  }

  void inspectErr(void Function(E error) f) {
    if (this case Err(:final error)) {
      f(error);
    }
  }

  Iterable<T> get iterable => switch (this) {
        Ok(:final value) => [value],
        Err() => [],
      };

  T expect(String msg) => switch (this) {
        Ok(:final value) => value,
        Err(:final error) => _unwrapFailed(msg, error),
      };

  T unwrap() => switch (this) {
        Ok(:final value) => value,
        Err(:final error) =>
          _unwrapFailed('called `Result.unwrap()` on an `Err` value', error),
      };

  E expectErr(String msg) => switch (this) {
        Ok(:final value) => _unwrapFailed(msg, value),
        Err(:final error) => error,
      };

  E unwrapErr() => switch (this) {
        Ok(:final value) =>
          _unwrapFailed('called `Result.unwrapErr()` on an `Ok` value', value),
        Err(:final error) => error,
      };

  Result<U, E> and<U extends Object>(Result<U, E> res) => switch (this) {
        Ok() => res,
        Err(:final error) => Err(error),
      };

  Result<U, E> andThen<U extends Object>(Result<U, E> Function(T value) f) =>
      switch (this) {
        Ok(:final value) => f(value),
        Err(:final error) => Err(error),
      };

  Result<T, F> or<F extends Object>(Result<T, F> res) => switch (this) {
        Ok(:final value) => Ok(value),
        Err() => res,
      };

  Result<T, F> orElse<F extends Object>(Result<T, F> Function(E error) f) =>
      switch (this) {
        Ok(:final value) => Ok(value),
        Err(:final error) => f(error),
      };

  T unwrapOr(T defaultValue) => switch (this) {
        Ok(:final value) => value,
        Err() => defaultValue,
      };

  T unwrapOrElse(T Function(E error) f) => switch (this) {
        Ok(:final value) => value,
        Err(:final error) => f(error),
      };
}

extension ResultOptionExtension<T extends Object, E extends Object>
    on Result<Option<T>, E> {
  Option<Result<T, E>> get transposed => switch (this) {
        Ok(value: Some(:final value)) => Option.some(Ok(value)),
        Ok(value: None()) => const None(),
        Err(:final error) => Option.some(Err(error)),
      };
}

extension NestedResult<T extends Object, E extends Object>
    on Result<Result<T, E>, E> {
  Result<T, E> get flattened => switch (this) {
        Ok(:final value) => value,
        Err(:final error) => Err(error),
      };
}

Never _unwrapFailed(String msg, Object error) {
  throw StateError('$msg: $error');
}
