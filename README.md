## Asynchronous Responsibility Chain Pattern

This library provides an implementation of the Responsibility Chain pattern that works asynchronously and utilizes
the functional and object-oriented approaches to creating responsibility handlers.

> The Responsibility Chain pattern is a behavioral design pattern that allows an object to pass a request through a
>  chain of handlers until one of them handles the request. By doing so, the pattern decouples the sender and receiver of
> the request and allows multiple handlers to handle the request without knowing about each other.
> 
> ![Responsibility Chain Pattern Illustration](https://github.com/mitryp/responsibility_chain/tree/master/_images/illustration.webp)

This package enables using a functional or object-oriented approach to define the handlers of responsibility.
It provides `ResponsibilityChain` and `ResponsibilityChainWithArgs` classes, which allow you to chain multiple handlers
together using the `node` and `funcNode` methods for object and functional handlers respectively.
You must also specify the `orElse` function when creating a chain object. The result of this function will be returned
if none of the handlers return a result.

## Usage

The complete example can be found at `example/responsibility_chain_example.dart`.

```dart
import 'package:responsibility_chain/responsibility_chain.dart';

void main() async {
  // the `double` type parameter is the type of value returned by the `handle` method of the chain
  // the `int` type parameter is the type of argument of the `handle` method of the chain
  final rateFetchRespChain = ResponsibilityChainWithArgs<double, int>(orElse: (_) => -1)
      ..funcNode(databaseFetchHandler)
      ..funcNode(serverFetchHandler);

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
  20230215: 20.0,
};

const exchangeRateServerMock = {
  // ...
  20230213: 13.0,
  // ...
};
```

### ResponsibilityChain classes

These classes are responsible for chaining handlers and distributing the responsibility between them in the order
of they were chained.

- `ResponsibilityChainWithArgs<R, A>` - a chain that returns a value of a generic type `R` and passes the argument of a
  generic type `A` to each handler during the iteration;
- `ResponsibilityChain<R>` - inherits from `ResponsibilityChainWithArgs<R, void>` and does not require an argument at
  its `handle` method while still returning the value of the type `R`.

Both of the classes have the following interface method signatures:

- `void node(Supplier<ResponsibilityNode<R, A>>)` - chains an object of a [ResponsibilityNode<R, A>](#Object-Handlers)
  subclass to this chain. Takes a closure that returns a `ResponsibilityNode<R, A>`;
- `void funcNode(FunctionHandler<R, A>)` - chains a [FunctionHandler<R, A>](#Functional-Handlers) to this chain;
- `Future<R> handle(A args)` - iterates through the chained responsibility nodes sequentially and

### ChainResult

This class is a monad wrapper around the result of chain computation. Each handler must return an instance of this 
class, either successful or unsuccessful, or throw an Exception derived object.

- The successful `ChainResult` is created by calling `ChainResult.success(R value)`. If a handler returns a successful
ChainResult, its value will be returned by the chain;
- The unsuccessful `ChainResult` is created by calling `ChainResult.failure()`. If a handler returns an unsuccessful
ChainResult, the chain will proceed to the next handler.

### Functional Handlers

The `funcNode` method of the chain is used to add a new functional handler.

It takes a `FunctionalHandler<R, A>` - a function that takes an argument of type `A` and returns
a `FutureOr<ChainResult<R>>`.

The syntax of the usage of the functional handler is as follows:

```dart
chain.funcNode((A args) {
  if (successCondition) return ChainResult<R>.success(value);
  else return ChainResult<R>.failure();
});
```

Internally, the functional handlers are wrapped into a `FunctionalNode` class object.

> When the argument does not influence the result of the handler, its name can be replaced with the `_` symbol.

### Object Handlers

The `node` method of the chain is used to add a new object handler.

It takes a `ResponsibilityNode<R, A>` subclass object.

To implement a `ResponsibilityNode<R, A>` subclass, you must implement its `handle` method as follows:

```dart
class MyResponsibilityNode extends ResponsibilityNode<R, A> {
  FutureOr<ChainResult<R>> handle(A args) {
    if (successCondition) return ChainResult.success(value);
    else return ChainResult.failure();
  }
}
```

> Using the functional approach requires less code to implement the handler, but it makes it more complicated to 
create abstractions in that way.


## Additional information

The contributions and bug reports are welcome at project's 
[GitHub repository](https://github.com/mitryp/responsibility_chain).
