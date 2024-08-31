typedef Identity<T> = T Function(T);
T id<T>(T t) => t;

C Function(A) Function(B Function(A)) comp<A, B, C>(C Function(B) f) =>
    (g) => (a) => f(g(a));

C Function(A) compUncurried<A, B, C>(C Function(B) f, B Function(A) g) =>
    (a) => f(g(a));
