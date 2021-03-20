import 'package:distinct_value_connectable_stream/distinct_value_connectable_stream.dart';
import 'package:test/test.dart';

void main() {
  group(
    'Single-subscription DistinctValueStream to broadcast DistinctValueStream',
    () {
      test('shareValueDistinct', () {
        final stream = Stream.fromIterable([0, 1, 1, 2, 3, 4, 4])
            .distinctValue(0)
            .shareValueDistinct();

        expect(stream.value, 0);
        expect(stream.isBroadcast, true);

        expect(stream, emitsInOrder(<Object>[1, 2, 3, 4]));
        expect(stream, emitsInOrder(<Object>[1, 2, 3, 4]));
      });
    },
  );
}
