import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:photo_manager_client/src/data_structures/fp/functor.dart';
import 'package:photo_manager_client/src/data_structures/fp/monad.dart';
import 'package:photo_manager_client/src/data_structures/fp/semigroup.dart';
import 'package:photo_manager_client/src/extensions/flatmap_extension.dart';

part 'i_list_fp.freezed.dart';

abstract final class _IListFPBrand {}

// todo: make lazy
@freezed
final class IListFP<T>
    with _$IListFP<T>, Iterable<T>
    implements
        Semigroup<_IListFPBrand, T, IListFP<T>>,
        Functor<_IListFPBrand, T>,
        Monad<_IListFPBrand, T> {
  const IListFP._();

  const factory IListFP(IList<T> list) = _IListFP;

  @override
  IListFP<T> combine(IListFP<T> other) => IListFP(list.addAll(other.list));

  @override
  IListFP<TNewVal> bind<TNewVal>(IListFP<TNewVal> Function(T val) fn) =>
      IListFP(list.flatMap(fn).toIList());

  @override
  IListFP<TNewVal> fmap<TNewVal>(TNewVal Function(T val) fn) =>
      IListFP(list.map(fn).toIList());

  @override
  Iterator<T> get iterator => list.iterator;
}
