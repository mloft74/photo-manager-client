/// The documentation for this library is taken
/// from https://doc.rust-lang.org/std/result/enum.Result.html.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:photo_manager_client/src/data_structures/option.dart';

part 'result.freezed.dart';

/// [Result] is a type that represents either success ([Ok]) or failure ([Err]).
///
/// See https://doc.rust-lang.org/std/result/index.html for more.
@freezed
sealed class Result<T extends Object, E extends Object> with _$Result {
  const Result._();

  /// Contains the success value.
  const factory Result.ok(T value) = Ok;

  /// Contains the error value.
  const factory Result.err(E error) = Err;

  /// Returns `true` if the result is [Ok].
  bool get isOk => switch (this) {
        Ok() => true,
        Err() => false,
      };

  /// Returns `true` if the result is [Ok]
  /// and the value inside of it matches a predicate.
  bool isOkAnd(bool Function(T value) fn) => switch (this) {
        Ok(:final value) => fn(value),
        Err() => false,
      };

  /// Returns `true` if the result is [Err].
  bool get isErr => !isOk;

  /// Returns `true` if the result is [Err]
  /// and the value inside of it matches a predicate.
  bool isErrAnd(bool Function(E error) fn) => switch (this) {
        Ok() => false,
        Err(:final error) => fn(error),
      };

  /// Converts from [Result] of [T] and [E] to [Option] of [T].
  Option<T> get ok => switch (this) {
        Ok(:final value) => Option.some(value),
        Err() => None<T>(),
      };

  /// Converts from [Result] of [T] and [E] to [Option] of [E].
  Option<E> get err => switch (this) {
        Ok() => None<E>(),
        Err(:final error) => Option.some(error),
      };

  /// Maps a [Result] of [T] and [E] to [Result] of [U] and [E]
  /// by applying a function to a contained [Ok] value,
  /// leaving an [Err] value untouched.
  ///
  /// This function can be used to compose the results of two functions.
  Result<U, E> map<U extends Object>(U Function(T value) fn) => switch (this) {
        Ok(:final value) => Ok(fn(value)),
        Err(:final error) => Err(error),
      };

  /// Returns the provided default (if [Err]),
  /// or applies a function to the contained value (if [Ok]).
  ///
  /// Arguments passed to [mapOr] are eagerly evaluated;
  /// if you are passing the result of a function call,
  /// it is recommended to use [mapOrElse],
  /// which is lazily evaluated.
  U mapOr<U extends Object>({
    required U or,
    required U Function(T value) map,
  }) =>
      switch (this) {
        Ok(:final value) => map(value),
        Err() => or,
      };

  /// Maps a [Result] of [T] and [E] to [U]
  /// by applying fallback function [orElse] to a contained [Err] value,
  /// or function [map] to a contained [Ok] value.
  ///
  /// This function can be used to unpack a successful
  /// result while handling an error.
  U mapOrElse<U extends Object>(
    U Function(E error) orElse,
    U Function(T value) map,
  ) =>
      switch (this) {
        Ok(:final value) => map(value),
        Err(:final error) => orElse(error),
      };

  /// Maps a [Result] of [T] and [E] to [Result] of [T] and [F]
  /// by applying a function to a contained [Err] value,
  /// leaving an [Ok] value untouched.
  ///
  /// This function can be used to pass through a successful
  /// result while handling an error.
  Result<T, F> mapErr<F extends Object>(F Function(E error) fn) =>
      switch (this) {
        Ok(:final value) => Ok(value),
        Err(:final error) => Err(fn(error)),
      };

  /// Calls the provided closure with a reference to the contained value (if [Ok]).
  void inspect(void Function(T value) fn) {
    if (this case Ok(:final value)) {
      fn(value);
    }
  }

  /// Calls the provided closure with a reference to the contained error (if [Err]).
  void inspectErr(void Function(E error) fn) {
    if (this case Err(:final error)) {
      fn(error);
    }
  }

  /// Returns an iterable over the possibly contained value.
  ///
  /// The iterator yields one value if the result is [Ok], otherwise none.
  Iterable<T> get iterable => switch (this) {
        Ok(:final value) => [value],
        Err() => [],
      };

  /// Returns the contained [Ok] value.
  ///
  /// Because this function can throw, its use is generally discouraged.
  /// Instead, prefer to use pattern matching
  /// and handle the [Err] case explicitly,
  /// or call [unwrapOr] or [unwrapOrElse]
  ///
  /// Throws a [StateError] if the value is an [Err]
  /// with a custom error message provided by [msg] and the content of [Err].
  T expect(String msg) => switch (this) {
        Ok(:final value) => value,
        Err(:final error) => _unwrapFailed(msg, error),
      };

