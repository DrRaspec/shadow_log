import 'dart:async' as async;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';

import 'config.dart';
import 'history.dart';
import 'level.dart';
import 'logger.dart';
import 'output.dart';
import 'record.dart';

/// ShadowLog writes to the configured outputs (default: `dart:developer`).
///
/// In Android, this appears in Logcat (ADB) for both debug and release builds
/// when [ShadowLogConfig.enabledInRelease] is true.
class ShadowLog {
  static ShadowLogConfig _config = const ShadowLogConfig();
  static int _sequence = 0;

  static final async.StreamController<ShadowLogRecord> _recordsController =
      async.StreamController<ShadowLogRecord>.broadcast(sync: true);

  /// Replace the global configuration.
  static void configure(ShadowLogConfig config) {
    _config = config;
  }

  /// Shorthand access to the current configuration.
  static ShadowLogConfig get config => _config;

  /// Stream of accepted log records (similar to `logging`'s `onRecord`).
  static Stream<ShadowLogRecord> get onRecord => _recordsController.stream;

  /// Resets [config] back to defaults (useful for tests).
  static void reset() {
    _config = const ShadowLogConfig();
    _sequence = 0;
  }

  /// Creates a named logger that automatically uses its name as the tag.
  ///
  /// If [name] is omitted or blank, [ShadowLogConfig.name] is used.
  static ShadowLogger logger([String? name]) {
    final resolvedName = _resolveTag(name);
    return ShadowLogger.withSink(resolvedName, _logFromLogger);
  }

  /// Adds an output to the current [config] (appends to [ShadowLogConfig.outputs]).
  static void addOutput(ShadowLogOutput output) {
    configure(
      _config.copyWith(
        outputs: <ShadowLogOutput>[..._config.outputs, output],
      ),
    );
  }

  /// Adds an observer to the current [config] (appends to [ShadowLogConfig.observers]).
  static void addObserver(ShadowLogObserver observer) {
    configure(
      _config.copyWith(
        observers: <ShadowLogObserver>[..._config.observers, observer],
      ),
    );
  }

  /// Creates and attaches an in-memory log history.
  ///
  /// Equivalent to:
  /// `final history = ShadowLogHistory(capacity: ...); ShadowLog.addObserver(history);`
  static ShadowLogHistory attachHistory({int capacity = 200}) {
    final history = ShadowLogHistory(capacity: capacity);
    addObserver(history);
    return history;
  }

  /// Installs Flutter error hooks to forward framework + platform errors to [ShadowLog].
  ///
  /// This is inspired by crash/logging tools like Talker.
  ///
  /// By default this:
  /// - Logs [FlutterError.onError] events, and then calls the previous handler.
  /// - Logs [ui.PlatformDispatcher.onError] events, then returns the previous
  ///   handler result (or `false` if none was set).
  static ShadowFlutterErrorHandler installFlutterErrorHandler({
    String flutterTag = 'FlutterError',
    String platformTag = 'PlatformDispatcher',
    bool callOriginalHandlers = true,
    bool handlePlatformDispatcherErrors = true,
  }) {
    final previousFlutterOnError = FlutterError.onError;
    final previousPlatformOnError = ui.PlatformDispatcher.instance.onError;

    FlutterError.onError = (details) {
      final context = details.context;
      ShadowLog.e(
        details.exceptionAsString(),
        tag: flutterTag,
        error: details.exception,
        stackTrace: details.stack,
        fields: <String, Object?>{
          'library': details.library,
          if (context != null) 'context': context.toDescription(),
        },
      );

      if (callOriginalHandlers && previousFlutterOnError != null) {
        previousFlutterOnError(details);
      }
    };

    if (handlePlatformDispatcherErrors) {
      ui.PlatformDispatcher.instance.onError = (error, stackTrace) {
        ShadowLog.e(
          'Uncaught platform error',
          tag: platformTag,
          error: error,
          stackTrace: stackTrace,
        );

        if (callOriginalHandlers && previousPlatformOnError != null) {
          return previousPlatformOnError(error, stackTrace);
        }

        return false;
      };
    }

    return ShadowFlutterErrorHandler._(
      previousFlutterOnError: previousFlutterOnError,
      previousPlatformOnError: previousPlatformOnError,
    );
  }

