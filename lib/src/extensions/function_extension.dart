extension FunctionExtension0<A> on A Function() {
  X Function() castRet<X extends A>() => () => this() as X;
}

extension FunctionExtension1<A, B> on B Function(A) {
  X Function(A) castRet<X extends B>() => (a) => this(a) as X;
}

extension FunctionExtension2<A, B, C> on C Function(A, B) {
  C Function(B) Function(A) curry() => (a) => (b) => this(a, b);
  C Function(B, A) swap() => (b, a) => this(a, b);
  X Function(A, B) castRet<X extends C>() => (a, b) => this(a, b) as X;
}

extension FunctionExtension2Curried<A, B, C> on C Function(B) Function(A) {
  C Function(A, B) uncurry() => (a, b) => this(a)(b);
  C Function(A) Function(B) swap() => (b) => (a) => this(a)(b);
}

extension CurryExtension3<A, B, C, D> on D Function(A, B, C) {
  D Function(C) Function(B) Function(A) curry() =>
      (a) => (b) => (c) => this(a, b, c);
  X Function(A, B, C) castRet<X extends D>() => (a, b, c) => this(a, b, c) as X;
}

extension UncurryExtension3<A, B, C, D> on D Function(C) Function(B) Function(
  A,
) {
  D Function(A, B, C) uncurry() => (a, b, c) => this(a)(b)(c);
}

extension CurryExtension4<A, B, C, D, E> on E Function(A, B, C, D) {
  E Function(D) Function(C) Function(B) Function(A) curry() =>
      (a) => (b) => (c) => (d) => this(a, b, c, d);
  X Function(A, B, C, D) castRet<X extends E>() =>
      (a, b, c, d) => this(a, b, c, d) as X;
}

extension UncurryExtension4<A, B, C, D, E>
    on E Function(D) Function(C) Function(B) Function(A) {
  E Function(A, B, C, D) uncurry() => (a, b, c, d) => this(a)(b)(c)(d);
}
