// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:async';

import 'package:rxdart_ext/rxdart_ext.dart';

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
@Deprecated(
    "Use StateSubject from 'rxdart_ext' package instead. This package is deprecated!")
typedef DistinctValueSubject<T> = StateSubject<T>;
