import 'dart:collection';

import 'package:flutter/foundation.dart';

import 'config.dart';
import 'record.dart';

/// Keeps a bounded in-memory list of recent [ShadowLogRecord]s.
///
/// Can be attached via [ShadowLogConfig.observers] to collect logs, similar to
/// Talker's in-memory history.
class ShadowLogHistory extends ChangeNotifier implements ShadowLogObserver {
  ShadowLogHistory({int capacity = 200}) : _capacity = capacity;

  final int _capacity;
  final ListQueue<ShadowLogRecord> _records = ListQueue<ShadowLogRecord>();

  int get capacity => _capacity;

  /// Oldest-to-newest.
  List<ShadowLogRecord> get records => List<ShadowLogRecord>.unmodifiable(
        _records.toList(growable: false),
      );

  /// Newest-to-oldest.
  List<ShadowLogRecord> get recordsReversed => List<ShadowLogRecord>.unmodifiable(
        _records.toList(growable: false).reversed,
      );

  @override
  void onLog(ShadowLogRecord record) {
    _records.addLast(record);

    final cap = _capacity;
    if (cap > 0) {
      while (_records.length > cap) {
        _records.removeFirst();
      }
    }

    notifyListeners();
  }

  void clear() {
    if (_records.isEmpty) {
      return;
    }
    _records.clear();
    notifyListeners();
  }
}