  /// Runs [body] in a guarded zone and logs uncaught errors.
  static R? runZonedGuarded<R>(
    R Function() body, {
    String tag = 'Zone',
    Object? message = 'Uncaught zone error',
    async.ZoneSpecification? zoneSpecification,
    Map<Object?, Object?>? zoneValues,
  }) {
    return async.runZonedGuarded(
      body,
      (error, stackTrace) {
        ShadowLog.e(
          message,
          tag: tag,
          error: error,
          stackTrace: stackTrace,
        );
      },
      zoneSpecification: zoneSpecification,
      zoneValues: zoneValues,
    );
  }

  static void v(
    Object? message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? fields,
  }) {
    _log(
      ShadowLogLevel.verbose,
      message,
      tag,
      error,
      stackTrace,
      fields,
    );
  }

  static void d(
    Object? message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? fields,
  }) {
    _log(
      ShadowLogLevel.debug,
      message,
      tag,
      error,
      stackTrace,
      fields,
    );
  }

  static void i(
    Object? message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? fields,
  }) {
    _log(
      ShadowLogLevel.info,
      message,
      tag,
      error,
      stackTrace,
      fields,
    );
  }

  static void w(
    Object? message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? fields,
  }) {
    _log(
      ShadowLogLevel.warning,
      message,
      tag,
      error,
      stackTrace,
      fields,
    );
  }

  static void e(
    Object? message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? fields,
  }) {
    _log(
      ShadowLogLevel.error,
      message,
      tag,
      error,
      stackTrace,
      fields,
    );
  }

  static void wtf(
    Object? message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? fields,
  }) {
    _log(
      ShadowLogLevel.wtf,
      message,
      tag,
      error,
      stackTrace,
      fields,
    );
  }

  /// Generic log entry point (useful for custom levels or dynamic logic).
  static void log(
    ShadowLogLevel level,
    Object? message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? fields,
  }) {
    _log(level, message, tag, error, stackTrace, fields);
  }

  static void _logFromLogger(
    ShadowLogLevel level,
    Object? message, {
    required String tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? fields,
  }) {
    _log(level, message, tag, error, stackTrace, fields);
  }

  static void _log(
    ShadowLogLevel level,
    Object? message,
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? fields,
  ) {
    final config = _config;

    if (!config.enabled) {
      return;
    }

    if (kReleaseMode && !config.enabledInRelease) {
      return;
    }

    if (level < config.minLevel) {
      return;
    }

    final record = ShadowLogRecord(
      sequenceNumber: ++_sequence,
      time: DateTime.now(),
      level: level,
      loggerName: _resolveTag(tag),
      message: message,
      error: error,
      stackTrace: stackTrace,
      fields: fields,
    );

    final filter = config.filter;
    if (filter != null && !filter(record)) {
      return;
    }

    _emitRecord(record, config);

    final formatted = config.formatter.format(record);
    for (final output in config.outputs) {
      try {
        output.write(record, formatted);
      } catch (_) {
        // Logging should never crash the app.
      }
    }
  }

  static void _emitRecord(ShadowLogRecord record, ShadowLogConfig config) {
    if (!_recordsController.isClosed) {
      try {
        _recordsController.add(record);
      } catch (_) {
        // Ignore stream errors (e.g. during test shutdown).
      }
    }

    for (final observer in config.observers) {
      try {
        observer.onLog(record);
      } catch (_) {
        // Observers should not crash the app.
      }
    }
  }

  static String _resolveTag(String? tag) {
    final trimmed = tag?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      return trimmed;
    }
    return _config.name;
  }
}

class ShadowFlutterErrorHandler {
  ShadowFlutterErrorHandler._({
    required FlutterExceptionHandler? previousFlutterOnError,
    required ui.ErrorCallback? previousPlatformOnError,
  })  : _previousFlutterOnError = previousFlutterOnError,
        _previousPlatformOnError = previousPlatformOnError;

  final FlutterExceptionHandler? _previousFlutterOnError;
  final ui.ErrorCallback? _previousPlatformOnError;

  void uninstall({bool restorePlatformDispatcherHandler = true}) {
    FlutterError.onError = _previousFlutterOnError;

    if (restorePlatformDispatcherHandler) {
      ui.PlatformDispatcher.instance.onError = _previousPlatformOnError;
    }
  }
}

/// Convenience top-level function for debug-level logs.
void slog(
  Object? message, {
  String? tag,
  Object? error,
  StackTrace? stackTrace,
  Map<String, Object?>? fields,
}) {
  ShadowLog.d(
    message,
    tag: tag,
    error: error,
    stackTrace: stackTrace,
    fields: fields,
  );
}
