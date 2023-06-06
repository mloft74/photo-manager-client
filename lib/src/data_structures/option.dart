/// The documenation for this library is taken
/// from https://doc.rust-lang.org/std/option/enum.Option.html.
/// The library author claims no copyright
/// over the documentation in this library.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';

part 'option.freezed.dart';

/// The [Option] type.
///
/// See https://doc.rust-lang.org/std/option/index.html for more.
@Freezed(map: FreezedMapOptions.none)
sealed class Option<T extends Object> with _$Option<T> {
  const Option._();

  /// Some value of type [T].
  const factory Option.some(T value) = Some;

  /// No value.
  const factory Option.none() = None;

  /// Converts a nullable [T] to an [Option] of [T].
  factory Option.from(T? value) =>
      value != null ? Option.some(value) : const Option.none();

  /// Returns `true` if the option is a [Some] value.
  bool get isSome => switch (this) {
        Some() => true,
        None() => false,
      };

  /// Returns `true` if the option is a [Some]
  /// and the value inside of it matches a predicate.
  bool isSomeAnd(bool Function(T value) f) => switch (this) {
        Some(:final value) => f(value),
        None() => false,
      };

  /// Returns `true` if the option is a [None] value.
  bool get isNone => !isSome;

  /// Returns the contained [Some] value.
  ///
  /// Because this function can throw, its use is generally discouraged.
  /// Instead, prefer to use pattern matching
  /// and handle the [None] case explicitly,
  /// or call [unwrapOr] or [unwrapOrElse]
  ///
  /// Throws a [StateError] if the value is a [None]
  /// with a custom error message provided by [msg].
  T expect(String msg) => switch (this) {
        Some(:final value) => value,
        None() => throw StateError(msg),
      };

  /// Returns the contained [Some] value.
  ///
  /// Because this function can throw, its use is generally discouraged.
  /// Instead, prefer to use pattern matching
  /// and handle the [None] case explicitly,
  /// or call [unwrapOr] or [unwrapOrElse]
  ///
  /// Throws a [StateError] if the value is a [None].
  T unwrap() => switch (this) {
        Some(:final value) => value,
        None() =>
          throw StateError('called `Option.unwrap()` on a `None` value'),
      };

  /// Returns the contained [Some] value or a provided default.
  ///
  /// Arguments passed to [unwrapOr] are eagerly evaluated;
  /// if you are passing the result of a function call,
  /// it is recommended to use [unwrapOrElse],
  /// which is lazily evaluated.
  T unwrapOr(T defaultValue) => switch (this) {
        Some(:final value) => value,
        None() => defaultValue,
      };

  /// Returns the contained [Some] value or computes it from a closure.
  T unwrapOrElse(T Function() f) => switch (this) {
        Some(:final value) => value,
        None() => f(),
      };

  /// Maps an [Option] of [T] to [Option] of [U] by applying
  /// a function to a contained value (if [Some]) or return [None] (if [None]).
  Option<U> map<U extends Object>(U Function(T value) f) => switch (this) {
        Some(:final value) => Option.some(f(value)),
        None() => const None(),
      };

  /// Calls the provided closure with a reference
  /// to the contained value (if [Some]).
  void inspect(void Function(T value) f) {
    if (this case Some(:final value)) {
      f(value);
    }
  }

  /// Returns the provided default result (if [None]),
  /// or applies a function to the contained value (if [Some]).
  ///
  /// Arguments passed to [mapOr] are eagerly evaluated;
  /// if you are passing the result of a function call,
  /// it is recommended to use [mapOrElse],
  /// which is lazily evaluated.
  U mapOr<U extends Object>(U defaultValue, U Function(T value) f) =>
      switch (this) {
        Some(:final value) => f(value),
        None() => defaultValue,
      };

  /// Computes a default function result (if [None]),
  /// or applies a different function to the contained value (if any).
  U mapOrElse<U extends Object>(U Function() defaultF, U Function(T value) f) =>
      switch (this) {
        Some(:final value) => f(value),
        None() => defaultF(),
      };

  /// Transforms the [Option] of [T] into a [Result] of [T] and [E],
  /// mapping [Some] to [Ok] and [None] to [Err] with [err].
  ///
  /// Arguments passed to [okOr] are eagerly evaluated;
  /// if you are passing the result of a function call,
  /// it is recommended to use [okOrElse],
  /// which is lazily evaluated.
  Result<T, E> okOr<E extends Object>(E err) => switch (this) {
        Some(:final value) => Ok(value),
        None() => Err(err),
      };

  /// Transforms the [Option] of [T] into a [Result] of [T] and [E],
  /// mapping [Some] to [Ok] and [None] to [Err] with the result of [errF].
  Result<T, E> okOrElse<E extends Object>(E Function() errF) => switch (this) {
        Some(:final value) => Ok(value),
        None() => Err(errF()),
      };

