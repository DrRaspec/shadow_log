import 'formatter.dart';
import 'level.dart';
import 'output.dart';
import 'record.dart';

typedef ShadowLogFilter = bool Function(ShadowLogRecord record);

/// Receives [ShadowLogRecord] events (Talker-style observers).
abstract interface class ShadowLogObserver {
  const ShadowLogObserver();

  void onLog(ShadowLogRecord record);
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

  /// Formats log records into a string.
  final ShadowLogFormatter formatter;

  /// Where logs are written (Logcat, console, memory, etc).
  final List<ShadowLogOutput> outputs;

  /// Optional additional filter (called after [minLevel] checks).
  final ShadowLogFilter? filter;

  /// Optional observers that receive accepted records.
  final List<ShadowLogObserver> observers;

  const ShadowLogConfig({
    this.enabled = true,
    this.enabledInRelease = true,
    this.minLevel = ShadowLogLevel.debug,
    this.name = 'ShadowLog',
    this.formatter = const ShadowMessageOnlyFormatter(),
    this.outputs = const <ShadowLogOutput>[ShadowDeveloperLogOutput()],
    this.filter,
    this.observers = const <ShadowLogObserver>[],
  });

  ShadowLogConfig copyWith({
    bool? enabled,
    bool? enabledInRelease,
    ShadowLogLevel? minLevel,
    String? name,
    ShadowLogFormatter? formatter,
    List<ShadowLogOutput>? outputs,
    Object? filter = _shadowUnset,
    List<ShadowLogObserver>? observers,
  }) {
    return ShadowLogConfig(
      enabled: enabled ?? this.enabled,
      enabledInRelease: enabledInRelease ?? this.enabledInRelease,
      minLevel: minLevel ?? this.minLevel,
      name: name ?? this.name,
      formatter: formatter ?? this.formatter,
      outputs: outputs ?? this.outputs,
      filter: identical(filter, _shadowUnset) ? this.filter : filter as ShadowLogFilter?,
      observers: observers ?? this.observers,
    );
  }
}

class _ShadowUnset {
  const _ShadowUnset();
}

const _shadowUnset = _ShadowUnset();
