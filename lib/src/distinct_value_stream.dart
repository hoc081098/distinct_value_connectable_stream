import 'dart:async';

import 'package:rxdart_ext/rxdart_ext.dart'
    show NotReplayValueStream, ValueStreamController, ValueWrapper;

/// An [Stream] that provides synchronous access to the last emitted item,
/// and two consecutive values are not equal.
/// The equality between previous data event and current data event is determined by [equals].
abstract class DistinctValueStream<T> extends NotReplayValueStream<T> {
  /// Determined equality between previous data event and current data event.
  bool Function(T, T) get equals;

  /// Default [equals] function.
  /// Use '==' operator on the last provided data element.
  static bool defaultEquals<T>(T lhs, T rhs) => lhs == rhs;

  @override
  Never get errorAndStackTrace;

  @override
  ValueWrapper<T> get valueWrapper;
}

/// Convert this [Stream] to a [DistinctValueStream].
extension AsDistinctValueStreamExtension<T> on Stream<T> {
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
  DistinctValueStream<T> distinctValue(
    T value, {
    bool Function(T p1, T p2)? equals,
  }) =>
      _DistinctValueStream(this, value, equals);
}

/// Default implementation of [DistinctValueStream].
/// This stream acts like [Stream.distinct] except it provides seed value
/// used to check for equality, and synchronous access to the last emitted item.
///
/// Data events are skipped if they are equal to the previous data event.
/// Equality is determined by the provided [equals] method. If that is omitted,
/// the '==' operator on the last provided data element is used.
///
/// This stream is a single-subscription stream.
class _DistinctValueStream<T> extends Stream<T>
    implements DistinctValueStream<T> {
  @override
  final bool Function(T p1, T p2) equals;

  final ValueStreamController<T> controller;

  @override
  bool get isBroadcast => false;

  /// Construct a [_DistinctValueStream] with source stream, seed value.
  _DistinctValueStream(
    Stream<T> source,
    T value,
    bool Function(T, T)? equals,
  )   : equals = equals ?? DistinctValueStream.defaultEquals,
        controller = ValueStreamController<T>(value, sync: true) {
    late StreamSubscription<T> subscription;

    controller.onListen = () {
      subscription = source.listen(
        (data) {
          if (!this.equals(valueWrapper.value, data)) {
            controller.add(data);
          }
        },
        onError: controller.addError,
        onDone: controller.close,
      );

      if (!source.isBroadcast) {
        controller.onPause = subscription.pause;
        controller.onResume = subscription.resume;
      }
    };
    controller.onCancel = () => subscription.cancel();
  }

  @override
  Never get errorAndStackTrace =>
      throw StateError('_DistinctValueStream always has no error!');

  @override
  ValueWrapper<T> get valueWrapper => controller.stream.valueWrapper!;

  @override
  StreamSubscription<T> listen(
    void Function(T event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) =>
      controller.stream.listen(
        onData,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      );
}
