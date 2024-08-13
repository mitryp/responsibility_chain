[![Dart Tests](https://github.com/mitryp/responsibility_chain/actions/workflows/dart.yml/badge.svg)](https://github.com/mitryp/responsibility_chain/actions/workflows/dart.yml?branch=master)
[![Pub package](https://img.shields.io/pub/v/responsibility_chain.svg)](https://pub.dev/packages/responsibility_chain)
[![Package publisher](https://img.shields.io/pub/publisher/responsibility_chain.svg)](https://pub.dev/packages/responsibility_chain/publisher)

## Asynchronous Responsibility Chain Pattern

> **This is a pre-release version of 2.0.0 removing the `node` and `funcNode` methods and respective handler classes. 
> Refer to the README for updated usage info.**
> 
> This release is stable though and exists to give the dependent packages some time to adapt to the changes before 
> rolling 2.0.0 out.

This library provides an implementation of the Responsibility Chain pattern that works asynchronously and utilizes
the functional and object-oriented approaches to creating responsibility handlers.

> The Responsibility Chain pattern is a behavioral design pattern that allows an object to pass a request through a
> chain of handlers until one of them handles the request. By doing so, the pattern decouples the sender and receiver of
> the request and allows multiple handlers to handle the request without knowing about each other.
>
> <img src="https://raw.githubusercontent.com/mitryp/responsibility_chain/master/_images/illustration.webp" alt="Responsibility Chain Pattern Illustration"/>
>
> [_Image source_](https://refactoring.guru/design-patterns/chain-of-responsibility)

This package enables using a functional or object-oriented approach to define handlers of responsibility.
It provides `ResponsibilityChain` and `ResponsibilityChainWithArgs` classes, which allow you to chain multiple handlers
together using the `chain` method.
You also need to specify the `orElse` function when creating a chain object. The result of this function will be returned
if none of the handlers return a result.

## Usage

The complete example can be found at `example/responsibility_chain_example.dart`.

```dart
import 'package:responsibility_chain/responsibility_chain.dart';

void main() async {
  // the `double` type parameter is the type of value returned by the `handle` method of the chain
  // the `int` type parameter is the type of argument of the `handle` method of the chain
  final rateFetchRespChain = ResponsibilityChainWithArgs<double, int>(orElse: (_) => -1)
    // the handlers can be functions with the [IResponsibilityNode] signature
    ..chain(localCacheHandler)
    // or [IResponsibilityNodeBase]-like objects for more complex logic
    ..chain(const ServerFetchHandler());

  // the result handling always happens asynchronously
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
  20230215: 20.0,
};

const exchangeRateServerMock = {
  // ...
  20230213: 13.0,
  // ...
};
```

### ResponsibilityChain classes

These classes are responsible for chaining handlers and distributing the responsibility between them in the order they
were chained.

- `ResponsibilityChainWithArgs<R, A>` - a chain that returns a value of a generic type `R` and passes the argument of a
  generic type `A` to each handler during the iteration;
- `ResponsibilityChain<R>` - inherits from `ResponsibilityChainWithArgs<R, void>` and does not require an argument at
  its `handle` method while still returning the value of the type `R`.

Both of the classes have the following interface method signatures:

- `void chain(IResponsibilityNode<R, A>)` - adds next handler to the end of the chain. The handler can either be a
  function with the `IResponsibilityNode` signature, or an ancestor of the `IResponsibilityNodeBase` class implementing
  a `call` method with the same signature.
- `Future<R> handle(A arg)` - iterates through the chained nodes sequentially and calls each node's
  `handle` method passing the `arg` as the argument. If the node returns a successful result, the value of the
  computation
  will be returned. Otherwise, if the result is unsuccessful or the node throws an exception, the chain proceeds to the
  next node. If none of the handlers return a successful result, the chain will return the result of the `orElse`
  function.

### ChainResult

This class is a monad wrapper around the result of chain computation. Each handler must return an instance of this
class, either successful or unsuccessful, or throw an Exception derived object.

- The successful `ChainResult` is created by calling `ChainResult.success(R value)`. If a handler returns a successful
  ChainResult, its value will be returned by the chain;
- The unsuccessful `ChainResult` is created by calling `ChainResult.failure()`. If a handler returns an unsuccessful
  ChainResult, the chain will proceed to the next handler.

### Functional Handlers

The `chain` method of the chain can be used to add a new functional handler.

It takes an `IResponsibilityNode<R, A>` - a function that takes an argument of type `A` and returns
a `FutureOr<ChainResult<R>>`.

The syntax of the usage of the functional handler is as follows:

```dart
chain.chain((A arg) {
  if (successCondition) {
    return ChainResult<R>.success(value);
  }
  
  return ChainResult<R>.failure();
});
```

> When the argument does not influence the result of the handler, its name can be replaced with the `_` symbol.

### Object Handlers

The `chain` method of the chain can also be used to add a new object handler.

It takes an `IResponsibilityNodeBase<R, A>`-like class object. Object handlers don't have any additional
advantages except there can be more decomposition and management opportunities for objects compared to functions -
it depends on your project structure.

To implement an `IResponsibilityNodeBase<R, A>`, you only need to implement its `call` method with the signature of
`IResponsibilityNode`:

```dart
class MyResponsibilityNode extends IResponsibilityNodeBase<R, A> {
  FutureOr<ChainResult<R>> call(A args) {
    if (successCondition) {
      return ChainResult.success(value);
    }
    
    return ChainResult.failure();
  }
}
```

> It is not necessary for a class to directly implement the `IResponsibilityNodeBase` interface.
> The only requirement is for the class to have the `call` method with the correct signature.
> The interface will allow the analyzer to hint the types though.

> Using the functional approach requires less code to implement the handler, but it makes creating complex abstractions 
> harder.

## Additional information

The contributions and bug reports are welcome at project's
[GitHub repository](https://github.com/mitryp/responsibility_chain).
