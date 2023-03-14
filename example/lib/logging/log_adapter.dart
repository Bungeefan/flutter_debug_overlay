import 'dart:io';

import 'package:flutter_debug_overlay/flutter_debug_overlay.dart';

class ExampleHttpClientAdapter extends HttpClientLogAdapter {
  ExampleHttpClientAdapter(super.httpBucket);

  @override
  HttpRequest convertRequest(HttpClientRequest request, [Object? body]) {
    var httpRequest = super.convertRequest(request, body);
    return httpRequest.copyWith(
      additionalData: {
        "handledByExampleAdapter": true,
        ...?httpRequest.additionalData,
      },
    );
  }
}
