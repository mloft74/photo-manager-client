extension FlatmapExtension<T> on Iterable<T> {
  Iterable<TNew> flatMap<TNew>(Iterable<TNew> Function(T val) fn) sync* {
    for (final i in this) {
      yield* fn(i);
    }
  }
}
