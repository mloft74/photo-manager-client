extension FunctionExtension2<A, B, C> on C Function(A, B) {
  C Function(B) Function(A) curry() => (a) => (b) => this(a, b);
  C Function(B, A) swap() => (b, a) => this(a, b);
}

extension FunctionExtension2Curried<A, B, C> on C Function(B) Function(A) {
  C Function(A, B) uncurry() => (a, b) => this(a)(b);
  C Function(A) Function(B) swap() => (b) => (a) => this(a)(b);
}

extension CurryExtension3<A, B, C, D> on D Function(A, B, C) {
  D Function(C) Function(B) Function(A) curry() =>
      (a) => (b) => (c) => this(a, b, c);
}

extension UncurryExtension3<A, B, C, D> on D Function(C) Function(B) Function(
  A,
) {
  D Function(A, B, C) uncurry() => (a, b, c) => this(a)(b)(c);
}

extension CurryExtension4<A, B, C, D, E> on E Function(A, B, C, D) {
  E Function(D) Function(C) Function(B) Function(A) curry() =>
      (a) => (b) => (c) => (d) => this(a, b, c, d);
}

extension UncurryExtension4<A, B, C, D, E>
    on E Function(D) Function(C) Function(B) Function(A) {
  E Function(A, B, C, D) uncurry() => (a, b, c, d) => this(a)(b)(c)(d);
}
