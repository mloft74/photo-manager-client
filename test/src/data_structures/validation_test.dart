// ignore_for_file: avoid_types_on_closure_parameters

import 'package:photo_manager_client/src/data_structures/fp/type_classes/applicative.dart';
import 'package:photo_manager_client/src/data_structures/iterable_fp.dart';
import 'package:photo_manager_client/src/data_structures/validation.dart';
import 'package:photo_manager_client/src/extensions/function_extension.dart';
import 'package:spec/spec.dart';

import 'fp/applicative_test.dart';

typedef Record = (int, String, double);

typedef ValidationT<T> = ValidationWithIterableErr<T, String>;

final ctors = makeValidationCtors<String>();
final pure = ctors.pure;
final succeed = pure;
final fail = ctors.fail;

void main() {
  group('${ValidationT<()>} \$', () {
    test('All data is acceptable', () {
      // Arrange
      const age = 20;
      const name = 'Naomi';
      const money = 12.34;
      final data = <String, Object?>{
        'age': age,
        'name': name,
        'money': money,
      };
      final sut = succeed(makeRecord.curry());

      // Act
      final parseAgeV = parseAge(data);
      final parseNameV = parseName(data);
      final parseMoneyV = parseMoney(data);
      final actual =
          sut.applyF(parseAgeV).applyF(parseNameV).applyF(parseMoneyV);

      // Assert
      final expected = succeed(makeRecord(age, name, money));
      expect(actual).toEqual(expected);
    });

    group(r'Applicative laws $', () {
      runIdentityLawTestsWithPure(pure);

      group(r'Composition $', () {
        final builder = IterableFP([
          ((
            ValidationT<String Function(int)> u,
            ValidationT<int Function(String)> v,
            ValidationT<String> w,
          ) =>
              (u: u, v: v, w: w)).curry(),
        ]);
        final us = IterableFP([
          fail<String Function(int)>(['int -> String failure']),
          succeed((int a) => '$a'),
        ]);
        final vs = IterableFP([
          fail<int Function(String)>(['String -> int failure']),
          succeed((String a) => a.length),
        ]);
        final ws = IterableFP([
          fail<String>(['String failure']),
          succeed('Hello there!'),
        ]);
        final data = builder.apply(us).apply(vs).apply(ws);

        for (final datum in data) {
          String type<T>(ValidationT<T> v) => switch (v) {
                Success() => 'Success',
                Failure() => 'Failure',
              };
          final u = type(datum.u);
          final v = type(datum.v);
          final w = type(datum.w);

          test('with u: $u, v: $v, w: $w', () {
            compositionLaw(
              pure,
              datum.u,
              datum.v,
              datum.w,
            );
          });
        }
      });

      runHomomorphismLawTestsWithPure(pure);

      test('Interchange', () {
        interchangeLaw(
          pure,
          succeed((int a) => '$a'),
          17,
        );
        interchangeLaw(
          pure,
          fail<String Function(int)>(['int -> String failure']),
          17,
        );
      });
    });
  });
}

ValidationT<int> parseAge(Map<String, Object?> json) {
  final age = json['age'] as int?;
  if (age == null) {
    return fail(['"age" key is missing']);
  }
  const minAge = 18;
  const maxAge = 100;
  return switch (age) {
    < minAge => fail(['Must be at least $minAge years old; got $age']),
    > maxAge => fail(['Can not be older than $maxAge years old; got $age']),
    _ => succeed(age)
  };
}

ValidationT<String> parseName(Map<String, Object?> json) {
  final name = json['name'] as String?;
  if (name == null) {
    return fail(['"name" key is missing']);
  }
  return succeed(name);
}

ValidationT<double> parseMoney(Map<String, Object?> json) {
  final money = json['money'] as double?;
  if (money == null) {
    return fail(['"money" key is missing']);
  }
  return succeed(money);
}

Record makeRecord(int age, String name, double money) {
  return (age, name, money);
}
