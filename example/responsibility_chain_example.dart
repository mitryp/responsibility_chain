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
