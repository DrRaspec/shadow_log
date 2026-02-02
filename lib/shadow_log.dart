library shadow_log;

import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Log level values aligned with common Android priorities.
///
/// Lower values are more verbose.
class ShadowLogLevel {
  const ShadowLogLevel._(this.value, this.label);

  /// Very detailed logs.
  static const verbose = ShadowLogLevel._(300, 'VERBOSE');

  /// Debug-level logs.
  static const debug = ShadowLogLevel._(500, 'DEBUG');

  /// Informational logs.
  static const info = ShadowLogLevel._(800, 'INFO');

  /// Warning logs.
  static const warning = ShadowLogLevel._(900, 'WARN');

  /// Error logs.
  static const error = ShadowLogLevel._(1000, 'ERROR');

  /// Critical logs.
  static const wtf = ShadowLogLevel._(1200, 'WTF');

  /// The numeric value sent to the logging backend.
  final int value;

  /// A short label for the level.
  final String label;
}

/// Configuration for [ShadowLog].
class ShadowLogConfig {
  /// Whether logging is enabled at all.
  final bool enabled;

  /// Whether logging is allowed in release mode.
  final bool enabledInRelease;

  /// Minimum level that will be emitted.
  final ShadowLogLevel minLevel;

  /// Default tag/name used when no tag is provided.
  final String name;

  const ShadowLogConfig({
    this.enabled = true,
    this.enabledInRelease = true,
    this.minLevel = ShadowLogLevel.debug,
    this.name = 'ShadowLog',
  });
}

/// ShadowLog writes to the platform logging system via `dart:developer`.
///
/// In Android, this appears in Logcat (ADB) for both debug and release builds
/// when [ShadowLogConfig.enabledInRelease] is true.
class ShadowLog {
  static ShadowLogConfig _config = const ShadowLogConfig();

  /// Replace the global configuration.
  static void configure(ShadowLogConfig config) {
    _config = config;
  }

  /// Shorthand access to the current configuration.
  static ShadowLogConfig get config => _config;

  static void v(
    Object? message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(ShadowLogLevel.verbose, message, tag, error, stackTrace);
  }

  static void d(
    Object? message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(ShadowLogLevel.debug, message, tag, error, stackTrace);
  }

  static void i(
    Object? message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(ShadowLogLevel.info, message, tag, error, stackTrace);
  }

  static void w(
    Object? message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(ShadowLogLevel.warning, message, tag, error, stackTrace);
  }

  static void e(
    Object? message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(ShadowLogLevel.error, message, tag, error, stackTrace);
  }

  static void wtf(
    Object? message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(ShadowLogLevel.wtf, message, tag, error, stackTrace);
  }

  static void _log(
    ShadowLogLevel level,
    Object? message,
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  ) {
    if (!_config.enabled) {
      return;
    }

    if (kReleaseMode && !_config.enabledInRelease) {
      return;
    }

    if (level.value < _config.minLevel.value) {
      return;
    }

    final tagName = tag?.trim().isNotEmpty == true ? tag!.trim() : _config.name;
    final payload = message?.toString() ?? 'null';

    developer.log(
      payload,
      name: tagName,
      level: level.value,
      error: error,
      stackTrace: stackTrace,
    );
  }
}

/// Convenience top-level function for debug-level logs.
void slog(
  Object? message, {
  String? tag,
  Object? error,
  StackTrace? stackTrace,
}) {
  ShadowLog.d(message, tag: tag, error: error, stackTrace: stackTrace);
}
