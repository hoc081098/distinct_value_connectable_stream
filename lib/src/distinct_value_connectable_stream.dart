import 'dart:async';

import 'package:rxdart/rxdart.dart'
    show ConnectableStream, ConnectableStreamSubscription, ErrorAndStackTrace;

import 'distinct_value_stream.dart';
import 'value_subject.dart';

/// A [ConnectableStream] that converts a single-subscription Stream into
/// a broadcast [Stream], and provides synchronous access to the latest emitted value.
///
/// This is a combine of [ConnectableStream], [ValueStream], [ValueSubject] and [Stream.distinct].
class DistinctValueConnectableStream<T> extends ConnectableStream<T>
    implements DistinctValueStream<T> {
  final Stream<T> _source;
  final ValueSubject<T> _subject;

  @override
  final bool Function(T, T) equals;

  DistinctValueConnectableStream._(
    this._source,
    this._subject,
    bool Function(T, T) equals,
  )   : assert(_source != null),
        equals = equals ?? DistinctValueStream.defaultEquals,
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
    bool Function(T previous, T next) equals,
    bool sync = false,
  }) =>
      DistinctValueConnectableStream<T>._(
          source, ValueSubject(seedValue, sync: sync), equals);

  ConnectableStreamSubscription<T> _connect() =>
      ConnectableStreamSubscription<T>(
        _source.listen(
          _onData,
          onError: _subject.addError,
          onDone: _subject.close,
        ),
        _subject,
      );

  @override
  DistinctValueStream<T> autoConnect({
    void Function(StreamSubscription<T> subscription) connection,
  }) {
    _subject.onListen = () {
      final subscription = _connect();
      connection?.call(subscription);
    };
    _subject.onCancel = null;

    return this;
  }

  @override
  StreamSubscription<T> connect() {
    _subject.onListen = _subject.onCancel = null;
    return _connect();
  }

  @override
  DistinctValueStream<T> refCount() {
    ConnectableStreamSubscription<T> subscription;

    _subject.onListen = () => subscription = _connect();
    _subject.onCancel = () => subscription.cancel();

    return this;
  }

  void _onData(T data) {
    bool isEqual;

    try {
      isEqual = equals(_subject.value, data);
    } catch (e, s) {
      _subject.addError(e, s);
      return;
    }

    if (!isEqual) {
      _subject.add(data);
    }
  }

  @override
  bool get hasValue => _subject.hasValue;

  @override
  T get value => _subject.value;

  @override
  ErrorAndStackTrace get errorAndStackTrace => _subject.errorAndStackTrace;

  @override
  bool get hasError => _subject.hasError;
}
