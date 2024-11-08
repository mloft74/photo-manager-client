// ignore_for_file: avoid_types_on_closure_parameters

import 'package:glados/glados.dart' hide expect;
import 'package:photo_manager_client/src/data_structures/iterable_fp.dart';
import 'package:photo_manager_client/src/extensions/function_extension.dart';
import 'package:spec/spec.dart';

import '../util.dart';
import 'fp/type_classes/applicative_test.dart' as applicative;
import 'fp/type_classes/functor_test.dart' as functor;
import 'fp/type_classes/monad_test.dart' as monad;
import 'fp/type_classes/monoid_test.dart' as monoid;

const pure = IterableFP.pure;
const $return = IterableFP.pure;

void main() {
  group('${IterableFP<()>} \$', () {
    test('General applicative usage', () {
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

    group(r'Monoid laws $', () {
      Glados<List<int>>().test('Right identity', (input) {
        IterableFP(input).rightIdentityLawExt(const IterableFP([]));
      });

      Glados<List<int>>().test('Left identity', (input) {
        IterableFP(input).leftIdentityLawExt(const IterableFP([]));
      });

      Glados3<List<int>, List<int>, List<int>>().test('Associativity',
          (aRaw, bRaw, cRaw) {
        final a = IterableFP(aRaw);
        final b = IterableFP(bRaw);
        final c = IterableFP(cRaw);

        a.associativityLawExt(b, c);
      });

      Glados3<List<int>, List<int>, List<int>>().test('Concatenation',
          (aRaw, bRaw, cRaw) {
        final a = IterableFP(aRaw);
        final b = IterableFP(bRaw);
        final c = IterableFP(cRaw);
        [a, b, c].concatenationLawExt(
          const IterableFP([]),
          IterableFP.mconcat,
        );
      });
    });

    group(r'Functor laws $', () {
      test('Identity', () {
        functor.identityLaw(const IterableFP([12]));
        functor.identityLaw(const IterableFP([true]));
        functor.identityLaw(const IterableFP([0.58736278393736]));
        functor.identityLaw(const IterableFP(['Nice looking string here!']));
      });

      Glados<List<int>>().test('Composition', (ints) {
        functor.compositionLaw(IterableFP(ints), (b) => '$b', (i) => i.isEven);
      });
    });

    group(r'Applicative laws $', () {
      applicative.runIdentityLawTestsWithPure(pure);

      Glados2<List<int>, String>(
        null,
        keyboardString,
      ).test('Composition', (ints, s) {
        applicative.compositionLaw(
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

      applicative.runHomomorphismLawTestsWithPure(pure);

      test('Interchange', () {
        applicative.interchangeLaw(
          pure,
          IterableFP([
            (int a) => '$a',
            (int a) => '${a.isEven}',
          ]),
          17,
        );
      });
    });

    group(r'Monad laws $', () {
      Glados<int>().test('Left identity law', (val) {
        val = val.abs();
        monad.leftIdentityLaw(
          $return,
          _gen,
          val,
        );
      });

      Glados<int>().test('Right identity law', (val) {
        monad.rightIdentityLaw($return, $return(val));
      });

      Glados<int>().test('Associativity law', (val) {
        val = val.abs();
        monad.associativityLaw(
          $return(val),
          (val) => _gen(val, 'Something'),
          (val) => IterableFP(val.split(' ')),
          // Evil hack to fix types
          fixedBind: <X1, X2>(x1, x2) => x1.bind(
            x2.castRet<IterableFP<X2>>(),
          ),
        );
      });

      Glados<int>().test('Pure is return', (val) {
        monad.pureIsReturn(pure, $return, val);
      });

      Glados<List<int>>().test('Apply relates to bind', (val) {
        val = val.map((e) => e.abs()).toList();
        monad.applyRelatesToBind(
          $return,
          IterableFP([
            (int val) => _gen(val, 'First'),
            (int val) => _gen(val, 'Second'),
          ]),
          IterableFP(val),
          // Evil hack to fix types
          fixedBind: <X1, X2>(x1, x2) => x1.bind(
            x2.castRet<IterableFP<X2>>(),
          ),
        );
      });
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

IterableFP<String> _gen(int num, [String str = 'Hello']) =>
    IterableFP(List.generate(num, (num) => '$str $num'));
