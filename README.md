# Flutter Debug Overlay

The Flutter Debug Overlay package allows you to implement an overlay in your app for easy debugging,
even on devices away from any computer. It provides features like displaying logs in a sorted view,
inspecting logged HTTP requests with a JSON viewer, and supporting custom widgets for global actions
from anywhere in your app.

## Features

* **Global overlay**: The debug overlay can be used as a global overlay even above your app
  navigation.
* **Customizable triggers**: By default, the debug overlay provides two triggers for opening the
  overlay:
    * **Mobile/Touch**: Press and hold 2 fingers on the screen.
    * **Desktop/Keyboard**: Press ALT+F12.
* **Custom widgets**: Supports custom widgets to enable global actions from everywhere in your app.
* **Log viewer**: Displays your logs in a nice and sorted view.
* **HTTP request inspector**: Allows you to inspect logged HTTP requests including a JSON viewer.
* **Provided HTTP middlewares**: The debug overlay provides several middleware options for logging
  HTTP
  requests, including the `DioLogInterceptor` for the
  popular [`dio` package](https://pub.dev/packages/dio), `HttpClientLogAdapter` when utilizing the
  default `dart:io` client, and `HttpLogClient` for
  the [`http` package](https://pub.dev/packages/http).

## Usage

To use the debug overlay in your app, import the package and insert the `DebugOverlay` widget
at any point in your widget tree, to achieve a global overlay, put it in the builder of your
WidgetsApp.

The short and simple way (supports only limited features and customization):

```dart
import 'package:flutter_debug_overlay/flutter_debug_overlay.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: DebugOverlay.builder(),
      home: const MyHomePage(),
    );
  }
}
```

The advanced way:

```dart
import 'package:flutter_debug_overlay/flutter_debug_overlay.dart';

class MyApp extends StatelessWidget {
  static final LogBucket logBucket = LogBucket();
  static final HttpBucket httpBucket = HttpBucket();

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) {
        return DebugOverlay(
          hiddenFields: const [HttpHeaders.authorizationHeader, "Token"],
          logBucket: logBucket,
          httpBucket: httpBucket,
          debugEntries: [ExampleDebug()],
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const MyHomePage(),
    );
  }
}
```

### Add log entries

To access your logs in the log view:

1. Create an instance of `LogBucket`.
2. Provide the instance to the `DebugOverlay` widget.
3. Add your logs to the bucket via `add`.

With this, all log events from your app will be displayed in the debug overlay.

#### Example Log Sources

* [Logger](https://pub.dev/packages/logger)
   ```dart
    import 'package:logger/logger.dart' hide LogEvent;
    
    // Connects logger to the overlay.
    Logger.addOutputListener((event) {
      LogLevel? level = LogLevel.values
          .firstWhereOrNull((element) => element.name == event.origin.level.name);
      if (level == null) return;
      MyApp.logBucket.add(LogEvent(
        level: level,
        message: event.origin.message,
        error: event.origin.error,
        stackTrace: event.origin.stackTrace,
        time: event.origin.time,
      ));
    });
    ```

* Flutter Errors (e.g. Rendering Exceptions)
    ```dart
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      MyApp.logBucket.add(LogEvent(
        level: LogLevel.fatal,
        message: details.exceptionAsString(),
        error: (kDebugMode
            ? details.toDiagnosticsNode().toStringDeep()
            : details.exception.toString()),
        stackTrace: details.stack,
      ));
    };
    ```

* Uncaught Exceptions
    ```dart
    PlatformDispatcher.instance.onError = (exception, stackTrace) {
      MyApp.logBucket.add(LogEvent(
        level: LogLevel.fatal,
        message: "Unhandled Exception",
        error: exception,
        stackTrace: stackTrace,
      ));
      return false; // "false" still dumps it to the console.
    };
    ```

More information: https://docs.flutter.dev/testing/errors#handling-all-types-of-errors

### Add HTTP requests

To inspect HTTP requests:

1. Create an instance of `HttpBucket`.
2. Provide the instance to the `DebugOverlay` widget.
3. Add your requests to the bucket:
  * By using one of the provided middlewares
    * `DioLogInterceptor` for the [`dio` package](https://pub.dev/packages/dio).
    * `HttpClientLogAdapter` when utilizing the default `dart:io` client.
    * and `HttpLogClient` for the [`http` package](https://pub.dev/packages/http).
  * Manually via `add`.

With this, all HTTP requests made within your app will be displayed and can be inspected in the
debug overlay.

#### Example HTTP Client Integrations

* Dio
    ```dart
    dio = Dio()..interceptors.add(DioLogInterceptor(MyApp.httpBucket));
    ```

* HttpClient (`dart:io`)
    ```dart
    httpClient = HttpClient();
    httpClientAdapter = HttpClientLogAdapter(MyApp.httpBucket);
    ```
  * Log request
    ```dart
    httpClientAdapter.onRequest(request);
    ```
  * Log response
    ```dart
    httpClientAdapter.onResponse(request, response, responseBody);
    ```
  * Log error
    ```dart
    httpClientAdapter.onError(request, error, stackTrace);
    ```

* "http"
    ```dart
    client = HttpLogClient(MyApp.httpBucket, http.Client());
    ```

### Open the Overlay

By default, the debug overlay can be triggered either by pressing and holding two fingers on the
screen or by pressing ALT+F12 on a keyboard.

You can also use the `visible` property of the `DebugOverlay` widget to control it programmatically.

## Additional information

If you have any questions or issues with the library, please don't hesitate to open an issue on
GitHub. Contributions are always welcome, so feel free to submit a pull request if you have any
improvements or bug fixes to share.

## Acknowledgments

Inspired by [debug_overlay](https://github.com/JonasWanke/debug_overlay) and
[cr_logger](https://github.com/Cleveroad/cr_logger).
