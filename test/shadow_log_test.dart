import 'package:flutter_test/flutter_test.dart';

import 'package:shadow_log/shadow_log.dart';

void main() {
  test('allows logging configuration updates', () {
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
}
