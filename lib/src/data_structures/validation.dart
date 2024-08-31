import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:photo_manager_client/src/data_structures/fp/applicative.dart';
import 'package:photo_manager_client/src/data_structures/fp/functor.dart';
import 'package:photo_manager_client/src/data_structures/fp/semigroup.dart';

part 'validation.freezed.dart';

abstract final class _ValidationBrand {}

abstract interface class ValidationPure<TErrSB, TErrSV,
        TErr extends Semigroup<TErrSB, TErrSV, TErr>>
    implements ApplicativePure<_ValidationBrand> {}

@freezed
sealed class Validation<TVal, TErrSB, TErrSV,
        TErr extends Semigroup<TErrSB, TErrSV, TErr>>
    with _$Validation<TVal, TErrSB, TErrSV, TErr>
    implements
        Functor<_ValidationBrand, TVal>,
        Applicative<_ValidationBrand, TVal> {
  const Validation._();

  const factory Validation.success(TVal val) = Success;

  const factory Validation.failure(TErr err) = Failure;

  @override
  Validation<TNewVal, TErrSB, TErrSV, TErr> fmap<TNewVal>(
    TNewVal Function(TVal val) fn,
  ) =>
      switch (this) {
        Success(:final val) => Success(fn(val)),
        Failure(:final err) => Failure(err),
      };

  @override
  Validation<TNewVal, TErrSB, TErrSV, TErr> rapply<TNewVal>(
    Validation<TNewVal Function(TVal val), TErrSB, TErrSV, TErr> app,
  ) {
    return switch ((this, app)) {
      (Success(val: final thisVal), Success(val: final appVal)) =>
        Success(appVal(thisVal)),
      (Failure(err: final thisErr), Failure(err: final appErr)) =>
        Failure(thisErr.combine(appErr)),
      (Failure(:final err), _) || (_, Failure(:final err)) => Failure(err),
    };
  }
}