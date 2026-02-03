import 'level.dart';

/// A single log event emitted by [ShadowLog] / [ShadowLogger].
class ShadowLogRecord {
  ShadowLogRecord({
    required this.sequenceNumber,
    required this.time,
    required this.level,
    required this.loggerName,
    required this.message,
    this.error,
    this.stackTrace,
    this.fields,
  });

  /// Monotonic counter for log ordering within the current isolate.
  final int sequenceNumber;

  /// Timestamp when the record was created.
  final DateTime time;

  /// Severity level.
  final ShadowLogLevel level;

  /// Logger/tag name (shown as the Logcat tag when using [ShadowDeveloperLogOutput]).
  final String loggerName;

  /// Original message object.
  final Object? message;

  /// Optional error/exception associated with the log.
  final Object? error;

  /// Optional stack trace associated with the log.
  final StackTrace? stackTrace;

  /// Optional structured fields for the log.
  final Map<String, Object?>? fields;

  /// Stringified message.
  String get messageText => message?.toString() ?? 'null';
}
