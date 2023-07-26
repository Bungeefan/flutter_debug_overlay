import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_debug_overlay/flutter_debug_overlay.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart' hide LogEvent;
import 'package:universal_io/io.dart';

import 'example_data.dart';
import 'example_debug_entry.dart';
import 'logging/log_adapter.dart';
import 'logging/log_client.dart';
import 'logging/log_interceptor.dart';

void main() {
  // Enables the debug overlay even in release mode.
  DebugOverlay.enabled = true;

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

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  static final Logger logger = Logger();
  static final LogBucket logBucket = LogBucket();
  static final HttpBucket httpBucket = HttpBucket();

  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode? _forcedTheme;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Flutter Debug Demo",
      themeMode: _forcedTheme ?? ThemeMode.system,
      theme: ThemeData(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      builder: DebugOverlay.builder(
        logBucket: MyApp.logBucket,
        httpBucket: MyApp.httpBucket,
        debugEntries: [
          ExampleDebug(
            onThemeChange: ([ThemeMode? themeMode]) => setState(() {
              _forcedTheme = themeMode;
            }),
          ),
        ],
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static Uri baseUrl = Uri.parse("https://httpstat.us/");

  late final HttpClient httpClient;
  late final HttpClientLogAdapter httpClientAdapter;
  late final http.Client client;
  late final Dio dio;

  @override
  void initState() {
    super.initState();

    // dart:io
    httpClient = HttpClient();
    httpClientAdapter = ExampleHttpClientAdapter(MyApp.httpBucket);
    // "http"
    client = ExampleHttpLogClient(MyApp.httpBucket, http.Client());
    // Dio
    dio = Dio()..interceptors.add(ExampleDioLogInterceptor(MyApp.httpBucket));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter Debug Demo"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  children: [
                    const SizedBox(height: 50),
                    Text(
                      "Open Overlay via a long-press with 2 fingers or press ALT+F12.",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 50),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Routing",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const MySecondPage(),
                            ));
                          },
                          child: const Text("Route to second page"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const AnotherPage(),
                            ));
                          },
                          child: const Text("Route to another page"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 50),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Logger",
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                MyApp.logger.t(
                                  "Username including an '@' was entered.\n"
                                  "This has never happened before.\n\n\n"
                                  "And the reason for this ridiculous long logger message is to test the boundaries of my design.\n"
                                  "There is probably some guy who writes such long logs normally and uses them in production, therefore I try to test for such events.",
                                );
                              },
                              child: const Text("Trace Log"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                MyApp.logger.d("Safe guard was engaged");
                              },
                              child: const Text("Debug Log"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                MyApp.logger.i("User requested update");
                              },
                              child: const Text("Info Log"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                MyApp.logger
                                    .w("Database didn't respond under 500ms");
                              },
                              child: const Text("Warn Log"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                MyApp.logger.e(
                                  "An error occurred.",
                                  error: HttpException(
                                    "Failed to connect",
                                    uri: Uri.parse("https://www.google.com"),
                                  ),
                                  stackTrace: StackTrace.current,
                                );
                              },
                              child: const Text("Error Log"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                MyApp.logger.f(
                                  "Render Engine stopped",
                                  error: AssertionError("Rendering crashed"),
                                  stackTrace: StackTrace.current,
                                );
                              },
                              child: const Text("Fatal Log"),
                            ),
                          ],
                        ),
                        const SizedBox(width: 25),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "HTTP Requests",
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _sendHttpClientRequest();
                              },
                              child: const Text("Dart HTTP Request"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _sendHttpRequest();
                              },
                              child: const Text("\"http\" HTTP Request"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _sendDioRequest();
                              },
                              child: const Text("Dio HTTP Request"),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    dio.close();
    client.close();
    httpClient.close();
    super.dispose();
  }

  /// Dart HttpClient
  Future<void> _sendHttpClientRequest([
    ResponseType responseType = ResponseType.plain,
  ]) async {
    HttpClientRequest? request;
    try {
      request = await httpClient.getUrl(baseUrl.replace(path: "418"));
      // Log request
      httpClientAdapter.onRequest(request);
      var response = await request.close();
      Object? responseBody =
          await _parseHttpClientResponse(response, responseType);
      // Log response
      httpClientAdapter.onResponse(request, response, responseBody);

      log("Received HttpClient response: $responseBody");
    } catch (e, stack) {
      log("HttpClient request failed", error: e, stackTrace: stack);
      if (request != null) {
        // Log error
        httpClientAdapter.onError(request, e, stack);
      }
    }
  }

  /// "http"
  Future<void> _sendHttpRequest() {
    return client
        .post(baseUrl.replace(path: "204"), body: bigJson)
        .then((value) => log("Received \"http\" response: ${value.body}"))
        .catchError((e, stack) =>
            log("\"http\" request failed", error: e, stackTrace: stack));
  }

  /// Dio
  Future<void> _sendDioRequest([
    ResponseType responseType = ResponseType.bytes,
  ]) {
    return dio
        .putUri(
          baseUrl.replace(path: "201"),
          data: json.decode("""
{
  "id": 1,
  "first_name": "Garvy",
  "last_name": "Fencott",
  "gender": "Male",
  "ip_address": "214.62.102.43",
  "sub": {
    "id": 5,
    "email": "gfencott0@hubpages.com"
  },
  "list": [
    5,6,7,8
  ]
}"""),
          options: Options(
            contentType: "application/octet-stream",
            extra: {
              "Test extras": true,
            },
            validateStatus: (status) => true,
            responseType: responseType,
          ),
        )
        .then((value) => log("Received Dio response: $value"))
        .catchError((e, stack) =>
            log("Dio request failed", error: e, stackTrace: stack));
  }

  Future<Object?> _parseHttpClientResponse(
    HttpClientResponse response,
    ResponseType responseType,
  ) async {
    Object? responseBody;
    switch (responseType) {
      case ResponseType.json:
      case ResponseType.plain:
        responseBody = await response.transform(utf8.decoder).join();
        break;
      case ResponseType.bytes:
        responseBody =
            (await response.toList()).expand((element) => element).toList();
        break;
      case ResponseType.stream:
        responseBody = response;
        break;
    }
    return responseBody;
  }
}

