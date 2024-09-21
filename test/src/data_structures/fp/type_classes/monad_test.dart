// ignore_for_file: unreachable_from_main

import 'package:photo_manager_client/src/data_structures/fp/type_classes/applicative.dart';
import 'package:photo_manager_client/src/data_structures/fp/type_classes/monad.dart';
import 'package:spec/spec.dart';

void main() {
  // Don't write tests here, just use the functions below in other files.
}

typedef FixedBind<TBrand> = Monad<TBrand, X2> Function<X1, X2>(
  Monad<TBrand, X1> x1,
  Monad<TBrand, X2> Function(X1 x1) x2,
);

() leftIdentityLaw<TBrand, A, B>(
  MonadReturn<TBrand> $return,
  Monad<TBrand, B> Function(A) k,
  A a,
) {
  final ma = $return(a);

  final actual = ma.bind(k);
  final expected = k(a);

  expect(actual).toEqual(expected);

  return ();
}

() rightIdentityLaw<TBrand, TVal>(
  MonadReturn<TBrand> $return,
  Monad<TBrand, TVal> m,
) {
  final actual = m.bind($return);

  expect(actual).toEqual(m);

  return ();
}

() associativityLaw<TBrand, A, B, C>(
  Monad<TBrand, A> m,
  Monad<TBrand, B> Function(A) k,
  Monad<TBrand, C> Function(B) h, {
  required FixedBind<TBrand> bind,
}) {
  final actual = bind(m, (x) => bind(k(x), h));
  final expected = bind(bind(m, k), h);

  expect(actual).toEqual(expected);

  return ();
}

() pureIsReturn<TBrand, TVal>(
  ApplicativePure<TBrand> pure,
  MonadReturn<TBrand> $return,
  TVal val,
) {
  final actual = pure(val);
  final expected = $return(val);

  expect(actual).toEqual(expected);

  return ();
}

() applyRelatesToBind<TBrand, X1, X2>(
  MonadReturn<TBrand> $return,
  Monad<TBrand, X1 Function(X2)> m1,
  Monad<TBrand, X2> m2, {
  required FixedBind<TBrand> bind,
}) {
  final actual = m1.applyF(m2);
  final expected = bind(m1, (x1) => bind(m2, (x2) => $return(x1(x2))));

  expect(actual).toEqual(expected);

  return ();
}
