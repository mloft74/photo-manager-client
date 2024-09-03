// ignore_for_file: unreachable_from_main

import 'package:photo_manager_client/src/data_structures/fp/type_classes/semigroup.dart';
import 'package:spec/spec.dart';

void main() {
  // Don't write tests here, just use the functions below in other files.
}

/// If this complains about type inference, try using [AssociativityExt.associativityLawExt].
() associativityLaw<TBrand, TVal, TImpl extends Semigroup<TBrand, TVal, TImpl>>(
  TImpl a,
  TImpl b,
  TImpl c,
) {
  final actual = a.combine(b).combine(c);
  final expected = a.combine(b.combine(c));

  expect(actual).toEqual(expected);

  return ();
}

extension AssociativityExt<TBrand, TVal,
    TImpl extends Semigroup<TBrand, TVal, TImpl>> on TImpl {
  /// Extension version of [associativityLaw] to fix type inference.
  () associativityLawExt(TImpl b, TImpl c) =>
      associativityLaw<TBrand, TVal, TImpl>(this, b, c);
}
