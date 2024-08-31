// ignore_for_file: avoid_types_on_closure_parameters

import 'package:photo_manager_client/src/data_structures/fp/applicative.dart';
import 'package:photo_manager_client/src/data_structures/iterable_fp.dart';
import 'package:photo_manager_client/src/extensions/curry_extension.dart';
import 'package:spec/spec.dart';

import 'fp/applicative_test.dart';

void main() {
  test('General usage', () {
    const ints = [8, 16, 32];
    const strings = ['Hello', 'there'];
    const bools = [true, false];

    final sut = IterableFP([interpolate.curry()]);
    final actual = sut
        .apply(const IterableFP([8, 16, 32]))
        .apply(const IterableFP(['Hello', 'there']))
        .apply(const IterableFP([true, false]));
    final expected = IterableFP([
      for (final i in ints) ...[
        for (final s in strings) ...[
          for (final b in bools) ...[
            interpolate(i, s, b),
          ],
        ],
      ],
    ]);

    expect(actual).toEqual(expected);
  });

  group('Applicative laws', () {
    runIdentityLawTestsWithPure(IterableFP.pure);

    test('Composition', () {
      compositionLaw(
        IterableFP.pure,
        IterableFP([
          (int a) => '$a',
          (int a) => '${a.isEven}',
        ]),
        IterableFP([
          (String a) => a.length,
          (String a) => int.tryParse(a) ?? -1000,
        ]),
        const IterableFP([
          'Hello there!',
          '12',
          '142',
          '-17',
        ]),
      );
    });

    runHomomorphismLawTestsWithPure(IterableFP.pure);

    test('Interchange', () {
      interchangeLaw(
        IterableFP.pure,
        IterableFP([
          (int a) => '$a',
          (int a) => '${a.isEven}',
        ]),
        17,
      );
    });
  });
}

// Needs to be positional for currying to work.
// ignore: avoid_positional_boolean_parameters
String interpolate(int first, String second, bool third) {
  return 'first: $first, second: $second, third: $third';
}
