<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

ShadowLog is a tiny Flutter logging package designed to replace `print` and
`debugPrint` while ensuring logs still appear in Android Logcat (ADB) in
release mode. It uses `dart:developer` under the hood so you can keep a
consistent logging API in all build modes.

## Features

* Log to Android Logcat (ADB) in debug and release.
* Simple drop-in API: `ShadowLog.d`, `ShadowLog.i`, `ShadowLog.w`, `ShadowLog.e`.
* Configurable minimum level, default tag, and release-mode behavior.

## Getting started

Add the package to your project and import it where you log messages.

## Usage

```dart
import 'package:shadow_log/shadow_log.dart';

void main() {
	ShadowLog.configure(
		const ShadowLogConfig(
			enabled: true,
			enabledInRelease: true,
			minLevel: ShadowLogLevel.debug,
			name: 'MyApp',
		),
	);

	ShadowLog.d('Debug message');
	ShadowLog.i('Info message');
	ShadowLog.w('Warning message');
	ShadowLog.e('Error message', error: Exception('Boom'));
}
```

You can also use the top-level helper `slog()` if you want a quick debug log:

```dart
slog('Quick debug log');
```

### Release behavior

`ShadowLog` keeps logging in release builds by default. If you want to disable
logs in release, set `enabledInRelease: false` in `ShadowLogConfig`.

### Filtering in Logcat

All logs are sent with a tag. By default it is `ShadowLog`, or you can pass a
custom `tag` parameter for each call.

### Related packages (alternatives)

If you want more features, these popular packages may also fit your needs:

* `logger` – rich formatting and pretty printers.
* `logging` – Dart’s standard logging package with hierarchical loggers.
* `talker` – structured logs, error capture, and UI helpers.

ShadowLog is intentionally minimal and optimized for Logcat in release.

## Additional information

Contributions and issues are welcome. Please include a short repro and the
expected Logcat output when filing bugs.
