// ignore_for_file: one_member_abstracts

abstract interface class ApplicativePure<TBrand> {
  Applicative<TBrand, TVal> call<TVal>(TVal val);
}

abstract interface class Applicative<TBrand, TVal> {
  /// This is <*> with the arguments reversed. That way, [ApplicativeExtension.applyF] has the arguments the right way around.
  /// Example: [applyR] corresponds to `app <*> this`, but is written in dart like `this.rapply(app)`.
  Applicative<TBrand, TNewVal> applyR<TNewVal>(
    covariant Applicative<TBrand, TNewVal Function(TVal val)> app,
  );
}

extension ApplicativeExtension<TBrand, TVal, TNewVal>
    on Applicative<TBrand, TNewVal Function(TVal val)> {
  Applicative<TBrand, TNewVal> applyF(Applicative<TBrand, TVal> val) =>
      val.applyR(this);
}
