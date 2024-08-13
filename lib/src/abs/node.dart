import 'dart:async';

import '../../responsibility_chain.dart';

/// A typedef representing a handler (responsibility node) that takes [args] of type [A] and returns a
/// Future<[ChainResult]> or [ChainResult] itself with the type parameter of [R].
/// Calling this method should either return a FutureOr<[ChainResult]<[R]>>, or throw an exception.
/// Throwing an exception will have the same effect as returning a [ChainResult.failure].
///
/// Alternatively, if you need to use objects as nodes, implement [IResponsibilityNodeBase] and treat its objects as
/// regular [IResponsibilityNode]s.
///
/// See also: [ChainResult], [IResponsibilityNodeBase].
typedef IResponsibilityNode<R, A> = FutureOr<ChainResult<R>> Function(A args);

/// An alternative way to declare responsibility node handlers - implement [IResponsibilityNode] and treat its objects
/// as regular [IResponsibilityNode]s.
///
/// The only method that needs to be implemented is [call], which corresponds to a [IResponsibilityNode] function type.
abstract class IResponsibilityNodeBase<R, A> {
  const IResponsibilityNodeBase();

  /// A method that corresponds to the [IResponsibilityNode] signature.
  /// This method should either return a FutureOr<[ChainResult]<[R]>>, or throw an exception.
  ///
  /// Throwing an exception will have the same effect as returning a [ChainResult.failure].
  FutureOr<ChainResult<R>> call(A args);
}
