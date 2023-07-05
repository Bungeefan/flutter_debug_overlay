import 'package:flutter/material.dart';

import 'debug_overlay.dart';

/// Represents the basis for a a simple debug entry used in [DebugOverlay.debugEntries].
///
/// Includes a title, possible actions and a child.
class DebugEntry extends StatelessWidget {
  const DebugEntry({
    super.key,
    required this.title,
    this.actions = const [],
    required this.child,
    this.headerPadding = const EdgeInsets.symmetric(horizontal: 8),
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 16),
  });

  /// The title displayed on top of the widget.
  final Widget title;

  /// Optional actions which are placed in the right top corner.
  ///
  /// Typically a list of [IconButton]s.
  final List<Widget> actions;

  /// The content in the entry.
  final Widget child;

  /// Padding that wraps the header row (title and actions).
  final EdgeInsetsGeometry headerPadding;

  /// Padding that wraps the content.
  final EdgeInsetsGeometry contentPadding;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 48),
          child: Padding(
            padding: headerPadding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: DefaultTextStyle.merge(
                      style: Theme.of(context).textTheme.titleLarge!,
                      child: title,
                    ),
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: actions,
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: contentPadding,
          child: child,
        ),
        const SizedBox(height: 12.5),
      ],
    );
  }
}
