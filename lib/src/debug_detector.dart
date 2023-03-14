import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:multi_long_press_gesture_recognizer/multi_long_press_gesture_recognizer.dart';

/// Enables various techniques to trigger an action.
///
/// If [onDetect] is null, this is a no-op widget.
///
/// See also:
/// * [MultiLongPressGestureRecognizer]
/// * [Shortcuts]
class DebugDetector extends StatelessWidget {
  final void Function()? onDetect;
  final Duration? delay;
  final double? acceptSlopTolerance;
  final int pointers;
  final bool useHapticFeedback;
  final List<ShortcutActivator> shortcuts;
  final Widget child;

  const DebugDetector({
    super.key,
    this.onDetect,
    this.delay,
    this.acceptSlopTolerance,
    this.pointers = 2,
    this.useHapticFeedback = true,
    this.shortcuts = const [
      SingleActivator(LogicalKeyboardKey.f12, alt: true),
    ],
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (onDetect == null) {
      return child;
    }

    return CallbackShortcuts(
      bindings: {
        for (var shortcut in shortcuts) shortcut: onDetect!,
      },
      child: RawGestureDetector(
        gestures: {
          MultiLongPressGestureRecognizer: GestureRecognizerFactoryWithHandlers<
              MultiLongPressGestureRecognizer>(
            () => MultiLongPressGestureRecognizer(
              duration: delay,
              preAcceptSlopTolerance: acceptSlopTolerance,
              pointerThreshold: pointers,
            ),
            (instance) {
              instance.onMultiLongPress = (details) {
                if (useHapticFeedback) {
                  HapticFeedback.vibrate();
                }
                onDetect!.call();
              };
            },
          ),
        },
        child: child,
      ),
    );
  }
}
