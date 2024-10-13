import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../debug_info_entry.dart';
import '../properties.dart';

class MediaQueryInfoEntry extends StatelessWidget {
  const MediaQueryInfoEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return DebugInfoEntry(
      title: const Text("MediaQuery"),
      data: _retrieveInfo(context),
    );
  }

  static Future<List<DebugPropertyNode>> _retrieveInfo(
      BuildContext context) async {
    var data = MediaQuery.maybeOf(context);
    if (data == null) {
      data = MediaQueryData.fromView(View.of(context));
      if (!kReleaseMode) {
        data = data.copyWith(platformBrightness: debugBrightnessOverride);
      }
    }

    return [
      DebugProperty(
        "Size",
        data.size,
        defaultValue: Size.zero,
        tooltip:
            "The size of the media in logical pixels (e.g, the size of the screen).",
      ),
      DebugDoubleProperty(
        "Device Pixel Ratio",
        data.devicePixelRatio,
        defaultValue: 1,
        tooltip: "The number of device pixels for each logical pixel.",
      ),
      DebugProperty(
        "Physical Size",
        data.size * data.devicePixelRatio,
        tooltip: "The size of the media in device pixels.",
      ),
      DebugEnumProperty(
        "Orientation",
        data.orientation,
      ),
      DebugDoubleProperty(
        "Text Scale Factor",
        data.textScaler.scale(1),
        defaultValue: 1,
        tooltip: "The number of font pixels for each logical pixel",
      ),
      DebugEnumProperty(
        "Platform Brightness",
        data.platformBrightness,
      ),
      DebugProperty(
        "Padding",
        data.padding,
        defaultValue: EdgeInsets.zero,
        tooltip:
            "Padding is derived from the values of viewInsets and viewPadding.",
      ),
      DebugProperty(
        "View Insets",
        data.viewInsets,
        defaultValue: EdgeInsets.zero,
        tooltip: "The parts of the display that are completely obscured by"
            " system UI, typically by the device's keyboard.",
      ),
      DebugProperty(
        "System Gesture Insets",
        data.systemGestureInsets,
        defaultValue: EdgeInsets.zero,
        tooltip: "The areas along the edges of the display where the system"
            " consumes certain input events and blocks delivery"
            " of those events to the app.",
      ),
      DebugProperty(
        "View Padding",
        data.viewPadding,
        defaultValue: EdgeInsets.zero,
        tooltip:
            'The parts of the display that are partially obscured by system UI,'
            ' typically by the hardware display "notches" or the system status bar.',
      ),
      DebugFlagProperty(
        "Always use 24 Hour Format",
        value: data.alwaysUse24HourFormat,
        ifTrue: "Always use 24 Hour Format",
      ),
      DebugFlagProperty(
        "Accessible Navigation",
        value: data.accessibleNavigation,
        ifTrue: "Use accessible navigation",
        tooltip:
            "Whether the user is using an accessibility service like TalkBack or VoiceOver to interact with the application.",
      ),
      DebugFlagProperty(
        "Invert Colors",
        value: data.invertColors,
        ifTrue: "The device inverts colors",
      ),
      DebugFlagProperty(
        "High Contrast",
        value: data.highContrast,
        ifTrue: "Should use high contrast",
      ),
      DebugFlagProperty(
        "On/Off switch labels",
        value: data.onOffSwitchLabels,
        ifTrue: "Should use on/off labels inside switches",
        tooltip: "Whether the user requested on/off labels inside switches",
      ),
      DebugFlagProperty(
        "Disable Animations",
        value: data.disableAnimations,
        ifTrue: "Disable animations",
      ),
      DebugFlagProperty(
        "Bold Text",
        value: data.boldText,
        ifTrue: "Use bold text",
      ),
      DebugEnumProperty(
        "Navigation Mode",
        data.navigationMode,
      ),
      DebugBlock(
        name: "Gesture Settings",
        children: [
          DebugDoubleProperty(
            "Touch Slop",
            data.gestureSettings.touchSlop,
            ifNull: "unset",
            tooltip:
                "The number of logical pixels a pointer is allowed to drift before it is considered an intentional touch.",
          ),
          DebugDoubleProperty(
            "Pan Slop",
            data.gestureSettings.panSlop,
            ifNull: "unset",
            tooltip:
                "The number of logical pixels a pointer is allowed to drift before it is considered an intentional pan.",
          ),
        ],
      ),
    ];
  }
}
