# distinct_value_connectable_stream <img src="https://avatars3.githubusercontent.com/u/6407041?s=200&v=4" width="32">

# **DEPRECATED**. This package is now merged into [rxdart_ext](https://pub.dev/packages/rxdart_ext) package. Please use [rxdart_ext](https://pub.dev/packages/rxdart_ext) package for the same purpose, thanks.

-   `Distinct` & `Connectable` & `ValueStream` RxDart Stream.
-   Useful for flutter `BLoC pattern` - `StreamBuilder`.

## Author: [Petrus Nguyễn Thái Học](https://github.com/hoc081098)

[![Build Status](https://travis-ci.com/hoc081098/distinct_value_connectable_stream.svg?branch=master)](https://travis-ci.com/hoc081098/distinct_value_connectable_stream)
[![Pub](https://img.shields.io/pub/v/distinct_value_connectable_stream.svg)](https://pub.dev/packages/distinct_value_connectable_stream)
[![codecov](https://codecov.io/gh/hoc081098/distinct_value_connectable_stream/branch/master/graph/badge.svg?token=L0jTkGFCfz)](https://codecov.io/gh/hoc081098/distinct_value_connectable_stream)

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

## API

- Broadcast
    - [DistinctValueSubject](https://pub.dev/documentation/distinct_value_connectable_stream/1.2.0/distinct_value_connectable_stream/DistinctValueSubject-class.html)
    - [DistinctValueConnectableStream](https://pub.dev/documentation/distinct_value_connectable_stream/1.2.0/distinct_value_connectable_stream/DistinctValueConnectableStream-class.html)
    - [publishValueDistinct](https://pub.dev/documentation/distinct_value_connectable_stream/1.2.0/distinct_value_connectable_stream/DistinctValueConnectableExtensions/publishValueDistinct.html)
    - [shareValueDistinct](https://pub.dev/documentation/distinct_value_connectable_stream/1.2.0/distinct_value_connectable_stream/DistinctValueConnectableExtensions/shareValueDistinct.html)

- Single-subscription:
    - [distinctValue](https://pub.dev/documentation/distinct_value_connectable_stream/1.2.0/distinct_value_connectable_stream/DistinctValueStreamExtensions/distinctValue.html)

- Single-subscription `DistinctValueStream` to broadcast `DistinctValueStream`
    - [asDistinctValueConnectableStream](https://pub.dev/documentation/distinct_value_connectable_stream/1.2.0/distinct_value_connectable_stream/BroadcastDistinctValueStreamExtensions/asDistinctValueConnectableStream.html)
    - [asBroadcastDistinctValueStream](https://pub.dev/documentation/distinct_value_connectable_stream/1.2.0/distinct_value_connectable_stream/BroadcastDistinctValueStreamExtensions/asBroadcastDistinctValueStream.html)

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

final distinctState$ = state$.publishValueDistinct(UiState.initial());
distinctState$.connect();

StreamBuilder<UiState>(
  initialData: distinctState$.value,
  stream: distinctState$,
  builder: (context, snapshot) {
    final UiState state = snapshot.requireData;
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
