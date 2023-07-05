import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import '../../../flutter_debug_overlay.dart';
import '../../util/utils.dart';

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

  HttpRequest convertRequest(RequestOptions options) {
    MediaType? mediaType = Utils.extractMediaType(options.headers);
    return HttpRequest(
      headers: options.headers,
      parameters: options.queryParameters,
      body: options.data is List<int> && Utils.isMediaTypeText(mediaType)
          ? Utils.encodingForCharset(mediaType).decode(options.data)
          : options.data,
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
    MediaType? mediaType = Utils.extractMediaType(response.headers.map);
    return HttpResponse(
      headers: response.headers.map,
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      body: response.data is List<int> && Utils.isMediaTypeText(mediaType)
          ? Utils.encodingForCharset(mediaType).decode(response.data)
          : response.data,
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
