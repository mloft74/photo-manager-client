// ignore: one_member_abstracts
abstract interface class Monad<TBrand, TVal> {
  Monad<TBrand, TNewVal> bind<TNewVal>(
    covariant Monad<TBrand, TNewVal> Function(TVal val) fn,
  );
}
