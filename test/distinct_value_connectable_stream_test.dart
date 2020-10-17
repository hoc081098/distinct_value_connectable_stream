import 'dart:async';

import 'package:distinct_value_connectable_stream/distinct_value_connectable_stream.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

class MockStream<T> extends Mock implements Stream<T> {}

void main() {
  group('DistinctValueConnectableStream', () {
    test('should not emit before connecting', () {
      final stream = MockStream<int>();
      when(stream.isBroadcast).thenReturn(true);
      when(stream.listen(any,
              onError: anyNamed('onError'), onDone: anyNamed('onDone')))
          .thenReturn(Stream.fromIterable(const [1, 2, 3]).listen(null));

      final distinctStream = DistinctValueConnectableStream(stream, null);

      verifyNever(stream.listen(any,
          onError: anyNamed('onError'), onDone: anyNamed('onDone')));

      distinctStream.connect();

      verify(stream.listen(any,
          onError: anyNamed('onError'), onDone: anyNamed('onDone')));
    });

    test('should begin emitting items after connection', () {
      var count = 0;
      const items = [1, 2, 3];
      final stream =
          DistinctValueConnectableStream(Stream.fromIterable(items), null);

      stream.connect();

      expect(stream, emitsInOrder(items));
      stream.listen(expectAsync1((i) {
        expect(stream.value, items[count]);
        count++;
      }, count: items.length));
    });

    test('stops emitting after the connection is cancelled', () async {
      final stream = DistinctValueConnectableStream(
        Stream.fromIterable(const [1, 2, 3]),
        null,
      );

      final subscription = stream.connect();
      await subscription.cancel();

      expect(stream, neverEmits(anything));
    });

    test('stops emitting after the last subscriber unsubscribes', () async {
      final stream = DistinctValueConnectableStream(
        Stream.fromIterable(const [1, 2, 3]),
        null,
      ).refCount();

      final subscription = stream.listen(null);
      await subscription.cancel();

      expect(stream, neverEmits(anything));
    });

    test('keeps emitting with an active subscription', () async {
      final stream = DistinctValueConnectableStream(
        Stream.fromIterable(const [1, 2, 3]),
        null,
      ).refCount();

      stream.listen(null);
      stream.listen(null)..cancel(); // ignore: unawaited_futures

      expect(stream, emitsInOrder(const <int>[1, 2, 3]));
    });

    test('multicasts a single-subscription stream', () async {
      final stream = DistinctValueConnectableStream(
        Stream.fromIterable(const [1, 2, 3]),
        null,
      ).autoConnect();

      expect(stream, emitsInOrder(const <int>[1, 2, 3]));
      expect(stream, emitsInOrder(const <int>[1, 2, 3]));
      expect(stream, emitsInOrder(const <int>[1, 2, 3]));
    });

    test('can multicast streams', () async {
      final stream = DistinctValueConnectableStream(
        Stream.fromIterable(const [1, 2, 3]),
        null,
      ).refCount();

      expect(stream, emitsInOrder(const <int>[1, 2, 3]));
      expect(stream, emitsInOrder(const <int>[1, 2, 3]));
      expect(stream, emitsInOrder(const <int>[1, 2, 3]));
    });

    test('transform streams with initial value', () async {
      final stream = DistinctValueConnectableStream(
        Stream.fromIterable(const [1, 2, 3]),
        0,
      ).refCount();

      expect(stream.value, 0);
      expect(stream, emitsInOrder(const <int>[1, 2, 3]));
    });

    test('provides access to the latest value', () async {
      const items = [1, 2, 3];
      var count = 0;
      final stream = DistinctValueConnectableStream(
        Stream.fromIterable(const [1, 2, 3]),
        null,
      ).refCount();

      stream.listen(expectAsync1((data) {
        expect(data, items[count]);
        count++;
        if (count == items.length) {
          expect(stream.value, 3);
        }
      }, count: items.length));
    });

    test('provide a function to autoconnect that stops listening', () async {
      final stream = DistinctValueConnectableStream(
        Stream.fromIterable(const [1, 2, 3]),
        null,
      ).autoConnect(connection: (subscription) => subscription.cancel());

      expect(stream, neverEmits(anything));
    });

    test('distinct until changed by default equals function', () async {
      const seedValue = 1;

      final stream = DistinctValueConnectableStream(
        Stream.fromIterable(const [seedValue, seedValue]),
        seedValue,
      ).refCount();

      var count = 0;
      stream.listen((_) => count++);

      await Future<void>.delayed(const Duration(seconds: 1));
      expect(count, 0);
      expect(stream.value, seedValue);
    });

    test('distinct until changed by custom equals function', () async {
      const values1 = [1, 2, 3];
      const values2 = [1, 1, 4];

      final stream = DistinctValueConnectableStream(
        Stream.fromIterable(const [values1, values2, values1]),
        values2,
        equals: _sumEquals,
      ).refCount();

      var count = 0;
      stream.listen((_) => count++);

      await Future<void>.delayed(Duration(seconds: 1));
      expect(count, 0);
      expect(stream.value, values2);
    });

    test('vs distinct().shareValue(), same behavior', () async {
      final matcher = emitsInOrder(const <int>[1, 2, 3, 4]);

      final shareValue = Stream.fromIterable([1, 1, 2, 2, 3, 3, 4, 4])
          .interval(const Duration(milliseconds: 200))
          .distinct()
          .shareValue();
      await expectLater(shareValue, matcher);

      final shareValueDistinct = Stream.fromIterable([1, 1, 2, 2, 3, 3, 4, 4])
          .interval(const Duration(milliseconds: 200))
          .shareValueDistinct(null);
      await expectLater(shareValueDistinct, matcher);
    });

    test('vs distinct().shareValueSeeded(...), different behavior', () async {
      final shareValueSeeded = Stream.fromIterable([1, 1, 2, 2, 3, 3, 4, 4])
          .interval(const Duration(milliseconds: 200))
          .distinct()
          .shareValueSeeded(1);
      await expectLater(
        shareValueSeeded,
        emitsInOrder(const <int>[1, 1, 2, 3, 4]),
      );

      final shareValueDistinct = Stream.fromIterable([1, 1, 2, 2, 3, 3, 4, 4])
          .interval(const Duration(milliseconds: 200))
          .shareValueDistinct(1);
      await expectLater(
        shareValueDistinct,
        emitsInOrder(const <int>[2, 3, 4]),
      );
    });
  });
}

bool _sumEquals(List<int> prev, List<int> cur) => prev.sum == cur.sum;

extension _Sum on Iterable<int> {
  int get sum => reduce((acc, e) => acc + e);
}
