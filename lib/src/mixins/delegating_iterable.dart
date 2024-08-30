mixin DelegatingIterable<T> implements Iterable<T> {
  Iterable<T> get delegate;

  @override
  Iterator<T> get iterator => delegate.iterator;

  @override
  bool any(bool Function(T element) test) => delegate.any(test);

  @override
  Iterable<R> cast<R>() => delegate.cast<R>();

  @override
  bool contains(Object? element) => delegate.contains(element);

  @override
  T elementAt(int index) => delegate.elementAt(index);

  @override
  bool every(bool Function(T element) test) => delegate.every(test);

  @override
  Iterable<R> expand<R>(Iterable<R> Function(T element) toElements) =>
      delegate.expand(toElements);

  @override
  T get first => delegate.first;

  @override
  T firstWhere(bool Function(T element) test, {T Function()? orElse}) =>
      delegate.firstWhere(test, orElse: orElse);

  @override
  R fold<R>(R initialValue, R Function(R previousValue, T element) combine) =>
      delegate.fold(initialValue, combine);

  @override
  Iterable<T> followedBy(Iterable<T> other) => delegate.followedBy(other);

  @override
  void forEach(void Function(T element) action) => delegate.forEach(action);

  @override
  bool get isEmpty => delegate.isEmpty;

  @override
  bool get isNotEmpty => delegate.isNotEmpty;

  @override
  String join([String separator = '']) => delegate.join(separator);

  @override
  T get last => delegate.last;

  @override
  T lastWhere(bool Function(T element) test, {T Function()? orElse}) =>
      delegate.lastWhere(test, orElse: orElse);

  @override
  int get length => delegate.length;

  @override
  Iterable<R> map<R>(R Function(T e) toElement) => delegate.map(toElement);

  @override
  T reduce(T Function(T value, T element) combine) => delegate.reduce(combine);

  @override
  T get single => delegate.single;

  @override
  T singleWhere(bool Function(T element) test, {T Function()? orElse}) =>
      delegate.singleWhere(test, orElse: orElse);

  @override
  Iterable<T> skip(int count) => delegate.skip(count);

  @override
  Iterable<T> skipWhile(bool Function(T value) test) => skipWhile(test);

  @override
  Iterable<T> take(int count) => delegate.take(count);

  @override
  Iterable<T> takeWhile(bool Function(T value) test) =>
      delegate.takeWhile(test);

  @override
  List<T> toList({bool growable = true}) => delegate.toList(growable: growable);

  @override
  Set<T> toSet() => delegate.toSet();

  @override
  Iterable<T> where(bool Function(T element) test) => delegate.where(test);

  @override
  Iterable<R> whereType<R>() => delegate.whereType<R>();
}
