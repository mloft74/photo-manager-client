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

// Create some annotation for code-genning a mixin like this:
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

// Example of a way to use MonadDefaults
/*
class _X {}

class _Y<TVal> with MonadDefaults<_X, TVal> implements Monad<_X, TVal> {
  TVal tval;
  _Y(this.tval);

  @override
  _Y<T> Function<T>(T val) get $return => _Y.new;

  @override
  Monad<_X, TNewVal> bind<TNewVal>(_Y<TNewVal> Function(TVal val) fn) =>
      fn(tval);
}

void x() {
  _Y<T> foo<T>(T v) => _Y(v);
  final MonadReturn<_X> bar = foo;
  final MonadReturn<_X> x = _Y.new;
}
*/
