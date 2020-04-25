import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

///
/// Like [ValueConnectableStream] of RxDart package
///
/// Except: data events are skipped if they are equal to the previous data event
///
/// Equality is determined by the provided equals method. If that is omitted,
/// the '==' operator on the last provided data element is used.
///
class DistinctValueConnectableStream<T> extends ConnectableStream<T>
    implements ValueStream<T> {
  final Stream<T> _source;
  final BehaviorSubject<T> _subject;
  final bool Function(T, T) _equals;

  DistinctValueConnectableStream._(
    Stream<T> source,
    this._subject,
    this._equals,
  )   : assert(source != null),
        _source =
            (source.isBroadcast ?? false) ? source : source.asBroadcastStream(),
        super(_subject);

  /// Constructs a [Stream] which only begins emitting events when
  /// the [connect] method is called, this [Stream] acts like a
  /// [BehaviorSubject] and distinct until changed.
  factory DistinctValueConnectableStream(
    Stream<T> source, {
    bool Function(T previous, T next) equals,
  }) {
    return DistinctValueConnectableStream<T>._(
      source,
      BehaviorSubject<T>(),
      equals,
    );
  }

  /// Constructs a [Stream] which only begins emitting events when
  /// the [connect] method is called, this [Stream] acts like a
  /// [BehaviorSubject.seeded] and distinct until changed.
  factory DistinctValueConnectableStream.seeded(
    Stream<T> source, {
    @required T seedValue,
    bool Function(T previous, T next) equals,
  }) {
    return DistinctValueConnectableStream<T>._(
      source,
      BehaviorSubject<T>.seeded(seedValue),
      equals,
    );
  }

  @override
  ValueStream<T> autoConnect({
    void Function(StreamSubscription<T> subscription) connection,
  }) {
    _subject.onListen = () {
      if (connection != null) {
        connection(connect());
      } else {
        connect();
      }
    };

    return _subject;
  }

  @override
  StreamSubscription<T> connect() {
    return ConnectableStreamSubscription<T>(
      _source.listen(_onData, onError: _subject.addError),
      _subject,
    );
  }

  @override
  ValueStream<T> refCount() {
    ConnectableStreamSubscription<T> subscription;

    _subject.onListen = () {
      subscription = ConnectableStreamSubscription<T>(
        _source.listen(_onData, onError: _subject.addError),
        _subject,
      );
    };

    _subject.onCancel = () {
      subscription.cancel();
    };

    return _subject;
  }

  void _onData(T data) {
    if (!_subject.hasValue) {
      _subject.add(data);
      return;
    }
    if (_equals == null) {
      if (!(data == _subject.value)) {
        _subject.add(data);
      }
    } else {
      if (!_equals(data, _subject.value)) {
        _subject.add(data);
      }
    }
  }

  @override
  bool get hasValue => _subject.hasValue;

  @override
  T get value => _subject.value;
}
