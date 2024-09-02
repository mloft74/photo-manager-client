import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:photo_manager_client/src/data_structures/fp/applicative.dart';
import 'package:photo_manager_client/src/data_structures/fp/monad.dart';
import 'package:photo_manager_client/src/data_structures/fp/semigroup.dart';
import 'package:photo_manager_client/src/data_structures/validation.dart';
import 'package:photo_manager_client/src/extensions/flatmap_extension.dart';
import 'package:photo_manager_client/src/mixins/delegating_iterable.dart';

part 'iterable_fp.freezed.dart';

typedef ValidationWithIterableErr<T, E>
    = Validation<T, _IterableFPBrand, E, IterableFP<E>>;

final class ValidationWithIterableErrPure<E>
    implements ValidationPure<_IterableFPBrand, E, IterableFP<E>> {
  const ValidationWithIterableErrPure._();

  @override
  ValidationWithIterableErr<TVal, E> call<TVal>(TVal val) {
    return Validation.success(val);
  }
}

({
  ValidationWithIterableErrPure<E> pure,
  ValidationWithIterableErr<T, E> Function<T>(Iterable<E>) fail,
}) makeValidationCtors<E>() {
  final pure = ValidationWithIterableErrPure<E>._();
  return (pure: pure, fail: _makeFail());
}

ValidationWithIterableErr<T, E> _fail<T, E>(Iterable<E> err) =>
    Validation.failure(IterableFP(err));
ValidationWithIterableErr<T, E> Function<T>(Iterable<E>) _makeFail<E>() {
  ValidationWithIterableErr<T, E> inner<T>(Iterable<E> err) => _fail(err);
  return inner;
}

abstract final class _IterableFPBrand {}

final class IterableFpPure implements ApplicativePure<_IterableFPBrand> {
  const IterableFpPure._();

  @override
  IterableFP<TVal> call<TVal>(TVal value) {
    return IterableFP([value]);
  }
}

@freezed
sealed class IterableFP<T>
    with _$IterableFP<T>, DelegatingIterable<T>
    implements
        Iterable<T>,
        Semigroup<_IterableFPBrand, T, IterableFP<T>>,
        Monad<_IterableFPBrand, T> {
  const IterableFP._();

  const factory IterableFP(Iterable<T> value) = _IterableFP;

  static const pure = IterableFpPure._();

  @override
  Iterable<T> get delegate => value;

  @override
  IterableFP<T> combine(IterableFP<T> other) =>
      IterableFP(other.followedBy(value));

  @override
  IterableFP<TNewVal> bind<TNewVal>(IterableFP<TNewVal> Function(T val) fn) =>
      IterableFP(value.flatMap(fn));

  @override
  IterableFP<TNewVal> fmap<TNewVal>(TNewVal Function(T val) fn) =>
      IterableFP(value.map(fn));

  @override
  IterableFP<TNewVal> applyR<TNewVal>(
    IterableFP<TNewVal Function(T val)> app,
  ) {
    return IterableFP(app.flatMap(fmap));
  }
}

extension IterableFPApply<TVal, TNewVal>
    on IterableFP<TNewVal Function(TVal val)> {
  IterableFP<TNewVal> apply(IterableFP<TVal> val) => val.applyR(this);
}
