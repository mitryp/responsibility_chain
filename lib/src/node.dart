import 'dart:async';

import '../responsibility_chain.dart';
import 'typedefs.dart';

/// A base class representing the responsibility chain handler node, intended for overriding by
/// custom subclasses.
///
/// The type parameter [R] is the type parameter of the [ChainResult] returned by the [handle]
/// method;
/// The type parameter [A] is the type of the arguments passed to the [handle] method.
///
/// When using the class, the [handle] method should be implemented.
///
/// The other way to implement the handler is to use [FunctionHandler]s (or utilize [FunctionalNode]
/// objects directly).
///
abstract class ResponsibilityNode<R, A> {
  /// A method that is called when the node is responsible for the getting the chain result.
  ///
  /// This method should either return FutureOr<[ChainResult]<[R]>> or throw an exception.
  /// Throwing an exception will have the same effect as returning the [ChainResult.failure].
  ///
  FutureOr<ChainResult<R>> handle(A args);

  const ResponsibilityNode();
}

/// A [ResponsibilityNode] wrapping a [FunctionHandler].
///
/// - The [FunctionalNode.new] constructor takes the [VoidFunctionHandler] which does not take any
/// arguments.
/// - The [FunctionalNode.withArgs] takes the [FunctionHandler] itself.
///
/// It is not necessary to create the [FunctionalNode] objects directly - the
/// [ResponsibilityChain.funcNode] method will create them automatically from the given
/// [FunctionHandler].
///
class FunctionalNode<R, A> extends ResponsibilityNode<R, A> {
  /// A [FunctionHandler] taking the argument of the type [A] and returning a [ChainResult]<[R]>.
  ///
  /// The function is also allowed to throw an exception, which have the same effect as returning
  /// the [ChainResult.failure].
  ///
  final FunctionHandler<R, A> handler;

  /// Creates a [FunctionalNode] from [VoidFunctionHandler] which does not take any arguments.
  ///
  FunctionalNode(VoidFunctionHandler<R> handler) : handler = ((args) => handler());

  /// Creates a [FunctionalNode] from [FunctionHandler], which takes an argument of the type [A].
  ///
  const FunctionalNode.withArgs(this.handler);

  @override
  FutureOr<ChainResult<R>> handle(A args) => Future.value(handler(args));
}
