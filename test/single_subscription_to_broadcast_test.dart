import 'package:distinct_value_connectable_stream/distinct_value_connectable_stream.dart';
import 'package:test/test.dart';

void main() {
  group(
    'Single-subscription DistinctValueStream to broadcast DistinctValueStream',
    () {
      Future<void> _test(DistinctValueStream<int> stream) async {
        expect(stream.value, 0);
        expect(stream.isBroadcast, true);

        expect(stream, emitsInOrder(<Object>[1, 2, 3, 4, emitsDone]));
        await expectLater(
            stream, emitsInOrder(<Object>[1, 2, 3, 4, emitsDone]));

        expect(stream, emitsDone);
      }

      test('SingleSubscription.asBroadcastDistinctValueStream', () async {
        final stream = Stream.fromIterable([0, 1, 1, 2, 3, 4, 4])
            .distinctValue(0)
            .asBroadcastDistinctValueStream();

        await _test(stream);
      });

      test('Broadcast.asBroadcastDistinctValueStream', () async {
        final source =
            Stream.fromIterable([0, 1, 1, 2, 3, 4, 4]).shareValueDistinct(0);
        final stream = source.asBroadcastDistinctValueStream();

        expect(identical(stream, source), true);
        await _test(stream);
      });
    },
  );
}
