
import 'package:distinct_value_connectable_stream/distinct_value_connectable_stream.dart';
import 'package:rxdart/rxdart.dart';
void main() async{
  final valueSubject = ValueSubject(1, sync: true);

  valueSubject
      .flatMap((value) => Stream.value(value))
      .listen(print);

  valueSubject.add(2);
  valueSubject.add(3);

  await Future<void>.delayed(const Duration(seconds: 1));
}