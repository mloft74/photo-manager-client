// ignore_for_file: one_member_abstracts

import 'dart:async';

import 'package:macros/macros.dart';
import 'package:photo_manager_client/src/data_structures/fp/functor.dart';

abstract interface class ApplicativePure<TBrand> {
  Applicative<TBrand, TVal> call<TVal>(TVal val);
}
typedef ApplicativePureFn<TBrand> = Applicative<TBrand, TVal> Function<TVal>(TVal val);

abstract interface class Applicative<TBrand, TVal> implements Functor<TBrand, TVal> {
  /// This is <*> with the arguments reversed. That way, [ApplicativeExtension.applyF] has the arguments the right way around.
  /// Example: [applyR] corresponds to `app <*> this`, but is written in dart like `this.rapply(app)`.
  Applicative<TBrand, TNewVal> applyR<TNewVal>(
    covariant Applicative<TBrand, TNewVal Function(TVal val)> app,
  );
}

// Create some annotation for code-genning an extension like this:
extension ApplicativeExtension<TBrand, TVal, TNewVal>
    on Applicative<TBrand, TNewVal Function(TVal val)> {
  Applicative<TBrand, TNewVal> applyF(Applicative<TBrand, TVal> val) =>
      val.applyR(this);
}

macro class ApplicativeMacro implements ClassTypesMacro {
  @override
  FutureOr<void> buildTypesForClass(ClassDeclaration clazz, ClassTypeBuilder builder) {
    final name = clazz.identifier.name;
    builder.declareType('${name}Apply', DeclarationCode.fromString('idk lul'));
  }
}
