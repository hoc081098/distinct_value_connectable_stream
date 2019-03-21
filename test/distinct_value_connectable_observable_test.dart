import 'package:distinct_value_connectable_observable/distinct_value_connectable_observable.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

class MockStream<T> extends Mock implements Stream<T> {}

void main() {
  group('BehaviorConnectableObservable', () {
    test('should not emit before connecting', () {
      final stream = MockStream<int>();
      final observable = DistinctValueConnectableObservable(stream);

      when(stream.listen(any, onError: anyNamed('onError')))
          .thenReturn(new Stream.fromIterable(const [1, 2, 3]).listen(null));

      verifyNever(stream.listen(any, onError: anyNamed('onError')));

      observable.connect();

      verify(stream.listen(any, onError: anyNamed('onError')));
    });

    test('should begin emitting items after connection', () {
      var count = 0;
      const items = [1, 2, 3];
      final observable =
          DistinctValueConnectableObservable(Stream.fromIterable(items));

      observable.connect();

      expect(observable, emitsInOrder(items));
      observable.listen(expectAsync1((i) {
        expect(observable.value, items[count]);
        count++;
      }, count: items.length));
    });

    test('stops emitting after the connection is cancelled', () async {
      final observable = DistinctValueConnectableObservable(
        Observable.fromIterable(const [1, 2, 3]),
      );

      observable.connect()..cancel(); // ignore: unawaited_futures

      expect(observable, neverEmits(anything));
    });

    test('stops emitting after the last subscriber unsubscribes', () async {
      final observable = DistinctValueConnectableObservable(
        Observable.fromIterable(const [1, 2, 3]),
      ).refCount();

      observable.listen(null)..cancel(); // ignore: unawaited_futures

      expect(observable, neverEmits(anything));
    });

    test('keeps emitting with an active subscription', () async {
      final observable = DistinctValueConnectableObservable(
        Observable.fromIterable(const [1, 2, 3]),
      ).refCount();

      observable.listen(null);
      observable.listen(null)..cancel(); // ignore: unawaited_futures

      expect(observable, emitsInOrder(const <int>[1, 2, 3]));
    });

    test('multicasts a single-subscription stream', () async {
      final observable = new DistinctValueConnectableObservable(
        Stream.fromIterable(const [1, 2, 3]),
      ).autoConnect();

      expect(observable, emitsInOrder(const <int>[1, 2, 3]));
      expect(observable, emitsInOrder(const <int>[1, 2, 3]));
      expect(observable, emitsInOrder(const <int>[1, 2, 3]));
    });

    test('replays the latest item', () async {
      final observable = new DistinctValueConnectableObservable(
        Stream.fromIterable(const [1, 2, 3]),
      ).autoConnect();

      expect(observable, emitsInOrder(const <int>[1, 2, 3]));
      expect(observable, emitsInOrder(const <int>[1, 2, 3]));
      expect(observable, emitsInOrder(const <int>[1, 2, 3]));

      await Future<Null>.delayed(Duration(milliseconds: 200));

      expect(observable, emits(3));
    });

    test('can multicast observables', () async {
      final observable = DistinctValueConnectableObservable(
        Observable.fromIterable(const [1, 2, 3]),
      ).refCount();

      expect(observable, emitsInOrder(const <int>[1, 2, 3]));
      expect(observable, emitsInOrder(const <int>[1, 2, 3]));
      expect(observable, emitsInOrder(const <int>[1, 2, 3]));
    });

    test('transform Observables with initial value', () async {
      final observable = DistinctValueConnectableObservable.seeded(
        Observable.fromIterable(const [1, 2, 3]),
        seedValue: 0,
      ).refCount();

      expect(observable.value, 0);
      expect(observable, emitsInOrder(const <int>[0, 1, 2, 3]));
    });

    test('provides access to the latest value', () async {
      const items = [1, 2, 3];
      var count = 0;
      final observable = DistinctValueConnectableObservable(
        Observable.fromIterable(const [1, 2, 3]),
      ).refCount();

      observable.listen(expectAsync1((data) {
        expect(data, items[count]);
        count++;
        if (count == items.length) {
          expect(observable.value, 3);
        }
      }, count: items.length));
    });

    test('provide a function to autoconnect that stops listening', () async {
      final observable = DistinctValueConnectableObservable(
        Observable.fromIterable(const [1, 2, 3]),
      ).autoConnect(connection: (subscription) => subscription.cancel());

      expect(observable, neverEmits(anything));
    });

    test('distinct until changed', () async {
      const expected = 1;

      final observable = DistinctValueConnectableObservable.seeded(
        Observable.fromIterable(const [expected, expected]),
        seedValue: 1,
      ).refCount();

      observable.listen(expectAsync1((actual) {
        expect(actual, expected);
      }));
    });

    test('distinct until changed with custom equals function', () async {
      const expected1 = [1, 2, 3];
      const expected2 = [1, 1, 4];

      final observable = DistinctValueConnectableObservable.seeded(
        Observable.fromIterable(
          const [expected1, expected2, expected1],
        ),
        seedValue: expected2,
        equals: (List<int> prev, List<int> cur) {
          return prev.reduce((acc, e) => acc + e) ==
              cur.reduce((acc, e) => acc + e);
        },
      ).refCount();

      observable.listen(expectAsync1((actual) {
        expect(actual, expected2);
      }));
    });
  });
}
