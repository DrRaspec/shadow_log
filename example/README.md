# ShadowLog Example

This example demonstrates how to use the `shadow_log` package to log messages at different levels in a Flutter app.

## Features Demonstrated

- Configuring `ShadowLog` with custom settings
- Logging at all available levels: `v()` (verbose), `d()` (debug), `i()` (info), `w()` (warning), `e()` (error), `wtf()` (critical)
- Using custom tags for log messages
- Logging exceptions and stack traces

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
- Sample error logging with exceptions
- Instructions for viewing logs
