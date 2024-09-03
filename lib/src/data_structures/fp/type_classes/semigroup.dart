// ignore: one_member_abstracts
abstract interface class Semigroup<TBrand, TVal,
    TImpl extends Semigroup<TBrand, TVal, TImpl>> {
  TImpl combine(TImpl other);
}
