import 'package:photo_manager_client/src/extensions/function_extension.dart';

typedef Identity<T> = T Function(T);
T id<T>(T t) => t;

C Function(A) Function(B Function(A)) comp<A, B, C>(C Function(B) f) =>
    (g) => (a) => f(g(a));

C Function(A) compUncurried<A, B, C>(C Function(B) f, B Function(A) g) =>
    (a) => f(g(a));

B foldrCurried<A, B>(B Function(B b) Function(A a) fn, B b, List<A> a) {
  return foldr(fn.uncurry(), b, a);
}

B foldr<A, B>(B Function(A a, B b) fn, B b, List<A> a) {
  return a.reversed.fold(b, fn.swap());
}
