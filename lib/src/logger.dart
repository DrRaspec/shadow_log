import 'level.dart';

/// A named logger that automatically uses its [name] as the tag.
///
/// Inspired by `logging` / `logger` style APIs.
class ShadowLogger {
  ShadowLogger.withSink(this.name, ShadowLoggerSink sink) : _sink = sink;

  final String name;
  final ShadowLoggerSink _sink;

  ShadowLogger child(String childName) {
    final trimmed = childName.trim();
    if (trimmed.isEmpty) {
      return this;
    }
    return ShadowLogger.withSink('$name.$trimmed', _sink);
  }

  void v(
    Object? message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? fields,
  }) {
    _sink(
      ShadowLogLevel.verbose,
      message,
      tag: name,
      error: error,
      stackTrace: stackTrace,
      fields: fields,
    );
  }

  void d(
    Object? message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? fields,
  }) {
    _sink(
      ShadowLogLevel.debug,
      message,
      tag: name,
      error: error,
      stackTrace: stackTrace,
      fields: fields,
    );
  }

  void i(
    Object? message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? fields,
  }) {
    _sink(
      ShadowLogLevel.info,
      message,
      tag: name,
      error: error,
      stackTrace: stackTrace,
      fields: fields,
    );
  }

  void w(
    Object? message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? fields,
  }) {
    _sink(
      ShadowLogLevel.warning,
      message,
      tag: name,
      error: error,
      stackTrace: stackTrace,
      fields: fields,
    );
  }

  void e(
    Object? message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? fields,
  }) {
    _sink(
      ShadowLogLevel.error,
      message,
      tag: name,
      error: error,
      stackTrace: stackTrace,
      fields: fields,
    );
  }

  void wtf(
    Object? message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? fields,
  }) {
    _sink(
      ShadowLogLevel.wtf,
      message,
      tag: name,
      error: error,
      stackTrace: stackTrace,
      fields: fields,
    );
  }

  void log(
    ShadowLogLevel level,
    Object? message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? fields,
  }) {
    _sink(
      level,
      message,
      tag: name,
      error: error,
      stackTrace: stackTrace,
      fields: fields,
    );
  }
}

typedef ShadowLoggerSink = void Function(
  ShadowLogLevel level,
  Object? message, {
  required String tag,
  Object? error,
  StackTrace? stackTrace,
  Map<String, Object?>? fields,
});
