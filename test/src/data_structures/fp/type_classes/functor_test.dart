// ignore_for_file: unreachable_from_main

import 'package:photo_manager_client/src/data_structures/fp/fp.dart';
import 'package:photo_manager_client/src/data_structures/fp/type_classes/functor.dart';
import 'package:spec/spec.dart';

void main() {
  // Don't write tests here, just use the functions below in other files.
}

() identityLaw<TBrand, TVal>(Functor<TBrand, TVal> f) {
  final actual = f.fmap(id);

  expect(actual).toEqual(f);

  return ();
}

() compositionLaw<TBrand, A, B, C>(
  Functor<TBrand, A> fa,
  C Function(B) f,
  B Function(A) g,
) {
  final actual = fa.fmap(comp(f, g));
  final expected = fa.fmap(g).fmap(f);

  expect(actual).toEqual(expected);

  return ();
}
