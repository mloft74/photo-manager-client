import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:photo_manager_client/src/data_structures/result.dart';

part 'option.freezed.dart';

// TODO(makayden): Document option with Rust api docs.

@Freezed(map: FreezedMapOptions.none)
sealed class Option<T extends Object> with _$Option<T> {
  const Option._();

  const factory Option.some(T value) = Some;

  const factory Option.none() = None;

  factory Option.from(T? value) =>
      value != null ? Option.some(value) : const Option.none();

  bool get isSome => switch (this) {
        Some() => true,
        None() => false,
      };

  bool get isNone => !isSome;

  bool isSomeAnd(bool Function(T value) f) => switch (this) {
        Some(:final value) => f(value),
        None() => false,
      };

  T expect(String msg) => switch (this) {
        Some(:final value) => value,
        None() => throw StateError(msg),
      };

  T unwrap() => switch (this) {
        Some(:final value) => value,
        None() =>
          throw StateError('called `Option.unwrap()` on a `None` value'),
      };

  T unwrapOr(T defaultValue) => switch (this) {
        Some(:final value) => value,
        None() => defaultValue,
      };

  T unwrapOrElse(T Function() f) => switch (this) {
        Some(:final value) => value,
        None() => f(),
      };

  Option<U> map<U extends Object>(U Function(T value) f) => switch (this) {
        Some(:final value) => Option.some(f(value)),
        None() => const None(),
      };

  void inspect(void Function(T value) f) {
    if (this case Some(:final value)) {
      f(value);
    }
  }

  U mapOr<U extends Object>(U defaultValue, U Function(T value) f) =>
      switch (this) {
        Some(:final value) => f(value),
        None() => defaultValue,
      };

  U mapOrElse<U extends Object>(U Function() defaultF, U Function(T value) f) =>
      switch (this) {
        Some(:final value) => f(value),
        None() => defaultF(),
      };

  Result<T, E> okOr<E extends Object>(E err) => switch (this) {
        Some(:final value) => Ok(value),
        None() => Err(err),
      };

  Result<T, E> okOrElse<E extends Object>(E Function() errF) => switch (this) {
        Some(:final value) => Ok(value),
        None() => Err(errF()),
      };

  Iterable<T> get iterable => switch (this) {
        Some(:final value) => [value],
        None() => [],
      };

  Option<U> and<U extends Object>(Option<U> optb) => switch (this) {
        Some() => optb,
        None() => const None(),
      };

  Option<U> andThen<U extends Object>(Option<U> Function(T value) f) =>
      switch (this) {
        Some(:final value) => f(value),
        None() => const None(),
      };

  Option<T> filter(bool Function(T value) predicate) {
    if (this case Some(:final value)) {
      if (predicate(value)) {
        return Some(value);
      }
    }
    return const None();
  }

  Option<T> or(Option<T> optb) => switch (this) {
        Some(:final value) => Some(value),
        None() => optb,
      };

  Option<T> orElse(Option<T> Function() f) => switch (this) {
        Some(:final value) => Some(value),
        None() => f(),
      };

  Option<T> xor(Option<T> optb) => switch ((this, optb)) {
        (Some(:final value), None()) => Option.some(value),
        (None(), Some(:final value)) => Option.some(value),
        _ => const None(),
      };

  Option<(T, U)> zip<U extends Object>(Option<U> other) =>
      switch ((this, other)) {
        (Some(value: final a), Some(value: final b)) => Option.some((a, b)),
        _ => const None(),
      };

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
  (Option<T>, Option<U>) get unzipped => switch (this) {
        Some(value: (final a, final b)) => (Option.some(a), Option.some(b)),
        None() => (const None(), const None()),
      };
}

extension OptionResultExtension<T extends Object, E extends Object>
    on Option<Result<T, E>> {
  Result<Option<T>, E> get transposed => switch (this) {
        Some(value: Ok(:final value)) => Ok(Some(value)),
        Some(value: Err(:final error)) => Err(error),
        None() => const Ok(None()),
      };
}

extension NestedOption<T extends Object> on Option<Option<T>> {
  Option<T> get flattened => switch (this) {
        Some(:final value) => value,
        None() => const None(),
      };
}
