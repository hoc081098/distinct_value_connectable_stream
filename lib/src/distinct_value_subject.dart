import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart_ext/rxdart_ext.dart'
    show PublishSubject, Subject, ValueSubject, ValueWrapper;

import 'distinct_value_stream.dart';

/// TODO
@sealed
class DistinctValueSubject<T> extends Subject<T>
    implements DistinctValueStream<T> {
  final ValueSubject<T> _subject;

  @override
  final bool Function(T p1, T p2) equals;

  DistinctValueSubject._(
    this.equals,
    this._subject,
  ) : super(_subject, _subject.stream);

  /// TODO
  factory DistinctValueSubject(
    T seedValue, {
    bool Function(T p1, T p2)? equals,
    void Function()? onListen,
    FutureOr<void> Function()? onCancel,
    bool sync = false,
  }) {
    final subject = ValueSubject<T>(
      seedValue,
      onListen: onListen,
      onCancel: onCancel,
      sync: sync,
    );
    return DistinctValueSubject._(
        equals ?? DistinctValueStream.defaultEquals, subject);
  }

  @override
  Null get errorAndStackTrace => null;

  @override
  ValueWrapper<T> get valueWrapper => _subject.valueWrapper!;

  @nonVirtual
  @override
  void add(T event) {
    if (!equals(valueWrapper.value, event)) {
      _subject.add(event);
    }
  }

  @override
  Future<void> close() => _subject.close();

  @override
  void addError(Object error, [StackTrace? stackTrace]) =>
      throw StateError('Cannot add error to DistinctValueSubject');

  @override
  Future<void> addStream(Stream<T> source, {bool? cancelOnError}) {
    final completer = Completer<void>.sync();
    source.listen(
      add,
      onError: addError,
      onDone: completer.complete,
      cancelOnError: cancelOnError,
    );
    return completer.future;
  }

  @override
  Subject<R> createForwardingSubject<R>({
    void Function()? onListen,
    void Function()? onCancel,
    bool sync = false,
  }) =>
      PublishSubject<R>(
        onListen: onListen,
        onCancel: onCancel,
        sync: sync,
      );
}
