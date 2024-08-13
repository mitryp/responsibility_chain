import 'package:meta/meta.dart';

import '../abs/node.dart';
import '../node.dart';

@protected
IResponsibilityNode<R, A> wrapDeprecatedNode<R, A>(
  ResponsibilityNode<R, A> node,
) =>
    node.handle;
