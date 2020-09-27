import 'package:rxdart/streams.dart';

/// An [Stream] that provides synchronous access to the last emitted item,
/// and two consecutive values are not equal.
abstract class DistinctValueStream<T> extends ValueStream<T> {
  /// Determined equality between previous data event and current data event.
  bool Function(T, T) get equals;

  /// Use '==' operator on the last provided data element.
  static bool defaultEquals<T>(T lhs, T rhs) => lhs == rhs;
}
