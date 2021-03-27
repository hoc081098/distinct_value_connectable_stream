import 'package:distinct_value_connectable_stream/distinct_value_connectable_stream.dart';
import 'package:test/test.dart';

void main() {
  group('DistinctValueSubject', () {
    test('add and close', () {
      {
        final s = DistinctValueSubject(0);
        expect(s, emitsInOrder(<Object>[1, 2, emitsDone]));

        s.add(0);
        s.add(1);
        s.add(1);
        s.add(2);
        s.add(2);
        s.add(2);

        s.close();
      }

      {
        final s = DistinctValueSubject(0);
        expect(s, emitsInOrder(<Object>[1, 3, 1, 2, emitsDone]));

        s.add(1);
        s.add(3);
        s.add(3);
        s.add(1);
        s.add(2);

        s.close();
      }
    });

    test('addError', () {
      final s = DistinctValueSubject(0);
      expect(() => s.addError(0), throwsStateError);
    });

    test('addStream', () async {
      {
        final s = DistinctValueSubject(0);
        expect(s, emitsDone);

        await s.addStream(Stream.value(0));
        await s.close();
      }

      {
        final s = DistinctValueSubject(0);
        expect(s, emitsInOrder(<Object>[1, 2, 3, 4, emitsDone]));

        await s.addStream(Stream.fromIterable([0, 1, 1, 2, 3, 4]));
        await s.close();
      }
    });
  });
}
