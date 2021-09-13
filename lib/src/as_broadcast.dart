// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:async';

import 'package:rxdart_ext/rxdart_ext.dart';

import 'distinct_value_connectable_stream.dart';
import 'distinct_value_stream.dart';

/// Convert a [DistinctValueStream] to a broadcast [DistinctValueStream].
extension BroadcastDistinctValueStreamExtensions<T> on DistinctValueStream<T> {
  /// Convert the this [DistinctValueStream] into a [DistinctValueConnectableStream]
  /// that can be listened to multiple times, providing an initial seeded value.
  /// It will not begin emitting items from the original Stream
  /// until the `connect` method is invoked.
  ///
  /// This is useful for converting a single-subscription stream into a
  /// broadcast Stream, that also provides access to the latest value synchronously.
  DistinctValueConnectableStream<T> asDistinctValueConnectableStream(
      {bool sync = true}) {
    final self = this;
    return self is DistinctValueConnectableStream<T>
        ? self
        : DistinctValueConnectableStream<T>(this, value,
            equals: equals, sync: sync);
  }

  /// Convert the this [DistinctValueStream] into a new [DistinctValueStream] that can
  /// be listened to multiple times, providing an initial value.
  /// It will automatically begin emitting items when first listened to,
  /// and shut down when no listeners remain.
  ///
  /// This is useful for converting a single-subscription stream into a
  /// broadcast Stream. It's also useful for providing sync access to the latest
  /// emitted value.
  DistinctValueStream<T> asBroadcastDistinctValueStream() =>
      isBroadcast ? this : _AsBroadcastStream(this);
}

class _AsBroadcastStream<T> extends StreamView<T>
    implements DistinctValueStream<T> {
  final DistinctValueStream<T> source;

  _AsBroadcastStream(this.source)
      : super(source.asBroadcastStream(onCancel: (s) => s.cancel()));

  @override
  bool Function(T p1, T p2) get equals => source.equals;

  @override
  T get value => source.value;

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
