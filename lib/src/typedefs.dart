/// A function that takes an argument of the type [A] and returns a value of type [R].
typedef ParametrizedSupplier<R, A> = R Function(A args);

/// A function that takes no arguments and returns a value of type [R];
typedef Supplier<R> = R Function();
