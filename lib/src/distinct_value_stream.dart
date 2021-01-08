import 'package:rxdart_ext/rxdart_ext.dart'
    show NotReplayValueStream, ValueWrapper;

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
