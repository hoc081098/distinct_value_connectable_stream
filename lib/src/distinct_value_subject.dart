import 'dart:async';

import 'package:distinct_value_connectable_stream/src/distinct_value_stream_mixin.dart';
import 'package:meta/meta.dart';
import 'package:rxdart_ext/rxdart_ext.dart'
    show PublishSubject, Subject, ValueSubject;

import 'distinct_value_stream.dart';

/// A special [StreamController] that captures the latest item that has been
/// added to the controller.
///
/// [DistinctValueSubject] is the same as [PublishSubject] and [ValueSubject], with the ability to capture
/// the latest item has been added to the controller.
/// [DistinctValueSubject] is a [DistinctValueStream], that provides synchronous access to the last emitted item,
/// and two consecutive values are not equal.
/// The equality between previous data event and current data event is determined by [equals].
///
/// [DistinctValueSubject] is, by default, a broadcast (aka hot) controller, in order
/// to fulfill the Rx Subject contract. This means the Subject's `stream` can
/// be listened to multiple times.
///
/// ### Example
///
///     final subject = DistinctValueSubject<int>(1);
///
///     print(subject.value);          // prints 1
///
///     // observers will receive 2, 3 and done events.
///     subject.stream.listen(print); // prints 2, 3
///     subject.stream.listen(print); // prints 2, 3
///     subject.stream.listen(print); // prints 2, 3
///
///     subject.add(1);
///     subject.add(1);
///     subject.add(2);
///     subject.add(2);
///     subject.add(3);
///     subject.close();
@sealed
class DistinctValueSubject<T> extends Subject<T>
    with DistinctValueStreamMixin<T>
    implements DistinctValueStream<T> {
  final ValueSubject<T> _subject;

  @override
  final bool Function(T p1, T p2) equals;

  DistinctValueSubject._(
    this.equals,
    this._subject,
  ) : super(_subject, _subject.stream);

  /// Constructs a [DistinctValueSubject], optionally pass handlers for
  /// [onListen], [onCancel] and a flag to handle events [sync].
  ///
  /// [seedValue] becomes the current [value] of Subject.
  /// [equals] is used to determine equality between previous data event and current data event.
  ///
  /// See also [StreamController.broadcast],  [ValueSubject].
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

  @nonVirtual
  @override
  void add(T event) {
    if (!equals(value, event)) {
      _subject.add(event);
    }
  }

  @override
  Future<void> close() => _subject.close();

  @override
  Never addError(Object error, [StackTrace? stackTrace]) =>
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

  @override
  T get value => _subject.value;
}
