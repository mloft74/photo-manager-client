// ignore_for_file: unreachable_from_main

import 'package:photo_manager_client/src/data_structures/fp/semigroup.dart';
import 'package:spec/spec.dart';

void main() {
  // Don't write tests here, just use the functions below in other files.
}

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
