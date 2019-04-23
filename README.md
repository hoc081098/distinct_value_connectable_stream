# distinct_value_connectable_observable
Distinct & Connectable & ValueObservable RxDart

[![Build Status](https://travis-ci.org/hoc081098/distinct_value_connectable_observable.svg?branch=master)](https://travis-ci.org/hoc081098/distinct_value_connectable_observable) 
<img alt="Pub" src="https://img.shields.io/pub/v/distinct_value_connectable_observable.svg"> <br>

Dart package: https://pub.dartlang.org/packages/distinct_value_connectable_observable.

Useful for flutter BLoC pattern, expose state stream to UI, can synchronous access to the last emitted item, and distinct until changed

A library for Dart developers.
Created from templates made available by Stagehand under a BSD-style
[license](https://github.com/dart-lang/stagehand/blob/master/LICENSE).

## Usage

A simple usage example:

```dart
import 'package:distinct_value_connectable_observable/distinct_value_connectable_observable.dart';

main() {
  DistinctValueConnectableObservable(
      Stream.fromIterable([1, 2, 3]),
      seedValue: [1],
  );
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/hoc081098/distinct_value_connectable_observable/issues
