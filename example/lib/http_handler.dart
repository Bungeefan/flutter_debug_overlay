import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_debug_overlay/flutter_debug_overlay.dart';
import 'package:flutter_html/flutter_html.dart';

class CustomHttpHandler extends DebugHttpHandler {
  @override
  BodyType determineBodyType(Map<String, dynamic>? headers, dynamic body) {
    var mediaType = headers != null ? extractMediaType(headers) : null;
    if (headers != null &&
        (mediaType?.type == "image" || mediaType?.subtype == "html")) {
      return BodyType.custom;
    }
    return super.determineBodyType(headers, body);
  }

  @override
  Widget buildCustomBody(
    BuildContext context,
    Map<String, dynamic>? headers,
    dynamic body,
    List<String> hiddenKeys,
  ) {
    if (body is List<int>) {
      return Image.memory(Uint8List.fromList(body));
    } else if (body is String) {
      return Html(data: body);
    }
    return Text(body.toString());
  }
}
