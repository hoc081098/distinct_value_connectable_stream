import 'package:distinct_value_connectable_stream/distinct_value_connectable_stream.dart';
import 'package:test/test.dart';

void main() {
  final elements = [0, 1, 1, 2, 3, 4, 4];
  final expected = <Object>[1, 2, 3, 4, emitsDone];

  group('To broadcast DistinctValueStream', () {
    group('asBroadcastDistinctValueStream', () {
      Future<void> _test(DistinctValueStream<int> stream) async {
        expect(stream.value, 0);
        expect(stream.isBroadcast, true);

        expect(stream, emitsInOrder(expected));
        await expectLater(stream, emitsInOrder(expected));

        expect(stream, emitsDone);
      }

      test('Single-Subscription', () async {
        final stream = Stream.fromIterable(elements)
            .distinctValue(0)
            .asBroadcastDistinctValueStream();

        await _test(stream);
      });

      test('Broadcast', () async {
        final source = Stream.fromIterable(elements).shareValueDistinct(0);
        final stream = source.asBroadcastDistinctValueStream();

        expect(identical(stream, source), true);
        await _test(stream);
      });
    });

    group('asDistinctValueConnectableStream', () {
      Future<void> _test(DistinctValueConnectableStream<int> stream) async {
        expect(stream.value, 0);
        expect(stream.isBroadcast, true);

        stream.connect();

        expect(stream, emitsInOrder(expected));
        await expectLater(stream, emitsInOrder(expected));

        expect(stream, emitsDone);
      }

      test('Single-Subscription', () async {
        final stream = Stream.fromIterable(elements)
            .distinctValue(0)
            .asDistinctValueConnectableStream();

        await _test(stream);
      });

      test('Broadcast', () async {
        final source = Stream.fromIterable(elements).publishValueDistinct(0);
        final stream = source.asDistinctValueConnectableStream();

        expect(identical(stream, source), true);
        await _test(stream);
      });
    });
  });
}
