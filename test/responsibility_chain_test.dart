import 'package:responsibility_chain/responsibility_chain.dart';
import 'package:test/test.dart';

import 'mock_data.dart';
import 'random_int_testing.dart';
import 'test_helpers.dart';

void main() {
  testChainResult();
  testResponsibilityNodes();
  testResponsibilityChain();
}

void testChainResult() {
  group('ChainResult tests', () {
    test('Successful result returns a value', () {
      repeatedIntTest((value) {
        final result = ChainResult.success(value);

        expect(result.isSuccessful, isTrue);
        expect(result.value, equals(value));
      });
    });

    test('Failed result throws a StateError when accessing the value', () {
      repeatedIntTest((_) {
        final result = ChainResult.failure();

        expect(result.isSuccessful, isFalse);
        expect(() => result.value, throwsStateError);
      });
    });
  });
}

void testResponsibilityNodes() {
  group('ResponsibilityNode tests', () {
    test('ResponsibilityNodes with parameters succeed and fail correctly', () {
      final conditionalFailNode =
          IResponsibilityNodeMock<int>(conditionalFailChainResult, id: 1);
      repeatedIntTest(
        (value) => testConditionalFailNode(conditionalFailNode, value),
      );
    });

    test('FunctionalNodes with parameters succeed and fail correctly', () {
      final IResponsibilityNode<int, int> conditionalFailNode =
          conditionalFailChainResult;
      repeatedIntTest(
        (value) => testConditionalFailNode(conditionalFailNode, value),
      );
    });
  });
}

void testResponsibilityChain() {
  group('ResponsibilityChain tests', () {
    const defaultValue = -1;
    late ResponsibilityChainWithArgs<int, int> chain;
    late Iterable<IResponsibilityNodeBase<int, int>> nodes;

    setUp(() {
      chain = ResponsibilityChainWithArgs(orElse: (_) => defaultValue);
      nodes = randomNodes();
      for (final node in nodes) {
        chain.chain(node);
      }
    });

    test('ResponsibilityChain maintains the order of its nodes', () {
      expect(chain.nodes, containsAllInOrder(nodes.map((e) => e.call)));
    });

    for (int i = 0; i < 100; i++) {
      test('ResponsibilityChain returns the correct result №${i + 1}', () {
        // each mock node returns its index in the list of nodes, while the default value is -1
        final expectedResult = nodes
            .cast<IResponsibilityNodeMock<int>>()
            .map((e) => e.willSucceed)
            .toList()
            .indexWhere((e) => e!);

        expect(chain.handle(defaultValue), completion(equals(expectedResult)));
      });
    }
  });
}
