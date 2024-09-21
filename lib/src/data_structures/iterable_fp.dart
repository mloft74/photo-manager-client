import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:photo_manager_client/src/data_structures/fp/type_classes/monad.dart';
import 'package:photo_manager_client/src/data_structures/fp/type_classes/monoid.dart';
import 'package:photo_manager_client/src/data_structures/validation.dart';
import 'package:photo_manager_client/src/extensions/flatmap_extension.dart';
import 'package:photo_manager_client/src/mixins/delegating_iterable.dart';

part 'iterable_fp.freezed.dart';

typedef ValidationWithIterableErr<T, E>
    = Validation<T, _IterableFPBrand, E, IterableFP<E>>;

typedef ValidationWithIterableErrPure<E>
    = ValidationPure<_IterableFPBrand, E, IterableFP<E>>;
typedef ValidationWithIterableErrFail<E> = ValidationWithIterableErr<T, E>
    Function<T>(Iterable<E>);

/// This makes constructors for Validation using and iterable error with inner type [E].
({
  ValidationWithIterableErrPure<E> pure,
  ValidationWithIterableErrFail<E> fail,
}) makeValidationCtors<E>() => (pure: _makePure(), fail: _makeFail());

ValidationWithIterableErrPure<E> _makePure<E>() =>
    <T>(val) => Validation.success(val);

ValidationWithIterableErrFail<E> _makeFail<E>() =>
    <T>(err) => Validation.failure(IterableFP(err));

abstract final class _IterableFPBrand {}

typedef IterableFPPure = IterableFP<TVal> Function<TVal>(TVal val);

@freezed
sealed class IterableFP<TVal>
    with _$IterableFP<TVal>, DelegatingIterable<TVal>
    implements
        Iterable<TVal>,
        Monoid<_IterableFPBrand, TVal, IterableFP<TVal>>,
        Monad<_IterableFPBrand, TVal> {
  const IterableFP._();

  const factory IterableFP(Iterable<TVal> value) = _IterableFP;

  factory IterableFP.pure(TVal val) => IterableFP([val]);
  factory IterableFP.$return(TVal val) => IterableFP([val]);
  factory IterableFP.mempty() => const IterableFP([]);
  factory IterableFP.mconcat(
    List<IterableFP<TVal>> list,
    IterableFP<TVal> mempty,
  ) =>
      list.mconcatExt(mempty);

  @override
  Iterable<TVal> get delegate => value;

  @override
  IterableFP<TVal> combine(IterableFP<TVal> other) =>
      IterableFP(other.followedBy(value));

  @override
  IterableFP<TNewVal> bind<TNewVal>(
    IterableFP<TNewVal> Function(TVal val) fn,
  ) =>
      IterableFP(value.flatMap(fn));

  @override
  IterableFP<TNewVal> fmap<TNewVal>(TNewVal Function(TVal val) fn) =>
      IterableFP(value.map(fn));

  @override
  IterableFP<TNewVal> applyR<TNewVal>(
    IterableFP<TNewVal Function(TVal val)> app,
  ) {
    return IterableFP(app.flatMap(fmap));
  }
}

extension IterableFPApply<TVal, TNewVal>
    on IterableFP<TNewVal Function(TVal val)> {
  IterableFP<TNewVal> apply(IterableFP<TVal> val) => val.applyR(this);
}
