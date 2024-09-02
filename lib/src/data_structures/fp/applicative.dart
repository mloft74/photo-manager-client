// ignore_for_file: one_member_abstracts

import 'package:photo_manager_client/src/data_structures/fp/functor.dart';

abstract interface class ApplicativePure<TBrand> {
  Applicative<TBrand, TVal> call<TVal>(TVal val);
}

typedef ApplicativePureFn<TBrand> = Applicative<TBrand, TVal> Function<TVal>(
  TVal val,
);

abstract interface class Applicative<TBrand, TVal>
    implements Functor<TBrand, TVal> {
  /// This is <*> with the arguments reversed. That way, [ApplicativeExtension.applyF] has the arguments the right way around.
  /// Example: [applyR] corresponds to `app <*> this`, but is written in dart like `this.rapply(app)`.
  Applicative<TBrand, TNewVal> applyR<TNewVal>(
    covariant Applicative<TBrand, TNewVal Function(TVal val)> app,
  );
}

// Eventually, a macro/code-gen tool would generate this for every Applicative.
// However, macros seem fairly broken at the moment, so this is here for reference.
extension ApplicativeExtension<TBrand, TVal, TNewVal>
    on Applicative<TBrand, TNewVal Function(TVal val)> {
  Applicative<TBrand, TNewVal> applyF(Applicative<TBrand, TVal> val) =>
      val.applyR(this);
}
