import 'package:flutter/material.dart';

/// Describes the level of a [LogEvent].
///
/// Similar to `package:logger`.
enum LogLevel {
  verbose,
  debug,
  info,
  warning,
  error,
  wtf,
}

/// Describes a single log event.
///
/// Similar to `package:logger`.
class LogEvent {
  final LogLevel level;
  final dynamic message;
  final dynamic error;
  final StackTrace? stackTrace;
  final DateTime time;

  /// Creates a new log event.
  ///
  /// If [time] is `null`, [DateTime.now] is assumed.
  LogEvent({
    required this.level,
    required this.message,
    this.error,
    this.stackTrace,
    DateTime? time,
  }) : time = time ?? DateTime.now();

  MaterialColor get levelColor => getLevelColor(level);

  static MaterialColor getLevelColor(LogLevel level) {
    switch (level) {
      case LogLevel.wtf:
        return Colors.pink;
      case LogLevel.error:
        return Colors.red;
      case LogLevel.warning:
        return Colors.orange;
      case LogLevel.info:
        return Colors.blue;
      case LogLevel.debug:
        return Colors.blueGrey;
      case LogLevel.verbose:
        return Colors.grey;
    }
  }
}
