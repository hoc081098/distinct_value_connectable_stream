import '../distinct_value_connectable_stream.dart';
import 'distinct_value_stream.dart';

/// Convert single-subscription [DistinctValueStream] to broadcast [DistinctValueStream].
extension BroadcastDistinctValueStreamExtensions<T> on DistinctValueStream<T> {
  /// Convert the this Stream into a [DistinctValueConnectableStream]
  /// that can be listened to multiple times, providing an initial seeded value.
  /// It will not begin emitting items from the original Stream
  /// until the `connect` method is invoked.
  ///
  /// This is useful for converting a single-subscription stream into a
  /// broadcast Stream, that also provides access to the latest value synchronously.
  DistinctValueConnectableStream<T> publishValueDistinct({
    bool Function(T previous, T next)? equals,
    bool sync = true,
  }) {
    final self = this;
    return self is DistinctValueConnectableStream<T>
        ? self
        : DistinctValueConnectableStream<T>(this, requireValue,
            equals: equals, sync: sync);
  }

  /// Convert the this Stream into a new [DistinctValueStream] that can
  /// be listened to multiple times, providing an initial value.
  /// It will automatically begin emitting items when first listened to,
  /// and shut down when no listeners remain.
  ///
  /// This is useful for converting a single-subscription stream into a
  /// broadcast Stream. It's also useful for providing sync access to the latest
  /// emitted value.
  DistinctValueStream<T> shareValueDistinct({
    bool Function(T previous, T next)? equals,
    bool sync = true,
  }) =>
      isBroadcast
          ? this
          : publishValueDistinct(equals: equals, sync: sync).refCount();
}
