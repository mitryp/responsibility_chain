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
