// ignore_for_file: one_member_abstracts

abstract interface class ApplicativePure<TBrand> {
  Applicative<TBrand, TVal> call<TVal>(TVal val);
}

abstract interface class Applicative<TBrand, TVal> {
  /// This is <*> with the arguments reversed. That way, [ApplicativeExtension.apply] has the arguments the right way around.
  /// Example: [rapply] corresponds to `app <*> this`, but is written in dart like `this.rapply(app)`.
  Applicative<TBrand, TNewVal> rapply<TNewVal>(
    covariant Applicative<TBrand, TNewVal Function(TVal val)> app,
  );
}

extension ApplicativeExtension<TBrand, TVal, TNewVal>
    on Applicative<TBrand, TNewVal Function(TVal val)> {
  Applicative<TBrand, TNewVal> apply(Applicative<TBrand, TVal> val) =>
      val.rapply(this);
}
