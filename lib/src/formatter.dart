import 'record.dart';

/// Formats [ShadowLogRecord] into a single message string.
///
/// Note: formatters typically do not include [ShadowLogRecord.error] or
/// [ShadowLogRecord.stackTrace]. Outputs decide how to render those.
abstract interface class ShadowLogFormatter {
  const ShadowLogFormatter();

  String format(ShadowLogRecord record);
}

/// Default formatter: message + optional structured fields.
class ShadowMessageOnlyFormatter implements ShadowLogFormatter {
  const ShadowMessageOnlyFormatter();

  @override
  String format(ShadowLogRecord record) {
    final fields = record.fields;
    if (fields == null || fields.isEmpty) {
      return record.messageText;
    }

    return '${record.messageText} ${_formatFields(fields)}';
  }
}

/// Human-friendly formatter inspired by common "pretty" loggers.
class ShadowPrettyFormatter implements ShadowLogFormatter {
  const ShadowPrettyFormatter({
    this.includeTimestamp = true,
    this.includeLevel = true,
    this.includeLoggerName = true,
    this.includeFields = true,
  });

  final bool includeTimestamp;
  final bool includeLevel;
  final bool includeLoggerName;
  final bool includeFields;

  @override
  String format(ShadowLogRecord record) {
    final parts = <String>[];

    if (includeTimestamp) {
      parts.add(record.time.toIso8601String());
    }
    if (includeLevel) {
      parts.add('[$record.level.label]');
    }
    if (includeLoggerName) {
      parts.add('($record.loggerName)');
    }

    parts.add(record.messageText);

    final fields = record.fields;
    if (includeFields && fields != null && fields.isNotEmpty) {
      parts.add(_formatFields(fields));
    }

    return parts.join(' ');
  }
}

String _formatFields(Map<String, Object?> fields) {
  final items = fields.entries
      .map((e) => '${e.key}=${e.value}')
      .join(', ');
  return '{${items}}';
}
