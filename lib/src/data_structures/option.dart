/// The documentation for this library is taken
/// from https://doc.rust-lang.org/std/option/enum.Option.html.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';
import 'package:rxdart/rxdart.dart';

part 'option.freezed.dart';

extension NullableTToOptionExtension<T extends Object> on T? {
  @useResult
  Option<T> toOption() => Option.from(this);
}

extension FutureNullableToOptionExtension<T extends Object> on Future<T?> {
  @useResult
  Future<Option<T>> toFutureOption() => then(Option.from);
}

extension StringToOptionExtension on String {
  @useResult
  Option<String> toNotEmptyOption() => isNotEmpty ? Some(this) : const None();
}

/// The [Option] type.
///
/// See https://doc.rust-lang.org/std/option/index.html for more.
@freezed
sealed class Option<T extends Object> with _$Option<T> {
  const Option._();

  /// Some value of type [T].
  @literal
  const factory Option.some(T value) = Some;

  /// No value.
  @literal
  const factory Option.none() = None;

  /// Converts a nullable [T] to an [Option] of [T].
  factory Option.from(T? value) => value != null ? Some(value) : None<T>();

  /// Converts an [Option] of [T] to a nullable [T].
  @useResult
  T? toNullable() => switch (this) {
        Some(:final value) => value,
        None() => null,
      };

  /// Returns `true` if the option is a [Some] value.
  @useResult
  bool get isSome => switch (this) {
        Some() => true,
        None() => false,
      };

  /// Returns `true` if the option is a [Some]
  /// and the value inside of it matches a predicate.
  @useResult
  bool isSomeAnd(bool Function(T value) fn) => switch (this) {
        Some(:final value) => fn(value),
        None() => false,
      };

  /// Returns `true` if the option is a [None] value.
  @useResult
  bool get isNone => switch (this) {
        Some() => false,
        None() => true,
      };

  /// Returns the contained [Some] value.
  ///
  /// Because this function can throw, its use is generally discouraged.
  /// Instead, prefer to use pattern matching
  /// and handle the [None] case explicitly,
  /// or call [unwrapOr] or [unwrapOrElse]
  ///
  /// Throws a [StateError] if the value is a [None]
  /// with a custom error message provided by [msg].
  @useResult
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
  @useResult
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
  @useResult
  T unwrapOr(T defaultValue) => switch (this) {
        Some(:final value) => value,
        None() => defaultValue,
      };

  /// Returns the contained [Some] value or computes it from a closure.
  @useResult
  T unwrapOrElse(T Function() fn) => switch (this) {
        Some(:final value) => value,
        None() => fn(),
      };

  /// Maps an [Option] of [T] to [Option] of [U] by applying
  /// a function to a contained value (if [Some]) or return [None] (if [None]).
  @useResult
  Option<U> map<U extends Object>(U Function(T value) fn) => switch (this) {
        Some(:final value) => Some(fn(value)),
        None() => None<U>(),
      };

  /// Calls the provided closure with a reference
  /// to the contained value (if [Some]).
  @useResult
  () inspect(() Function(T value) fn) {
    if (this case Some(:final value)) {
      fn(value);
    }
    return ();
  }

  /// Returns the provided default result (if [None]),
  /// or applies a function to the contained value (if [Some]).
  ///
  /// Arguments passed to [mapOr] are eagerly evaluated;
  /// if you are passing the result of a function call,
  /// it is recommended to use [mapOrElse],
  /// which is lazily evaluated.
  @useResult
  U mapOr<U extends Object>({
    required U or,
    required U Function(T value) map,
  }) =>
      switch (this) {
        Some(:final value) => map(value),
        None() => or,
      };

  /// Computes a default function result (if [None]),
  /// or applies a different function to the contained value (if any).
  @useResult
  U mapOrElse<U extends Object>({
    required U Function() orElse,
    required U Function(T value) map,
  }) =>
      switch (this) {
        Some(:final value) => map(value),
        None() => orElse(),
      };

  /// Transforms the [Option] of [T] into a [Result] of [T] and [E],
  /// mapping [Some] to [Ok] and [None] to [Err] with [err].
  ///
  /// Arguments passed to [okOr] are eagerly evaluated;
  /// if you are passing the result of a function call,
  /// it is recommended to use [okOrElse],
  /// which is lazily evaluated.
  @useResult
  Result<T, E> okOr<E extends Object>(E err) => switch (this) {
        Some(:final value) => Ok(value),
        None() => Err(err),
      };

  /// Transforms the [Option] of [T] into a [Result] of [T] and [E],
  /// mapping [Some] to [Ok] and [None] to [Err] with the result of [errFn].
  @useResult
  Result<T, E> okOrElse<E extends Object>(E Function() errFn) => switch (this) {
        Some(:final value) => Ok(value),
        None() => Err(errFn()),
      };

  /// Returns an [Iterable] over the possibly contained value.
  @useResult
  Iterable<T> toIterable() => switch (this) {
        Some(:final value) => [value],
        None() => <T>[],
      };

