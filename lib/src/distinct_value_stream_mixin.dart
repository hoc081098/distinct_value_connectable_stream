import 'package:rxdart_ext/rxdart_ext.dart' show ValueStreamError;

import 'distinct_value_stream.dart';

/// TODO
mixin DistinctValueStreamMixin<T> implements DistinctValueStream<T> {
  @override
  Never get error => throw ValueStreamError.hasNoError();

  @override
  Null get errorOrNull => null;

  @override
  bool get hasError => false;

  @override
  Null get stackTrace => null;

  @override
  bool get hasValue => true;

  @override
  T get valueOrNull => value;
}
