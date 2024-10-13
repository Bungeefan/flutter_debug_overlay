import 'package:flutter/material.dart';

import '../util/utils.dart';

class HttpInteraction {
  int id;
  Uri? uri;
  String? method;
  HttpRequest? request;
  HttpResponse? response;
  HttpError? error;

  /// Creates a [HttpInteraction].
  ///
  /// Usually [id] is the [hashCode] of the original request object,
  /// for example [HttpClientRequest.hashCode].
  /// This is used to be able to later update the interaction.
  HttpInteraction({
    required this.id,
    this.uri,
    this.method,
    this.request,
    this.response,
    this.error,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HttpInteraction &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  Duration? get duration =>
      request?.time != null ? responseTime?.difference(request!.time!) : null;

  /// Returns either the [HttpResponse.time] or the [HttpError.time].
  DateTime? get responseTime => (response?.time ?? error?.time);

  MaterialColor get statusColor => getStatusColor(response?.statusCode);

  MaterialColor get durationColor => getDurationColor(duration);

  static MaterialColor getStatusColor(int? statusCode) => statusCode == null
      ? Colors.grey
      : statusCode < 200
          ? Colors.blue
          : statusCode < 300
              ? Colors.green
              : statusCode < 400
                  ? Colors.blue
                  : statusCode < 500
                      ? Colors.orange
                      : Colors.red;

  static MaterialColor getDurationColor(Duration? duration) => duration == null
      ? Colors.grey
      : duration.inMilliseconds < 150
          ? Colors.green
          : duration.inMilliseconds < 500
              ? Colors.orange
              : Colors.red;
}

class HttpRequest {
  final Map<String, dynamic>? headers;
  final Map<String, dynamic>? parameters;
  final Object? body;
  final DateTime? time;
  final Map<String, dynamic>? additionalData;

  HttpRequest({
    this.headers,
    this.parameters,
    Object? body,
    this.time,
    this.additionalData,
  }) : body = Utils.tryParseJson(body);

  HttpRequest.fromJson(Map<String, dynamic> json)
      : this(
          headers: json["headers"],
          parameters: json["parameters"],
          body: json["body"],
          time: json["time"],
          additionalData: json["additionalData"],
        );

  Map<String, dynamic> toJson() => {
        "headers": headers,
        "parameters": parameters,
        "body": body,
        "time": time,
        "additionalData": additionalData,
      };

  HttpRequest copyWith({
    Map<String, dynamic>? headers,
    Map<String, dynamic>? parameters,
    Object? body,
    DateTime? time,
    Map<String, dynamic>? additionalData,
  }) {
    return HttpRequest(
      headers: headers ?? this.headers,
      parameters: parameters ?? this.parameters,
      body: body ?? this.body,
      time: time ?? this.time,
      additionalData: additionalData ?? this.additionalData,
    );
  }
}

class HttpResponse {
  final int? statusCode;
  final String? statusMessage;
  final Map<String, dynamic>? headers;
  final Object? body;
  final DateTime? time;
  final Map<String, dynamic>? additionalData;

  HttpResponse({
    this.statusCode,
    this.statusMessage,
    this.headers,
    Object? body,
    this.time,
    this.additionalData,
  }) : body = Utils.tryParseJson(body);

  HttpResponse.fromJson(Map<String, dynamic> json)
      : this(
          statusCode: json["statusCode"],
          statusMessage: json["statusMessage"],
          headers: json["headers"],
          body: json["body"],
          time: json["time"],
          additionalData: json["additionalData"],
        );

  Map<String, dynamic> toJson() => {
        "statusCode": statusCode,
        "statusMessage": statusMessage,
        "headers": headers,
        "body": body,
        "time": time,
        "additionalData": additionalData,
      };

  HttpResponse copyWith({
    int? statusCode,
    String? statusMessage,
    Map<String, dynamic>? headers,
    Object? body,
    DateTime? time,
    Map<String, dynamic>? additionalData,
  }) {
    return HttpResponse(
      statusCode: statusCode ?? this.statusCode,
      statusMessage: statusMessage ?? this.statusMessage,
      headers: headers ?? this.headers,
      body: body ?? this.body,
      time: time ?? this.time,
      additionalData: additionalData ?? this.additionalData,
    );
  }
}

class HttpError {
  final Object? error;
  final StackTrace? stackTrace;
  final DateTime? time;
  final Map<String, dynamic>? additionalData;

  HttpError({
    this.error,
    this.stackTrace,
    this.time,
    this.additionalData,
  });

  bool containsData() =>
      error != null || stackTrace != null || additionalData != null;

  HttpError.fromJson(Map<String, dynamic> json)
      : this(
          error: json["error"],
          stackTrace: json["stackTrace"],
          time: json["time"],
          additionalData: json["additionalData"],
        );

  Map<String, dynamic> toJson() => {
        "error": error,
        "stackTrace": stackTrace,
        "time": time,
        "additionalData": additionalData,
      };

  HttpError copyWith({
    Object? error,
    StackTrace? stackTrace,
    DateTime? time,
    Map<String, dynamic>? additionalData,
  }) {
    return HttpError(
      error: error ?? this.error,
      stackTrace: stackTrace ?? this.stackTrace,
      time: time ?? this.time,
      additionalData: additionalData ?? this.additionalData,
    );
  }
}
