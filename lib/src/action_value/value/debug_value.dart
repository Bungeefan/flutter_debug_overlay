import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import '../../debug_overlay.dart';

/// Provides an interface for adding listenables via [DebugOverlayState.addValue].
class DebugValue<T> {
  final String name;
  final ValueListenable<T> listenable;

  /// Optional builder to create custom Widgets.
  ///
  /// Default: [Text] widget with `toString` call on value.
  final ValueWidgetBuilder<T>? builder;

  const DebugValue({
    required this.name,
    required this.listenable,
    this.builder,
  });
}
