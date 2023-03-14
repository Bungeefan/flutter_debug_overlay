import 'dart:typed_data';

import 'package:flutter_debug_overlay/flutter_debug_overlay.dart';
import 'package:http/http.dart' as http;

class ExampleHttpLogClient extends HttpLogClient {
  ExampleHttpLogClient(super.httpBucket, super.inner);

  @override
  HttpRequest convertRequest(http.BaseRequest request, Uint8List body) {
    var httpRequest = super.convertRequest(request, body);
    return httpRequest.copyWith(
      additionalData: {
        "handledByExampleClient": true,
        ...?httpRequest.additionalData,
      },
    );
  }
}
