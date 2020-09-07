import 'dart:async';

import 'package:rxdart/streams.dart';
import 'package:rxdart/subjects.dart';

enum _Event { data, error }

class _DataOrError<T> {
  _Event event;
  T value;
  ErrorAndStacktrace errorAndStacktrace;

  _DataOrError(this.value)
      : event = _Event.data,
        errorAndStacktrace = null;

  void error(ErrorAndStacktrace errorAndStacktrace) {
    this.errorAndStacktrace = errorAndStacktrace;
    event = _Event.error;
  }

  void data(T value) {
    this.value = value;
    event = _Event.data;
  }
}

class ValueSubject<T> extends Subject<T> implements ValueStream<T> {
  final _DataOrError<T> _dataOrError;

  ValueSubject._(
    StreamController<T> controller,
    Stream<T> stream,
    this._dataOrError,
  ) : super(controller, stream);

  factory ValueSubject(
    T seedValue, {
    void Function() onListen,
    void Function() onCancel,
    bool sync = false,
  }) {
    final controller = StreamController<T>.broadcast(
      onListen: onListen,
      onCancel: onCancel,
      sync: sync,
    );

    return ValueSubject._(
      controller,
      controller.stream,
      _DataOrError(seedValue),
    );
  }

  @override
  void onAdd(T event) => _dataOrError.data(event);

  @override
  void onAddError(Object error, [StackTrace stackTrace]) =>
      _dataOrError.error(ErrorAndStacktrace(error, stackTrace));

  @override
  bool get hasValue => _dataOrError.event == _Event.data;

  @override
  T get value => _dataOrError.value;

  @override
  Object get error => _dataOrError.errorAndStacktrace.error;

  @override
  bool get hasError => _dataOrError.event == _Event.error;
}
