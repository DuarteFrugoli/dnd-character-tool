bool sameReference(Object? a, Object? b) => identical(a, b);

int referenceHash(Object? value) => value == null ? 0 : identityHashCode(value);
