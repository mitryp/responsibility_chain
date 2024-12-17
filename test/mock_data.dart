import 'dart:async';
import 'dart:math';

import 'package:responsibility_chain/responsibility_chain.dart';

final rand = Random();

int randInt({int min = -1000, int max = 1000}) => rand.nextInt(max - min) + min;

class IResponsibilityNodeMock<T> extends IResponsibilityNodeBase<int, T> {
  final int id;
  final IResponsibilityNode<int, T> handler;
  final bool? willSucceed;

  const IResponsibilityNodeMock(
    this.handler, {
    required this.id,
    this.willSucceed,
  });

  IResponsibilityNodeMock.success({required int id, int? val})
      : this(
          (_) => ChainResult.success(val ?? randInt()),
          willSucceed: true,
          id: id,
        );

  IResponsibilityNodeMock.failure({required int id})
      : this(
          (_) => ChainResult.failure(),
          willSucceed: false,
          id: id,
        );

  factory IResponsibilityNodeMock.random({
    required int id,
    int? val,
  }) {
    if (rand.nextBool()) {
      return IResponsibilityNodeMock.success(val: val, id: id);
    }

    return IResponsibilityNodeMock.failure(id: id);
  }

  @override
  FutureOr<ChainResult<int>> call(T args) => handler(args);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IResponsibilityNodeMock &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'IResponsibilityNodeMock{$id}';
}

Iterable<IResponsibilityNodeBase<int, int>> randomNodes<R, A>(
        [int length = 10]) =>
    List.generate(
      length,
      (i) => IResponsibilityNodeMock.random(val: i, id: i),
    );
