import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http_parser/http_parser.dart';

abstract class Utils {
  static Future<void> copyToClipboard(
    BuildContext context, {
    required String value,
    String? title,
  }) async {
    var scaffoldMessenger = ScaffoldMessenger.of(context);

    await Clipboard.setData(ClipboardData(text: value));

    final snackBar = SnackBar(
      content: Text(
        'Copied ${title ?? '"$value"'} to clipboard.',
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
      ),
      behavior: SnackBarBehavior.floating,
    );
    scaffoldMessenger.clearSnackBars();
    scaffoldMessenger.showSnackBar(snackBar);
  }

  static String encodePrettyJson(Object? data) {
    const je = JsonEncoder.withIndent("  ");
    return je.convert(data);
  }

  static Object? tryParseJson(Object? data) {
    if (data is String) {
      try {
        return json.decode(data);
      } on FormatException catch (_) {}
    }
    return data;
  }

  static MediaType? extractMediaType(Map<String, dynamic> headers) {
    dynamic contentType = headers["content-type"];
    if (contentType is List) {
      contentType = contentType.firstOrNull;
    }
    MediaType? mediaType =
        contentType != null ? MediaType.parse(contentType) : null;
    return mediaType;
  }

  static bool isMediaTypeText(MediaType? mediaType) {
    return mediaType?.type == "text" ||
        mediaType?.subtype == "x-www-form-urlencoded" ||
        mediaType?.subtype == "form-data" ||
        mediaType?.subtype == "xml" ||
        mediaType?.subtype == "json";
  }

  static Encoding encodingForCharset(MediaType? mediaType) {
    return Encoding.getByName(mediaType?.parameters['charset']) ?? utf8;
  }
}

extension DurationPresentation on Duration {
  String toHumanString() {
    if (inMinutes >= 10) {
      return "${(inSeconds / 1000).toStringAsFixed(3)}m";
    }
    if (inSeconds >= 10) {
      return "${(inMilliseconds / 1000).toStringAsFixed(3)}s";
    }
    return "${inMilliseconds}ms";
  }
}
