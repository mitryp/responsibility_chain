import 'dart:async';

import 'package:meta/meta.dart';

import 'abs/node.dart';
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
  @visibleForTesting
  List<IResponsibilityNode<R, A>> get nodes;

  /// The function that returns the default value of type [R].
  ///
  /// The result of this function will be used when none of the handler nodes succeed to return the
  /// result.
  @visibleForTesting
  ParametrizedSupplier<R, A> get orElse;

  /// Adds a given [node] to this chain.
  ///
  /// The given node can either be a [IResponsibilityNode] function, or an [IResponsibilityNodeBase] ancestor
  /// class object.
  void chain(IResponsibilityNode<R, A> node);

  /// This method iterates through the chained nodes in the precise order they had been chained and
  /// calls the [IResponsibilityNode]s with the argument [arg].
  ///
  /// If a node returns a successful result, the method stops iterating and returns the result.
  /// Otherwise, if the result is not successful or throws an exception is thrown, the method
  /// proceeds to the next chained node.
  ///
  /// If no chained node succeeded to return a successful result, the result of [orElse] function is
  /// returned.
  Future<R> handle(A arg);
}

/// In contrast to the [ResponsibilityChain], this class allows to pass the argument of type [A] to
/// its [handle] method. This argument will be passed to every handler node in the chain.
///
/// For other features, see the [ResponsibilityChain] documentation.
class ResponsibilityChainWithArgs<R, A> implements IResponsibilityChain<R, A> {
  @visibleForTesting
  @override
  final List<IResponsibilityNode<R, A>> nodes = [];

  @visibleForTesting
  @override
  final ParametrizedSupplier<R, A> orElse;

  ResponsibilityChainWithArgs({required this.orElse});

  @override
  void chain(IResponsibilityNode<R, A> node) => nodes.add(node);

  @override
  Future<R> handle(A args) async {
    ChainResult<R>? lastResult;

    for (final node in nodes) {
      try {
        lastResult = await node(args);
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
/// - The [chain] method adds a responsibility node to the end of this chain;
/// - The [handle] method returns the Future of [R] and lets the chained handle nodes successively
/// try to return the value. If none of the handlers succeed, the result of [orElse] will be
/// returned.
class ResponsibilityChain<R> extends ResponsibilityChainWithArgs<R, void> {
  ResponsibilityChain({required super.orElse});

  @override
  Future<R> handle([void args]) => super.handle(args);
}
