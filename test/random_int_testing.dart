import 'dart:async';

import 'mock_data.dart';

typedef IntValueTest = FutureOr<void> Function(int value);
typedef IntSupplier = int Function();

const testCount = 100;

Future<void> repeatedIntTest(
  IntValueTest testFunc, {
  int runs = testCount,
  IntSupplier randomValueSupplier = randInt,
}) async {
  for (var i = 0; i < runs; i++) {
    final value = randomValueSupplier.call();
    await testFunc.call(value);
  }
}
