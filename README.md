# shadow_log

ShadowLog is a small Flutter logging package designed to replace `print` / `debugPrint` while keeping logs visible in **Android Logcat (ADB)** in **release builds**.

It’s inspired by the ergonomics of packages like `logger`, `logging`, and `talker`, but stays lightweight and Logcat-friendly by default.

## Features

- Logcat-friendly default output (`dart:developer.log`)
- Familiar API: `ShadowLog.d/i/w/e/wtf` + `ShadowLog.logger('Tag')`
- Multiple outputs (Logcat + `debugPrint` + custom)
- Formatters (default is message-only, optional pretty formatter)
- `onRecord` stream + Talker-style observers
- Optional in-memory history (`ShadowLogHistory`)
- Optional Flutter error hooks (`ShadowLog.installFlutterErrorHandler`)
- Optional guarded-zone helper (`ShadowLog.runZonedGuarded`)

## Quick start

```dart
import 'package:shadow_log/shadow_log.dart';

void main() {
  ShadowLog.configure(
    ShadowLogConfig(
      name: 'MyApp',
      minLevel: ShadowLogLevel.debug,
      formatter: const ShadowPrettyFormatter(),
      outputs: const <ShadowLogOutput>[
        ShadowDeveloperLogOutput(), // Android Logcat-friendly
        ShadowDebugPrintOutput(), // Flutter console
      ],
    ),
  );

  // Optional: capture Flutter framework + platform errors.
  ShadowLog.installFlutterErrorHandler();

  ShadowLog.d('Hello debug');
  ShadowLog.e('Something failed', error: Exception('Boom'));
}
```

## Named loggers (tags)

```dart
final log = ShadowLog.logger('Auth');

log.i('Signed in', fields: {'userId': 123});
log.w('Token expired');
```

You can create child loggers too:

```dart
final apiLog = ShadowLog.logger('Api').child('User');
apiLog.d('GET /me');
```

## Structured fields

All log methods support `fields`:

```dart
ShadowLog.i('Fetched profile', fields: {'userId': 123, 'cached': true});
```

The default formatter prints `message {k=v, ...}` only when `fields` are provided.

## Listen to logs (`onRecord`)

```dart
ShadowLog.onRecord.listen((record) {
  // Send to analytics, save to file, show in UI, etc.
  // record.level / record.loggerName / record.time / record.messageText ...
});
```

## In-memory history (Talker-like)

```dart
final history = ShadowLog.attachHistory(capacity: 200);

// `history` is a ChangeNotifier; you can rebuild widgets when it changes.
// history.recordsReversed -> newest first
```

If you prefer explicit config:

```dart
final history = ShadowLogHistory(capacity: 200);
ShadowLog.configure(
  ShadowLog.config.copyWith(observers: <ShadowLogObserver>[history]),
);
```

## Custom outputs

You can create your own output:

```dart
ShadowLog.addOutput(
  ShadowCallbackOutput((record, message) {
    // Do something with `record` and the formatted `message`
  }),
);
```

For tests, use `ShadowMemoryOutput`.

## Release behavior

ShadowLog logs in release builds by default. To disable logs in release:

```dart
ShadowLog.configure(
  ShadowLog.config.copyWith(enabledInRelease: false),
);
```

## Filtering in Logcat

Logs use the logger/tag name as the Logcat tag. Example:

```sh
adb logcat | grep "MyApp"
```

## Alternatives

If you need even more features, consider:

- `logger` (pretty printers, filters, outputs)
- `logging` (hierarchical loggers + standard record model)
- `talker` (structured logs + observers + UI helpers)
