/// Provides a base for implementing asynchronous responsibility chains in Dart.
///
/// The [ResponsibilityChain] and [ResponsibilityChainWithArgs] classes provide the ability to chain
/// handlers using the method cascading.
///
/// Use [ResponsibilityChain.node] to chain [ResponsibilityNode] class ancestors and
/// [ResponsibilityChain.funcNode] to chain the functional handler nodes.
/// - Functional handler nodes can utilize simple logic.
/// - Inherit from [ResponsibilityNode] to implement more complex abstractions.
///
library responsibility_chain;

export 'src/abs/node.dart' show IResponsibilityNode, IResponsibilityNodeBase;
export 'src/chain.dart' show ResponsibilityChain, ResponsibilityChainWithArgs;
export 'src/node.dart' show ResponsibilityNode, FunctionalNode;
export 'src/result.dart' show ChainResult;
export 'src/typedefs.dart' show FunctionHandler, VoidFunctionHandler, Supplier;
