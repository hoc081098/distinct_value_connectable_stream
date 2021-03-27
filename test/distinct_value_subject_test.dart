import 'dart:async';

import 'package:distinct_value_connectable_stream/distinct_value_connectable_stream.dart';
import 'package:rxdart_ext/rxdart_ext.dart';
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

      {
        final s = DistinctValueSubject(0);
        expect(s, emitsInOrder(<Object>[2, 1, 2, 3, 4, emitsDone]));

        s.add(2);
        await s.addStream(Stream.fromIterable([2, 1, 1, 2, 3, 4]));
        await s.close();
      }

      {
        final s = DistinctValueSubject(0);

        await runZonedGuarded(
          () => s.addStream(Stream.error(Exception())),
          (e, s) => expect(e, isA<StateError>()),
        );
      }
    });

    test('Rx', () {
      {
        final s = DistinctValueSubject(0);
        expect(
          s.flatMap((value) => Stream.value(value)),
          emitsInOrder(<Object>[1, 2, 3]),
        );

        s.add(1);
        s.add(2);
        s.add(3);
      }

      {
        final s = DistinctValueSubject(0, sync: true);
        expect(
          s.flatMap((value) => Stream.value(value)),
          emitsInOrder(<Object>[1, 2, 3]),
        );

        s.add(1);
        s.add(2);
        s.add(3);
      }
    });
  });
}
