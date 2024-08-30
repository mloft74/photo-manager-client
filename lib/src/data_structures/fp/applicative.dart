// ignore: one_member_abstracts
abstract interface class Applicative<Brand, TVal> {
  Applicative<Brand, TNewVal> apply<TNewVal>(
    covariant Applicative<Brand, TNewVal Function(TVal val)> app,
  );
}
