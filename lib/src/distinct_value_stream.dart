// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:async';

import 'package:rxdart_ext/rxdart_ext.dart';

/// An [Stream] that provides synchronous access to the last emitted item,
/// and two consecutive values are not equal.
/// The equality between previous data event and current data event is determined by [equals].
@Deprecated(
    "Use StateStream from 'rxdart_ext' package instead. This package is deprecated!")
typedef DistinctValueStream<T> = StateStream<T>;

/// Convert this [Stream] to a [DistinctValueStream].
extension ToDistinctValueStreamExtension<T> on Stream<T> {
  /// Convert this [Stream] to a [DistinctValueStream].
  ///
  /// Returned stream acts like [Stream.distinct] except it provides seed value
  /// used to check for equality, and synchronous access to the last emitted item.
  ///
  /// Data events are skipped if they are equal to the previous data event.
  /// Equality is determined by the provided [equals] method. If that is omitted,
  /// the '==' operator on the last provided data element is used.
  ///
  /// This stream is a single-subscription stream.
  @Deprecated(
      "Use ToStateStreamExtension.toStateStream from 'rxdart_ext' package instead. This package is deprecated!")
  DistinctValueStream<T> distinctValue(
    T value, {
    bool Function(T p1, T p2)? equals,
  }) =>
      toStateStream(value, equals: equals);
}
