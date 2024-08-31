extension CurryExtension2<A, B, C> on C Function(A, B) {
  C Function(B) Function(A) curry() => (a) => (b) => this(a, b);
}

extension CurryExtension3<A, B, C, D> on D Function(A, B, C) {
  D Function(C) Function(B) Function(A) curry() =>
      (a) => (b) => (c) => this(a, b, c);
}

extension CurryExtension4<A, B, C, D, E> on E Function(A, B, C, D) {
  E Function(D) Function(C) Function(B) Function(A) curry() =>
      (a) => (b) => (c) => (d) => this(a, b, c, d);
}
