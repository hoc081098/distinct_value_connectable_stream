import 'package:distinct_value_connectable_stream/distinct_value_connectable_stream.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class MockStream<T> extends Mock implements Stream<T> {}

void main() {
  group('DistinctValueConnectableStream', () {
    test('should not emit before connecting', () {
      final stream = MockStream<int>();
      final distinctStream = DistinctValueConnectableStream(stream);

      when(stream.listen(any, onError: anyNamed('onError')))
          .thenReturn(Stream.fromIterable(const [1, 2, 3]).listen(null));

      verifyNever(stream.listen(any, onError: anyNamed('onError')));

      distinctStream.connect();

      verify(stream.listen(any, onError: anyNamed('onError')));
    });

    test('should begin emitting items after connection', () {
      var count = 0;
      const items = [1, 2, 3];
      final stream = DistinctValueConnectableStream(Stream.fromIterable(items));

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
      );

      stream.connect()..cancel(); // ignore: unawaited_futures

      expect(stream, neverEmits(anything));
    });

    test('stops emitting after the last subscriber unsubscribes', () async {
      final stream = DistinctValueConnectableStream(
        Stream.fromIterable(const [1, 2, 3]),
      ).refCount();

      stream.listen(null)..cancel(); // ignore: unawaited_futures

      expect(stream, neverEmits(anything));
    });

    test('keeps emitting with an active subscription', () async {
      final stream = DistinctValueConnectableStream(
        Stream.fromIterable(const [1, 2, 3]),
      ).refCount();

      stream.listen(null);
      stream.listen(null)..cancel(); // ignore: unawaited_futures

      expect(stream, emitsInOrder(const <int>[1, 2, 3]));
    });

    test('multicasts a single-subscription stream', () async {
      final stream = DistinctValueConnectableStream(
        Stream.fromIterable(const [1, 2, 3]),
      ).autoConnect();

      expect(stream, emitsInOrder(const <int>[1, 2, 3]));
      expect(stream, emitsInOrder(const <int>[1, 2, 3]));
      expect(stream, emitsInOrder(const <int>[1, 2, 3]));
    });

    test('replays the latest item', () async {
      final stream = DistinctValueConnectableStream(
        Stream.fromIterable(const [1, 2, 3]),
      ).autoConnect();

      expect(stream, emitsInOrder(const <int>[1, 2, 3]));
      expect(stream, emitsInOrder(const <int>[1, 2, 3]));
      expect(stream, emitsInOrder(const <int>[1, 2, 3]));

      await Future<Null>.delayed(Duration(milliseconds: 200));

      expect(stream, emits(3));
    });

    test('can multicast streams', () async {
      final stream = DistinctValueConnectableStream(
        Stream.fromIterable(const [1, 2, 3]),
      ).refCount();

      expect(stream, emitsInOrder(const <int>[1, 2, 3]));
      expect(stream, emitsInOrder(const <int>[1, 2, 3]));
      expect(stream, emitsInOrder(const <int>[1, 2, 3]));
    });

    test('transform streams with initial value', () async {
      final stream = DistinctValueConnectableStream.seeded(
        Stream.fromIterable(const [1, 2, 3]),
        seedValue: 0,
      ).refCount();

      expect(stream.value, 0);
      expect(stream, emitsInOrder(const <int>[0, 1, 2, 3]));
    });

    test('provides access to the latest value', () async {
      const items = [1, 2, 3];
      var count = 0;
      final stream = DistinctValueConnectableStream(
        Stream.fromIterable(const [1, 2, 3]),
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
      ).autoConnect(connection: (subscription) => subscription.cancel());

      expect(stream, neverEmits(anything));
    });

    test('distinct until changed', () async {
      const expected = 1;

      final stream = DistinctValueConnectableStream.seeded(
        Stream.fromIterable(const [expected, expected]),
        seedValue: 1,
      ).refCount();

      stream.listen(expectAsync1((actual) {
        expect(actual, expected);
      }));
    });

    test('distinct until changed with custom equals function', () async {
      const expected1 = [1, 2, 3];
      const expected2 = [1, 1, 4];

      final stream = DistinctValueConnectableStream.seeded(
        Stream.fromIterable(
          const [expected1, expected2, expected1],
        ),
        seedValue: expected2,
        equals: (List<int> prev, List<int> cur) {
          return prev.reduce((acc, e) => acc + e) ==
              cur.reduce((acc, e) => acc + e);
        },
      ).refCount();

      stream.listen(expectAsync1((actual) {
        expect(actual, expected2);
      }));
    });
  });
}
