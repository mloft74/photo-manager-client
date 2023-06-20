extension PipeExtension<T extends Object> on T {
  U pipe<U>(U Function(T value) fn) => fn(this);
}
