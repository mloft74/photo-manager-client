// ignore: one_member_abstracts
import 'package:photo_manager_client/src/data_structures/fp/applicative.dart';
import 'package:photo_manager_client/src/data_structures/fp/functor.dart';

typedef MonadReturn<TBrand> = Monad<TBrand, TVal> Function<TVal>(TVal val);

abstract interface class Monad<TBrand, TVal>
    implements Applicative<TBrand, TVal> {
  Monad<TBrand, TNewVal> bind<TNewVal>(
    covariant Monad<TBrand, TNewVal> Function(TVal val) fn,
  );
}

// Eventually, a macro/code-gen tool would generate this for every Monad.
// However, macros seem fairly broken at the moment, so this is here for reference.
mixin MonadDefaults<TBrand, TVal> on Monad<TBrand, TVal> {
  Monad<TBrand, T> Function<T>(T val) get $return;

  @override
  Functor<TBrand, TNewVal> fmap<TNewVal>(TNewVal Function(TVal val) fn) =>
      bind((val) => $return(fn(val)));

  @override
  Applicative<TBrand, TNewVal> applyR<TNewVal>(
    Monad<TBrand, TNewVal Function(TVal val)> other,
  ) =>
      bind((val) => other.bind((fn) => $return(fn(val))));
}
