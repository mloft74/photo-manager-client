import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:photo_manager_client/src/data_structures/fp/functor.dart';
import 'package:photo_manager_client/src/data_structures/fp/monad.dart';
import 'package:photo_manager_client/src/data_structures/fp/semigroup.dart';
import 'package:photo_manager_client/src/extensions/flatmap_extension.dart';
import 'package:photo_manager_client/src/mixins/delegating_iterable.dart';

part 'iterable_fp.freezed.dart';

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
