import 'dart:async';

import 'package:distinct_value_connectable_stream/distinct_value_connectable_stream.dart';
import 'package:rxdart_ext/rxdart_ext.dart';
import 'package:test/test.dart';

void main() {
  group('distinctValue return a DistinctValueStream', () {
    test('allows access to latest value', () {
      final controller = StreamController<int>(sync: true);
      final stream = controller.stream.distinctValue(0)..collect();
      expect(stream.value, 0);

      for (var i = 0; i < 10; i++) {
        controller.add(i);
        expect(stream.value, i);
        expect(stream.error, isNull);
      }
    });

    test('distinct until changed', () {
      {
        final stream =
            Stream.fromIterable([1, 2, 2, 3, 3, 4, 5, 6, 7]).distinctValue(1);

        expect(
          stream,
          emitsInOrder(<Object>[
            2,
            3,
            4,
            5,
            6,
            7,
            emitsDone,
          ]),
        );
      }

      {
        final stream =
            Stream.fromIterable([1, 2, 2, 3, 3, 4, 5, 6, 7]).distinctValue(2);

        expect(
          stream,
          emitsInOrder(<Object>[
            1,
            2,
            3,
            4,
            5,
            6,
            7,
            emitsDone,
          ]),
        );
      }
    });

    test('does not handle error', () async {
      await runZonedGuarded(
        () => Stream<int>.error(Exception())
            .distinctValue(0)
            .collect()
            .asFuture<void>(),
        (e, s) => expect(e, isException),
      );
    });

    test('is single-subscription Stream', () {
      final stream = Stream.value(1).distinctValue(0);
      expect(stream.isBroadcast, isFalse);

      stream.collect();
      expect(() => stream.collect(), throwsStateError);
    });

    test('asBroadcastStream', () {
      final broadcastStream =
          Stream.value(1).distinctValue(0).asBroadcastStream();

      broadcastStream.collect();
      broadcastStream.collect();

      expect(true, isTrue);
    });

    test('pause resume', () {
      {
        final stream = Stream.value(1).distinctValue(0);

        final subscription = stream.listen(null);
        subscription.onData(
          expectAsync1(
            (data) {
              expect(data, 1);
              subscription.cancel();
            },
            count: 1,
          ),
        );

        subscription.pause();
        subscription.resume();
      }

      {
        final stream = Stream.value(1).distinctValue(1);

        final subscription = stream.listen(null);
        subscription.onData(expectAsync1((_) {}, count: 0));
        subscription.onDone(expectAsync0(() {}, count: 1));

        subscription.pause();
        subscription.resume();
      }
    });

    test('extensions', () {
      final distinctValue = Stream.value(1).distinctValue(0);
      expect(distinctValue.hasValue, true);
      expect(distinctValue.value, 0);
      expect(distinctValue.requireValue, 0);

      expect(distinctValue.hasError, false);
      expect(distinctValue.error, null);
      expect(() => distinctValue.requireError, throwsStateError);
    });
  });
}
