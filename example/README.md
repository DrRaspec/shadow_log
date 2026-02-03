# ShadowLog Example

This example demonstrates how to use the `shadow_log` package to log messages at different levels in a Flutter app.

## Features Demonstrated

- Configuring `ShadowLog` with multiple outputs (Logcat + `debugPrint`)
- Using a named logger: `ShadowLog.logger('Example')`
- Logging at all available levels: `v/d/i/w/e/wtf`
- Logging structured `fields`
- Keeping an in-memory log history (`ShadowLogHistory`) and showing it in-app
- Installing Flutter error hooks (`ShadowLog.installFlutterErrorHandler`)

## Running the Example

### Prerequisites
- Flutter SDK installed
- A connected device or emulator

### Steps

1. Navigate to the example directory:
   ```bash
   cd example
   ```

2. Get dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Viewing Logs

### Android
View logs in Logcat while running the app:
```bash
adb logcat | grep "ShadowLogExample"
```

### All Platforms
Logs will appear in the Flutter console output during development.

## Code Overview

The example app features:
- Initial configuration of `ShadowLog` in `main()`
- Buttons for each log level
- Sample error logging with exceptions and structured fields
- A simple in-app log viewer powered by `ShadowLogHistory`
- Instructions for viewing logs
