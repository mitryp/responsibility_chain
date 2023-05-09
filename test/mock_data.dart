import 'dart:async';
import 'dart:math';

import 'package:responsibility_chain/responsibility_chain.dart';

final rand = Random();

int randInt({int min = -1000, int max = 1000}) => rand.nextInt(max - min) + min;

class ResponsibilityNodeMock<T> extends ResponsibilityNode<int, T> {
  final FunctionHandler<int, T> handler;
  final bool? willSucceed;

  const ResponsibilityNodeMock(this.handler, {this.willSucceed});

  ResponsibilityNodeMock.success([int? val])
      : this((_) => ChainResult.success(val ?? randInt()), willSucceed: true);

  ResponsibilityNodeMock.failure()
      : this((_) => ChainResult.failure(), willSucceed: false);

  factory ResponsibilityNodeMock.random([int? val]) {
    if (rand.nextBool()) return ResponsibilityNodeMock.success(val);
    return ResponsibilityNodeMock.failure();
  }

  @override
  FutureOr<ChainResult<int>> handle(args) => handler(args);
}

FunctionHandler<int, void> randomVoidFunctionalHandler() {
  return (args) {
    if (rand.nextBool()) return ChainResult.success(randInt());
    return ChainResult.failure();
  };
}

FunctionHandler<int, int> randomIntFunctionalHandler(int param) {
  return (args) {
    if (rand.nextBool()) return ChainResult.success(args * args + param);
    return ChainResult.failure();
  };
}

Iterable<ResponsibilityNodeMock<int>> randomNodes<R, A>([int length = 10]) {
  return [
    for (int i = 0; i < length; i++) ResponsibilityNodeMock.random(i),
  ];
}
