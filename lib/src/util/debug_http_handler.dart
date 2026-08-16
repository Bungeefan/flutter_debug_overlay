import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http_parser/http_parser.dart';

enum BodyType {
  json,
  raw,
  empty,
  custom,
}

class DebugHttpHandler {
  /// Extracts [MediaType] from [headers], if applicable.
  MediaType? extractMediaType(Map<String, dynamic> headers) {
    dynamic contentType = headers["content-type"];
    if (contentType is List) {
      contentType = contentType.firstOrNull;
    }
    MediaType? mediaType =
        contentType != null ? MediaType.parse(contentType) : null;
    return mediaType;
  }

  /// Whether [mediaType] is considered to be "plain text".
  bool isMediaTypeText(MediaType? mediaType) {
    return mediaType?.type == "text" ||
        mediaType?.subtype == "x-www-form-urlencoded" ||
        mediaType?.subtype == "form-data" ||
        mediaType?.subtype == "xml" ||
        mediaType?.subtype == "json";
  }

  /// Extracts [Encoding] from [mediaType].
  Encoding encodingForCharset(MediaType? mediaType) {
    return Encoding.getByName(mediaType?.parameters['charset']) ?? utf8;
  }

  Object? tryParseBody(Object? data) {
    if (data is String) {
      try {
        return json.decode(data);
      } on FormatException catch (_) {}
    }
    return data;
  }

  /// Determines the effective body type.
  ///
  /// Return [BodyType.custom] to use [buildCustomBody].
  BodyType determineBodyType(Map<String, dynamic>? headers, dynamic body) {
    if (body != null && (body is! String || body.isNotEmpty)) {
      if (body is Map || body is Iterable) {
        return BodyType.json;
      } else {
        return BodyType.raw;
      }
    } else {
      return BodyType.empty;
    }
  }

  /// Handles displaying a custom body type.
  ///
  /// See also:
  /// * [determineBodyType]
  Widget buildCustomBody(BuildContext context, Map<String, dynamic>? headers,
      dynamic body, List<String> hiddenKeys) {
    throw UnimplementedError(
        'No handler for "${BodyType.custom}" implemented.');
  }
}
