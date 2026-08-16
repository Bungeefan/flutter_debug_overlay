import 'dart:io';

import 'package:http_parser/http_parser.dart';

import '../../../flutter_debug_overlay.dart';

/// An "dart:io" [HttpClient] adapter that logs requests to a [HttpBucket].
///
/// Usage:
/// ```dart
/// httpClientAdapter = HttpClientLogAdapter(MyApp.httpBucket);
///
/// try {
///   // Log request
///   httpClientAdapter.onRequest(request);
///   // Log response
///   httpClientAdapter.onResponse(request, response, responseBody);
/// } catch (e, stack) {
///   // Log error
///   httpClientAdapter.onError(request, e, stack);
/// }
/// ```
class HttpClientLogAdapter {
  final HttpBucket httpBucket;

  HttpClientLogAdapter(this.httpBucket);

  void onRequest(HttpClientRequest request, [Object? body]) {
    if (!DebugOverlay.enabled) return;

    httpBucket.add(HttpInteraction(
      id: request.hashCode,
      uri: request.uri,
      method: request.method,
      request: convertRequest(request, body),
    ));
  }

  void onResponse(
    HttpClientRequest request,
    HttpClientResponse response, [
    Object? body,
  ]) {
    if (!DebugOverlay.enabled) return;

    var resp = convertResponse(response, body);
    httpBucket.addResponse(request.hashCode, resp);
  }

  void onError(
    HttpClientRequest request, [
    Object? error,
    StackTrace? stack,
  ]) {
    if (!DebugOverlay.enabled) return;

    var err = convertError(error, stack);
    httpBucket.addError(request.hashCode, err);
  }

  Map<String, List<String>> extractHeaders(HttpHeaders httpHeaders) {
    final Map<String, List<String>> headers = {};
    httpHeaders.forEach((name, values) {
      headers[name] = values;
    });
    return headers;
  }

  Object? decodeBody(Map<String, List<String>> headers, Object? body) {
    MediaType? mediaType = DebugOverlay.httpHandler.extractMediaType(headers);
    return body is List<int> &&
            DebugOverlay.httpHandler.isMediaTypeText(mediaType)
        ? DebugOverlay.httpHandler.encodingForCharset(mediaType).decode(body)
        : body;
  }

  HttpRequest convertRequest(
    HttpClientRequest request, [
    Object? body,
  ]) {
    var headers = extractHeaders(request.headers);
    return HttpRequest(
      headers: headers,
      body: decodeBody(headers, body),
      time: DateTime.now(),
      additionalData: {
        "contentLength": request.contentLength,
        "persistentConnection": request.persistentConnection,
        "maxRedirects": request.maxRedirects,
        "followRedirects": request.followRedirects,
        "bufferOutput": request.bufferOutput,
        "encoding": request.encoding.name,
        if (request.connectionInfo != null) ...{
          "localPort": request.connectionInfo?.localPort,
          "remoteAddress": request.connectionInfo?.remoteAddress,
          "remotePort": request.connectionInfo?.remotePort,
        },
      },
    );
  }

  HttpResponse convertResponse(
    HttpClientResponse response, [
    Object? body,
  ]) {
    var headers = extractHeaders(response.headers);
    return HttpResponse(
      headers: headers,
      statusCode: response.statusCode,
      statusMessage: response.reasonPhrase,
      body: decodeBody(headers, body),
      time: DateTime.now(),
      additionalData: {
        "contentLength": response.contentLength,
        "persistentConnection": response.persistentConnection,
        "compressionState": response.compressionState.name,
        "isRedirect": response.isRedirect,
        "redirects": response.redirects.length,
      },
    );
  }

  HttpError convertError([Object? e, StackTrace? stack]) {
    return HttpError(
      error: e,
      stackTrace: stack,
      time: DateTime.now(),
    );
  }
}
