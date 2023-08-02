import 'package:flutter/material.dart';

/// Describes the level of a [LogEvent].
///
/// Similar to `package:logger`.
enum LogLevel {
  all(0),
  @Deprecated("Use [trace] instead.")
  verbose(999),
  trace(1000),
  debug(2000),
  info(3000),
  warning(4000),
  error(5000),
  @Deprecated("Use [fatal] instead.")
  wtf(5999),
  fatal(6000),
  off(10000),
  ;

  final int value;

  const LogLevel(this.value);
}

/// Describes a single log event.
///
/// Similar to `package:logger`.
class LogEvent {
  final LogLevel level;
  final dynamic message;
  final Object? error;
  final StackTrace? stackTrace;
  final DateTime time;

  /// Creates a new log event.
  ///
  /// If [time] is `null`, [DateTime.now] is assumed.
  LogEvent({
    required this.level,
    required this.message,
    DateTime? time,
    this.error,
    this.stackTrace,
  }) : time = time ?? DateTime.now();

  MaterialColor get levelColor => getLevelColor(level);

  static MaterialColor getLevelColor(LogLevel level) {
    var color = getLevelColorOrNull(level);
    if (color == null) throw ArgumentError.value(level.name, "LogLevel");
    return color;
  }

  static MaterialColor? getLevelColorOrNull(LogLevel level) {
    switch (level) {
      // ignore: deprecated_member_use_from_same_package
      case LogLevel.wtf:
      case LogLevel.fatal:
        return Colors.pink;
      case LogLevel.error:
        return Colors.red;
      case LogLevel.warning:
        return Colors.orange;
      case LogLevel.info:
        return Colors.blue;
      case LogLevel.debug:
        return Colors.blueGrey;
      // ignore: deprecated_member_use_from_same_package
      case LogLevel.verbose:
      case LogLevel.trace:
        return Colors.grey;
      default:
        return null;
    }
  }
}
