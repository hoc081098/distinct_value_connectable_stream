# distinct_value_connectable_stream <img src="https://avatars3.githubusercontent.com/u/6407041?s=200&v=4" width="32">

-   `Distinct` & `Connectable` & `ValueStream` RxDart Stream.
-   Useful for flutter `BLoC pattern` - `StreamBuilder`.

------

-   [x] `Distinct`: distinct until changed.
-   [x] `Value`: can synchronous access to the last emitted item.
-   [x] `NotReplay`: not replay the latest value.
-   [x] `Connectable`: broadcast stream - can be listened to multiple time.

```
                                Stream (dart:core)
                                   ^
                                   |
                                   |
            |--------------------------------------------|
            |                                            |
            |                                            |
        ValueStream (rxdart)                             |
            ^                                            |
            |                                            |
            |                                            |
    NotReplayValueStream (rxdart_ext)                    |
            ^                                    ConnectableStream (rxdart)
            |                                            ^
            |                                            |
    DistinctValueStream (this package)                   |
            ^                                            |
            |                                            |
            |------------                     -----------|
                        |                     |
                        |                     |
                     DistinctValueConnectableStream (this package)
```

## Author: [Petrus Nguyễn Thái Học](https://github.com/hoc081098)

[![Build Status](https://travis-ci.com/hoc081098/distinct_value_connectable_stream.svg?branch=master)](https://travis-ci.com/hoc081098/distinct_value_connectable_stream)
[![Pub](https://img.shields.io/pub/v/distinct_value_connectable_stream.svg)](https://pub.dev/packages/distinct_value_connectable_stream)

[comment]: <> (## Implement BLoC)

[comment]: <> ( ### Without using package)
 
[comment]: <> ( <p align="center">)

[comment]: <> (    <img src="https://github.com/hoc081098/distinct_value_connectable_stream/raw/master/bloc1.png" width="480"/>)

[comment]: <> ( </p>)
 
[comment]: <> ( ### Using package)
  
[comment]: <> ( <p align="center">)

[comment]: <> (    <img src="https://github.com/hoc081098/distinct_value_connectable_stream/raw/master/bloc2.png" width="480"/>)

[comment]: <> ( </p>)

## Usage

```dart
import 'package:distinct_value_connectable_stream/distinct_value_connectable_stream.dart';
```

```dart
class UiState { ... }

final Stream<UiState> state$ = ...;

final distinctState$ = state$.publishValueDistinct();
distinctState$.connect();

StreamBuilder<UiState>(
  initialData: distinctState$.value,
  stream: distinctState$,
  builder: (context, snapshot) {
    final UiState state = snapshot.data;
    return ...;
  },
);
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/hoc081098/distinct_value_connectable_stream/issues

License
-------
    MIT License

    Copyright (c) 2020 Petrus Nguyễn Thái Học
