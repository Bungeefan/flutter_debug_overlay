import 'package:flutter/foundation.dart';

import '../../debug_overlay.dart';

/// Provides an interface for adding custom actions via [DebugOverlayState.addAction].
class DebugAction {
  final String name;
  final VoidCallback onAction;

  const DebugAction({
    required this.name,
    required this.onAction,
  });
}
