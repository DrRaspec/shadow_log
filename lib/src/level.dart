/// Log level values aligned with common Android priorities.
///
/// Lower values are more verbose.
class ShadowLogLevel implements Comparable<ShadowLogLevel> {
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

  /// All available levels.
  static const List<ShadowLogLevel> values = <ShadowLogLevel>[
    verbose,
    debug,
    info,
    warning,
    error,
    wtf,
  ];

  /// The numeric value sent to the logging backend.
  final int value;

  /// A short label for the level.
  final String label;

  @override
  int compareTo(ShadowLogLevel other) => value.compareTo(other.value);

  bool operator <(ShadowLogLevel other) => value < other.value;
  bool operator <=(ShadowLogLevel other) => value <= other.value;
  bool operator >(ShadowLogLevel other) => value > other.value;
  bool operator >=(ShadowLogLevel other) => value >= other.value;

  @override
  String toString() => label;
}
