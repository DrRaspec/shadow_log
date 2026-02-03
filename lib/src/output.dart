import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

import 'record.dart';

/// Writes formatted log records to a destination.
abstract interface class ShadowLogOutput {
  const ShadowLogOutput();

  void write(ShadowLogRecord record, String formattedMessage);
}

/// Default output: forwards to `dart:developer.log` (Logcat-friendly on Android).
class ShadowDeveloperLogOutput implements ShadowLogOutput {
  const ShadowDeveloperLogOutput();

  @override
  void write(ShadowLogRecord record, String formattedMessage) {
    developer.log(
      formattedMessage,
      name: record.loggerName,
      level: record.level.value,
      error: record.error,
      stackTrace: record.stackTrace,
    );
  }
}

/// Output that writes to Flutter's `debugPrint`.
///
/// Useful in debug builds and for platforms where `dart:developer` isn't ideal.
class ShadowDebugPrintOutput implements ShadowLogOutput {
  const ShadowDebugPrintOutput();

  @override
  void write(ShadowLogRecord record, String formattedMessage) {
    debugPrint(formattedMessage);

    final error = record.error;
    if (error != null) {
      debugPrint('error: $error');
    }

    final stackTrace = record.stackTrace;
    if (stackTrace != null) {
      debugPrint(stackTrace.toString());
    }
  }
}

/// Output that keeps logs in memory (helpful for tests or in-app log UIs).
class ShadowMemoryOutput implements ShadowLogOutput {
  ShadowMemoryOutput({this.maxRecords});

  /// Optional cap; when exceeded the oldest records are discarded.
  final int? maxRecords;

  final List<ShadowLogRecord> records = <ShadowLogRecord>[];
  final List<String> messages = <String>[];

  @override
  void write(ShadowLogRecord record, String formattedMessage) {
    records.add(record);
    messages.add(formattedMessage);

    final cap = maxRecords;
    if (cap != null && cap > 0 && records.length > cap) {
      final overflow = records.length - cap;
      records.removeRange(0, overflow);
      messages.removeRange(0, overflow);
    }
  }

  void clear() {
    records.clear();
    messages.clear();
  }
}

/// Output that delegates to a callback.
class ShadowCallbackOutput implements ShadowLogOutput {
  ShadowCallbackOutput(this.onWrite);

  final void Function(ShadowLogRecord record, String formattedMessage) onWrite;

  @override
  void write(ShadowLogRecord record, String formattedMessage) {
    onWrite(record, formattedMessage);
  }
}
