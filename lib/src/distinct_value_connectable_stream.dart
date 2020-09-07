import 'dart:async';

import 'package:rxdart/streams.dart';

import 'value_subject.dart';

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
  final ValueSubject<T> _subject;
  final bool Function(T, T) _equals;
  final bool addAfterErrorEvent;

  DistinctValueConnectableStream._(
    this._source,
    this._subject,
    bool Function(T, T) equals,
    this.addAfterErrorEvent,
  )   : assert(_source != null),
        assert(addAfterErrorEvent != null),
        _equals = equals ?? _defaultEquals,
        super(_subject);

  static bool _defaultEquals<T>(T lhs, T rhs) => lhs == rhs;

  /// Constructs a [Stream] which only begins emitting events when
  /// the [connect] method is called, this [Stream] acts like a
  /// [BehaviorSubject] and distinct until changed.
  factory DistinctValueConnectableStream(
    Stream<T> source,
    T seedValue, {
    bool Function(T previous, T next) equals,
    bool sync = false,
    bool addAfterErrorEvent = false,
  }) {
    return DistinctValueConnectableStream<T>._(
      source,
      ValueSubject(seedValue, sync: sync),
      equals,
      addAfterErrorEvent,
    );
  }

  @override
  ValueStream<T> autoConnect(
      {void Function(StreamSubscription<T> subscription) connection}) {
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
  StreamSubscription<T> connect() => ConnectableStreamSubscription<T>(
        _source.listen(_onData, onError: _subject.addError),
        _subject,
      );

  @override
  ValueStream<T> refCount() {
    ConnectableStreamSubscription<T> subscription;

    _subject.onListen = () {
      subscription = ConnectableStreamSubscription<T>(
        _source.listen(_onData, onError: _subject.addError),
        _subject,
      );
    };
    _subject.onCancel = () => subscription.cancel();

    return _subject;
  }

  void _onData(T data) {
    if (addAfterErrorEvent && _subject.hasError) {
      return _subject.add(data);
    }
    if (!_equals(_subject.value, data)) {
      _subject.add(data);
    }
  }

  @override
  bool get hasValue => _subject.hasValue;

  @override
  T get value => _subject.value;

  @override
  Object get error => _subject.error;

  @override
  bool get hasError => _subject.hasError;
}
