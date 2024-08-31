import 'package:photo_manager_client/src/data_structures/fp/applicative.dart';
import 'package:photo_manager_client/src/data_structures/iterable_fp.dart';
import 'package:photo_manager_client/src/extensions/curry_extension.dart';
import 'package:spec/spec.dart';

void main() {
  test('Works', () {
    const ints = [8, 16, 32];
    const strings = ['Hello', 'there'];
    const bools = [true, false];

    final sut = IterableFP([interpolate.curry()]);
    final actual = sut
        .apply(const IterableFP([8, 16, 32]))
        .apply(const IterableFP(['Hello', 'there']))
        .apply(const IterableFP([true, false]));
    final expected = IterableFP(
      [
        for (final i in ints) ...[
          for (final s in strings) ...[
            for (final b in bools) ...[
              interpolate(i, s, b),
            ],
          ],
        ],
      ],
    );

    expect(actual).toEqual(expected);
  });
}

String interpolate(int first, String second, bool third) {
  return 'first: $first, second: $second, third: $third';
}
