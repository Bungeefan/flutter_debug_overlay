import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'package:http_parser/http_parser.dart';

import '../../../flutter_debug_overlay.dart';
import '../../util/utils.dart';

/// An [http.Client] wrapper that logs requests to a [HttpBucket].
///
/// Usage:
/// ```dart
/// client = HttpLogClient(MyApp.httpBucket, http.Client());
/// ```
class HttpLogClient extends http.BaseClient {
  final HttpBucket httpBucket;
  final http.Client _inner;

  HttpLogClient(this.httpBucket, this._inner);

  @override
  void close() => _inner.close();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    bool enabled = DebugOverlay.enabled;

    try {
      var effectiveRequest = request;
      if (enabled) {
        var requestBody = await request.finalize().toBytes();
        httpBucket.add(HttpInteraction(
          id: request.hashCode,
          uri: request.url,
          method: request.method,
          request: convertRequest(request, requestBody),
        ));
        effectiveRequest =
            _copyRequest(request, http.ByteStream.fromBytes(requestBody));
      }

      http.StreamedResponse response = await _inner.send(effectiveRequest);

      if (enabled) {
        var responseBody = await response.stream.toBytes();
        httpBucket.addResponse(
          request.hashCode,
          convertResponse(response, responseBody),
        );
        return _copyResponse(response, http.ByteStream.fromBytes(responseBody));
      }
      return response;
    } catch (e, stack) {
      if (enabled) {
        httpBucket.addError(request.hashCode, convertError(e, stack));
      }
      rethrow;
    }
  }

  /// Returns a copy of [original] with the given [body].
  ///
  /// Copied from [RetryClient._copyRequest].
  http.StreamedRequest _copyRequest(
    http.BaseRequest original,
    Stream<List<int>> body,
  ) {
    final request = http.StreamedRequest(original.method, original.url)
      ..contentLength = original.contentLength
      ..followRedirects = original.followRedirects
      ..headers.addAll(original.headers)
      ..maxRedirects = original.maxRedirects
      ..persistentConnection = original.persistentConnection;

    body.listen(
      request.sink.add,
      onError: request.sink.addError,
      onDone: request.sink.close,
      cancelOnError: true,
    );

    return request;
  }

  /// Returns a copy of [original] with the given [body].
  http.StreamedResponse _copyResponse(
    http.StreamedResponse original,
    Stream<List<int>> body,
  ) {
    final response = http.StreamedResponse(
      body,
      original.statusCode,
      contentLength: original.contentLength,
      headers: original.headers,
      request: original.request,
      isRedirect: original.isRedirect,
      reasonPhrase: original.reasonPhrase,
      persistentConnection: original.persistentConnection,
    );

    return response;
  }

  HttpRequest convertRequest(http.BaseRequest request, Uint8List body) {
    MediaType? mediaType = Utils.extractMediaType(request.headers);
    return HttpRequest(
      headers: request.headers,
      body: Utils.isMediaTypeText(mediaType)
          ? http.Response.bytes(body, 200).body
          : body,
      time: DateTime.now(),
      additionalData: {
        "contentLength": request.contentLength ?? body.lengthInBytes,
        "persistentConnection": request.persistentConnection,
      },
    );
  }

  HttpResponse convertResponse(http.StreamedResponse response, Uint8List body) {
    MediaType? mediaType = Utils.extractMediaType(response.headers);
    return HttpResponse(
      headers: response.headers,
      statusCode: response.statusCode,
      statusMessage: response.reasonPhrase,
      body: Utils.isMediaTypeText(mediaType)
          ? http.Response.bytes(body, 200).body
          : body,
      time: DateTime.now(),
      additionalData: {
        "contentLength": response.contentLength ?? body.lengthInBytes,
        "persistentConnection": response.persistentConnection,
        "isRedirect": response.isRedirect,
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
