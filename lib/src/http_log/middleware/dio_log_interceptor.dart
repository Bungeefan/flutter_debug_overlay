import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import '../../../flutter_debug_overlay.dart';

/// An [Dio] interceptor that logs requests to a [HttpBucket].
///
/// Usage:
/// ```dart
/// dio = Dio()
///   ..interceptors.add(DioLogInterceptor(MyApp.httpBucket));
/// ```
class DioLogInterceptor extends Interceptor {
  final HttpBucket httpBucket;

  DioLogInterceptor(this.httpBucket);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (DebugOverlay.enabled) {
      httpBucket.add(HttpInteraction(
        id: options.hashCode,
        uri: options.uri,
        method: options.method,
        request: convertRequest(options),
      ));
    }
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (DebugOverlay.enabled) {
      var resp = convertResponse(response);
      httpBucket.addResponse(response.requestOptions.hashCode, resp);
    }
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (DebugOverlay.enabled) {
      var error = convertError(err);
      httpBucket.addError(err.requestOptions.hashCode, error);
    }
    return handler.next(err);
  }

  Object? decodeBody(Map<String, dynamic> headers, dynamic body) {
    MediaType? mediaType = DebugOverlay.httpHandler.extractMediaType(headers);
    return body is List<int> &&
            DebugOverlay.httpHandler.isMediaTypeText(mediaType)
        ? DebugOverlay.httpHandler.encodingForCharset(mediaType).decode(body)
        : body;
  }

  HttpRequest convertRequest(RequestOptions options) {
    return HttpRequest(
      headers: options.headers,
      parameters: options.queryParameters,
      body: decodeBody(options.headers, options.data),
      time: DateTime.now(),
      additionalData: {
        "persistentConnection": options.persistentConnection,
        "maxRedirects": options.maxRedirects,
        "followRedirects": options.followRedirects,
        "receiveDataWhenStatusError": options.receiveDataWhenStatusError,
        "connectTimeout": options.connectTimeout,
        "sendTimeout": options.sendTimeout,
        "receiveTimeout": options.receiveTimeout,
        "extra": options.extra,
      },
    );
  }

  HttpResponse convertResponse(Response response) {
    return HttpResponse(
      headers: response.headers.map,
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      body: decodeBody(response.headers.map, response.data),
      time: DateTime.now(),
      additionalData: {
        "realUri": response.realUri,
        "isRedirect": response.isRedirect,
        "redirects": response.redirects.length,
        "extra": response.extra,
      },
    );
  }

  HttpError convertError(DioException error) {
    return HttpError(
      error: error.error,
      stackTrace: error.stackTrace,
      time: DateTime.now(),
      additionalData: {
        "type": error.type,
        "message": error.message,
      },
    );
  }
}
