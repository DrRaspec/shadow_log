import 'package:flutter/material.dart';
import 'package:shadow_log/shadow_log.dart';

void main() {
  // Configure ShadowLog
  ShadowLog.configure(
    ShadowLogConfig(
      enabled: true,
      enabledInRelease: true,
      minLevel: ShadowLogLevel.debug,
      name: 'ShadowLogExample',
    ),
  );

  runApp(const ShadowLogExampleApp());
}

class ShadowLogExampleApp extends StatelessWidget {
  const ShadowLogExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShadowLog Example',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const ShadowLogExamplePage(),
    );
  }
}

class ShadowLogExamplePage extends StatefulWidget {
  const ShadowLogExamplePage({Key? key}) : super(key: key);

  @override
  State<ShadowLogExamplePage> createState() => _ShadowLogExamplePageState();
}

class _ShadowLogExamplePageState extends State<ShadowLogExamplePage> {
  @override
  void initState() {
    super.initState();
    // Log initialization
    ShadowLog.d('App initialized');
  }

  void _logVerbose() {
    ShadowLog.v('This is a verbose message', tag: 'Example');
  }

  void _logDebug() {
    ShadowLog.d('This is a debug message', tag: 'Example');
  }

  void _logInfo() {
    ShadowLog.i('This is an info message', tag: 'Example');
  }

  void _logWarning() {
    ShadowLog.w('This is a warning message', tag: 'Example');
  }

  void _logError() {
    ShadowLog.e(
      'This is an error message',
      tag: 'Example',
      error: Exception('Sample exception'),
    );
  }

  void _logWTF() {
    ShadowLog.wtf(
      'Something went really wrong!',
      tag: 'Example',
      error: Exception('Critical error'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ShadowLog Example'), elevation: 0),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Tap buttons to log at different levels.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _logVerbose,
                child: const Text('Log Verbose'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _logDebug,
                child: const Text('Log Debug'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _logInfo,
                child: const Text('Log Info'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _logWarning,
                child: const Text('Log Warning'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _logError,
                child: const Text('Log Error'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _logWTF, child: const Text('Log WTF')),
              const SizedBox(height: 32),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'View logs in:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text('• Android: adb logcat | grep "ShadowLogExample"'),
                      SizedBox(height: 8),
                      Text('• Check app console output for debug builds'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
