## 0.1.9

* Increased version range for `device_info_plus`.
* Added some missing `MediaQuery` properties.
* Fixed Dart (`>=3.4.0`) and Flutter (`>=3.22.0`) versions to reflect the actual constraints.
* Enabled trimming of stack traces in log view.
* Added pub.dev `topics`.

## 0.1.8

* Increased version range for `device_info_plus`.

## 0.1.7

* Further increased upper version range for `package_info_plus`. Thanks to
  @hakonber ([#5](https://github.com/Bungeefan/flutter_debug_overlay/issues/5)).

## 0.1.6

* Increased upper version range for `package_info_plus`.
* Replaced `textScaleFactor` usages with `textScaler`.

## 0.1.5

* Fixed LICENSE detection.
* Added filter to search logs and requests.
* Added entry highlighting for selected logs and requests.
* Added PageStorage to persist scroll positions.
* Improved formatting of request duration.
* Improved and documented usages of AutomaticKeepAliveClientMixins.
* Removed deprecated `describeEnum` usages.

## 0.1.4

* Added examples for log sources and HTTP integrations.
* Example: Fixed missing dispose.
* Example: Upgraded dependencies.

## 0.1.3

* Adopted more common LogLevel names.

## 0.1.2

* Added proper response parsing via content-type and charset.
* Use `SelectionArea` instead of `SelectableText` for Info tab.
* Bumped Flutter SDK to `3.10.0`.
* Upgraded http to `1.0.0`.

## 0.1.1

* Upgraded package_info_plus to `4.0.0`.
* Upgraded device_info_plus to `9.0.0`.

## 0.1.0+1

* Changed sdk constraint to `2.18.0`.

## 0.1.0

* Replaced the `enableOnlyInDebugMode` constructor parameter with a static `enabled` field to
  further improve performance when disabled.
* Added KeepAlive to Info page to prevent frequent re-evaluations.

## 0.0.1+2

* Further fixed "setState() or markNeedsBuild() called during build" errors.

## 0.0.1+1

* Fixed pub.dev platforms.
* Fixed "setState() or markNeedsBuild() called during build".

## 0.0.1

* Initial release.
