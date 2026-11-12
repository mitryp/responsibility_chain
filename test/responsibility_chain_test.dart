import 'dart:async';

import 'package:responsibility_chain/responsibility_chain.dart';
import 'package:test/test.dart';

void main() {
  testChainResult();
  testResponsibilityNodes();
  testResponsibilityChain();
}

void testChainResult() {
  group('ChainResult tests', () {
    test('Successful result returns a value', () {
      final result = ChainResult.success(42);

      expect(result.isSuccessful, isTrue);
      expect(result.value, 42);
    });

    test('Successful result can hold null', () {
      final result = ChainResult<int?>.success(null);

      expect(result.isSuccessful, isTrue);
      expect(result.value, isNull);
    });

    test('Failed result throws a StateError when accessing the value', () {
      final result = ChainResult<int>.failure();

      expect(result.isSuccessful, isFalse);
      expect(() => result.value, throwsStateError);
    });
  });
}

class _ExtendingNode extends IResponsibilityNodeBase<int, int> {
  const _ExtendingNode();

  @override
  ChainResult<int> call(int args) => ChainResult.success(args * 2);
}

class _ImplementingNode implements IResponsibilityNodeBase<int, int> {
  const _ImplementingNode();

  @override
  Future<ChainResult<int>> call(int args) async =>
      ChainResult.success(args * 3);
}

void testResponsibilityNodes() {
  group('ResponsibilityNode tests', () {
    test('IResponsibilityNodeBase can be extended', () async {
      final chain = ResponsibilityChainWithArgs<int, int>(orElse: (_) => -1)
        ..chain(const _ExtendingNode().call);

      expect(await chain.handle(5), 10);
    });

    test('IResponsibilityNodeBase can be implemented', () async {
      final chain = ResponsibilityChainWithArgs<int, int>(orElse: (_) => -1)
        ..chain(const _ImplementingNode().call);

      expect(await chain.handle(5), 15);
    });
  });
}

void testResponsibilityChain() {
  group('ResponsibilityChain tests', () {
    late List<String> calls;

    IResponsibilityNode<int, int> node(String id, ChainResult<int> result) =>
        (_) {
          calls.add(id);
          return result;
        };

    setUp(() => calls = []);

    test('Keeps the nodes in the order they were chained', () {
      final a = node('a', ChainResult.failure());
      final b = node('b', ChainResult.failure());
      final chain = ResponsibilityChainWithArgs<int, int>(orElse: (_) => -1)
        ..chain(a)
        ..chain(b);

      expect(chain.nodes, [a, b]);
    });

    test('Returns the first successful result and skips the rest', () async {
      final chain = ResponsibilityChainWithArgs<int, int>(orElse: (_) => -1)
        ..chain(node('a', ChainResult.failure()))
        ..chain(node('b', ChainResult.success(1)))
        ..chain(node('c', ChainResult.success(2)));

      expect(await chain.handle(0), 1);
      expect(calls, ['a', 'b']);
    });

    test('Passes the argument to every node', () async {
      final args = <int>[];
      final chain = ResponsibilityChainWithArgs<int, int>(orElse: (_) => -1)
        ..chain((a) {
          args.add(a);
          return ChainResult.failure();
        })
        ..chain((a) {
          args.add(a);
          return ChainResult.success(a);
        });

      expect(await chain.handle(7), 7);
      expect(args, [7, 7]);
    });

    test('Awaits asynchronous nodes', () async {
      final chain = ResponsibilityChainWithArgs<int, int>(orElse: (_) => -1)
        ..chain((_) async {
          await Future<void>.delayed(Duration.zero);
          return ChainResult.failure();
        })
        ..chain((a) async => ChainResult.success(a + 1));

      expect(await chain.handle(1), 2);
    });

    test('Returns the orElse result for the argument if all nodes fail',
        () async {
      final chain = ResponsibilityChainWithArgs<int, int>(orElse: (a) => -a)
        ..chain(node('a', ChainResult.failure()))
        ..chain(node('b', ChainResult.failure()));

      expect(await chain.handle(3), -3);
      expect(calls, ['a', 'b']);
    });

    test('Returns the orElse result if no nodes are chained', () async {
      final chain = ResponsibilityChainWithArgs<int, int>(orElse: (_) => -1);

      expect(await chain.handle(3), -1);
    });

    test('Skips nodes that throw an Exception', () async {
      final chain = ResponsibilityChainWithArgs<int, int>(orElse: (_) => -1)
        ..chain((_) => throw const FormatException())
        ..chain((_) async => throw TimeoutException(null))
        ..chain(node('c', ChainResult.success(1)));

      expect(await chain.handle(0), 1);
      expect(calls, ['c']);
    });

    test('Rethrows errors thrown by nodes', () {
      final chain = ResponsibilityChainWithArgs<int, int>(orElse: (_) => -1)
        ..chain((_) => throw StateError('bug'))
        ..chain(node('b', ChainResult.success(1)));

      expect(chain.handle(0), throwsStateError);
    });

    test('Nodes chained during handle do not break the running call', () async {
      final chain = ResponsibilityChainWithArgs<int, int>(orElse: (_) => -1)
        ..chain((_) async {
          await Future<void>.delayed(Duration.zero);
          return ChainResult.failure();
        });

      final pending = chain.handle(0);
      chain.chain(node('late', ChainResult.success(1)));

      expect(await pending, -1);
      expect(await chain.handle(0), 1);
    });

    test('ResponsibilityChain handles without an argument', () async {
      final chain = ResponsibilityChain<int>(orElse: (_) => -1)
        ..chain((_) => ChainResult.failure())
        ..chain((_) => ChainResult.success(1));

      expect(await chain.handle(), 1);
      expect(await ResponsibilityChain<int>(orElse: (_) => -1).handle(), -1);
    });
  });
}
