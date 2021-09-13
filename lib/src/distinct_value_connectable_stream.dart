// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:async';

import 'package:rxdart_ext/rxdart_ext.dart';

import 'distinct_value_stream.dart';

/// A [ConnectableStream] that converts a single-subscription Stream into
/// a broadcast [Stream], and provides synchronous access to the latest emitted value.
///
/// This is a combine of [ConnectableStream], [ValueStream], [ValueSubject] and [Stream.distinct].
@Deprecated(
    "Use StateConnectableStream from 'rxdart_ext' package instead. This package is deprecated!")
typedef DistinctValueConnectableStream<T> = StateConnectableStream<T>;

/// Provide two extension methods for [Stream]:
/// - [publishValueDistinct]
/// - [shareValueDistinct]
extension DistinctValueConnectableExtensions<T> on Stream<T> {
  /// Convert the this Stream into a [DistinctValueConnectableStream]
  /// that can be listened to multiple times, providing an initial seeded value.
  /// It will not begin emitting items from the original Stream
  /// until the `connect` method is invoked.
  ///
  /// This is useful for converting a single-subscription stream into a
  /// broadcast Stream, that also provides access to the latest value synchronously.
  ///
  /// ### Example
  ///
  /// ```
  /// final source = Stream.fromIterable([1, 2, 2, 3, 3, 3]);
  /// final connectable = source.publishValueDistinct(0);
  ///
  /// // Does not print anything at first
  /// connectable.listen(print);
  ///
  /// // Start listening to the source Stream. Will cause the previous
  /// // line to start printing 1, 2, 3
  /// final subscription = connectable.connect();
  ///
  /// // Late subscribers will not receive anything
  /// connectable.listen(print);
  ///
  /// // Can access the latest emitted value synchronously. Prints 3
  /// print(connectable.value);
  ///
  /// // Stop emitting items from the source stream and close the underlying
  /// // ValueSubject
  /// subscription.cancel();
  /// ```
  @Deprecated(
      "Use StateConnectableExtensions.publishState from 'rxdart_ext' package instead. This package is deprecated!")
  DistinctValueConnectableStream<T> publishValueDistinct(
    T seedValue, {
    bool Function(T previous, T next)? equals,
    bool sync = true,
  }) =>
      publishState(seedValue, equals: equals, sync: sync);

  /// Convert the this Stream into a new [DistinctValueStream] that can
  /// be listened to multiple times, providing an initial value.
  /// It will automatically begin emitting items when first listened to,
  /// and shut down when no listeners remain.
  ///
  /// This is useful for converting a single-subscription stream into a
  /// broadcast Stream. It's also useful for providing sync access to the latest
  /// emitted value.
  ///
  /// ### Example
  ///
  /// ```
  /// // Convert a single-subscription fromIterable stream into a broadcast
  /// // stream that will emit the latest value to any new listeners
  /// final stream = Stream
  ///   .fromIterable([1, 2, 2, 3, 3, 3])
  ///   .shareValueDistinct(0);
  ///
  /// // Start listening to the source Stream. Will start printing 1, 2, 3
  /// final subscription = stream.listen(print);
  ///
  /// // Synchronously print the latest value
  /// print(stream.value);
  ///
  /// // Subscribe again later. Does not print anything.
  /// final subscription2 = stream.listen(print);
  ///
  /// // Stop emitting items from the source stream and close the underlying
  /// // ValueSubject by cancelling all subscriptions.
  /// subscription.cancel();
  /// subscription2.cancel();
  /// ```
  @Deprecated(
      "Use StateConnectableExtensions.shareState from 'rxdart_ext' package instead. This package is deprecated!")
  DistinctValueStream<T> shareValueDistinct(
    T seedValue, {
    bool Function(T previous, T next)? equals,
    bool sync = true,
  }) =>
      shareState(seedValue, equals: equals, sync: sync);
}
