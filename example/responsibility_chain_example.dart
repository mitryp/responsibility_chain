import 'package:responsibility_chain/responsibility_chain.dart';

/// This example demonstrates how to use create and use responsibility nodes from the `responsibility_chain` package.
/// The usage of the IResponsibilityNodeBase subclasses will look exactly the same, but with an
/// additional step of creating inherited classes for handlers.
void main() async {
  // create a chain instance and chain handlers to it
  final rateFetchRespChain = ResponsibilityChainWithArgs<double, int>(
      orElse: (_) => -1)
    // the handlers can be functions with the [IResponsibilityNode] signature
    ..chain(localCacheHandler)
    // or [IResponsibilityNodeBase]-like objects for more complex logic
    ..chain(const ServerFetchHandler());

  // the result handling is always happens asynchronously
  // the argument will be passed to each of the handler nodes during the execution

  // 20.0 will be returned by databaseFetchHandler
  print(await rateFetchRespChain.handle(20230215));

  // if the databaseFetchHandler fails to return the result, the next handler will be called

  // 13.00 will be returned by serverFetchHandler
  print(await rateFetchRespChain.handle(20230213));

  // if no handler succeeds to return the result, the result of orElse function from the chain
  // constructor will be returned

  // -1 will be returned by orElse function as none of the handlers returned the result
  print(await rateFetchRespChain.handle(20230209));
}

/* Chain Nodes examples */

/// A functional-style handler. Must comply to the [IResponsibilityNode] signature.
ChainResult<double> localCacheHandler(int date) {
  final rate = localDatabaseMock[date];

  if (rate == null) return ChainResult.failure();
  return ChainResult.success(rate);
}

/// An object-style handler.
/// Must have a [call] function complying to the [IResponsibilityNode] signature.
///
/// It is not required to implement [IResponsibilityNodeBase], but this way the analyzer will hint the types for you.
class ServerFetchHandler implements IResponsibilityNodeBase<double, int> {
  const ServerFetchHandler();

  @override
  Future<ChainResult<double>> call(int date) async {
    final rate = exchangeRateServerMock[date];

    if (rate == null) return ChainResult.failure();
    return ChainResult.success(rate);
  }
}

const localDatabaseMock = {
  20230217: 22.0,
  20230216: 21.0,
  20230215: 20.0,
};

const exchangeRateServerMock = {
  20230217: 19.0,
  20230216: 17.0,
  20230215: 17.0,
  20230214: 14.0,
  20230213: 13.0,
  20230212: 12.0,
};
