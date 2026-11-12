## 2.1.1

- Reverted `IResponsibilityNodeBase` to an abstract class: 2.1.0 made it an interface class, which broke classes
  extending it. It can be both extended and implemented again.
- Fixed `handle` throwing a `ConcurrentModificationError` when a node was chained while it was running. Nodes chained
  during a `handle` call are now used starting from the next call.
- Lowered the `meta` constraint to `^1.9.1`, so the package resolves on Dart 3.0+ and on Flutter versions that pin
  older `meta` versions again.
- Updated the documentation and the example to chain object handlers by their `call` method, which avoids the
  `implicit_call_tearoffs` lint.
- Fixed the outdated library documentation and the README badge link.

## 2.1.0

- Made the IResponsibilityNodeBase an interface instead of abstract class, so that classes that already extend other
  classes can still be responsibility nodes.
- Lifted the Dart SDK version constraint to `>=3.0.0`.
- Upgraded package dependencies.
- Updated GitHub Actions workflows.

## 2.0.0

- Unified the handler types with new `IResponsibilityNode` signature and `IResponsibilityNodeBase` hint interface.
- Added a `chain` method to replace the existing `node` and `funcNode` methods.
- Removed the `ResponsibilityNode`, `FunctionNode`, `FunctionHandler`, `ResponsibilityChain.node`,
  and `ResponsibilityChain.funcNode` entities.

## 1.1.0

- Unified the handler types with new `IResponsibilityNode` signature and `IResponsibilityNodeBase` hint interface.
- Added a `chain` method to replace the existing `node` and `funcNode` methods.
- **Deprecated the `ResponsibilityNode`, `FunctionNode`, `FunctionHandler`, `ResponsibilityChain.node`,
  and `ResponsibilityChain.funcNode` entries. These will be removed in _2.0.0_.**

## 1.0.3

- Reordered the CHANGELOG.md for the latest changes to appear first.

## 1.0.2

- Raised the maximum Dart SDK version to support Dart 3.

## 1.0.1

- Added exports for the `FunctionHandler` and `VoidFunctionHandler` typedefs to allow easier implementation of
  the function handlers.
- Removed debug prints.

## 1.0.0

- Initial version.
