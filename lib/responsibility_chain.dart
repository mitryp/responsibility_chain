/// Provides a base for implementing asynchronous responsibility chains in Dart.
///
/// The [ResponsibilityChain] and [ResponsibilityChainWithArgs] classes provide the ability to chain
/// handlers using the method cascading.
///
/// Use [ResponsibilityChainWithArgs.chain] to add handlers, which are [IResponsibilityNode] functions:
/// - Functions can utilize simple logic.
/// - Extend or implement [IResponsibilityNodeBase] for more complex abstractions, and chain the
///   `call` method of its objects.
library;

export 'src/abs/node.dart' show IResponsibilityNode, IResponsibilityNodeBase;
export 'src/chain.dart' show ResponsibilityChain, ResponsibilityChainWithArgs;
export 'src/result.dart' show ChainResult;
