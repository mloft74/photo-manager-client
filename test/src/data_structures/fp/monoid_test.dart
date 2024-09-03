// ignore_for_file: unreachable_from_main

import 'package:photo_manager_client/src/data_structures/fp/fp.dart';
import 'package:photo_manager_client/src/data_structures/fp/monoid.dart';
import 'package:spec/spec.dart';

export './semigroup_test.dart' hide main;

void main() {
  // Don't write tests here, just use the functions below in other files.
}

() rightIdentityLaw<TBrand, TVal, TImpl extends Monoid<TBrand, TVal, TImpl>>(
  TImpl x,
  TImpl mempty,
) {
  final actual = x.combine(mempty);
  expect(actual).toEqual(x);

  return ();
}

() leftIdentityLaw<TBrand, TVal, TImpl extends Monoid<TBrand, TVal, TImpl>>(
  TImpl mempty,
  TImpl x,
) {
  final actual = mempty.combine(x);
  expect(actual).toEqual(x);

  return ();
}

() concatenationLaw<TBrand, TVal, TImpl extends Monoid<TBrand, TVal, TImpl>>(
  List<TImpl> list,
  TImpl mempty,
  Mconcat<TBrand, TVal, TImpl> mconcat,
) {
  final actual = mconcat(list, mempty);
  final expected = foldr((a, b) => a.combine(b), mempty, list);

  expect(actual).toEqual(expected);

  return ();
}

extension IdentityExt<TBrand, TVal, TImpl extends Monoid<TBrand, TVal, TImpl>>
    on TImpl {
  /// Extension version of [rightIdentityLaw] to fix type inference.
  () rightIdentityLawExt(TImpl mempty) =>
      rightIdentityLaw<TBrand, TVal, TImpl>(this, mempty);

  /// Extension version of [leftIdentityLaw] to fix type inference.
  () leftIdentityLawExt(TImpl mempty) =>
      leftIdentityLaw<TBrand, TVal, TImpl>(mempty, this);
}

extension ConcatenationExt<TBrand, TVal,
    TImpl extends Monoid<TBrand, TVal, TImpl>> on List<TImpl> {
  /// Extension version of [concatenationLaw] to fix type inference.
  () concatenationLawExt(
    TImpl mempty,
    Mconcat<TBrand, TVal, TImpl> mconcat,
  ) =>
      concatenationLaw<TBrand, TVal, TImpl>(this, mempty, mconcat);
}
