import 'dart:async';

import 'result.dart';

/// A function that takes an argument of the type [A] and returns FutureOr<[ChainResult]<[R]>>.
@Deprecated(
  'FunctionHandlers are replaced by IResponsibilityNode type and will be removed in 2.0.0',
)
typedef FunctionHandler<R, A> = FutureOr<ChainResult<R>> Function(A args);

/// A function that takes no arguments and returns FutureOr<[ChainResult]<[R]>>.
@Deprecated(
  'FunctionHandlers are replaced by IResponsibilityNode type and will be removed in 2.0.0',
)
typedef VoidFunctionHandler<R> = FutureOr<ChainResult<R>> Function();

/// A function that takes an argument of the type [A] and returns a value of type [R].
typedef ParametrizedSupplier<R, A> = R Function(A args);

/// A function that takes no arguments and returns a value of type [R];
typedef Supplier<R> = R Function();