class MySecondPage extends StatelessWidget {
  const MySecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DebugOverlay(
      debugEntries: [
        const Center(child: Text("Second Page Exclusive")),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Go back"),
        ),
      ],
      infoEntries: const [],
      child: Scaffold(
        appBar: AppBar(title: const Text("Second Page")),
        body: const Center(
          child: Text("Second Page"),
        ),
      ),
    );
  }
}

class AnotherPage extends StatefulWidget {
  const AnotherPage({super.key});

  @override
  State<AnotherPage> createState() => _AnotherPageState();
}

class _AnotherPageState extends State<AnotherPage> {
  final ValueNotifier<int> _counter = ValueNotifier(0);

  DebugOverlayState? debugOverlay;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    startTimer();

    // Simple value
    DebugOverlay.maybeOf(context)?.addValue(DebugValue(
      name: "Counter",
      listenable: _counter,
    ));

    // Custom widget
    DebugOverlay.maybeOf(context)?.addValue(DebugValue(
      name: "Custom Counter",
      listenable: _counter,
      builder: (context, value, child) {
        return Icon(
          value % 2 == 0
              ? Icons.markunread_mailbox
              : Icons.markunread_mailbox_outlined,
        );
      },
    ));

    DebugOverlay.maybeOf(context)?.addAction(DebugAction(
      name: "Start Counter",
      onAction: startTimer,
    ));
    DebugOverlay.maybeOf(context)?.addAction(DebugAction(
      name: "Stop Counter",
      onAction: stopTimer,
    ));
  }

  void startTimer() {
    timer = Timer.periodic(
      const Duration(milliseconds: 500),
      (timer) {
        _counter.value++;
      },
    );
  }

  void stopTimer() {
    timer.cancel();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Save latest known instance for dispose.
    debugOverlay = DebugOverlay.maybeOf(context);
  }

  @override
  void dispose() {
    timer.cancel();
    debugOverlay?.removeValue(_counter);
    debugOverlay?.removeAction(startTimer);
    debugOverlay?.removeAction(stopTimer);
    _counter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Another Page")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Counter"),
              ValueListenableBuilder(
                valueListenable: _counter,
                builder: (context, value, child) => Text(value.toString()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
