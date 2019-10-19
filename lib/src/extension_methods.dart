import 'package:distinct_value_connectable_observable/distinct_value_connectable_observable.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

///
/// Include 4 extension functions on Stream:
///              |        not seeded      |            seeded
/// publishValue | [publishValueDistinct] | [publishValueSeededDistinct]
/// shareValue   | [shareValueDistinct]   | [shareValueSeededDistinct]
///

extension DistinctValueConnectableExtension<T> on Stream<T> {
  /// Convert the [this$] Observable into a [DistinctValueConnectableObservable]
  /// that can be listened to multiple times. It will not begin emitting items
  /// from the original Observable until the `connect` method is invoked.
  ///
  /// This is useful for converting a single-subscription stream into a
  /// broadcast Stream that replays the latest emitted value to any new
  /// listener. It also provides access to the latest value synchronously.
  ///
  /// ### Example
  ///
  /// ```
  /// final source = Observable.fromIterable([1, 2, 2, 3, 3, 3]);
  /// final connectable = publishValueDistinct(source);
  ///
  /// // Does not print anything at first
  /// connectable.listen(print);
  ///
  /// // Start listening to the source Observable. Will cause the previous
  /// // line to start printing 1, 2, 3
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
  /// await subscription.cancel();
  /// ```
  DistinctValueConnectableObservable<T> publishValueDistinct({
    bool equals(T previous, T next),
  }) {
    return DistinctValueConnectableObservable<T>(
      this,
      equals: equals,
    );
  }

  /// Convert the [this$] Observable into a [DistinctValueConnectableObservable]
  /// that can be listened to multiple times, providing an initial seeded value.
  /// It will not begin emitting items from the original Observable
  /// until the `connect` method is invoked.
  ///
  /// This is useful for converting a single-subscription stream into a
  /// broadcast Stream that replays the latest emitted value to any new
  /// listener. It also provides access to the latest value synchronously.
  ///
  /// ### Example
  ///
  /// ```
  /// final source = Observable.fromIterable([1, 2, 2, 3, 3, 3]);
  /// final connectable = publishValueSeededDistinct(source, seedValue: 0);
  ///
  /// // Does not print anything at first
  /// connectable.listen(print);
  ///
  /// // Start listening to the source Observable. Will cause the previous
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
  DistinctValueConnectableObservable<T> publishValueSeededDistinct({
    @required T seedValue,
    bool equals(T previous, T next),
  }) {
    return DistinctValueConnectableObservable<T>.seeded(
      this,
      seedValue: seedValue,
      equals: equals,
    );
  }

  /// Convert the [this$] Observable into a new [ValueObservable] that can
  /// be listened to multiple times. It will automatically begin emitting items
  /// when first listened to, and shut down when no listeners remain.
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
  /// final observable = shareValueDistinct(Observable.fromIterable([1, 2, 2, 3, 3, 3]));
  ///
  /// // Start listening to the source Observable. Will start printing 1, 2, 3
  /// final subscription = observable.listen(print);
  ///
  /// // Synchronously print the latest value
  /// print(observable.value);
  ///
  /// // Subscribe again later. This will print 3 because it receives the last
  /// // emitted value.
  /// final subscription2 = observable.listen(print);
  ///
  /// // Stop emitting items from the source stream and close the underlying
  /// // BehaviorSubject by cancelling all subscriptions.
  /// subscription.cancel();
  /// subscription2.cancel();
  /// ```
  ValueObservable<T> shareValueDistinct({
    bool equals(T previous, T next),
  }) {
    return publishValueDistinct(equals: equals).refCount();
  }

  /// Convert the [this$] Observable into a new [ValueObservable] that can
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
  /// final observable = shareValueSeededDistinct(
  ///    Observable.fromIterable([1, 2, 2, 3, 3, 3]),
  ///    seedValue: 0,
  /// );
  ///
  /// // Start listening to the source Observable. Will start printing 0, 1, 2, 3
  /// final subscription = observable.listen(print);
  ///
  /// // Synchronously print the latest value
  /// print(observable.value);
  ///
  /// // Subscribe again later. This will print 3 because it receives the last
  /// // emitted value.
  /// final subscription2 = observable.listen(print);
  ///
  /// // Stop emitting items from the source stream and close the underlying
  /// // BehaviorSubject by cancelling all subscriptions.
  /// subscription.cancel();
  /// subscription2.cancel();
  /// ```
  ValueObservable<T> shareValueSeededDistinct(
    Observable<T> this$, {
    @required T seedValue,
    bool equals(T previous, T next),
  }) {
    return publishValueSeededDistinct(
      seedValue: seedValue,
      equals: equals,
    ).refCount();
  }
}
