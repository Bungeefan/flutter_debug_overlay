import 'package:flutter/material.dart';

import '../util/selector.dart';
import 'log_event.dart';

class LevelSelector extends StatelessWidget {
  final LogLevel level;
  final ValueSetter<LogLevel> onLevelChanged;
  final double iconSize;
  final double splashRadius;

  const LevelSelector({
    super.key,
    required this.level,
    required this.onLevelChanged,
    this.iconSize = 32,
    this.splashRadius = 25,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<LogLevel>(
      tooltip: "Select minimum log level",
      values: {
        for (var level in LogLevel.values)
          // ignore: deprecated_member_use_from_same_package
          if (!const [LogLevel.verbose, LogLevel.wtf].contains(level))
            level.name.toUpperCase(): level,
      },
      selectedValue: level,
      onSelected: onLevelChanged,
      valueBuilder: (key, level) => Icon(
        levelToIcon(level),
        color: LogEvent.getLevelColorOrNull(level),
      ),
      iconSize: iconSize,
      splashRadius: splashRadius,
    );
  }

  IconData levelToIcon(LogLevel level) {
    switch (level) {
      case LogLevel.off:
        return Icons.not_interested_outlined;
      // ignore: deprecated_member_use_from_same_package
      case LogLevel.verbose:
      case LogLevel.trace:
        return Icons.route;
      case LogLevel.debug:
        return Icons.bug_report_outlined;
      case LogLevel.info:
        return Icons.info_outline;
      case LogLevel.warning:
        return Icons.warning_outlined;
      case LogLevel.error:
        return Icons.error_outlined;
      // ignore: deprecated_member_use_from_same_package
      case LogLevel.wtf:
      case LogLevel.fatal:
        return Icons.dangerous;
      case LogLevel.all:
        return Icons.all_inclusive_outlined;
    }
  }
}
