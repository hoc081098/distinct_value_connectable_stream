# distinct_value_connectable_stream <img src="https://avatars3.githubusercontent.com/u/6407041?s=200&v=4" width="32">
- `Distinct` & `Connectable` & `ValueStream` rxdart
- Useful for flutter BLoC pattern, expose broadcast state stream to UI, can synchronous access to the last emitted item, and distinct until changed

## Author: [Petrus Nguyễn Thái Học](https://github.com/hoc081098)

[![Build Status](https://travis-ci.org/hoc081098/distinct_value_connectable_stream.svg?branch=master)](https://travis-ci.org/hoc081098/distinct_value_connectable_stream)
[![Pub](https://img.shields.io/pub/v/distinct_value_connectable_stream.svg)](https://pub.dartlang.org/packages/distinct_value_connectable_stream)

## Implement BLoC

 ### Without using package
 
 <p align="center">
    <img src="https://raw.githubusercontent.com/hoc081098/hoc081098.github.io/master/distinct_value_connectable_stream/carbon%20(18).png" height="512"/>
 </p>
 
 ### Using package
  
 <p align="center">
    <img src="https://github.com/hoc081098/hoc081098.github.io/raw/master/distinct_value_connectable_stream/carbon%20(19).png" height="512"/>
 </p>

## Usage

Import `distinct_value_connectable_stream`:

```dart
import 'package:distinct_value_connectable_stream/distinct_value_connectable_stream.dart';
```

### 1. Constructor based

Wrap your `Stream` in a `DistinctValueConnectableStream` using `constructor`:

```dart
final Stream<State> state$;
final distinct$ = DistinctValueConnectableStream(state$);
final distinctSeeded$ = DistinctValueConnectableStream.seeded(
  state$,
  seedValue: State.initial(),
);
```

You can pass `equals` parameter type `bool Function(T, T)` to `constructor`, used to determined equality (default is `operator ==`):

```dart
final Stream<State> state$;
final bool Function(State, State) isEquals;

final distinct$ = DistinctValueConnectableStream.seeded(
  state$,
  seedValue: State.initial(),
  equals: isEquals,
);
```

### 2. Extension method based

```dart
final source$ = Stream.fromIterable([1, 2, 2, 3, 3, 3]);

// publish
final connectable$       = source$.publishValueDistinct();
final connectableSeeded$ = source$.publishValueSeededDistinct(seedValue: 0);

// share
final shared$            = source$.shareValueDistinct();
final sharedSeeded$      = source$.shareValueSeededDistinct(seedValue: 0);
```

All extension methods have optional parameter `equals` type `bool Function(T, T)` like constructor based

```dart
final source$ = Stream.fromIterable([1, 2, 2, 3, 3, 3]);
final connectable$ = source$.publishValueDistinct();

// Does not print anything at first
connectable$.listen(print);

// Start listening to the source Stream. Will cause the previous
// line to start printing 1, 2, 3
final subscription = connectable$.connect();

// Late subscribers will receive the last emitted value
connectable$.listen(print); // Prints 3

// Can access the latest emitted value synchronously. Prints 3
print(connectable$.value);

// Stop emitting items from the source stream and close the underlying
// BehaviorSubject
await subscription.cancel();
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/hoc081098/distinct_value_connectable_stream/issues

License
-------
    MIT License

    Copyright (c) 2019 Petrus Nguyễn Thái Học

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
