// ignore_for_file: avoid_types_on_closure_parameters

import 'package:glados/glados.dart' hide expect;
import 'package:photo_manager_client/src/data_structures/iterable_fp.dart';
import 'package:photo_manager_client/src/extensions/curry_extension.dart';
import 'package:spec/spec.dart';

import '../util.dart';
import 'fp/applicative_test.dart';

const pure = IterableFP.pure;

void main() {
  test('General usage', () {
    const ints = [8, 16, 32];
    const strings = ['Hello', 'there'];
    const bools = [true, false];

    // Needs to be positional for currying to work.
    // ignore: avoid_positional_boolean_parameters
    String interpolate(int first, String second, bool third) {
      return 'first: $first, second: $second, third: $third';
    }

    final sut = pure(interpolate.curry());
    final actual = sut
        .apply(const IterableFP(ints))
        .apply(const IterableFP(strings))
        .apply(const IterableFP(bools));
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

  test('Cards', () {
    final fcard = pure(_Card.new.curry());
    const fsuits = IterableFP(_Suit.values);
    const ffaces = IterableFP(_Face.values);
    final cards = fcard.apply(fsuits).apply(ffaces);
    for (final card in cards) {
      // ignore: avoid_print
      print(card);
    }
  });

  group('Applicative laws', () {
    runIdentityLawTestsWithPure(pure);

    Glados2<List<int>, String>(
      null,
      keyboardString,
    ).test('Composition', (ints, s) {
      compositionLaw(
        pure,
        IterableFP([
          (int a) => '$a',
          (int a) => '${a.isEven}',
        ]),
        IterableFP([
          (String a) => a.length,
          (String a) => int.tryParse(a) ?? -1000,
        ]),
        IterableFP([
          s,
          ...ints.map((e) => '$e'),
        ]),
      );
    });

    runHomomorphismLawTestsWithPure(pure);

    test('Interchange', () {
      interchangeLaw(
        pure,
        IterableFP([
          (int a) => '$a',
          (int a) => '${a.isEven}',
        ]),
        17,
      );
    });
  });
}

enum _Suit {
  spades,
  clubs,
  hearts,
  diamonds,
}

enum _Face {
  ace,
  two,
  three,
  four,
  five,
  six,
  seven,
  eight,
  nine,
  ten,
  jack,
  queen,
  king,
}

final class _Card {
  final _Suit suit;
  final _Face face;

  const _Card(
    this.suit,
    this.face,
  );

  @override
  String toString() {
    return '_Card(suit: ${suit.name}, face: ${face.name})';
  }
}
