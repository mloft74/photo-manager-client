// ignore_for_file: unreachable_from_main

import 'package:photo_manager_client/src/data_structures/fp/type_classes/monad.dart';
import 'package:spec/spec.dart';

void main() {
  // Don't write tests here, just use the functions below in other files.
}

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
  Monad<TBrand, TVal> m,
  MonadReturn<TBrand> $return,
) {
  final actual = m.bind($return);

  expect(actual).toEqual(m);

  return ();
}

() associativityLaw<TBrand, A, B, C>(
  Monad<TBrand, A> m,
  Monad<TBrand, B> Function(A) k,
  Monad<TBrand, C> Function(B) h,
) {
  final actual = m.bind((x) => k(x).bind(h));
  final expected = m.bind(k).bind(h);

  expect(actual).toEqual(expected);

  return ();
}
