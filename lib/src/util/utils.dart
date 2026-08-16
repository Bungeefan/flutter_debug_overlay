import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

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