  /// Returns an [Iterable] over the possibly contained value.
  Iterable<T> get iterable => switch (this) {
        Some(:final value) => [value],
        None() => [],
      };

  /// Returns [None] if the option is [None], otherwise returns [optb].
  ///
  /// Arguments passed to [and] are eagerly evaluated;
  /// if you are passing the result of a function call,
  /// it is recommended to use [andThen],
  /// which is lazily evaluated.
  Option<U> and<U extends Object>(Option<U> optb) => switch (this) {
        Some() => optb,
        None() => const None(),
      };

  /// Returns [None] if the option is [None],
  /// otherwise calls [f] with the wrapped value and returns the result.
  ///
  /// Some languages call this operation flatmap.
  ///
  /// Often used to chain fallible operations that may return [None].
  Option<U> andThen<U extends Object>(Option<U> Function(T value) f) =>
      switch (this) {
        Some(:final value) => f(value),
        None() => const None(),
      };

  /// Returns [None] if the option is [None],
  /// otherwise calls [predicate] with the wrapped value and returns:
  /// - [Some] if [predicate] returns `true`, and
  /// - [None] if [predicate] returns `false`.
  ///
  /// This function works similar to [List.where].
  /// You can imagine the [Option] of [T]
  /// being an iterable over one or zero elements.
  /// [where] lets you decide which elements to keep.
  Option<T> where(bool Function(T value) predicate) {
    if (this case Some(:final value)) {
      if (predicate(value)) {
        return Some(value);
      }
    }
    return const None();
  }

  /// Returns the option if it contains a value,
  /// otherwise returns [optb].
  ///
  /// Arguments passed to [or] are eagerly evaluated;
  /// if you are passing the result of a function call,
  /// it is recommended to use [orElse],
  /// which is lazily evaluated.
  Option<T> or(Option<T> optb) => switch (this) {
        Some(:final value) => Some(value),
        None() => optb,
      };

  /// Returns the option if it contains a value, otherwise calls [f] and returns the result.
  Option<T> orElse(Option<T> Function() f) => switch (this) {
        Some(:final value) => Some(value),
        None() => f(),
      };

  /// Returns [Some] if exactly one of this or [optb] is [Some],
  /// otherwise returns [None].
  Option<T> xor(Option<T> optb) => switch ((this, optb)) {
        (Some(:final value), None()) => Option.some(value),
        (None(), Some(:final value)) => Option.some(value),
        _ => const None(),
      };

  /// Zips this with another [Option].
  ///
  /// If this is [Some] and [other] is [Some],
  /// the method returns [Some].
  /// Otherwise, [None] is returned.
  Option<(T, U)> zip<U extends Object>(Option<U> other) =>
      switch ((this, other)) {
        (Some(value: final a), Some(value: final b)) => Option.some((a, b)),
        _ => const None(),
      };

  /// Zips this with another [Option] using [f].
  ///
  /// If this is [Some] and [other] is [Some],
  /// the method returns [Some].
  /// Otherwise, [None] is returned.
  Option<R> zipWith<U extends Object, R extends Object>(
    Option<U> other,
    R Function(T a, U b) f,
  ) =>
      switch ((this, other)) {
        (Some(value: final a), Some(value: final b)) => Option.some(f(a, b)),
        _ => const None(),
      };
}

extension ZippedOptionExtension<T extends Object, U extends Object>
    on Option<(T, U)> {
  /// Unzips an option containing a tuple of two options.
  ///
  /// If this is [Some] this method returns ([Some], [Some]).
  /// Otherwise, ([None], [None]) is returned.
  (Option<T>, Option<U>) get unzipped => switch (this) {
        Some(value: (final a, final b)) => (Option.some(a), Option.some(b)),
        None() => (const None(), const None()),
      };
}

extension OptionResultExtension<T extends Object, E extends Object>
    on Option<Result<T, E>> {
  /// Transposes an [Option] of a [Result] into a [Result] of an [Option].
  ///
  /// [None] will be mapped to [Ok] with [None].
  /// [Some] with [Ok] and [Some] with [Err] will
  /// be mapped to [Ok] with [Some] and [Err].
  Result<Option<T>, E> get transposed => switch (this) {
        Some(value: Ok(:final value)) => Ok(Some(value)),
        Some(value: Err(:final error)) => Err(error),
        None() => const Ok(None()),
      };
}

extension NestedOptionExtension<T extends Object> on Option<Option<T>> {
  /// Converts an [Option] of [Option] of [T] to [Option] of [T].
  ///
  /// Flattening only removes one level of nesting at a time.
  Option<T> get flattened => switch (this) {
        Some(:final value) => value,
        None() => const None(),
      };
}
