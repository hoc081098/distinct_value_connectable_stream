import 'dart:async';

import 'package:distinct_value_connectable_stream/distinct_value_connectable_stream.dart';
import 'package:rxdart/rxdart.dart';

class CounterBloc {
  /// Inputs
  final void Function(int) increment;
  final void Function(int) decrement;

  /// Outputs
  final DistinctValueStream<int> state$;

  /// Clean up
  final void Function() dispose;

  CounterBloc._({
    required this.increment,
    required this.decrement,
    required this.state$,
    required this.dispose,
  });

  factory CounterBloc() {
    final incrementController = StreamController<int>();
    final decrementController = StreamController<int>();

    final streams = [
      incrementController.stream,
      decrementController.stream.map((i) => -i),
    ];
    final state$ = Rx.merge(streams)
        .scan<int>((acc, e, _) => acc + e, 0)
        .publishValueDistinct(0);

    final subscription = state$.connect();
    return CounterBloc._(
      increment: incrementController.add,
      decrement: decrementController.add,
      state$: state$,
      dispose: () async {
        await subscription.cancel();
        await Future.wait<void>([
          incrementController.close(),
          decrementController.close(),
        ]);
      },
    );
  }
}

void main() async {
  final counterBloc = CounterBloc();

  print('[LOGGER] state=${counterBloc.state$.value}');
  final listen1 =
      counterBloc.state$.listen((i) => print('[LOGGER 1] state=$i'));
  final listen2 =
      counterBloc.state$.listen((i) => print('[LOGGER 2] state=$i'));

  counterBloc
    ..increment(0)
    ..increment(2)
    ..decrement(2)
    ..decrement(2)
    ..decrement(2)
    ..increment(2)
    ..increment(2)
    ..increment(0)
    ..increment(0)
    ..increment(0)
    ..increment(0)
    ..increment(0);

  await Future<void>.delayed(Duration(seconds: 1));
  print(counterBloc.state$.value);

  await listen1.cancel();
  await listen2.cancel();
  counterBloc.dispose();
}