  /// Returns the contained [Ok] value.
  ///
  /// Because this function can throw, its use is generally discouraged.
  /// Instead, prefer to use pattern matching
  /// and handle the [Err] case explicitly,
  /// or call [unwrapOr] or [unwrapOrElse]
  ///
  /// Throws a [StateError] if the value is an [Err]
  /// with an error message provided by the [Err]'s value.
  T unwrap() => switch (this) {
        Ok(:final value) => value,
        Err(:final error) =>
          _unwrapFailed('called `Result.unwrap()` on an `Err` value', error),
      };

  /// Returns the contained [Err] value.
  ///
  /// Throws a [StateError] if the value is an [Ok]
  /// with a custom error message provided by [msg] and the content of [Ok].
  E expectErr(String msg) => switch (this) {
        Ok(:final value) => _unwrapFailed(msg, value),
        Err(:final error) => error,
      };

  /// Returns the contained [Err] value.
  ///
  /// Throws a [StateError] if the value is an [Ok]
  /// with an error message provided by the [Ok]'s value.
  E unwrapErr() => switch (this) {
        Ok(:final value) =>
          _unwrapFailed('called `Result.unwrapErr()` on an `Ok` value', value),
        Err(:final error) => error,
      };

  /// Returns [other] if the result is [Ok],
  /// otherwise returns the [Err] value of this.
  ///
  /// Arguments passed to and are eagerly evaluated;
  /// if you are passing the result of a function call,
  /// it is recommended to use [andThen],
  /// which is lazily evaluated.
  Result<U, E> and<U extends Object>(Result<U, E> other) => switch (this) {
        Ok() => other,
        Err(:final error) => Err(error),
      };

  /// Calls [fn] if the result is [Ok], otherwise returns the [Err] value of this.
  ///
  /// This function can be used for control flow based on [Result] values.
  ///
  /// Often used to chain fallible operations that may return [Err].
  Result<U, E> andThen<U extends Object>(Result<U, E> Function(T value) fn) =>
      switch (this) {
        Ok(:final value) => fn(value),
        Err(:final error) => Err(error),
      };

  /// Returns [res] if the result is [Err],
  /// otherwise returns the [Ok] value of this.
  ///
  /// Arguments passed to or are eagerly evaluated;
  /// if you are passing the result of a function call,
  /// it is recommended to use [orElse],
  /// which is lazily evaluated.
  Result<T, F> or<F extends Object>(Result<T, F> res) => switch (this) {
        Ok(:final value) => Ok(value),
        Err() => res,
      };

  /// Calls [fn] if the result is [Err],
  /// otherwise returns the [Ok] value of this.
  ///
  /// This function can be used for control flow based on result values.
  Result<T, F> orElse<F extends Object>(Result<T, F> Function(E error) fn) =>
      switch (this) {
        Ok(:final value) => Ok(value),
        Err(:final error) => fn(error),
      };

  /// Returns the contained [Ok] value or a provided default.
  ///
  /// Arguments passed to [unwrapOr] are eagerly evaluated;
  /// if you are passing the result of a function call,
  /// it is recommended to use [unwrapOrElse],
  /// which is lazily evaluated.
  T unwrapOr(T defaultValue) => switch (this) {
        Ok(:final value) => value,
        Err() => defaultValue,
      };

  /// Returns the contained [Ok] value or computes it from a closure.
  T unwrapOrElse(T Function(E error) fn) => switch (this) {
        Ok(:final value) => value,
        Err(:final error) => fn(error),
      };
}

extension ResultOptionExtension<T extends Object, E extends Object>
    on Result<Option<T>, E> {
  /// Transposes a [Result] of an [Option] into an [Option] of a [Result].
  ///
  /// [Ok] with [None] will be mapped to [None].
  /// [Ok] with [Some] and [Err] will be
  /// mapped to [Some] with [Ok] and [Some] with [Err].
  Option<Result<T, E>> get transposed => switch (this) {
        Ok(value: Some(:final value)) => Option.some(Ok(value)),
        Ok(value: None()) => None<Result<T, E>>(),
        Err(:final error) => Option.some(Err(error)),
      };
}

extension NestedResult<T extends Object, E extends Object>
    on Result<Result<T, E>, E> {
  /// Converts from [Result] of [Result] of [T] and [E] and [E]
  /// to [Result] of [T] and [E].
  Result<T, E> get flattened => switch (this) {
        Ok(:final value) => value,
        Err(:final error) => Err(error),
      };
}

/// This is a separate function to reduce the code size of the methods.
Never _unwrapFailed(String msg, Object error) {
  throw StateError('$msg: $error');
}
