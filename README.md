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

[tracker]: http://example.com/issues/replaceme
