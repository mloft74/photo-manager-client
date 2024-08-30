// ignore: one_member_abstracts
abstract interface class Functor<TBrand, TVal> {
  Functor<TBrand, TNewVal> fmap<TNewVal>(TNewVal Function(TVal val) fn);
}
