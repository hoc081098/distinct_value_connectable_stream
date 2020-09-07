import 'package:distinct_value_connectable_stream/distinct_value_connectable_stream.dart';
import 'package:rxdart/rxdart.dart';

///
/// Include 4 extension methods on [Stream]
///
/// Publish value: [publishValueDistinct], [publishValueSeededDistinct]
/// Shared value : [shareValueDistinct]  , [shareValueSeededDistinct]
///
extension DistinctValueConnectableExtensions<T> on Stream<T> {
  /// Convert the this Stream into a [DistinctValueConnectableStream]
  /// that can be listened to multiple times, providing an initial seeded value.
  /// It will not begin emitting items from the original Stream
  /// until the `connect` method is invoked.
  ///
  /// This is useful for converting a single-subscription stream into a
  /// broadcast Stream that replays the latest emitted value to any new
  /// listener. It also provides access to the latest value synchronously.
  ///
  /// ### Example
  ///
  /// ```
  /// final source = Stream.fromIterable([1, 2, 2, 3, 3, 3]);
  /// final connectable = source.publishValueSeededDistinct(seedValue: 0);
  ///
  /// // Does not print anything at first
  /// connectable.listen(print);
  ///
  /// // Start listening to the source Stream. Will cause the previous
  /// // line to start printing 0, 1, 2, 3
  /// final subscription = connectable.connect();
  ///
  /// // Late subscribers will receive the last emitted value
  /// connectable.listen(print); // Prints 3
  ///
  /// // Can access the latest emitted value synchronously. Prints 3
  /// print(connectable.value);
  ///
  /// // Stop emitting items from the source stream and close the underlying
  /// // BehaviorSubject
  /// subscription.cancel();
  /// ```
  DistinctValueConnectableStream<T> publishValueDistinct(
    T seedValue, {
    bool Function(T previous, T next) equals,
    bool sync = false,
    bool addAfterErrorEvent = false,
  }) =>
      DistinctValueConnectableStream<T>(
        this,
        seedValue,
        equals: equals,
        sync: sync,
        addAfterErrorEvent: addAfterErrorEvent,
      );

  /// Convert the this Stream into a new [ValueStream] that can
  /// be listened to multiple times, providing an initial value.
  /// It will automatically begin emitting items when first listened to,
  /// and shut down when no listeners remain.
  ///
  /// This is useful for converting a single-subscription stream into a
  /// broadcast Stream. It's also useful for providing sync access to the latest
  /// emitted value.
  ///
  /// It will replay the latest emitted value to any new listener.
  ///
  /// ### Example
  ///
  /// ```
  /// // Convert a single-subscription fromIterable stream into a broadcast
  /// // stream that will emit the latest value to any new listeners
  /// final stream = Stream
  ///   .fromIterable([1, 2, 2, 3, 3, 3])
  ///   .shareValueSeededDistinct(seedValue: 0);
  ///
  /// // Start listening to the source Stream. Will start printing 0, 1, 2, 3
  /// final subscription = stream.listen(print);
  ///
  /// // Synchronously print the latest value
  /// print(stream.value);
  ///
  /// // Subscribe again later. This will print 3 because it receives the last
  /// // emitted value.
  /// final subscription2 = stream.listen(print);
  ///
  /// // Stop emitting items from the source stream and close the underlying
  /// // BehaviorSubject by cancelling all subscriptions.
  /// subscription.cancel();
  /// subscription2.cancel();
  /// ```
  ValueStream<T> shareValueDistinct(
    T seedValue, {
    bool Function(T previous, T next) equals,
    bool sync = false,
    bool addAfterErrorEvent = false,
  }) =>
      publishValueDistinct(
        seedValue,
        equals: equals,
        sync: sync,
        addAfterErrorEvent: addAfterErrorEvent,
      ).refCount();
}
