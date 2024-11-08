extension PartitionExtension<T> on Iterable<T> {
  ({List<T> pass, List<T> fail}) partition(bool Function(T val) test) {
    final pass = <T>[];
    final fail = <T>[];
    for (final val in this) {
      if (test(val)) {
        pass.add(val);
      } else {
        fail.add(val);
      }
    }

    return (pass: pass, fail: fail);
  }

  ({List<U> pass, List<V> fail}) partitionMap<U, V>({
    required bool Function(T val) test,
    required U Function(T val) onPass,
    required V Function(T val) onFail,
  }) {
    final pass = <U>[];
    final fail = <V>[];
    for (final val in this) {
      if (test(val)) {
        pass.add(onPass(val));
      } else {
        fail.add(onFail(val));
      }
    }

    return (pass: pass, fail: fail);
  }
}
