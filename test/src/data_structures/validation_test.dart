import 'package:photo_manager_client/src/data_structures/fp/applicative.dart';
import 'package:photo_manager_client/src/data_structures/iterable_fp.dart';
import 'package:photo_manager_client/src/extensions/curry_extension.dart';
import 'package:spec/spec.dart';

typedef Record = (int, String, double);

typedef ValidationT<T> = ValidationWithIterableErr<T, String>;

void main() {
  test('All data is acceptable', () {
    // Arrange
    const age = 20;
    const name = 'Naomi';
    const money = 12.34;
    final data = <String, dynamic>{
      'age': age,
      'name': name,
      'money': money,
    };
    final sut = succeedI(makeRecord.curry(), '');

    // Act
    final parseAgeV = parseAge(data);
    final parseNameV = parseName(data);
    final parseMoneyV = parseMoney(data);
    final actual = sut.apply(parseAgeV).apply(parseNameV).apply(parseMoneyV);

    // Assert
    final expected = succeedI(makeRecord(age, name, money), '');
    expect(actual).toEqual(expected);
  });
}

ValidationT<int> parseAge(Map<String, dynamic> json) {
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

ValidationT<String> parseName(Map<String, dynamic> json) {
  final name = json['name'] as String?;
  if (name == null) {
    return fail(['"name" key is missing']);
  }
  return succeed(name);
}

ValidationT<double> parseMoney(Map<String, dynamic> json) {
  final money = json['money'] as double?;
  if (money == null) {
    return fail(['"money" key is missing']);
  }
  return succeed(money);
}

Record makeRecord(int age, String name, double money) {
  return (age, name, money);
}
