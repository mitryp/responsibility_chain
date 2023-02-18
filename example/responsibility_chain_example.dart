import 'package:responsibility_chain/responsibility_chain.dart';

/// This example demonstrates how to use the FunctionHandlers of the `responsibility_chain` package.
/// The usage of the ResponsibilityNode subclasses will look exactly the same, but with an
/// additional step of creating inherited classes for handlers.
///
/// I consider it a good idea to use FunctionHandlers to simplify your code when possible, though
/// the base class can be inherited from or mixed with to implement more complex abstractions.
///
void main() async {
  final rateFetchRespChain = ResponsibilityChainWithArgs<double, int>(orElse: (_) => -1)
    ..funcNode((args) => databaseFetchHandler(args))
    ..funcNode(serverFetchHandler);

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

/* Mocks */

ChainResult<double> databaseFetchHandler(int date) {
  final rate = localDatabaseMock[date];

  if (rate == null) return ChainResult.failure();
  return ChainResult.success(rate);
}

// handlers can return both ChainResult<R> and Future<ChainResult<R>>
Future<ChainResult<double>> serverFetchHandler(int date) async {
  final rate = exchangeRateServerMock[date];

  if (rate == null) return ChainResult.failure();
  return ChainResult.success(rate);
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

// void main() {
//   final chain = ResponsibilityChain<int>()
//     ..node(() => DatabaseFetchHandler())
//     ..node(() => ApiFetchHandler());
//
//   chain.handle().then(print);
// }
//
//
// // final chain = ResponsibilityChain<int, void>()
// //   ..funcNode((_) => ChainResult.failure())
// //   ..funcNode((_) => ChainResult.success(31122003))
// //   ..orElse((_) => 0);
//
// class DatabaseFetchHandler extends ResponsibilityNode<int, void> {
//   @override
//   Future<ChainResult<int>> handle(void args) async => ChainResult.success(await compute());
//
//   Future<int> compute() {
//     return Future.delayed(const Duration(milliseconds: 500), () {
//       throw Exception();
//     });
//   }
// }
//
// class ApiFetchHandler extends ResponsibilityNode<int, void> {
//   @override
//   Future<ChainResult<int>> handle(void args) => Future.value(ChainResult.success(14022022));
// }
