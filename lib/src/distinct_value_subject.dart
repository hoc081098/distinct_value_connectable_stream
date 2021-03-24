import 'dart:async';

import 'package:distinct_value_connectable_stream/distinct_value_connectable_stream.dart';
import 'package:rxdart_ext/rxdart_ext.dart';

/// TODO
class DistinctValueSubject<T> extends Subject<T>
    implements DistinctValueStream<T> {
  var _isAddingStream = false;
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

  @override
  void add(T event) {
    if (_isAddingStream) {
      throw StateError(
          'You cannot add items while items are being added from addStream');
    }

    _addIfDistinct(event);
  }

  void _addIfDistinct(T event) {
    if (!equals(valueWrapper.value, event)) {
      _subject.add(event);
    }
  }

  @override
  Future<void> close() {
    if (_isAddingStream) {
      throw StateError(
          'You cannot close the subject while items are being added from addStream');
    }
    return _subject.close();
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) =>
      throw StateError('Cannot add error to DistinctValueSubject');

  @override
  Future<void> addStream(Stream<T> source, {bool? cancelOnError}) {
    if (_isAddingStream) {
      throw StateError(
          'You cannot add items while items are being added from addStream');
    }

    final completer = Completer<void>.sync();

    var isOnDoneCalled = false;
    final onDone = () {
      if (!isOnDoneCalled) {
        isOnDoneCalled = true;
        _isAddingStream = false;
        completer.complete();
      }
    };
    _isAddingStream = true;

    source.listen(
      _addIfDistinct,
      onError: (Object e, StackTrace s) =>
          throw StateError('Cannot add error to DistinctValueSubject'),
      onDone: onDone,
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

void main() {
  final s = DistinctValueSubject(1, sync: true);

  print(s.value);
  s.listen(print);

  s.add(1);
  s.add(1);
  s.add(2);
  s.add(3);
}
