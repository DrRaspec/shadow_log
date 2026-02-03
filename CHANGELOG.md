## 0.2.0

* Add `ShadowLogger` (named loggers + `child()`).
* Add `ShadowLog.onRecord` stream + observer support.
* Add formatters (`ShadowMessageOnlyFormatter`, `ShadowPrettyFormatter`).
* Add outputs (`ShadowDeveloperLogOutput`, `ShadowDebugPrintOutput`, `ShadowCallbackOutput`, `ShadowMemoryOutput`).
* Add `ShadowLogHistory` (bounded in-memory history).
* Add Flutter error hooks (`ShadowLog.installFlutterErrorHandler`) and `ShadowLog.runZonedGuarded`.
* Update README + example app.

## 0.1.2

* Fix: update package version.

## 0.1.1

* Fix: minor improvements and documentation updates.

## 0.1.0

* Add ShadowLog API for Logcat-friendly logging in release and debug.
* Provide log levels, configuration, and top-level convenience function.
