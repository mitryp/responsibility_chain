import '../responsibility_chain.dart';

/// A monad that wraps the result of [ResponsibilityChain] handler node execution.
///
/// The type [R] is the type contained in the result.
///
/// The [value] getter should not be used without checking if the result is successful using the
/// [isSuccessful] property.
///
class ChainResult<R> {
  late final R _value;

  /// Returns true if the result contains the exact result value.
  ///
  /// If the result is not successful, the _value property is not initialized, so obtaining the
  /// result is impossible.
  ///
  final bool isSuccessful;

  /// Returns the value of the result, if the result is successful.
  ///
  /// If the result is not successful, throws a [StateError].
  ///
  R get value {
    if (isSuccessful) return _value;
    throw StateError('Unsuccessful result cannot be obtained. '
        'Check if the result is successful first');
  }

  /// Creates a successful [ChainResult] with the value [value].
  ///
  ChainResult.success(R value)
      : _value = value,
        isSuccessful = true;

  /// Creates an unsuccessful [ChainResult] without the value.
  ///
  ChainResult.failure() : isSuccessful = false;
}
