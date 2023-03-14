import 'package:dio/dio.dart';
import 'package:flutter_debug_overlay/flutter_debug_overlay.dart';

class ExampleDioLogInterceptor extends DioLogInterceptor {
  ExampleDioLogInterceptor(super.httpBucket);

  @override
  HttpRequest convertRequest(RequestOptions options) {
    var httpRequest = super.convertRequest(options);
    return httpRequest.copyWith(
      additionalData: {
        "handledByExampleInterceptor": true,
        ...?httpRequest.additionalData,
      },
    );
  }
}
