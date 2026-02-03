import 'package:flutter_test/flutter_test.dart';

import 'package:shadow_log/shadow_log.dart';

void main() {
  test('allows logging configuration updates', () {
    ShadowLog.reset();
    ShadowLog.configure(
      const ShadowLogConfig(
        enabled: true,
        enabledInRelease: true,
        minLevel: ShadowLogLevel.info,
        name: 'TestLog',
      ),
    );

    final config = ShadowLog.config;
    expect(config.enabled, isTrue);
    expect(config.enabledInRelease, isTrue);
    expect(config.minLevel, ShadowLogLevel.info);
    expect(config.name, 'TestLog');
  });

  test('writes accepted logs to outputs', () {
    ShadowLog.reset();

    final output = ShadowMemoryOutput();
    ShadowLog.configure(
      ShadowLogConfig(
        outputs: <ShadowLogOutput>[output],
        minLevel: ShadowLogLevel.debug,
      ),
    );

    ShadowLog.d('debug');
    ShadowLog.i('info');

    expect(output.records, hasLength(2));
    expect(output.records.first.messageText, 'debug');
    expect(output.records.last.level, ShadowLogLevel.info);
  });

  test('respects minLevel filtering', () {
    ShadowLog.reset();

    final output = ShadowMemoryOutput();
    ShadowLog.configure(
      ShadowLogConfig(
        outputs: <ShadowLogOutput>[output],
        minLevel: ShadowLogLevel.warning,
      ),
    );

    ShadowLog.i('nope');
    ShadowLog.w('yep');

    expect(output.records, hasLength(1));
    expect(output.records.single.level, ShadowLogLevel.warning);
  });

  test('supports custom record filter', () {
    ShadowLog.reset();

    final output = ShadowMemoryOutput();
    ShadowLog.configure(
      ShadowLogConfig(
        outputs: <ShadowLogOutput>[output],
        filter: (record) => record.loggerName != 'Noisy',
      ),
    );

    ShadowLog.d('a', tag: 'Noisy');
    ShadowLog.d('b', tag: 'Ok');

    expect(output.records, hasLength(1));
    expect(output.records.single.loggerName, 'Ok');
  });

  test('ShadowLogger uses tag and supports child()', () {
    ShadowLog.reset();

    final output = ShadowMemoryOutput();
    ShadowLog.configure(
      ShadowLogConfig(
        outputs: <ShadowLogOutput>[output],
      ),
    );

    final log = ShadowLog.logger('Api').child('User');
    log.d('hello');

    expect(output.records, hasLength(1));
    expect(output.records.single.loggerName, 'Api.User');
  });

  test('emits records on onRecord stream', () async {
    ShadowLog.reset();

    final output = ShadowMemoryOutput();
    ShadowLog.configure(
      ShadowLogConfig(
        outputs: <ShadowLogOutput>[output],
      ),
    );

    final future = expectLater(
      ShadowLog.onRecord,
      emits(
        isA<ShadowLogRecord>()
            .having((r) => r.messageText, 'messageText', 'streamed'),
      ),
    );

    ShadowLog.d('streamed');
    await future;
  });

  test('ShadowLogHistory keeps bounded history', () {
    ShadowLog.reset();

    final output = ShadowMemoryOutput();
    final history = ShadowLogHistory(capacity: 2);
    ShadowLog.configure(
      ShadowLogConfig(
        outputs: <ShadowLogOutput>[output],
        observers: <ShadowLogObserver>[history],
      ),
    );

    ShadowLog.d('1');
    ShadowLog.d('2');
    ShadowLog.d('3');

    expect(history.records, hasLength(2));
    expect(history.records.first.messageText, '2');
    expect(history.records.last.messageText, '3');
  });
}
