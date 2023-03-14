import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
}
