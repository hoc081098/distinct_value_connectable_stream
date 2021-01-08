## 1.2.0-nullsafety.2 - Jan 9, 2021

-   **Breaking change**: Any errors from upstream and from `equals` callback will be not added to Stream.
    They are considered unhandled, and will be passed to the current `Zone`'s error handler.
    By default, unhandled async errors are treated as if they were uncaught top-level errors.

## 1.2.0-nullsafety.1 - Jan 8, 2021

-   Update README.md.

## 1.2.0-nullsafety.0 - Jan 8, 2021

-   Migrate this package to null safety.
-   Sdk constraints: >=2.12.0-0 <3.0.0 based on beta release guidelines.
-   Depends on [rxdart_ext](https://pub.dev/packages/rxdart_ext).

## 1.2.0-beta02 - Dec 7, 2020

-   Updated `rxdart: ^0.25.0`.

## 1.2.0-beta01 - Oct 18, 2020

-   Introduce `ValueSubject` same as `PublishSubject`, with the ability to capture the latest item has been added to the controller.
-   Rewrite `DistinctValueConnectableStream`: now will not replay the latest data or error, `value` getter instead.
    This is more consistent to `StreamBuilder.initialData` in `Flutter`.

-   `Extension methods`: removed `publishValueSeededDistinct` and `shareValueSeededDistinct`. 
    Add to `publishValueDistinct` and `shareValueDistinct` a required parameter `T seedValue`. 
    This is more consistent to `StreamBuilder.initialData` in `Flutter`.
    
-   Added `DistinctValueStream`: It's also `ValueStream` but emphasizes that two consecutive values are not equal 
    (Equality is determined by `equals` method).
    
-   Note that this is a beta release, mainly because the behavior of `DistinctValueConnectableStream` has been adjusted. 
    If all goes well, we'll release a proper 1.2.0 release soon.

## 1.1.1 - Apr 27, 2020

-   Minor updates.

## 1.1.0 - Apr 23, 2020

-   Breaking change: support for `rxdart` 0.24.x.

## 1.0.3+1 - Jan 14, 2020

-   Fix analysis

## 1.0.3 - Dec 15, 2019

-   Fix README.md

## 1.0.2 - Dec 15, 2019

-   Fix README.md

## 1.0.1 - Dec 15, 2019

-   Fix README.md

## 1.0.0 - Dec 15, 2019

-   Publish
