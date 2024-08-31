import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:photo_manager_client/src/data_structures/fp/functor.dart';
import 'package:photo_manager_client/src/data_structures/fp/monad.dart';
import 'package:photo_manager_client/src/data_structures/fp/semigroup.dart';
import 'package:photo_manager_client/src/data_structures/validation.dart';
import 'package:photo_manager_client/src/extensions/flatmap_extension.dart';
import 'package:photo_manager_client/src/mixins/delegating_iterable.dart';

part 'iterable_fp.freezed.dart';

typedef ValidationWithIterableErr<T, E>
    = Validation<T, _IterableFPBrand, E, IterableFP<E>>;

ValidationWithIterableErr<T, E> succeed<T, E>(T val) => Validation.success(val);
ValidationWithIterableErr<T, E> fail<T, E>(Iterable<E> err) =>
    Validation.failure(IterableFP(err));

/// `I` stands for inference, inferring [E].
ValidationWithIterableErr<T, E> succeedI<T, E>(T val, E errEx) =>
    Validation.success(val);

/// `I` stands for inference, inferring [T].
ValidationWithIterableErr<T, E> failI<T, E>(Iterable<E> err, T valEx) =>
    Validation.failure(IterableFP(err));

abstract final class _IterableFPBrand {}

@freezed
sealed class IterableFP<T>
    with _$IterableFP<T>, DelegatingIterable<T>
    implements
        Iterable<T>,
        Semigroup<_IterableFPBrand, T, IterableFP<T>>,
        Functor<_IterableFPBrand, T>,
        Monad<_IterableFPBrand, T> {
  const IterableFP._();

  const factory IterableFP(Iterable<T> value) = _IterableFP;

  @override
  Iterable<T> get delegate => value;

  @override
  IterableFP<T> combine(IterableFP<T> other) =>
      IterableFP(value.followedBy(other));

  @override
  IterableFP<TNewVal> bind<TNewVal>(IterableFP<TNewVal> Function(T val) fn) =>
      IterableFP(value.flatMap(fn));

  @override
  IterableFP<TNewVal> fmap<TNewVal>(TNewVal Function(T val) fn) =>
      IterableFP(value.map(fn));
}
