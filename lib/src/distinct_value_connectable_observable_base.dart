import 'dart:async';

import 'package:rxdart/rxdart.dart';

///
/// Like [ValueConnectableObservable] of RxDart package
///
/// Except: data events are skipped if they are equal to the previous data event
///
/// Equality is determined by the provided equals method. If that is omitted,
/// the '==' operator on the last provided data element is used.
///
class DistinctValueConnectableObservable<T> extends ConnectableObservable<T>
    implements ValueObservable<T> {
  final Stream<T> _source;
  final BehaviorSubject<T> _subject;
  final bool Function(T, T) _equals;

  DistinctValueConnectableObservable._(
    this._source,
    this._subject,
    this._equals,
  ) : super(_subject);

  factory DistinctValueConnectableObservable(
    Stream<T> source, {
    T seedValue,
    bool equals(T previous, T next),
  }) {
    return DistinctValueConnectableObservable<T>._(
      source,
      BehaviorSubject<T>(seedValue: seedValue),
      equals,
    );
  }

  @override
  ValueObservable<T> autoConnect({
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
    return ConnectableObservableStreamSubscription<T>(
      _source.listen(_onData, onError: _subject.addError),
      _subject,
    );
  }

  @override
  ValueObservable<T> refCount() {
    ConnectableObservableStreamSubscription<T> subscription;

    _subject.onListen = () {
      subscription = ConnectableObservableStreamSubscription<T>(
        _source.listen(_onData, onError: _subject.addError),
        _subject,
      );
    };

    _subject.onCancel = () {
      subscription.cancel();
    };

    return _subject;
  }

  @override
  T get value => _subject.value;

  void _onData(T data) {
    if (_equals == null) {
      if (data != _subject.value) {
        _subject.add(data);
      }
    } else {
      if (!_equals(data, _subject.value)) {
        _subject.add(data);
      }
    }
  }
}
