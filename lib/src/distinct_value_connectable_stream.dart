import 'dart:async';

import 'package:rxdart_ext/rxdart_ext.dart'
    show
        ConnectableStream,
        ConnectableStreamSubscription,
        ValueStream,
        ValueSubject,
        ValueWrapper,
        ValueStreamExtensions;

import 'distinct_value_stream.dart';

/// A [ConnectableStream] that converts a single-subscription Stream into
/// a broadcast [Stream], and provides synchronous access to the latest emitted value.
///
/// This is a combine of [ConnectableStream], [ValueStream], [ValueSubject] and [Stream.distinct].
class DistinctValueConnectableStream<T> extends ConnectableStream<T>
    implements DistinctValueStream<T> {
  final Stream<T> _source;
  final ValueSubject<T> _subject;
  var _used = false;

  @override
  final bool Function(T, T) equals;

  DistinctValueConnectableStream._(
    this._source,
    this._subject,
    bool Function(T, T)? equals,
  )   : equals = equals ?? DistinctValueStream.defaultEquals,
        super(_subject);

  /// Constructs a [Stream] which only begins emitting events when
  /// the [connect] method is called, this [Stream] acts like a
  /// [ValueSubject] and distinct until changed.
  ///
  /// Data events are skipped if they are equal to the previous data event.
  /// Equality is determined by the provided [equals] method. If that is omitted,
  /// the '==' operator on the last provided data element is used.
  factory DistinctValueConnectableStream(
    Stream<T> source,
    T seedValue, {
    bool Function(T previous, T next)? equals,
    bool sync = true,
  }) =>
      DistinctValueConnectableStream<T>._(
          source, ValueSubject(seedValue, sync: sync), equals);

  ConnectableStreamSubscription<T> _connect() =>
      ConnectableStreamSubscription<T>(
        _source.listen(
          (data) {
            if (!equals(_subject.requireValue, data)) {
              _subject.add(data);
            }
          },
          onError: null,
          onDone: _subject.close,
        ),
        _subject,
      );

  void _checkUsed() {
    if (_used) {
      throw StateError('Cannot reuse this stream. This causes many problems.');
    }
    _used = true;
  }

  @override
  DistinctValueStream<T> autoConnect({
    void Function(StreamSubscription<T> subscription)? connection,
  }) {
    _checkUsed();

    _subject.onListen = () {
      final subscription = _connect();
      connection?.call(subscription);
    };
    _subject.onCancel = null;

    return this;
  }

  @override
  StreamSubscription<T> connect() {
    _checkUsed();

    _subject.onListen = _subject.onCancel = null;
    return _connect();
  }

  @override
  DistinctValueStream<T> refCount() {
    _checkUsed();

    late ConnectableStreamSubscription<T> subscription;

    _subject.onListen = () => subscription = _connect();
    _subject.onCancel = () => subscription.cancel();

    return this;
  }

  @override
  Null get errorAndStackTrace => null;

  @override
  ValueWrapper<T> get valueWrapper => _subject.valueWrapper!;
}

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
  DistinctValueConnectableStream<T> publishValueDistinct(
    T seedValue, {
    bool Function(T previous, T next)? equals,
    bool sync = true,
  }) =>
      DistinctValueConnectableStream<T>(this, seedValue,
          equals: equals, sync: sync);

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
  DistinctValueStream<T> shareValueDistinct(
    T seedValue, {
    bool Function(T previous, T next)? equals,
    bool sync = true,
  }) =>
      publishValueDistinct(seedValue, equals: equals, sync: sync).refCount();
}
