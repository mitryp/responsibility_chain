import 'package:responsibility_chain/responsibility_chain.dart';
import 'package:responsibility_chain/src/abs/node.dart';
import 'package:responsibility_chain/src/chain.dart';
import 'package:test/test.dart';

Future<void> testConditionalFailNode(
    ResponsibilityNode<int, int> node, int value) async {
  final res = await node.handle(value);

  if (res.isSuccessful) {
    expect(res.value, equals(value * 2));
  } else {
    expect(() => res.value, throwsStateError);
  }
}

ChainResult<int> conditionalFailChainResult(int args) =>
    args > 0 ? ChainResult.success(args * 2) : ChainResult.failure();

void chainNodesTo<R, A>(
  IResponsibilityChain<R, A> chain, {
  required Iterable<IResponsibilityNode<R, A>> nodes,
}) =>
    nodes.forEach(chain.chain);
