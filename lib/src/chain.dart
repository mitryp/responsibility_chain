import 'dart:async';

import 'node.dart';
import 'result.dart';
import 'typedefs.dart';

/// An interface of the [ResponsibilityChain] which [handle] method takes an argument of the type
/// [A] and returns Future<[R]>.
///
/// See the [ResponsibilityChain] and [ResponsibilityChainWithArgs] documentation for more
/// information.
///
abstract class IResponsibilityChain<R, A> {
  /// The list of nodes that are currently chained to this responsibility chain.
  ///
  List<Supplier<ResponsibilityNode<R, A>>> get nodes;

  /// The function that returns the default value of type [R].
  ///
  /// The result of this function will be used when none of the handler nodes succeed to return the
  /// result.
  ///
  ParametrizedSupplier<R, A> get orElse;

  /// Chains the given node to this chain.
  ///
  /// - The [layerNode] is a function returning a [ResponsibilityNode] ancestor object.
  ///
  void node(Supplier<ResponsibilityNode<R, A>> layerNode);

  /// Chains the given function to this chain. The given function will be wrapped in the closure
  /// returning a [FunctionalNode] object.
  ///
  /// - The [functionHandler] is a [FunctionHandler]. It must either return [ChainResult]<[R]> or
  /// throw one of [Exception] subclasses.
  ///
  void funcNode(FunctionHandler<R, A> functionHandler);

  /// This method iterates through the chained nodes in the precise order they have been chained and
  /// calls the [ResponsibilityNode.handle] method with the argument of [args].
  ///
  /// If a node returns a successful result, the method stops iterating and returns the result.
  /// Otherwise, if the result is not successful or throws an exception is thrown, the method
  /// proceeds to the next chained node.
  ///
  /// If no chained node succeeded to return a successful result, the result of [orElse] function is
  /// returned.
  ///
  Future<R> handle(A args);
}

/// In contrast to the [ResponsibilityChain], this class allows to pass the argument of type [A] to
/// its [handle] method. This argument will be passed to every handler node in the chain.
///
/// For other functionality, see the [ResponsibilityChain] documentation.
///
class ResponsibilityChainWithArgs<R, A> implements IResponsibilityChain<R, A> {
  @override
  final ParametrizedSupplier<R, A> orElse;

  @override
  final List<Supplier<ResponsibilityNode<R, A>>> nodes = [];

  ResponsibilityChainWithArgs({required this.orElse});

  @override
  void node(Supplier<ResponsibilityNode<R, A>> layerNodeSupplier) =>
      nodes.add(layerNodeSupplier);

  @override
  void funcNode(FunctionHandler<R, A> functionHandler) =>
      node(() => FunctionalNode.withArgs(functionHandler));

  @override
  Future<R> handle(A args) async {
    ChainResult<R>? lastResult;

    for (final nodeSupplier in nodes) {
      final node = nodeSupplier.call();

      try {
        lastResult = await node.handle(args);
      } on Exception {
        continue;
      }

      if (lastResult.isSuccessful) return lastResult.value;
    }

    return orElse.call(args);
  }
}

/// A class providing the functionality for chaining responsibility handler nodes together and
/// controlling the responsibility distribution between the linked nodes. The [orElse] function
/// returns the value that should be returned when none of the responsibility handlers succeed to
/// return the result.
///
/// Nodes of responsibility are lazily created and executed in the precise order in which they are
/// chained.
///
/// The type parameter [R] represents the type of the result returned by the chain.
///
/// - The [node] method takes the function returning the node which will be chained;
/// - The [funcNode] method takes the function returning the [ChainResult] and wraps it in a
/// [FunctionalNode] before chaining;
/// - The [handle] method returns the Future of [R] and lets the chained handle nodes successively
/// try to return the value. If none of the handlers succeed, the result of [orElse] will be
/// returned.
///
class ResponsibilityChain<R> extends ResponsibilityChainWithArgs<R, void> {
  ResponsibilityChain({required super.orElse});

  @override
  Future<R> handle([void args]) => super.handle(args);
}
