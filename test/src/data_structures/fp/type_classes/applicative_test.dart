// ignore_for_file: avoid_types_on_closure_parameters, unreachable_from_main

import 'package:photo_manager_client/src/data_structures/fp/fp.dart';
import 'package:photo_manager_client/src/data_structures/fp/type_classes/applicative.dart';
import 'package:photo_manager_client/src/extensions/function_extension.dart';
import 'package:spec/spec.dart';

void main() {
  // Don't write tests here, just use the functions below in other files.
}

() identityLaw<TBrand, TVal>(ApplicativePure<TBrand> pure, TVal value) {
  final fv = pure(value);
  final fid = pure(id<TVal>);

  final actual = fid.applyF(fv);
  final expected = pure(value);

  expect(actual).toEqual(expected);

  return ();
}

() compositionLaw<TBrand, A, B, C>(
  ApplicativePure<TBrand> pure,
  Applicative<TBrand, C Function(B)> u,
  Applicative<TBrand, B Function(A)> v,
  Applicative<TBrand, A> w,
) {
  final fc = pure(comp<A, B, C>.curry());

  final actual = fc.applyF(u).applyF(v).applyF(w);
  final expected = u.applyF(v.applyF(w));

  expect(actual).toEqual(expected);

  return ();
}

() homomorphismLaw<TBrand, A, B>(
  ApplicativePure<TBrand> pure,
  B Function(A) f,
  A x,
) {
  final ff = pure(f);
  final fx = pure(x);

  final actual = ff.applyF(fx);
  final expected = pure(f(x));

  expect(actual).toEqual(expected);

  return ();
}

() interchangeLaw<TBrand, A, B>(
  ApplicativePure<TBrand> pure,
  Applicative<TBrand, B Function(A)> u,
  A y,
) {
  final fy = pure(y);
  final f$y = pure((B Function(A) a) => a(y));

  final actual = u.applyF(fy);
  final expected = f$y.applyF(u);

  expect(actual).toEqual(expected);

  return ();
}

() runIdentityLawTestsWithPure<TBrand>(ApplicativePure<TBrand> pure) {
  test('Identity', () {
    identityLaw(pure, 12);
    identityLaw(pure, true);
    identityLaw(pure, 0.58736278393736);
    identityLaw(pure, 'Nice looking string here!');
  });

  return ();
}

() runHomomorphismLawTestsWithPure<TBrand>(ApplicativePure<TBrand> pure) {
  test('Homomorphism', () {
    homomorphismLaw(
      pure,
      (String a) => a.length,
      'Hello there!',
    );
    homomorphismLaw(pure, (int a) => a.isEven, 12);
  });

  return ();
}