  /// Returns [None] if the option is [None], otherwise returns [other].
  ///
  /// Arguments passed to [and] are eagerly evaluated;
  /// if you are passing the result of a function call,
  /// it is recommended to use [andThen],
  /// which is lazily evaluated.
  @useResult
  Option<U> and<U extends Object>(Option<U> other) => switch (this) {
        Some() => other,
        None() => None<U>(),
      };

  /// Returns [None] if the option is [None],
  /// otherwise calls [fn] with the wrapped value and returns the result.
  ///
  /// Some languages call this operation flatmap.
  ///
  /// Often used to chain fallible operations that may return [None].
  @useResult
  Option<U> andThen<U extends Object>(Option<U> Function(T value) fn) =>
      switch (this) {
        Some(:final value) => fn(value),
        None() => None<U>(),
      };

  @useResult
  Future<Option<U>> andThenAsync<U extends Object>(
    Future<Option<U>> Function(T value) fn,
  ) =>
      switch (this) {
        Some(:final value) => fn(value),
        None() => Future.value(None<U>()),
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
  @useResult
  Option<T> where(bool Function(T value) predicate) {
    if (this case Some(:final value)) {
      if (predicate(value)) {
        return Some(value);
      }
    }
    return None<T>();
  }

  /// Returns the option if it contains a value,
  /// otherwise returns [other].
  ///
  /// Arguments passed to [or] are eagerly evaluated;
  /// if you are passing the result of a function call,
  /// it is recommended to use [orElse],
  /// which is lazily evaluated.
  @useResult
  Option<T> or(Option<T> other) => switch (this) {
        Some(:final value) => Some(value),
        None() => other,
      };

  /// Returns the option if it contains a value, otherwise calls [fn] and returns the result.
  @useResult
  Option<T> orElse(Option<T> Function() fn) => switch (this) {
        Some(:final value) => Some(value),
        None() => fn(),
      };

  /// Returns [Some] if exactly one of this or [other] is [Some],
  /// otherwise returns [None].
  @useResult
  Option<T> xor(Option<T> other) => switch ((this, other)) {
        (Some(:final value), None()) => Some(value),
        (None(), Some(:final value)) => Some(value),
        _ => None<T>(),
      };

  /// Zips this with another [Option].
  ///
  /// If this is [Some] and [other] is [Some],
  /// the method returns [Some].
  /// Otherwise, [None] is returned.
  @useResult
  Option<(T, U)> zip<U extends Object>(Option<U> other) {
    return switch ((this, other)) {
      (Some(value: final a), Some(value: final b)) => Some((a, b)),
      _ =>
        // False-positive; this actually can't be const.
        // ignore: prefer_const_constructors
        None<(T, U)>(),
    };
  }

  /// Zips this with another [Option] using [fn].
  ///
  /// If this is [Some] and [other] is [Some],
  /// the method returns [Some].
  /// Otherwise, [None] is returned.
  @useResult
  Option<R> zipWith<U extends Object, R extends Object>(
    Option<U> other,
    R Function(T a, U b) fn,
  ) =>
      switch ((this, other)) {
        (Some(value: final a), Some(value: final b)) => Some(fn(a, b)),
        _ => None<R>(),
      };
}

extension ZippedOptionExtension<T extends Object, U extends Object>
    on Option<(T, U)> {
  /// Unzips an option containing a tuple of two options.
  ///
  /// If this is [Some] this method returns ([Some], [Some]).
  /// Otherwise, ([None], [None]) is returned.
  @useResult
  (Option<T>, Option<U>) unzip() => switch (this) {
        Some(value: (final a, final b)) => (Some(a), Some(b)),
        None() => (None<T>(), None<U>()),
      };
}

extension OptionResultExtension<T extends Object, E extends Object>
    on Option<Result<T, E>> {
  /// Transposes an [Option] of a [Result] into a [Result] of an [Option].
  ///
  /// [None] will be mapped to [Ok] with [None].
  /// [Some] with [Ok] and [Some] with [Err] will
  /// be mapped to [Ok] with [Some] and [Err].
  @useResult
  Result<Option<T>, E> transpose() => switch (this) {
        Some(value: Ok(:final value)) => Ok(Some(value)),
        Some(value: Err(:final error)) => Err(error),
        None() => Ok(None<T>()),
      };
}

extension NestedOptionExtension<T extends Object> on Option<Option<T>> {
  /// Converts an [Option] of [Option] of [T] to [Option] of [T].
  ///
  /// Flattening only removes one level of nesting at a time.
  @useResult
  Option<T> flatten() => switch (this) {
        Some(:final value) => value,
        None() => None<T>(),
      };
}

extension IterableOptionExtension<T extends Object> on Iterable<Option<T>> {
  @useResult
  Iterable<T> whereSome() => whereType<Some<T>>().map((e) => e.value);
}

extension StreamOptionExtension<T extends Object> on Stream<Option<T>> {
  @useResult
  Stream<T> whereSome() => whereType<Some<T>>().map((e) => e.value);
}

extension OptionFutureExtension<T extends Object> on Option<Future<T>> {
  @useResult
  Future<Option<T>> transpose() => switch (this) {
        Some(:final value) => value.then(Some.new),
        None() => Future.value(None<T>()),
      };
}
